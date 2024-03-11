/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_GetPipelineMetadataRetrievalFull
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes in 4 parameters extracted from Synapse using pipeline dynamic expressions:

   - @PARAM_DATETIME (DATETIME): Pipeline run start time. Notebook nb_util_sql_staged_etl_and_logging_py: '{PARAM_TRIGGER_TIME}'
   - @PARAM_SOURCE_TYPE (STR): Passed in parameter for required source type. Notebook nb_util_sql_staged_etl_and_logging_py: '{PARAM_SOURCE_TYPE}'
   - @PARAM_SOURCE_SYSTEM (STR): Passed in parameter for required source system. Notebook nb_util_sql_staged_etl_and_logging_py: '{PARAM_SOURCE_SYSTEM}'
   - @PARAM_SOURCE_GROUPING_ID (INT): Passed in parameter for required source grouping. Notebook nb_util_sql_staged_etl_and_logging_py: {PARAM_SOURCE_GROUPING_ID}

    It returns the full information (metadata) about all the objects from the batch. In addition to the metadata from ETL.JsonMetadata,
    it also calculates and returns HNS (Hierarchical Namespace) which is used by the Copy Activity to sort the data in the Raw layer.
    This info is then used in the ingestion pipeline, specifically within the Notebook to drive the ETL into the enriched layer, ETL logging, and 
    queuing of the specific object within the delta merge function.
    
    Fields returned:
    - All the fields from ETL.JsonMetadata in full (including JSON) for all of the objects
    - HNS 

    Please note that currently, a batch is defined by querying the ETL.JsonMetadata table and filtering all the matching objects
    on matching SOURCE_TYPE, SOURCE_SYSTEM, SOURCE_GROUPING_ID, and IS_ENABLED = 1.

===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
2023-12-13  Andrei Dumitru  Added description and inline comments
2024-01-15  Darren Price    Renamed and Uplifted to work with v2.1
2024-03-01  Darren Price    Changed CASE END AS HNS to set the else to empty. (This allows an SDLH raw path to exclude any date path as a return option)
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_GetPipelineMetadataRetrievalFull] 
    @PARAM_DATETIME DATETIME2,
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150),
    @PARAM_SOURCE_GROUPING_ID INT
    
AS
BEGIN
    SET NOCOUNT ON
    SELECT *,
        CASE 
            WHEN BATCH_FREQUENCY = 'Minute' THEN CONCAT(DATEPART(year, @PARAM_DATETIME),'/', FORMAT(@PARAM_DATETIME,'MM') ,'/', FORMAT(@PARAM_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@PARAM_DATETIME, 1), 'HH'),'/', FORMAT([ETL].[udf_RoundTime](@PARAM_DATETIME, 60), 'mm'))
            WHEN BATCH_FREQUENCY = 'Hour' THEN CONCAT(DATEPART(year, @PARAM_DATETIME),'/', FORMAT(@PARAM_DATETIME,'MM') ,'/', FORMAT(@PARAM_DATETIME, 'dd'),'/', FORMAT([ETL].[udf_RoundTime](@PARAM_DATETIME, 1), 'HH'))
            WHEN BATCH_FREQUENCY = 'Day' THEN CONCAT(DATEPART(year, @PARAM_DATETIME),'/', FORMAT(@PARAM_DATETIME,'MM') ,'/', FORMAT(@PARAM_DATETIME, 'dd'))
            WHEN BATCH_FREQUENCY = 'Month' THEN CONCAT(DATEPART(year, @PARAM_DATETIME),'/', FORMAT(@PARAM_DATETIME,'MM'))
            WHEN BATCH_FREQUENCY = 'Year' THEN CONVERT(VARCHAR(30),DATEPART(year, @PARAM_DATETIME))
            ELSE ''
        END AS HNS
    FROM [ETL].[JsonMetadata]
    WHERE SOURCE_TYPE = @PARAM_SOURCE_TYPE
    AND SOURCE_SYSTEM = @PARAM_SOURCE_SYSTEM
    AND SOURCE_GROUPING_ID = @PARAM_SOURCE_GROUPING_ID
    AND IS_ENABLED = 1
END;