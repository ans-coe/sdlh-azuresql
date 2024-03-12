/*
===============================================================
Author: Darren Price
Created: 2024-02-15
Name: usp_SQLUpdateColumns
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 4 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Source Type name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Source System name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_SYSTEM
   - @PARAM_DATABASE_NAME (STR): Database name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().DATABASE_NAME
   - @PARAM_SCHEMA_NAME (STR): Schema name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SCHEMA_NAME
   - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME
   
    It is required to disable any columns that have been deleted or renamed in the source system.
    It sets the IS_ENABLED column to 0 in table ETL.SQLColumnMetadata, this setting is reset to 1 by the copy activity (sql_etl_columns) if still exists.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-02-22  Darren Price    Initial config
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_SQLUpdateColumns]
    @PARAM_SOURCE_TYPE VARCHAR(250),
    @PARAM_SOURCE_SYSTEM VARCHAR(250),
    @PARAM_DATABASE_NAME VARCHAR(250),
    @PARAM_SCHEMA_NAME VARCHAR(250),
    @PARAM_TABLE_NAME VARCHAR(250)
AS

BEGIN
    UPDATE [ETL].[SQLColumnMetadata]
    SET [IS_ENABLED] = 0
    WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
    AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [DATABASE_NAME] = @PARAM_DATABASE_NAME
    AND [SCHEMA_NAME] = @PARAM_SCHEMA_NAME
    AND [TABLE_NAME] = @PARAM_TABLE_NAME
END;