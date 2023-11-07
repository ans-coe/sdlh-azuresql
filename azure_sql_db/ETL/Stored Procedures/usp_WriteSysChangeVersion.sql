/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_WriteSysChangeVersion
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_WriteSysChangeVersion]     
    @OBJECT_NAME VARCHAR(250),
    @SERVER_NAME VARCHAR(250) NULL,
    @DATABASE_NAME VARCHAR(250) NULL,
    @SCHEMA_NAME VARCHAR(250) NULL,
    @TABLE_NAME VARCHAR(250) NULL,
    @SYS_CHANGE_VERSION_VALUE VARCHAR(250)
AS
-- DECLARE @OBJECT_NAME VARCHAR(250);
-- SET @OBJECT_NAME = CONCAT(REPLACE(REPLACE(REPLACE(@SERVER_NAME,'.','_'), '-','_'), '\', '_'), '_',@DATABASE_NAME,'_', @SCHEMA_NAME, '_',@TABLE_NAME);
BEGIN
    UPDATE ETL.SourceIncrementalLoad
    SET [SYS_CHANGE_VERSION_VALUE] = @SYS_CHANGE_VERSION_VALUE
    WHERE [OBJECT_NAME] = @OBJECT_NAME
END;