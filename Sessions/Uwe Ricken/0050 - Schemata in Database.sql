/*============================================================================
	File:		0050 - Schemata in Database.sql

	Summary:	This script demonstrates the usage of server roles

	Date:		April 2017

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
USE MyCastle;
GO

-- Daisy was pregnant and has given birth to 3 kids
IF USER_ID(N'Tick') IS NULL
	CREATE USER [Tick] WITHOUT LOGIN;
	GO

IF USER_ID(N'Trick') IS NULL
	CREATE USER [Trick] WITHOUT LOGIN;
	GO

IF USER_ID(N'Track') IS NULL
	CREATE USER [Track] WITHOUT LOGIN;
	GO

-- All kids belong to the group of "children"
IF USER_ID(N'Children') IS NULL
	CREATE ROLE [Children] AUTHORIZATION dbo;
	GO

SELECT * FROM sys.database_principals;
GO

ALTER ROLE [Children] ADD MEMBER [Tick];
ALTER ROLE [Children] ADD MEMBER [Trick];
ALTER ROLE [Children] ADD MEMBER [Track];
GO

-- Donald and Daisy belong to the group "parents"
IF USER_ID(N'Parents') IS NULL
	CREATE ROLE [Parents] AUTHORIZATION dbo;
	GO

ALTER ROLE [Parents] ADD MEMBER [Daisy Duck];

ALTER ROLE [Parents] ADD MEMBER [NB-LENOVO-I\Donald Duck];
GO

-- Create the living room in the appartment
IF SCHEMA_ID(N'Living Room') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [Living Room] AUTHORIZATION dbo;';
	GO

-- Create the kitchen in the appartment
IF SCHEMA_ID(N'Kitchen') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [Kitchen] AUTHORIZATION dbo;';
	GO

-- Create the bed room in the appartment
IF SCHEMA_ID(N'Bed room') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [Bed Room] AUTHORIZATION dbo;';
	GO

-- Create the bath room in the appartment
IF SCHEMA_ID(N'Bath Room') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [Bath Room] AUTHORIZATION dbo;';
	GO

-- Create the chidren's room in the appartment
IF SCHEMA_ID(N'Children Room') IS NULL
	EXEC sp_executesql N'CREATE SCHEMA [Children Room] AUTHORIZATION dbo;';
	GO