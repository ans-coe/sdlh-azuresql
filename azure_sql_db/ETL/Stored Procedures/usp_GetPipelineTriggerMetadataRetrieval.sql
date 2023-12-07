/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_GetPipelineTriggerMetadataRetrieval
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GetPipelineTriggerMetadataRetrieval]
    @PIPELINE_CURRENT_DATETIME DATETIME2,
    @PIPELINE_TRIGGER_NAME VARCHAR(500),
    @PIPELINE_NAME VARCHAR(500),
    @OBJECT_NAME VARCHAR(500)
    
AS
BEGIN
    SET NOCOUNT ON
    SELECT *,
        CASE 
            WHEN BATCH_FREQUENCY = 'Minute' THEN CONCAT(DATEPART(year, @PIPELINE_CURRENT_DATETIME),'/', FORMAT(@PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@PIPELINE_CURRENT_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@PIPELINE_CURRENT_DATETIME, 1), 'HH'),'/', FORMAT([ETL].[udf_RoundTime](@PIPELINE_CURRENT_DATETIME, 60), 'mm'))
            WHEN BATCH_FREQUENCY = 'Hour' THEN CONCAT(DATEPART(year, @PIPELINE_CURRENT_DATETIME),'/', FORMAT(@PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@PIPELINE_CURRENT_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@PIPELINE_CURRENT_DATETIME, 1), 'HH'))
            WHEN BATCH_FREQUENCY = 'Day' THEN CONCAT(DATEPART(year, @PIPELINE_CURRENT_DATETIME),'/', FORMAT(@PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@PIPELINE_CURRENT_DATETIME, 'dd'))
            WHEN BATCH_FREQUENCY = 'Month' THEN CONCAT(DATEPART(year, @PIPELINE_CURRENT_DATETIME),'/', FORMAT(@PIPELINE_CURRENT_DATETIME,'MM'))
            ELSE CONCAT(DATEPART(year, @PIPELINE_CURRENT_DATETIME),'/', FORMAT(@PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@PIPELINE_CURRENT_DATETIME, 'dd'))
            END AS HNS,

        JSON_VALUE(triggers.value, '$.TRIGGER_NAME') as TRIGGER_NAME

    FROM [ETL].[JsonMetadata]
    CROSS APPLY OPENJSON(JsonMetadata.TRIGGERS_INFO) as triggers
    WHERE JSON_VALUE(triggers.value, '$.TRIGGER_NAME') = @PIPELINE_TRIGGER_NAME
    AND PIPELINE_NAME = @PIPELINE_NAME
    AND OBJECT_NAME = @OBJECT_NAME
END;