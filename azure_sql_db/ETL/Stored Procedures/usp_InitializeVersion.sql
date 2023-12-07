/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_InitializeVersion
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_InitializeVersion] AS
BEGIN
    INSERT INTO ETL.SourceSchemaVersion (OBJECT_NAME, VERSION_NUMBER)
    SELECT TABLE_NAME AS OBJECT_NAME, 0 AS VERSION_NUMBER FROM ETL.SourceTable
END;