/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_UpdateLog
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in a number paramters from Synapse using pipeline dynamic expressions.

    It updates a row in [ETL].[Log] with passed in parameters for a matching LOG_ID.
    
    Fields returned:
    - None

    Please note that this stored procedure has a dependency on stored procedure usp_InsertLog running first.
    usp_InsertLog creates to log entry in the [ETL].[Log] table

===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2024-01-15  Darren Price    Uplifted to work with v2.1
2024-01-15  Darren Price    Uplifted to work with v2.1.3, columns removed LAST_UPDATE_USER, LAST_UPDATE_TIME
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_UpdateLog]
    @LOG_ID            INT
    ,@END_TIME         DATETIME2(0)
    ,@DURATION_SECONDS INT = NULL
    ,@INSERTS          INT = NULL
    ,@UPDATES          INT = NULL
    ,@DELETES          INT = NULL
    ,@ERROR_MESSAGE    VARCHAR(500) = NULL
AS
SET NOCOUNT ON;

IF (@DURATION_SECONDS IS NULL)
BEGIN
    SELECT @DURATION_SECONDS = DATEDIFF(SS, START_TIME, @END_TIME)
    FROM   [ETL].[Log]
    WHERE  LOG_ID = @LOG_ID;
END

UPDATE [ETL].[Log]
    SET END_TIME = @END_TIME
    ,DURATION_SECONDS = @DURATION_SECONDS
    ,INSERTS = @INSERTS
    ,UPDATES = @UPDATES
    ,DELETES = @DELETES
    ,ERROR_MESSAGE = @ERROR_MESSAGE
WHERE LOG_ID = @LOG_ID;