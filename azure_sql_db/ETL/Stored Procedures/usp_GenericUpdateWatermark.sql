/*
===============================================================
Author: Darren Price
Created: 2024-04-25
Name: usp_GenericUpdateWatermark
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 4 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Source Type name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Source System name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().SOURCE_SYSTEM
   - @PARAM_TABLE_NAME (STR): Table name corresponding to the current ForEach loop item. Pipeline dynamic expression: @item().TABLE_NAME
   - @PARAM_NEW_WATERMARK_VALUE (DATETIME2): Data retrived from a lookup to get the new watermark datetime. Pipeline dynamic expression: @activity('lookup_set_watermark_value').output.firstRow.NEW_WATERMARK_VALUE

    It updates the LAST_WATERMARK_VALUE in table [ETL].[GenericTableMetadata] with the latest captured value.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-04-25  Darren Price    Initial create
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GenericUpdateWatermark]
    @PARAM_SOURCE_TYPE VARCHAR(250),
    @PARAM_SOURCE_SYSTEM VARCHAR(250),
    @PARAM_TABLE_NAME VARCHAR(250),
    @PARAM_NEW_WATERMARK_VALUE VARCHAR(250)
AS

BEGIN
    UPDATE [ETL].[GenericTableMetadata]
    SET [LAST_WATERMARK_VALUE] = CAST(@PARAM_NEW_WATERMARK_VALUE AS DATETIME2)
    WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
    AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [TABLE_NAME] = @PARAM_TABLE_NAME
END;