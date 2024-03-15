/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_InsertLog
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in a number paramters from Synapse using pipeline dynamic expressions.

    It inserts a row into [ETL].[Log] with passed in parameters.
    
    Fields returned:
    - LOG_ID for the row thats been inserts.

    Please note that this stored procedure can be used in conjuction with usp_UpdateLog.
    usp_UpdateLog maybe used to update a given row in the [ETL].[Log] table

===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2024-01-15  Darren Price    Uplifted to work with v2.1, columns added DATABASE_NAME, TRIGGERING_PIPELINE_RUN_ID, TRIGGERING_PIPELINE_NAME
2024-01-15  Darren Price    Uplifted to work with v2.2, columns added SOURCE_TYPE, SOURCE_GROUPING_ID, OBJECT_NAME.
                                                        columns removed TRIGGER_NAME, INSERT_USER, INSERT_TIME, LAST_UPDATE_USER, LAST_UPDATE_TIME
                                                        columns renamed INCREMENTAL_KEY_VALUE to NEW_INCREMENTAL_KEY_VALUE 
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_InsertLog]
    @SOURCE_TYPE                        VARCHAR(500)
    ,@SOURCE_SYSTEM                     VARCHAR(500)
    ,@SOURCE_GROUPING_ID                INT
    ,@OBJECT_NAME                       VARCHAR(500)
    ,@DATABASE_NAME                     VARCHAR(500)
    ,@SCHEMA_NAME                       VARCHAR(500)
    ,@TABLE_NAME                        VARCHAR(500)
    ,@TRIGGER_TIME                      DATETIME2(0)
    ,@TRIGGER_TYPE                      VARCHAR(100)
    ,@PIPELINE_RUN_ID                   VARCHAR(500)
    ,@PIPELINE_NAME                     VARCHAR(500)
    ,@TRIGGERING_PIPELINE_RUN_ID        VARCHAR(500)
    ,@TRIGGERING_PIPELINE_NAME          VARCHAR(500)
    ,@OPERATION                         VARCHAR(500)
    ,@COMPONENT_NAME                    VARCHAR(500)
    ,@TARGET_SYSTEM                     VARCHAR(500)
    ,@START_TIME                        DATETIME2(0)
    ,@END_TIME                          DATETIME2(0) = NULL
    ,@DURATION_SECONDS                  INT = NULL
    ,@INSERTS                           INT = NULL
    ,@UPDATES                           INT = NULL
    ,@DELETES                           INT = NULL
    ,@ERROR_MESSAGE                     VARCHAR(4000) = NULL
    ,@NEW_INCREMENTAL_KEY_VALUE         VARCHAR(500) = NULL
    ,@PREVIOUS_INCREMENTAL_KEY_VALUE    VARCHAR(500) = NULL
AS
SET NOCOUNT ON;

INSERT INTO [ETL].[Log] (
    [SOURCE_TYPE]
    ,[SOURCE_SYSTEM]
    ,[SOURCE_GROUPING_ID]
    ,[OBJECT_NAME]
    ,[DATABASE_NAME]
    ,[SCHEMA_NAME]
    ,[TABLE_NAME]
    ,[TRIGGER_TIME]
    ,[TRIGGER_TYPE]
    ,[PIPELINE_RUN_ID]
    ,[PIPELINE_NAME]
    ,[TRIGGERING_PIPELINE_RUN_ID]
    ,[TRIGGERING_PIPELINE_NAME]
    ,[OPERATION]
    ,[COMPONENT_NAME]
    ,[TARGET_SYSTEM]
    ,[START_TIME]
    ,[END_TIME]
    ,[DURATION_SECONDS]
    ,[INSERTS]
    ,[UPDATES]
    ,[DELETES]
    ,[ERROR_MESSAGE]
    ,[NEW_INCREMENTAL_KEY_VALUE]
    ,[PREVIOUS_INCREMENTAL_KEY_VALUE]
)
VALUES (
    @SOURCE_TYPE
    ,@SOURCE_SYSTEM
    ,@SOURCE_GROUPING_ID
    ,@OBJECT_NAME
    ,@DATABASE_NAME
    ,@SCHEMA_NAME
    ,@TABLE_NAME
    ,@TRIGGER_TIME
    ,@TRIGGER_TYPE
    ,@PIPELINE_RUN_ID
    ,@PIPELINE_NAME
    ,@TRIGGERING_PIPELINE_RUN_ID
    ,@TRIGGERING_PIPELINE_NAME
    ,@OPERATION
    ,@COMPONENT_NAME
    ,@TARGET_SYSTEM
    ,@START_TIME
    ,@END_TIME
    ,@DURATION_SECONDS
    ,@INSERTS
    ,@UPDATES
    ,@DELETES
    ,@ERROR_MESSAGE
    ,@NEW_INCREMENTAL_KEY_VALUE
    ,@PREVIOUS_INCREMENTAL_KEY_VALUE
);

SELECT SCOPE_IDENTITY() AS LOG_ID;