/*============================================================================
	File:		0020 - Security for Microsoft SQL Server.sql

	Summary:	This script creates a demo database which will be used for
				the future demonstration scripts


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

-- what security model is Microsoft SQL Server using?
DECLARE @T TABLE (Value NVARCHAR(255), Data SQL_VARIANT);
INSERT INTO @T (Value, Data)
EXEC sys.xp_instance_regread
	N'HKEY_LOCAL_MACHINE',
	N'Software\Microsoft\MSSQLServer\MSSQLServer',
	N'LoginMode';

SELECT	*,
		CASE WHEN CAST(Data AS INT) = 1
			 THEN 'Windows Authentication'
			 ELSE 'Mixed Authentication'
		END	AS	Authentication_Mode
FROM @T;
GO

-- a sysadmin is the master of the SQL Server
SELECT	IS_SRVROLEMEMBER(N'sysadmin', SUSER_SNAME());
GO

-- Who is allowed to access my SQL Server
SELECT * FROM sys.server_principals
WHERE	type_desc != N'SERVER_ROLE'
		AND name NOT LIKE N'##%';
GO

-- Windows accounts can always be created!
-- a windows account is organized by the windows domain controller
IF SUSER_SID('NB-LENOVO-I\Donald Duck') IS NULL
	CREATE LOGIN [NB-LENOVO-I\Donald Duck] FROM WINDOWS;
	GO

-- If no windows account is available we need to create a login from
-- inside Microsoft SQL Server.
-- The Login can only be used inside of the instance of Microsoft SQL Server!
-- This technique requires "mixed authentication" for the login to the server!
IF SUSER_SID(N'Daisy Duck') IS NULL
	CREATE LOGIN [Daisy Duck]
	WITH PASSWORD = N'Pa$$w0rd',
		 CHECK_EXPIRATION = OFF,
		 CHECK_POLICY = OFF,
		 DEFAULT_DATABASE = master,
		 DEFAULT_LANGUAGE = deutsch;
GO

