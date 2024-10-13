/*
===============================================================
Author: Darren Price
Created: 2024-05-25
Name: usp_GenericGenerateJsonMetadata
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 2 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Passed in parameter for required source type. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Passed in parameter for required source system. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_SYSTEM

    It INSERTS or UPDATES via MERGE statement into table ETL.JsonMetadata
    Based on data selected and joined from [ETL].[SalesforceTableMetadata] and [ETL].[SalesforceColumnMetadata]
    Selects SOURCE_TYPE, SOURCE_SYSTEM, SOURCE_GROUPING_ID, IS_ENABLED, LOAD_TYPE, BATCH_FREQUENCY
    Generates 3 new columns, OBJECT_NAME and 2 new json based columns ( OBJECT_PARAMETERS & ADLS_PATHS ) 
    
    Fields returned:
    - None

================================================================
Change History

Date        Name            Description
2024-05-25  Darren Price    Initial create
2024-10-04  Darren Price    Added parameters for datalake container naming
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GenericGenerateJsonMetadata]
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150),
    @PARAM_CONTAINER_NAME_RAW VARCHAR(150) = 'raw',
    @PARAM_CONTAINER_NAME_ENRICHED VARCHAR(150) = 'enriched'

AS
BEGIN
    SET NOCOUNT ON;

-- CREATING IN-MEMORY TABLE FOR STORING PARAMETERS ABOUT THE OBJECT
    WITH cte_object_params AS (
        SELECT T.[SOURCE_TYPE]
            ,T.[SOURCE_SYSTEM]
            ,T.[TABLE_NAME]
            ,0 AS [SCHEMA_VERSION] --SCHEMA_VERSION_FIX
            ,T.[PRIMARY_KEYS]
            ,T.[COLUMNS_META]
            ,T.[COLUMNS_LIST]
            ,(SELECT C.[COLUMN_NAME]
                ,C.[DATA_TYPE]
                ,C.[CHARACTER_MAXIMUM_LENGTH]
            FROM [ETL].[GenericColumnMetadata] C
            WHERE C.[SOURCE_TYPE] = T.[SOURCE_TYPE]
            AND C.[SOURCE_SYSTEM] = T.[SOURCE_SYSTEM]
            AND C.[TABLE_NAME] = T.[TABLE_NAME]
            AND C.[IS_ENABLED] = 1
            FOR JSON PATH) AS [INFORMATION_SCHEMA]
        FROM [ETL].[GenericTableMetadata] T
        WHERE T.[SOURCE_TYPE] = @PARAM_SOURCE_TYPE
        AND T.[SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    ),

    cte_adls_paths AS (
        SELECT [SOURCE_TYPE]
            ,[SOURCE_SYSTEM]
            ,[TABLE_NAME]
            ,(SELECT DISTINCT @PARAM_CONTAINER_NAME_RAW AS [FP0]
            ,CONCAT(SOURCE_SYSTEM,'/',TABLE_NAME,'/','0','/') AS [FP1] --SCHEMA_VERSION_FIX
            FOR JSON PATH) AS [raw]
            ,(SELECT @PARAM_CONTAINER_NAME_ENRICHED AS [FP0]
            ,CONCAT([SERVERLESS_SQL_POOL_DATABASE],'/',[SERVERLESS_SQL_POOL_SCHEMA],'/',[TABLE_NAME],'/' ) AS [FP1]
            FOR JSON PATH) as [staged]
        FROM [ETL].[GenericTableMetadata]
        WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
        AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    )

    MERGE [ETL].[JsonMetadata] AS target
    USING (
    SELECT [SOURCE_TYPE]
        ,[SOURCE_SYSTEM]
        ,[SOURCE_GROUPING_ID]
        ,[IS_ENABLED]
        ,[LOAD_TYPE]
        ,[BATCH_FREQUENCY]
        ,[SERVERLESS_SQL_POOL_DATABASE]
        ,[SERVERLESS_SQL_POOL_SCHEMA]
        ,LOWER(REPLACE(CONCAT(T.[SOURCE_TYPE],'_',T.[SOURCE_SYSTEM],'_',T.[TABLE_NAME]),' ', '')) AS [OBJECT_NAME]
        ,(SELECT DISTINCT T.[SOURCE_TYPE]
            ,T.[SOURCE_SYSTEM]
            ,T.[SOURCE_GROUPING_ID]
            ,T.[TABLE_NAME]
            ,T.[PRIMARY_KEYS]
            ,0 AS [SCHEMA_VERSION] --SCHEMA_VERSION_FIX
            ,T.[COLUMNS_META]
            ,T.[COLUMNS_LIST]
            ,T.[SERVERLESS_SQL_POOL_DATABASE]
            ,T.[SERVERLESS_SQL_POOL_SCHEMA]
            ,OBP.[INFORMATION_SCHEMA]
        FROM cte_object_params OBP
        WHERE T.[SOURCE_TYPE] = OBP.[SOURCE_TYPE]
        AND T.[SOURCE_SYSTEM] = OBP.[SOURCE_SYSTEM]
        AND T.[TABLE_NAME] = OBP.[TABLE_NAME]
        FOR JSON PATH ) AS [OBJECT_PARAMETERS]
        ,(SELECT [raw], [staged]
        FROM cte_adls_paths ADLS
        WHERE T.[SOURCE_TYPE] = ADLS.[SOURCE_TYPE]
        AND T.[SOURCE_SYSTEM] = ADLS.[SOURCE_SYSTEM]
        AND T.[TABLE_NAME] = ADLS.[TABLE_NAME]
        FOR JSON PATH) AS [ADLS_PATHS]
    FROM [ETL].[GenericTableMetadata] T) AS source        
        ON (target.OBJECT_NAME = source.OBJECT_NAME)
    WHEN MATCHED
    AND source.SOURCE_TYPE = @PARAM_SOURCE_TYPE
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
    AND source.SOURCE_TYPE = @PARAM_SOURCE_TYPE
    AND source.SOURCE_SYSTEM = @PARAM_SOURCE_SYSTEM
        THEN
            INSERT (SOURCE_TYPE, SOURCE_SYSTEM, SOURCE_GROUPING_ID, IS_ENABLED, LOAD_TYPE, BATCH_FREQUENCY, SERVERLESS_SQL_POOL_DATABASE, SERVERLESS_SQL_POOL_SCHEMA, OBJECT_NAME, OBJECT_PARAMETERS, ADLS_PATHS)
            VALUES (source.SOURCE_TYPE, source.SOURCE_SYSTEM, source.SOURCE_GROUPING_ID, source.IS_ENABLED, source.LOAD_TYPE, source.BATCH_FREQUENCY, source.SERVERLESS_SQL_POOL_DATABASE, source.SERVERLESS_SQL_POOL_SCHEMA, source.OBJECT_NAME, source.OBJECT_PARAMETERS, source.ADLS_PATHS);
END;