/*
===============================================================
Author: Andrei Dumitru
Created: 2022-11-01
Name: usp_GetPipelineTriggerMetadata
Description:	 
   
===============================================================
Change History

Date        Name            Description
2022-11-01  Andrei Dumitru  Initial create
2023-11-01  Darren Price    Brought inline with data standards
===============================================================
*/
CREATE FUNCTION [ETL].[udf_RoundTime] (@Time DATETIME, @RoundToMin INT)
RETURNS DATETIME
AS
BEGIN
RETURN ROUND(CAST(CAST(CONVERT(VARCHAR,
@Time,121) AS DATETIME) AS FLOAT) * (1440/@RoundToMin),0)/(1440/@RoundToMin)
END