/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_UpdateLog
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_UpdateLog]
    @Log_ID             INT
    ,@END_TIME          DATETIME2(0)
    ,@DURATION_SECONDS  INT = NULL
    ,@INSERTS           INT = NULL
    ,@UPDATES           INT = NULL
    ,@DELETES           INT = NULL
    ,@ERROR_MESSAGE     VARCHAR(500) = NULL
AS
SET NOCOUNT ON;

IF (@DURATION_SECONDS IS NULL)
BEGIN
    SELECT @DURATION_SECONDS = DATEDIFF(SS, START_TIME, @END_TIME)
    FROM   ETL.Log
    WHERE  Log_ID = @Log_ID;
END

UPDATE ETL.Log
    SET END_TIME = @END_TIME
    ,DURATION_SECONDS = @DURATION_SECONDS
    ,INSERTS = @INSERTS
    ,UPDATES = @UPDATES
    ,DELETES = @DELETES
    ,ERROR_MESSAGE = @ERROR_MESSAGE
    ,LAST_UPDATE_USER = ORIGINAL_LOGIN()
    ,LAST_UPDATE_TIME = SYSDATETIME()
WHERE Log_ID = @Log_ID;