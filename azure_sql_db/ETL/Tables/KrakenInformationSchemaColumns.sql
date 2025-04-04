CREATE TABLE [ETL].[KrakenInformationSchemaColumns](
	[SOURCE_TYPE]						NVARCHAR(150) NULL,
	[SOURCE_SYSTEM]						NVARCHAR(150) NULL,
	[TABLE_CATALOG]						NVARCHAR(150) NULL,
	[TABLE_SCHEMA]						NVARCHAR(150) NULL,
	[TABLE_NAME]						NVARCHAR(150) NULL,
	[COLUMN_NAME]						NVARCHAR(150) NULL,
	[COLUMN_DEFAULT]					NVARCHAR(150) NULL,
	[IS_NULLABLE]						NVARCHAR(150) NULL,
	[DATA_TYPE]							NVARCHAR(150) NULL,
	[CHARACTER_MAXIMUM_LENGTH]			BIGINT NULL,
	[NUMERIC_PRECISION]					TINYINT NULL,
	[NUMERIC_SCALE]						INT NULL,
	[COLLATION_NAME]					NVARCHAR(128) NULL
);