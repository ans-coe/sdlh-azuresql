/*
===============================================================
Author: Darren Price
Created: 2024-04-25
Name: usp_GenericUpdateTable
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes 6 parameters from Synapse using pipeline dynamic expressions.

    It sets IS_ENABLED column to false on matching criteria.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-04-25  Darren Price    Initial version
===============================================================
*/

CREATE PROCEDURE [ETL].[usp_GenericUpdateTable]
    @PARAM_SOURCE_TYPE VARCHAR(150),
    @PARAM_SOURCE_SYSTEM VARCHAR(150),
    @PARAM_SOURCE_GROUPING_ID_START VARCHAR(10),
    @PARAM_SOURCE_GROUPING_ID_END VARCHAR(10),
    @PARAM_SCHEMA_NAME VARCHAR(150),
    @PARAM_TABLE_NAME VARCHAR(150)

AS
BEGIN
    DECLARE @sql NVARCHAR(max)

    SET @sql =
    N'
    BEGIN
        UPDATE ['+ @PARAM_SCHEMA_NAME +'].['+ @PARAM_TABLE_NAME +']
        SET [IS_ENABLED] = 0
        WHERE [SOURCE_TYPE] = '''+ @PARAM_SOURCE_TYPE +'''
        AND [SOURCE_SYSTEM] = '''+ @PARAM_SOURCE_SYSTEM +'''
        AND [SOURCE_GROUPING_ID] BETWEEN '+ @PARAM_SOURCE_GROUPING_ID_START +' AND '+ @PARAM_SOURCE_GROUPING_ID_END +';
    END
    '

    EXEC sp_executesql @sql;
END;