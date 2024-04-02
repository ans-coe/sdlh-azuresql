/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_SQLUpdateWatermark
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 5 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Source Type name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Source System name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_SYSTEM
   - @PARAM_DATABASE_NAME (STR): Database name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().DATABASE_NAME
   - @PARAM_SCHEMA_NAME (STR): Schema name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SCHEMA_NAME
   - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME
   - @PARAM_NEW_WATERMARK_VALUE (DATETIME2): Data retrived from a lookup to get the new watermark datetime. Pipeline dynamic expression: @activity('lookup_set_watermark_value').output.firstRow.NEW_WATERMARK_VALUE

    It updates the LAST_WATERMARK_VALUE in table [ETL].[SQLTableMetadata] with the latest captured value.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2023-12-13  Andrei Dumitru  Added description and inline comments
2024-01-15  Darren Price    Renamed and Uplifted to work with v2.1
2024-03-28  Darren Price    Updated WHERE SCHEMA_NAME ISNULL for MySQL usage
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_SQLUpdateWatermark]
    @PARAM_SOURCE_TYPE VARCHAR(250),
    @PARAM_SOURCE_SYSTEM VARCHAR(250),
    @PARAM_DATABASE_NAME VARCHAR(250),
    @PARAM_SCHEMA_NAME VARCHAR(250),
    @PARAM_TABLE_NAME VARCHAR(250),
    @PARAM_NEW_WATERMARK_VALUE VARCHAR(250)
AS

BEGIN
    UPDATE [ETL].[SQLTableMetadata]
    SET [LAST_WATERMARK_VALUE] = CAST(@PARAM_NEW_WATERMARK_VALUE AS DATETIME2)
    WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
    AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [DATABASE_NAME] = @PARAM_DATABASE_NAME
	AND ISNULL([SCHEMA_NAME],'NA') = ISNULL(@PARAM_SCHEMA_NAME,'NA')
    AND [TABLE_NAME] = @PARAM_TABLE_NAME
END;