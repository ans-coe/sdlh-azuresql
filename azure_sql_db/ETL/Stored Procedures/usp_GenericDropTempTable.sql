/*
===============================================================
Author: Darren Price
Created: 2024-04-25
Name: usp_GenericDropTempTable
Description:	 
    This stored procedure is ran from within SDLH ingestion pipelines in Azure Synapse Analytics.
    It takes 2 parameters from Synapse using pipeline dynamic expressions.

    It drops the supplied table from the database.
    
    Fields returned:
    - None

===============================================================
Change History

Date        Name            Description
2024-04-25  Darren Price    Initial version
===============================================================
*/

CREATE PROCEDURE [ETL].[usp_GenericDropTempTable]
    @PARAM_SCHEMA_NAME VARCHAR(150),
    @PARAM_TABLE_NAME VARCHAR(150)

AS
BEGIN
    DECLARE @sql NVARCHAR(max)

    SET @sql =
    N'
    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''['+ @PARAM_SCHEMA_NAME +'].['+ @PARAM_TABLE_NAME +']'') AND type in (N''U''))

    BEGIN
        DROP TABLE ['+ @PARAM_SCHEMA_NAME +'].['+ @PARAM_TABLE_NAME +'];  
    END
    '

    EXEC sp_executesql @sql;
END;