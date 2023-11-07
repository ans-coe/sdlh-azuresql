CREATE TABLE [ETL].[SourceSchemaVersion] (
    [ID]               INT            IDENTITY (1, 1) NOT NULL,
    [SOURCE_NAME]      VARCHAR (40)   NULL,
    [OBJECT_NAME]      VARCHAR (200)  NULL,
    [SCHEMA_HASH]      VARCHAR (40)   NULL,
    [VERSION_NUMBER]   INT            NULL,
    [SCHEMA_JSON_DUMP] VARCHAR (4000) NULL,
    [START_DATE]       DATETIME       NULL,
    [END_DATE]         DATETIME       NULL,
    [IS_CURRENT]       BIT            NULL,
    CONSTRAINT [PK_SourceSchemaVersion] PRIMARY KEY CLUSTERED ([ID] ASC)
);