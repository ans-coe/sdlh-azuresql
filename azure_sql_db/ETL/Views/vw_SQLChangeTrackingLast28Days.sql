﻿CREATE VIEW [ETL].[vw_SQLChangeTrackingLast28Days] AS
WITH cte_get_changes_copy_activity AS (
    SELECT [LOG_ID]
        ,[TRIGGERING_PIPELINE_RUN_ID]
        ,[SOURCE_SYSTEM]
        ,[OBJECT_NAME]
        ,[INSERTS]
        ,[UPDATES]
        ,[DELETES]
        ,[TRIGGER_TIME]
        ,[PREVIOUS_INCREMENTAL_KEY_VALUE]
    FROM [ETL].[Log]
    WHERE ([COMPONENT_NAME] = 'copy_sql_to_raw_change_tracking' OR [COMPONENT_NAME] = 'copy_sql_to_raw_full_load_change_tracking_null')
    AND [TRIGGER_TIME] >= DATEADD(DAY,-28,GETDATE())
),

cte_get_changes_delta AS (
    SELECT [LOG_ID]
        ,[TRIGGERING_PIPELINE_RUN_ID]
        ,[SOURCE_SYSTEM]
        ,[OBJECT_NAME]
        ,[INSERTS]
        ,[UPDATES]
        ,[DELETES]
        ,[TRIGGER_TIME]
    FROM [ETL].[Log]
    WHERE [COMPONENT_NAME] = 'nb_lakehouse_orchestration_py'
    AND [TRIGGER_TIME] >= DATEADD(DAY,-28,GETDATE())
)

SELECT L.[SOURCE_SYSTEM]
    ,L.[DATABASE_NAME]
    ,L.[SCHEMA_NAME]
    ,L.[TABLE_NAME]
    ,L.[NEW_INCREMENTAL_KEY_VALUE] AS [NEW_CT_VALUE]
    ,CP.[PREVIOUS_INCREMENTAL_KEY_VALUE] AS [PREVIOUS_CT_VALUE]
    ,CP.[INSERTS] AS [INSERTS_COPY]
    ,DT.[INSERTS] AS [INSERTS_DELTA]
    ,CASE
        WHEN CP.[INSERTS] IS NULL AND DT.[INSERTS] IS NULL THEN 'NA'
        WHEN CP.[INSERTS] - DT.[INSERTS] = 0 THEN 'PARITY'
        ELSE 'DISPARITY' 
    END AS [INSERTS_COMPARE]
    ,CP.[UPDATES] AS [UPDATES_COPY]
    ,DT.[UPDATES] AS [UPDATES_DELTA]
    ,CASE
        WHEN CP.[UPDATES] IS NULL AND DT.[UPDATES] IS NULL THEN 'NA'
        WHEN CP.[UPDATES] - DT.[UPDATES] = 0 THEN 'PARITY'
        ELSE 'DISPARITY' 
    END AS [UPDATES_COMPARE]
    ,CP.[DELETES] AS [DELETES_COPY]
    ,DT.[DELETES] AS [DELETES_DELTA]
    ,CASE
        WHEN CP.[DELETES] IS NULL AND DT.[DELETES] IS NULL THEN 'NA'
        WHEN CP.[DELETES] - DT.[DELETES] = 0 THEN 'PARITY'
        ELSE 'DISPARITY' 
    END AS [DELETES_COMPARE]
    ,L.[LOG_ID] AS [LOG_ID_CT_UPDATE]
    ,CP.[LOG_ID] AS [LOG_ID_COPY]
    ,DT.[LOG_ID] AS [LOG_ID_DELTA]
    ,L.[TRIGGER_TIME] AS [LOG_TIME_CT_UPDATE]
    ,CP.[TRIGGER_TIME] AS [LOG_TIME_COPY]
    ,DT.[TRIGGER_TIME] AS [LOG_TIME_DELTA]
FROM [ETL].[Log] L
LEFT JOIN cte_get_changes_copy_activity CP
    ON L.[TRIGGERING_PIPELINE_RUN_ID] = CP.[TRIGGERING_PIPELINE_RUN_ID]
    AND L.[OBJECT_NAME] = CP.[OBJECT_NAME]
LEFT JOIN cte_get_changes_delta DT
    ON L.[TRIGGERING_PIPELINE_RUN_ID] = DT.[TRIGGERING_PIPELINE_RUN_ID]
    AND L.[OBJECT_NAME] = DT.[OBJECT_NAME]
WHERE L.[COMPONENT_NAME] = 'update_change_tracking'
AND L.[TRIGGER_TIME] >= DATEADD(DAY,-28,GETDATE())
ORDER BY L.[SOURCE_SYSTEM], L.[DATABASE_NAME], L.[SCHEMA_NAME], L.[TABLE_NAME], L.[TRIGGER_TIME] DESC
OFFSET 0 ROWS