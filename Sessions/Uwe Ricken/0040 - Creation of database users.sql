/*============================================================================
	File:		0040 - Creation of database users.sql

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
USE master;
GO

-- Who is the ower of the database MyCastle?
SELECT	database_id,
		name,
		owner_sid,
		SUSER_SNAME(owner_sid)	AS	owner
FROM	sys.databases
WHERE	database_id = DB_ID(N'MyCastle');
GO

-- Let's transfer the ownership to Donald Duck
ALTER AUTHORIZATION ON DATABASE::MyCastle
TO [NB-LENOVO-I\Donald Duck];
GO

-- Let's make Daisy Duck the main tenant of the database
USE MyCastle;
GO

IF USER_ID(N'Daisy Duck') IS NULL
	CREATE USER [Daisy Duck] FROM LOGIN [Daisy Duck];
	GO

ALTER ROLE [db_owner] ADD MEMBER [Daisy Duck];
GO

-- Login von Daisy Duck
SELECT * FROM sys.server_principals
WHERE	name = N'Daisy Duck';
GO

SELECT * FROM sys.database_principals
WHERE	name = N'Daisy Duck';
GO

EXECUTE AS USER = N'Daisy Duck';
GO

ALTER AUTHORIZATION ON DATABASE::myCastle TO [Daisy Duck];
GO

REVERT;
GO

-- Kann der sa/sysadmin den Eigentümer ändern?
ALTER AUTHORIZATION ON DATABASE::myCastle TO [Daisy Duck];
GO

DROP USER [Daisy Duck];
GO

ALTER AUTHORIZATION ON DATABASE::myCastle TO [Daisy Duck];
GO

ALTER AUTHORIZATION ON DATABASE::myCastle TO [NB-LENOVO-I\Donald Duck];
GO

-- Donald verkauft die Wohnung wieder an den Eigentümer des Hauses
ALTER AUTHORIZATION ON DATABASE::myCastle TO sa;
GO

CREATE USER [NB-LENOVO-I\Donald Duck] FOR LOGIN [NB-LENOVO-I\Donald Duck];
GO

ALTER ROLE [db_owner] ADD MEMBER [NB-LENOVO-I\Donald Duck];
GO

-- Kann Donald Daisy in die Wohnung lassen?
EXECUTE AS USER = N'NB-LENOVO-I\Donald Duck';
GO

CREATE USER [Daisy Duck] FOR LOGIN [Daisy Duck];
GO

ALTER ROLE [db_owner] ADD MEMBER [Daisy Duck];
GO

REVERT;
GO

-- Kann Daisy Donald aus der Wohnung schmeissen?
EXECUTE AS USER = N'Daisy Duck';
GO

DROP USER [NB-LENOVO-I\Donald Duck];
GO

REVERT;
GO

CREATE USER [NB-LENOVO-I\Donald Duck] FOR LOGIN [NB-LENOVO-I\Donald Duck];
GO

ALTER ROLE [db_owner] ADD MEMBER [NB-LENOVO-I\Donald Duck];
GO
