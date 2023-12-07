/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_TruncateMetaAndColumns
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE PROCEDURE [ETL].[usp_TruncateMetaAndColumns]
AS
BEGIN
    TRUNCATE TABLE [ETL].[SourceTable];
    TRUNCATE TABLE [ETL].[SourceColumn];
END;