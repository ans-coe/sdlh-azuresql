CREATE TABLE [ETL].[CurationMetadata] (
    [ID]                          INT           IDENTITY (1, 1) NOT NULL,
    [CURATION_GROUPING_ID]        INT           NOT NULL,
    [CURATION_GROUPING_PRIORITY]  INT           NOT NULL,
    [IS_ENABLED]                  BIT           NOT NULL,
    [TARGET_DATABASE_NAME]        VARCHAR (100) NULL,
    [TARGET_SCHEMA_NAME]          VARCHAR (100) NULL,
    [TARGET_TABLE_NAME]           VARCHAR (150) NULL,
    [EXTERNAL_DATA_SOURCE]        VARCHAR (150) NULL,
    [EXTERNAL_FILE_FORMAT]        VARCHAR (150) NULL,
    [ADLS_CONTAINER]              VARCHAR (100) NULL,
    [ADLS_LOCATION_PATH]          VARCHAR (250) NULL,
    [SQL_QUERY_OR_PROCEDURE_NAME] VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_1]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_2]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_3]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_4]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_5]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_6]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_7]              VARCHAR (MAX) NULL,
    [CUSTOM_FIELD_8]              VARCHAR (MAX) NULL
);

