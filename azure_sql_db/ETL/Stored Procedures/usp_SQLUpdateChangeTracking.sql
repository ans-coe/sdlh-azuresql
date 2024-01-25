/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_SQLUpdateChangeTracking
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 5 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_SYSTEM (STR): Source System name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_SYSTEM
   - @PARAM_DATABASE_NAME (STR): Database name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().DATABASE_NAME
   - @PARAM_SCHEMA_NAME (STR): Schema name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SCHEMA_NAME
   - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME
   - @NEW_CHANGE_TRACKING_VALUE (INT): Data retrived from a lookup to get the new change tracking value. New change tracking value. Pipeline dynamic expression: @activity('lookup_set_change_tracking_value').output.firstRow.NEW_CHANGE_TRACKING_VALUE

    It updates the LAST_CHANGE_TRACKING_VALUE in table [ETL].[SQLTableMetadata] with the latest captured value.
    
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
CREATE PROCEDURE [ETL].[usp_SQLUpdateChangeTracking]     
    @SOURCE_SYSTEM VARCHAR(250),
    @DATABASE_NAME VARCHAR(250),
    @SCHEMA_NAME VARCHAR(250),
    @TABLE_NAME VARCHAR(250),
    @NEW_CHANGE_TRACKING_VALUE INT
AS

BEGIN
    UPDATE [ETL].[SQLTableMetadata]
    SET [LAST_CHANGE_TRACKING_VALUE] = @NEW_CHANGE_TRACKING_VALUE
    WHERE [SOURCE_SYSTEM] = @SOURCE_SYSTEM
    AND [DATABASE_NAME] = @DATABASE_NAME
    AND [SCHEMA_NAME] = @SCHEMA_NAME
    AND [TABLE_NAME] = @TABLE_NAME
END;