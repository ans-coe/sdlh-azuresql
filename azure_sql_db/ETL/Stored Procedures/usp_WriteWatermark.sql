/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_WriteWatermark
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_WriteWatermark]     
    @OBJECT_NAME VARCHAR(250),
    @SERVER_NAME VARCHAR(250) NULL,
    @DATABASE_NAME VARCHAR(250) NULL,
    @SCHEMA_NAME VARCHAR(250) NULL,
    @TABLE_NAME VARCHAR(250) NULL,
    @WATERMARK_VALUE DATETIME2
AS
BEGIN
    UPDATE ETL.SourceIncrementalLoad
    SET [WATERMARK_VALUE] = @WATERMARK_VALUE
    WHERE [OBJECT_NAME] = @OBJECT_NAME
END;