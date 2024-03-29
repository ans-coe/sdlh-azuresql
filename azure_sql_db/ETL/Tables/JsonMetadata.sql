﻿CREATE TABLE [ETL].[JsonMetadata] (
    [ID]                           INT           IDENTITY (1, 1) NOT NULL,
    [SOURCE_TYPE]                  VARCHAR (150) NOT NULL,
    [SOURCE_SYSTEM]                VARCHAR (150) NOT NULL,
    [SOURCE_GROUPING_ID]           INT           NOT NULL,
    [IS_ENABLED]                   BIT           NOT NULL,
    [LOAD_TYPE]                    VARCHAR (100) NOT NULL,
    [BATCH_FREQUENCY]              VARCHAR (100) NOT NULL,
    [SERVERLESS_SQL_POOL_DATABASE] VARCHAR (100) NOT NULL,
    [SERVERLESS_SQL_POOL_SCHEMA]   VARCHAR (100) NOT NULL,
    [OBJECT_NAME]                  VARCHAR (500) NOT NULL,
    [OBJECT_PARAMETERS]            VARCHAR (MAX) NOT NULL,
    [ADLS_PATHS]                   VARCHAR (MAX) NOT NULL
);

