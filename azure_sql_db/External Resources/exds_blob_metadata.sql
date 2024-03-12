CREATE EXTERNAL DATA SOURCE [exds_blob_metadata]
WITH (
    LOCATION = N'https://$(datalake_account_name).blob.core.windows.net/$(datalake_container_metadata_name)',
    CREDENTIAL = [cred_managed_identity],
    TYPE = BLOB_STORAGE
);