CREATE TABLE [ETL].[SourceTable] (
    [TABLE_ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [SOURCE_SYSTEM]                   VARCHAR (150) NULL,
    [DATABASE_NAME]                   VARCHAR (150) NULL,
    [SCHEMA_NAME]                     VARCHAR (150) NULL,
    [TABLE_NAME]                      VARCHAR (150) NOT NULL,
    [PRIMARY_KEYS]                    VARCHAR (MAX) NULL,
    [SOURCE_SYSTEM_CONNECTION_STRING] VARCHAR (500) NULL,
    [COLUMNS_META]                    VARCHAR (MAX) NULL,
    [COLUMNS_LIST]                    VARCHAR (MAX) NULL,
    [LOAD_TYPE]                       VARCHAR (100) NULL,
    [OBJECT_TYPE]                     VARCHAR (100) NULL,
    [BATCH_FREQUENCY]                 VARCHAR (100) NULL,
    [SERVERLESS_SQL_POOL_DATABASE]    VARCHAR (100) NULL,
    [SERVERLESS_SQL_POOL_SCHEMA]      VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([TABLE_NAME] ASC)
);