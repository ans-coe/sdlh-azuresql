/*
===============================================================
Author: Andrei Dumitru
Created: 2024-05-01
Name: usp_PGSQLUpdateColumnMetadata
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 5 parameters extracted from Synapse using pipeline dynamic expressions:

    - @PARAM_SOURCE_TYPE (STR): Passed in parameter for required source type. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_TYPE
    - @PARAM_SOURCE_SYSTEM (STR): Passed in parameter for required source system. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_SYSTEM
    - @PARAM_DATABASE_NAME (STR): Database name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().DATABASE_NAME
    - @PARAM_SCHEMA_NAME (STR): Schema name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SCHEMA_NAME
    - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME

    Purpose of this stored prcedure is to update severals columns in the [ETL].[SQLColumnMetadata] that have PgSQL data types.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-05-01  Andrei Dumitru  Initial create CTE config
2024-06-13  Tom Legge		Updated mapping based on how data is stored in the S3 parquet files, so that resulting synapse external tables are generated with compatable data types to the parquet data types that the postgres datatypes have been converted into
===============================================================
*/

CREATE PROCEDURE [ETL].[usp_PGSQLMapColumnMetadata]
    @PARAM_SOURCE_TYPE nvarchar(150),
    @PARAM_SOURCE_SYSTEM nvarchar(150),
	@PARAM_DATABASE_NAME nvarchar(150),
	@PARAM_SCHEMA_NAME nvarchar(150),
	@PARAM_TABLE_NAME nvarchar(150)


AS
BEGIN
    SET NOCOUNT ON;

    WITH cte_pgsql_columns_mapping AS (
        SELECT
			[SOURCE_TYPE]
			,[SOURCE_SYSTEM]
			,[DATABASE_NAME]
			,[SCHEMA_NAME]
            ,[TABLE_NAME]
            ,[COLUMN_NAME]
            ,CASE
                WHEN [DATA_TYPE] LIKE '%pg%' THEN 'nvarchar'
				WHEN [DATA_TYPE] LIKE '%char%' THEN 'nvarchar'
                WHEN [DATA_TYPE] = 'date' THEN 'date'
                WHEN [DATA_TYPE] = 'USER-DEFINED' THEN 'nvarchar'
                WHEN [DATA_TYPE] = 'smallint' THEN 'int' -- will use default scale and precision
                WHEN [DATA_TYPE] = 'double precision' THEN 'float' -- will use default scale and precision
                WHEN [DATA_TYPE] = 'boolean' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'bigserial' THEN 'bigint'
				WHEN [DATA_TYPE] = 'cidr' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'circle' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'bytea' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'double precision' THEN 'numeric' -- will use default scale and precision
				WHEN [DATA_TYPE] = 'inet' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'integer' THEN 'int'
				WHEN [DATA_TYPE] like '%json%' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'line' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'lseg' THEN 'nvarchar'
				WHEN [DATA_TYPE] like '%macaddr%' THEN 'nvarchar'
				WHEN [DATA_TYPE] like '%timestamp%' THEN 'bigint' -- will use default scale and precision
				WHEN [DATA_TYPE] like '%time %' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'path' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'point' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'polygon' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'real' THEN 'numeric(1,2)'
				WHEN [DATA_TYPE] = 'smallserial' THEN 'smallint'
				WHEN [DATA_TYPE] = 'serial' THEN 'int'
				WHEN [DATA_TYPE] = 'text' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'tsquery' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'tsvector' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'txid_snapshot' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'uuid' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'xml' THEN 'nvarchar'
				WHEN [DATA_TYPE] = 'tstzrange' THEN 'nvarchar'
                WHEN [DATA_TYPE] = 'ARRAY' THEN 'nvarchar'
				ELSE [DATA_TYPE]
            END AS [DATA_TYPE]
            ,[CHARACTER_MAXIMUM_LENGTH]
        FROM [ETL].[SQLColumnMetadata]
		WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
		AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
		AND [DATABASE_NAME] = @PARAM_DATABASE_NAME
		AND [SCHEMA_NAME] = @PARAM_SCHEMA_NAME
		AND [TABLE_NAME] = @PARAM_TABLE_NAME
    )

	-- Generate column [DATA_TYPE]
    UPDATE [ETL].[SQLColumnMetadata]
    SET [DATA_TYPE] = CTE.[DATA_TYPE]
    FROM [ETL].[SQLColumnMetadata] PG
    INNER JOIN cte_pgsql_columns_mapping AS CTE
        ON PG.[SOURCE_TYPE] = CTE.[SOURCE_TYPE]
		AND PG.[SOURCE_SYSTEM] = CTE.[SOURCE_SYSTEM]
		AND PG.[DATABASE_NAME] = CTE.[DATABASE_NAME]
		AND PG.[SCHEMA_NAME] = CTE.[SCHEMA_NAME]
		AND PG.[TABLE_NAME] = CTE.[TABLE_NAME]
        AND PG.[COLUMN_NAME] = CTE.[COLUMN_NAME]

	-- Update CHARACTER_MAXIMUM_LENGTH to NULL for any data type other than nvarchar AND varchar
    UPDATE [ETL].[SQLColumnMetadata]
    SET [CHARACTER_MAXIMUM_LENGTH] = NULL
	WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
	AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [DATA_TYPE] NOT IN ('varchar','nvarchar')

    UPDATE [ETL].[SQLColumnMetadata]
    SET [CHARACTER_MAXIMUM_LENGTH] = 4000
	WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
	AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [DATA_TYPE] IN ('varchar','nvarchar')
	AND ([CHARACTER_MAXIMUM_LENGTH] = 0 OR [CHARACTER_MAXIMUM_LENGTH] IS NULL)

END
