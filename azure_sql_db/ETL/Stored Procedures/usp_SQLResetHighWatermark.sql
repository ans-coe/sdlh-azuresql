
/*
===============================================================
Author: Darren Price
Created: 2024-02-15
Name: usp_SQLResetHighWatermark
Description:	 
    This stored procedure is intended to be run manually.
    It takes in 4 parameters provide manually by the Data Engineer.

   - @PARAM_SOURCE_TYPE (STR): Source Type name of the required grouping to reset change tracking on.
   - @PARAM_SOURCE_SYSTEM (STR): Source System name of the required grouping to reset change tracking on.
   - @PARAM_SOURCE_GROUPING_ID_START (INT): Source System Grouping ID start range of the required groupings to reset change tracking on.
   - @PARAM_SOURCE_GROUPING_ID_END (INT): Source System Grouping ID end range of the required groupings to reset change tracking on.
   
    It is required enforce a given set of groupinsg to reset thei high watermark value.
    It sets the [LAST_WATERMARK_VALUE] to NULL
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-02-22  Darren Price    Initial config
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_SQLResetHighWatermark]
    @PARAM_SOURCE_TYPE VARCHAR(250),
    @PARAM_SOURCE_SYSTEM VARCHAR(250),
    @PARAM_SOURCE_GROUPING_ID_START INT,
	@PARAM_SOURCE_GROUPING_ID_END INT
AS

BEGIN
    UPDATE [ETL].[SQLTableMetadata]
    SET [LAST_WATERMARK_VALUE] = NULL
    WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
    AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
    AND [SOURCE_GROUPING_ID] BETWEEN @PARAM_SOURCE_GROUPING_ID_START AND @PARAM_SOURCE_GROUPING_ID_END
END;