/*============================================================================
	File:		0070 - grant privileges to the family.sql

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
USE myCastle;
GO

-- Can Daisy use the stove?
EXECUTE AS USER = N'Daisy Duck';
SELECT * FROM [Kitchen].[Herd];
REVERT;
GO

-- Can the kids use the stove?
EXECUTE AS USER = N'Tick';
SELECT * FROM [Kitchen].[Herd];
REVERT;
GO

-- Can they use the fridge?
EXECUTE AS USER = N'Tick';
SELECT * FROM [Kitchen].[Kühlschrank];
REVERT;
GO

-- OK - give ALL kids the permission to use the fridge!
GRANT SELECT ON [Kitchen].[Kühlschrank] TO [Children];
GO

EXECUTE AS USER = N'Tick';
SELECT * FROM [Kitchen].[Kühlschrank];
REVERT;
GO

-- Trick wants to "insert" in the [Toilet] :)
EXECUTE AS USER = N'Trick'
INSERT INTO [Bath Room].[Toilet]
(Name, Price, Currency, IsActive)
VALUES ('Trick', 0, '€', 1);

SELECT * FROM [Bath Room].[Toilet];

REVERT;
GO

-- Everybody who has access to the appartment is allowed
-- to use the toilet!
GRANT INSERT, UPDATE, DELETE ON SCHEMA::[Bath Room] TO PUBLIC;
GO

GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::[Children Room] TO [Children];

ALTER AUTHORIZATION ON SCHEMA::[Children Room] TO [Children];
GO
