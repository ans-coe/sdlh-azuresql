CREATE TABLE [ETL].[GenericColumnMetadata] (
    [ID]                       INT            IDENTITY (1, 1) NOT NULL,
    [SOURCE_TYPE]              VARCHAR (150)  NOT NULL,
    [SOURCE_SYSTEM]            VARCHAR (150)  NOT NULL,
    [SOURCE_GROUPING_ID]       INT            NOT NULL,
    [IS_ENABLED]               BIT            NOT NULL,
    [TABLE_NAME]               VARCHAR (150)  NOT NULL,
    [COLUMN_NAME]              NVARCHAR (150) NOT NULL,
    [DATA_TYPE]                NVARCHAR (150) NULL,
    [CHARACTER_MAXIMUM_LENGTH] BIGINT         NULL,
    [CUSTOM_FIELD_1]           VARCHAR (MAX)  NULL,
    [CUSTOM_FIELD_2]           VARCHAR (MAX)  NULL,
    [CUSTOM_FIELD_3]           VARCHAR (MAX)  NULL,
    [CUSTOM_FIELD_4]           VARCHAR (MAX)  NULL
);

