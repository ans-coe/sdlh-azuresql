﻿CREATE MASTER KEY
GO

CREATE DATABASE SCOPED CREDENTIAL [cred_managed_identity]
WITH IDENTITY = 'MANAGED IDENTITY';
GO