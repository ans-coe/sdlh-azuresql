/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_InsertLog
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_InsertLog]
    @TRIGGER_NAME           VARCHAR(500)
    ,@TRIGGER_TIME          DATETIME2(0)
    ,@TRIGGER_TYPE          VARCHAR(100)
    ,@PIPELINE_RUN_ID       VARCHAR(500)
    ,@PIPELINE_NAME         VARCHAR(500)
    ,@COMPONENT_NAME        VARCHAR(500)
    ,@SOURCE_SYSTEM   	    VARCHAR(500)
    ,@TARGET_SYSTEM         VARCHAR(500)
    ,@SCHEMA_NAME		        VARCHAR(500)
    ,@TABLE_NAME    		    VARCHAR(500)  
    ,@OPERATION		          VARCHAR(500)  
    ,@START_TIME            DATETIME2(0)
    ,@END_TIME              DATETIME2(0) = NULL
    ,@DURATION_SECONDS      INT = NULL
    ,@INSERTS               INT = NULL
    ,@UPDATES               INT = NULL
    ,@DELETES               INT = NULL
    ,@ERROR_MESSAGE         VARCHAR(500) = NULL
    ,@INCREMENTAL_KEY_VALUE VARCHAR(500) = NULL
AS
SET NOCOUNT ON;

INSERT INTO [ETL].[Log]
    (TRIGGER_NAME
    ,TRIGGER_TIME
    ,TRIGGER_TYPE
    ,PIPELINE_RUN_ID
    ,PIPELINE_NAME
    ,COMPONENT_NAME
    ,SOURCE_SYSTEM
    ,TARGET_SYSTEM
    ,SCHEMA_NAME
    ,TABLE_NAME
    ,OPERATION
    ,START_TIME
    ,END_TIME
    ,DURATION_SECONDS
    ,INSERTS
    ,UPDATES
    ,DELETES
    ,ERROR_MESSAGE
    ,INCREMENTAL_KEY_VALUE)
VALUES (@TRIGGER_NAME
    ,@TRIGGER_TIME
    ,@TRIGGER_TYPE
    ,@PIPELINE_RUN_ID
    ,@PIPELINE_NAME
    ,@COMPONENT_NAME
    ,@SOURCE_SYSTEM
    ,@TARGET_SYSTEM
	  ,@SCHEMA_NAME
	  ,@TABLE_NAME
    ,@OPERATION
    ,@START_TIME
    ,@END_TIME
    ,@DURATION_SECONDS
    ,@INSERTS
    ,@UPDATES
    ,@DELETES
    ,@ERROR_MESSAGE
    ,@INCREMENTAL_KEY_VALUE);

SELECT SCOPE_IDENTITY() AS EtlLogId;