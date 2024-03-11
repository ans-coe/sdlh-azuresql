/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_SQLGenerateSchemaVersion
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 5 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_SYSTEM (STR): Source System name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_SYSTEM
   - @PARAM_DATABASE_NAME (STR): Database name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().DATABASE_NAME
   - @PARAM_SCHEMA_NAME (STR): Schema name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SCHEMA_NAME
   - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME
   - @CHECK_INFORMATION_SCHEMA (STR): Data retrived from a lookup to get the current INFORMATION_SCHEMA. Pipeline dynamic expression: @activity('lookup_current_columns').output.firstRow.INFORMATION_SCHEMA

    It incraments the SCHEMA_VERSION in table [ETL].[SQLTableMetadata] when a change in INFORMATION_SCHEMA is found.
    If SCHEMA_VERSION is currently NULL indicating a first run its is set as 0 instead.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2023-12-13  Andrei Dumitru  Added description and inline comments
2024-01-15  Darren Price    Renamed and Uplifted to work with v2.1
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_SQLGenerateSchemaVersion]
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150),
    @PARAM_DATABASE_NAME VARCHAR(150),
    @PARAM_SCHEMA_NAME VARCHAR(150),
    @PARAM_TABLE_NAME VARCHAR(150),
    @PARAM_CHECK_INFORMATION_SCHEMA VARCHAR(MAX)
AS
BEGIN
    UPDATE [ETL].[SQLTableMetadata]
    SET [SCHEMA_VERSION] = CASE WHEN [SCHEMA_VERSION] IS NULL THEN 0 ELSE [SCHEMA_VERSION] +1 END
    WHERE [SCHEMA_VERSION] IS NULL
    OR ( [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
        AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
        AND [DATABASE_NAME] = @PARAM_DATABASE_NAME
        AND [SCHEMA_NAME] = @PARAM_SCHEMA_NAME
        AND [TABLE_NAME] = @PARAM_TABLE_NAME
        AND [INFORMATION_SCHEMA] != @PARAM_CHECK_INFORMATION_SCHEMA
    )
END;