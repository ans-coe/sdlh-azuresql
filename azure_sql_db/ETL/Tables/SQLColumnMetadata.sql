CREATE TABLE [ETL].[SQLColumnMetadata] (
    [ID]                       INT            IDENTITY (1, 1) NOT NULL,
    [SOURCE_TYPE]              VARCHAR (150)  NOT NULL,
    [SOURCE_SYSTEM]            VARCHAR (150)  NOT NULL,
    [IS_ENABLED]               BIT            NOT NULL,
    [DATABASE_NAME]            VARCHAR (150)  NOT NULL,
    [SCHEMA_NAME]              VARCHAR (150)  NULL,
    [TABLE_NAME]               VARCHAR (150)  NOT NULL,
    [COLUMN_NAME]              NVARCHAR (150) NOT NULL,
    [COLUMN_DEFAULT]           NVARCHAR (150) NULL,
    [IS_NULLABLE]              NVARCHAR (150) NULL,
    [DATA_TYPE]                NVARCHAR (150) NULL,
    [CHARACTER_MAXIMUM_LENGTH] BIGINT         NULL,
    [COLLATION_NAME]           NVARCHAR (150) NULL,
    [ORDINAL_POSITION]         INT            NULL
);

