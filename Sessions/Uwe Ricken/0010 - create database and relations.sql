/*============================================================================
	File:		0010 - create database and relations.sql

	Summary:	This script creates a demo database which will be used for
				the future demonstration scripts

	Date:		Mai 2016

	SQL Server Version: 2008 / 2012 / 2014 / 2016
------------------------------------------------------------------------------
	Written by Uwe Ricken, db Berater GmbH

	This script is intended only as a supplement to demos and lectures
	given by Uwe Ricken.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/
USE master;
GO

IF DB_ID(N'MyCastle') IS NOT NULL
BEGIN
	ALTER DATABASE [MyCastle] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [MyCastle];
END
GO

CREATE DATABASE myCastle;
ALTER DATABASE MyCastle SET RECOVERY SIMPLE;
ALTER AUTHORIZATION ON DATABASE::MyCastle TO sa;
GO
