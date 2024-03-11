/*
===============================================================
Author: Darren Price
Created: 2024-02-16
Name: usp_GetTriggeringPipelineLastRunState
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 3 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_SOURCE_TYPE (STR): Passed in parameter for required source type. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_TYPE
   - @PARAM_SOURCE_SYSTEM (STR): Passed in parameter for required source system. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_SYSTEM
   - @PARAM_SOURCE_GROUPING_ID (INT): Passed in parameter for required source grouping. Pipeline dynamic expression: @pipeline().parameters.PARAM_SOURCE_GROUPING_ID
   - @PARAM_PIPELINE_NAME (STR): Passed in parameter for required source grouping. Pipeline dynamic expression: @pipeline().Pipeline
   - @PARAM_TRIGGERING_PIPELINE_NAME (STR): Object name corresponding to the current ForEach loop item. Pipeline dynamic expression: @pipeline().TriggeredByPipelineName

    It finds the most resent log entry for the given parameters and returns fields below for the record
    
    Fields returned From ETL.Log:
    - LOG_ID
    - PIPELINE_RUN_ID
    - TRIGGER_TIME
    - LAST_TRIGGERING_PIPELINE_RUN_STATUS (If column ERROR_MESSAGE is null it returns as 'Succeeded' else returns as 'Failed')

===============================================================
Change History

Date        Name            Description
2024-02-16  Darren Price  Initial create
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GetTriggeringPipelineLastRunState]
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150),
    @PARAM_SOURCE_GROUPING_ID INT,
    @PARAM_PIPELINE_NAME VARCHAR(150),
    @PARAM_TRIGGERING_PIPELINE_NAME VARCHAR(150)
    
AS
BEGIN
    SET NOCOUNT ON;

    WITH cte_get_last_completed_run AS (
        SELECT [SOURCE_TYPE]
            ,[SOURCE_SYSTEM]
            ,[SOURCE_GROUPING_ID]
            ,[PIPELINE_NAME]
            ,[TRIGGERING_PIPELINE_NAME]
            ,MAX([TRIGGER_TIME]) AS [TRIGGER_TIME]
        FROM [ETL].[Log]
        WHERE [SOURCE_TYPE] = @PARAM_SOURCE_TYPE
        AND [SOURCE_SYSTEM] = @PARAM_SOURCE_SYSTEM
        AND [SOURCE_GROUPING_ID] = @PARAM_SOURCE_GROUPING_ID
        AND [PIPELINE_NAME] = @PARAM_PIPELINE_NAME
        AND [TRIGGERING_PIPELINE_NAME] = @PARAM_TRIGGERING_PIPELINE_NAME
        AND [END_TIME] IS NOT NULL
        GROUP BY [SOURCE_TYPE], [SOURCE_SYSTEM], [SOURCE_GROUPING_ID], [PIPELINE_NAME], [TRIGGERING_PIPELINE_NAME]
    )

    SELECT L.[LOG_ID]
        ,L.[PIPELINE_RUN_ID]
        ,L.[TRIGGERING_PIPELINE_RUN_ID]
        ,L.[TRIGGER_TIME]
        ,CASE
            WHEN L.[ERROR_MESSAGE] IS NULL THEN 'Succeeded'
            ELSE 'Failed' 
        END AS [LAST_TRIGGERING_PIPELINE_RUN_STATUS]
    FROM [ETL].[Log] L
    JOIN cte_get_last_completed_run CTE
        ON L.[SOURCE_TYPE] = CTE.[SOURCE_TYPE]
        AND L.[SOURCE_SYSTEM] = CTE.[SOURCE_SYSTEM]
        AND L.[SOURCE_GROUPING_ID] = CTE.[SOURCE_GROUPING_ID]
        AND L.[PIPELINE_NAME] = CTE.[PIPELINE_NAME]
        AND L.[TRIGGERING_PIPELINE_NAME] = CTE.[TRIGGERING_PIPELINE_NAME]
        AND L.[TRIGGER_TIME] = CTE.[TRIGGER_TIME]
END;