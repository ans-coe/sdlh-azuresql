﻿CREATE TABLE [ETL].[SourceIncrementalLoad] (
    [INCREMENTAL_LOAD_ID]      INT           IDENTITY (1, 1) NOT NULL,
    [OBJECT_NAME]              VARCHAR (500) NOT NULL,
    [SOURCE_SYSTEM]            VARCHAR (250) NOT NULL,
    [DATABASE_NAME]            VARCHAR (250) NOT NULL,
    [SCHEMA_NAME]              VARCHAR (100) NULL,
    [TABLE_NAME]               VARCHAR (250) NOT NULL,
    [LOAD_TYPE]                VARCHAR (100) NOT NULL,
    [WATERMARK_FIELD]          VARCHAR (100) NULL,
    [WATERMARK_VALUE]          VARCHAR (100) NULL,
    [SYS_CHANGE_VERSION_VALUE] BIGINT        NULL,
    PRIMARY KEY CLUSTERED ([OBJECT_NAME] ASC)
);