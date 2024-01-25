/*
===============================================================
Author: Tom Legge
Created: 2024-01-15
Name: usp_InsertLogRowCounts
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in a number paramters from Synapse using pipeline dynamic expressions.

    It inserts a rows in [ETL].[LogRowCounts] with passed in parameters.
    
    Fields returned:
    - EtlLogId

===============================================================
Change History

Date        Name            Description
2024-01-15  Tom Legge       Initial version
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_InsertLogRowCounts]
    @PIPELINE_RUN_ID varchar(500),
    @SOURCE_SYSTEM varchar(500),
    @TARGET_SYSTEM varchar(500),
    @TABLE_NAME varchar(500),
    @START_TIME datetime2(0),
    @SOURCE_SYSTEM_ROW_COUNT INT,
    @TARGET_SYSTEM_ROW_COUNT INT
AS
SET NOCOUNT ON;

INSERT INTO [ETL].[LogRowCounts]
    (PIPELINE_RUN_ID
    ,SOURCE_SYSTEM
    ,TARGET_SYSTEM
    ,TABLE_NAME
    ,START_TIME
    ,SOURCE_SYSTEM_ROW_COUNT
    ,TARGET_SYSTEM_ROW_COUNT)
VALUES (@PIPELINE_RUN_ID
    ,@SOURCE_SYSTEM
    ,@TARGET_SYSTEM
    ,@TABLE_NAME
    ,@START_TIME
    ,@SOURCE_SYSTEM_ROW_COUNT
    ,@TARGET_SYSTEM_ROW_COUNT);

SELECT SCOPE_IDENTITY() AS EtlLogId;