/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_SQLGenerateJsonMetadata
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 2 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Passed in parameter for required source type. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Passed in parameter for required source system. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_SYSTEM

    It INSERTS or UPDATES via MERGE statement into table ETL.JsonMetadata
    Based on data selected and joined from [ETL].[SQLTableMetadata] and [ETL].[SQLColumnMetadata]
    Selects SOURCE_TYPE, SOURCE_SYSTEM, SOURCE_GROUPING_ID, IS_ENABLED, LOAD_TYPE, BATCH_FREQUENCY
    Generates 3 new columns, OBJECT_NAME and 2 new json based columns ( OBJECT_PARAMETERS & ADLS_PATHS ) 
    
    Fields returned:
    - None

================================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2024-01-15  Darren Price    Renamed and Uplifted to work with v2.1
2024-03-08  Darren Price    Add serverless sql columns with v2.1.3
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_SQLGenerateJsonMetadata]
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150)

AS
BEGIN
    SET NOCOUNT ON;

    -- CREATING IN-MEMORY TABLE FOR STORING PARAMETERS ABOUT THE OBJECT
    WITH cte_object_params AS (
        SELECT T.[SOURCE_SYSTEM]
            ,T.[DATABASE_NAME]
            ,T.[SCHEMA_NAME]
            ,T.[TABLE_NAME]
            ,T.[SCHEMA_VERSION]
            ,T.[PRIMARY_KEYS]
            ,T.[COLUMNS_META]
            ,T.[COLUMNS_META_CHANGE_TRACKING]
            ,T.[CHANGE_TRACKING_JOIN_CONDITION]
            ,(SELECT C.COLUMN_NAME AS [COLUMN_NAME]
                ,C.IS_NULLABLE AS [IS_NULLABLE]
                ,C.DATA_TYPE AS [DATA_TYPE]
                ,C.CHARACTER_MAXIMUM_LENGTH AS [CHARACTER_MAXIMUM_LENGTH]
                ,C.COLLATION_NAME AS [COLLATION_NAME]
            FROM [ETL].[SQLColumnMetadata] C
            WHERE C.SOURCE_SYSTEM = T.[SOURCE_SYSTEM]
            AND C.[DATABASE_NAME] = T.[DATABASE_NAME]
            AND ISNULL(C.[SCHEMA_NAME],'NA') = ISNULL(T.[SCHEMA_NAME],'NA')
            AND C.[TABLE_NAME] = T.[TABLE_NAME]
            AND C.[IS_ENABLED] = 1
            FOR JSON PATH) AS [INFORMATION_SCHEMA]
        FROM [ETL].[SQLTableMetadata] T
        WHERE T.SOURCE_TYPE = @PARAM_SOURCE_TYPE
        AND T.SOURCE_SYSTEM = @PARAM_SOURCE_SYSTEM
    ),

    cte_adls_paths AS (
        SELECT [SOURCE_SYSTEM]
            ,[DATABASE_NAME]
            ,[SCHEMA_NAME]
            ,[TABLE_NAME]
            ,(SELECT DISTINCT 'raw' AS FP0
                ,CASE
                    WHEN UPPER(SOURCE_TYPE) = 'MYSQL' THEN CONCAT(REPLACE(REPLACE(REPLACE(SOURCE_SYSTEM,'.','_'), '-','_'),'\', '_'),'/',DATABASE_NAME,'/',TABLE_NAME,'/',SCHEMA_VERSION,'/')
                    WHEN UPPER(SOURCE_TYPE) = 'MY_SQL' THEN CONCAT(REPLACE(REPLACE(REPLACE(SOURCE_SYSTEM,'.','_'), '-','_'),'\', '_'),'/',DATABASE_NAME,'/',TABLE_NAME,'/',SCHEMA_VERSION,'/')
                ELSE CONCAT(REPLACE(REPLACE(REPLACE(SOURCE_SYSTEM,'.','_'), '-','_'),'\', '_'),'/',DATABASE_NAME,'/',SCHEMA_NAME,'/',TABLE_NAME,'/',SCHEMA_VERSION,'/')
                END AS FP1
            FOR JSON PATH) AS [raw]
            ,(SELECT 'enriched' AS FP0
                ,CONCAT(SERVERLESS_SQL_POOL_DATABASE,'/',SERVERLESS_SQL_POOL_SCHEMA ,'/',TABLE_NAME, '/' ) AS FP1
            FOR JSON PATH) as [staged]
        FROM [ETL].[SQLTableMetadata]
        WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
        AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    )

    MERGE [ETL].[JsonMetadata] AS target
    USING (
    SELECT @PARAM_SOURCE_TYPE AS [SOURCE_TYPE]
        ,[SOURCE_SYSTEM]
        ,[SOURCE_GROUPING_ID]
        ,[IS_ENABLED]
        ,[LOAD_TYPE]
        ,[BATCH_FREQUENCY]
        ,[SERVERLESS_SQL_POOL_DATABASE]
        ,[SERVERLESS_SQL_POOL_SCHEMA]
        ,CASE
            WHEN UPPER(@PARAM_SOURCE_TYPE) = 'MYSQL' THEN CONCAT(REPLACE(REPLACE(REPLACE(T.SOURCE_SYSTEM,'.','_'), '-','_'), '\', '_'), '_',T.DATABASE_NAME,'_',T.TABLE_NAME)
            WHEN UPPER(@PARAM_SOURCE_TYPE) = 'MY_SQL' THEN CONCAT(REPLACE(REPLACE(REPLACE(T.SOURCE_SYSTEM,'.','_'), '-','_'), '\', '_'), '_',T.DATABASE_NAME,'_',T.TABLE_NAME)
            ELSE CONCAT(REPLACE(REPLACE(REPLACE(T.SOURCE_SYSTEM,'.','_'), '-','_'), '\', '_'), '_',T.DATABASE_NAME,'_',T.SCHEMA_NAME, '_',T.TABLE_NAME)
        END AS [OBJECT_NAME]
        ,(SELECT DISTINCT T.[SOURCE_SYSTEM]
            ,T.[SOURCE_GROUPING_ID]
            ,T.[SOURCE_CONNECTION_STRING]
            ,T.[DATABASE_NAME]
            ,T.[SCHEMA_NAME]
            ,T.[TABLE_NAME]
            ,T.[PRIMARY_KEYS]
            ,T.[SCHEMA_VERSION]
            ,T.[COLUMNS_META]
            ,T.[COLUMNS_META_CHANGE_TRACKING]
            ,T.[CHANGE_TRACKING_JOIN_CONDITION]
            ,T.[SERVERLESS_SQL_POOL_DATABASE]
            ,T.[SERVERLESS_SQL_POOL_SCHEMA]
            ,OBP.[INFORMATION_SCHEMA]
        FROM cte_object_params OBP
        WHERE T.SOURCE_SYSTEM = OBP.SOURCE_SYSTEM
        AND T.DATABASE_NAME = OBP.DATABASE_NAME
        AND ISNULL(T.SCHEMA_NAME,'NA') = ISNULL(OBP.SCHEMA_NAME,'NA')
        AND T.TABLE_NAME = OBP.TABLE_NAME
        FOR JSON PATH ) AS OBJECT_PARAMETERS
        ,(SELECT [raw], [staged]
        FROM cte_adls_paths ADLS
        WHERE T.SOURCE_SYSTEM = ADLS.SOURCE_SYSTEM
        AND T.DATABASE_NAME = ADLS.DATABASE_NAME
        AND ISNULL(T.SCHEMA_NAME,'NA') = ISNULL(ADLS.SCHEMA_NAME,'NA')
        AND T.TABLE_NAME = ADLS.TABLE_NAME
        FOR JSON PATH) AS ADLS_PATHS
    FROM [ETL].[SQLTableMetadata] T) AS source
        ON (target.OBJECT_NAME = source.OBJECT_NAME)
    WHEN MATCHED
    AND source.SOURCE_SYSTEM = @PARAM_SOURCE_SYSTEM
        THEN
            UPDATE SET 
                target.SOURCE_TYPE = source.SOURCE_TYPE,
                target.SOURCE_SYSTEM = source.SOURCE_SYSTEM,
                target.SOURCE_GROUPING_ID = source.SOURCE_GROUPING_ID,
                target.IS_ENABLED = source.IS_ENABLED,
                target.LOAD_TYPE = source.LOAD_TYPE,
                target.BATCH_FREQUENCY = source.BATCH_FREQUENCY,
                target.SERVERLESS_SQL_POOL_DATABASE = source.SERVERLESS_SQL_POOL_DATABASE,
                target.SERVERLESS_SQL_POOL_SCHEMA = source.SERVERLESS_SQL_POOL_SCHEMA,
                target.OBJECT_PARAMETERS = source.OBJECT_PARAMETERS,
                target.ADLS_PATHS = source.ADLS_PATHS
    WHEN NOT MATCHED
    AND source.SOURCE_SYSTEM = @PARAM_SOURCE_SYSTEM
        THEN
            INSERT (SOURCE_TYPE, SOURCE_SYSTEM, SOURCE_GROUPING_ID, IS_ENABLED, LOAD_TYPE, BATCH_FREQUENCY, SERVERLESS_SQL_POOL_DATABASE, SERVERLESS_SQL_POOL_SCHEMA, OBJECT_NAME, OBJECT_PARAMETERS, ADLS_PATHS)
            VALUES (source.SOURCE_TYPE, source.SOURCE_SYSTEM, source.SOURCE_GROUPING_ID, source.IS_ENABLED, source.LOAD_TYPE, source.BATCH_FREQUENCY, source.SERVERLESS_SQL_POOL_DATABASE, source.SERVERLESS_SQL_POOL_SCHEMA, source.OBJECT_NAME, source.OBJECT_PARAMETERS, source.ADLS_PATHS);
END;