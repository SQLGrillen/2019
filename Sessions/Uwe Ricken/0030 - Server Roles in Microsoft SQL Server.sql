/*============================================================================
	File:		0030 - Server Roles in Microsoft SQL Server.sql

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

-- what server roles do we have in Microsoft SQL Server
SELECT * FROM sys.server_principals WHERE type = 'R';
GO

-- Let's give Donald Duck the same privileges as the owner of the server
ALTER SERVER ROLE sysadmin ADD MEMBER [NB-LENOVO-I\Donald Duck];
GO

-- what privileges does Donald have now?
SELECT	R.name	AS	server_role,
		U.name	AS	user_name
FROM	sys.server_principals AS R
		INNER JOIN sys.server_role_members AS RM ON (R.principal_id = RM.role_principal_id)
		INNER JOIN sys.server_principals AS U ON (RM.member_principal_id = U.principal_id)
WHERE	U.name = N'NB-LENOVO-I\Donald Duck';
GO

-- now let's make Daisy a security admin to hand over the keys
-- to the server
ALTER SERVER ROLE securityadmin ADD MEMBER [Daisy Duck];
GO

-- what privileges does Daisy have now?
SELECT	R.name	AS	server_role,
		U.name	AS	user_name
FROM	sys.server_principals AS R
		INNER JOIN sys.server_role_members AS RM ON (R.principal_id = RM.role_principal_id)
		INNER JOIN sys.server_principals AS U ON (RM.member_principal_id = U.principal_id)
WHERE	U.name = N'Daisy Duck';
GO

-- Let's check the possible privileges of Daisy...
-- can she make her own account an owner of the server?
EXECUTE AS LOGIN = N'Daisy Duck';
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [Daisy Duck];
EXEC sys.sp_addsrvrolemember
	@loginame = N'Daisy Duck',
    @rolename = N'sysadmin';
GO

-- Can Daisy hand over a new key to the server?
CREATE LOGIN [NB-LENOVO-I\Tick Duck] FROM WINDOWS;
GO

-- Can Daisy make Tick Duck an owner of the server?
ALTER SERVER ROLE processadmin ADD MEMBER [NB-LENOVO-I\Tick Duck];
EXEC sys.sp_addsrvrolemember
	@loginame = N'NB-LENOVO-I\Tick Duck',
    @rolename = N'sysadmin';
GO

REVERT;
GO
