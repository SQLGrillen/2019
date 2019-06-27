/*============================================================================
	File:		0060 - Play around in our new appartment.sql

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

-- Let's get the furniture in...
IF OBJECT_ID(N'[Bed Room].[Bett]', N'U') IS NULL
	SELECT	*
	INTO	[Bed Room].[Bett]
	FROM	CustomerOrders.dbo.Employees;
	GO

IF OBJECT_ID(N'[Children Room].[Bett]', N'U') IS NULL
	SELECT	*
	INTO	[Children Room].[Bett]
	FROM	CustomerOrders.dbo.Employees;
	GO


IF OBJECT_ID(N'[Kitchen].[Kühlschrank]', N'U') IS NULL
	SELECT	*
	INTO	[Kitchen].[Kühlschrank]
	FROM	CustomerOrders.dbo.Articles;
	GO

IF OBJECT_ID(N'[Kitchen].[Herd]', N'U') IS NULL
	SELECT	*
	INTO	[Kitchen].[Herd]
	FROM	CustomerOrders.dbo.Articles;
	GO

IF OBJECT_ID(N'[Living Room].[Fernseher]', N'U') IS NULL
	SELECT	*
	INTO	[Living Room].[Fernseher]
	FROM	CustomerOrders.dbo.CustomerOrders;
	GO

IF OBJECT_ID(N'[Children Room].[Spielzeug]', N'U') IS NULL
	SELECT	*
	INTO	[Children Room].[Spielzeug]
	FROM	CustomerOrders.dbo.Addresses;
	GO

IF OBJECT_ID(N'[Bath Room].[Toilet]', N'U') IS NULL
	SELECT	*
	INTO	[Bath Room].[Toilet]
	FROM	CustomerOrders.dbo.Articles;
	GO

IF OBJECT_ID(N'[Living Room].[85 Inch FlatScreen Curved]', N'U') IS NULL
	SELECT	*
	INTO	[Living Room].[85 Inch FlatScreen Curved]
	FROM	CustomerOrders.dbo.Employees;
	GO
