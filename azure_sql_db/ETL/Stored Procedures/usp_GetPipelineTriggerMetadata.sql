/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_GetPipelineTriggerMetadata
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GetPipelineTriggerMetadata] 
    @PIPELINE_CURRENT_DATETIME DATETIME2,
    @PIPELINE_TRIGGER_NAME VARCHAR(100),
    @PIPELINE_NAME VARCHAR(100)
    
AS
BEGIN
    SET NOCOUNT ON
    SELECT OBJECT_NAME,
        JSON_VALUE(OP.value, '$.SERVER_NAME') as SERVER_NAME,
        JSON_VALUE(OP.value, '$.DATABASE_NAME') as DATABASE_NAME,
        JSON_VALUE(OP.value, '$.SCHEMA_NAME') as SCHEMA_NAME,
        JSON_VALUE(OP.value, '$.TABLE_NAME') as TABLE_NAME,
        JSON_VALUE(OP.value, '$.SOURCE_SYSTEM_CONNECTION_STRING') as SOURCE_SYSTEM_CONNECTION_STRING,
        -- CASE 
        --     WHEN BATCH_FREQUENCY = 'Minute' THEN CONCAT(DATEPART(year, @VAR_PIPELINE_CURRENT_DATETIME),'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@VAR_PIPELINE_CURRENT_DATETIME, 1), 'HH'),'/', FORMAT([ETL].[udf_RoundTime](@VAR_PIPELINE_CURRENT_DATETIME, 60), 'mm'))
        --     WHEN BATCH_FREQUENCY = 'Hour' THEN CONCAT(DATEPART(year, @VAR_PIPELINE_CURRENT_DATETIME),'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@VAR_PIPELINE_CURRENT_DATETIME, 1), 'HH'))
        --     WHEN BATCH_FREQUENCY = 'Day' THEN CONCAT(DATEPART(year, @VAR_PIPELINE_CURRENT_DATETIME),'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME, 'dd'))
        --     WHEN BATCH_FREQUENCY = 'Month' THEN CONCAT(DATEPART(year, @VAR_PIPELINE_CURRENT_DATETIME),'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME,'MM'))
        --     ELSE CONCAT(DATEPART(year, @VAR_PIPELINE_CURRENT_DATETIME),'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME,'MM') ,'/', FORMAT(@VAR_PIPELINE_CURRENT_DATETIME, 'dd'))
        --     END AS HNS,

        JSON_VALUE(triggers.value, '$.TRIGGER_NAME') as TRIGGER_NAME

    FROM [ETL].[JsonMetadata]
    CROSS APPLY OPENJSON(JsonMetadata.TRIGGERS_INFO) as triggers
    CROSS APPLY OPENJSON(JsonMetadata.OBJECT_PARAMETERS) as OP
    WHERE 
    JSON_VALUE(triggers.value, '$.TRIGGER_NAME') = @PIPELINE_TRIGGER_NAME
    AND PIPELINE_NAME = @PIPELINE_NAME
END;