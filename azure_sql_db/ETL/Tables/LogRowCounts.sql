CREATE TABLE [ETL].[LogRowCounts] (
    [ROW_COUNT_ID]            INT           IDENTITY (1, 1) NOT NULL,
    [PIPELINE_RUN_ID]         VARCHAR (500) NULL,
    [SOURCE_SYSTEM]           VARCHAR (500) NULL,
    [TARGET_SYSTEM]           VARCHAR (500) NULL,
    [TABLE_NAME]              VARCHAR (500) NULL,
    [START_TIME]              DATETIME2 (0) NULL,
    [SOURCE_SYSTEM_ROW_COUNT] INT           NULL,
    [TARGET_SYSTEM_ROW_COUNT] INT           NULL
);

