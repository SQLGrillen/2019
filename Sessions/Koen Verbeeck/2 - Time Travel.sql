-- clean up
DROP TABLE IF EXISTS dbo.TimeTravelTest;

CREATE TABLE IF NOT EXISTS dbo.TimeTravelTest
(TestString STRING);

-- insert sample data
INSERT INTO dbo.TimeTravelTest(TestString)
SELECT 'Hello'
UNION ALL
SELECT 'World';

-- Wait for some time.
SELECT * FROM dbo.TimeTravelTest;

-- Insert other sample data.
INSERT INTO dbo.TimeTravelTest(TestString)
SELECT 'This is a ...'
UNION ALL
SELECT '... test';

SELECT * FROM dbo.TimeTravelTest;

-- Query time travel data
-- Using statement ID (don't forget to change it!)
SELECT *
FROM dbo.TimeTravelTest
BEFORE (STATEMENT => '018b898b-00c5-9dee-0000-0819000b64e6');

-- Using Offset
SELECT *
FROM dbo.TimeTravelTest
AT (OFFSET => -60*8);
-- offset is in seconds

-- What about TRUNCATE?
TRUNCATE TABLE dbo.TimeTravelTest;

SELECT *
FROM dbo.TimeTravelTest
BEFORE (STATEMENT => '018b8993-009b-96fe-0000-0819000b6536');

-- Insert some sample data again
INSERT INTO dbo.TimeTravelTest(TestString)
SELECT 'Hello'
UNION ALL
SELECT 'World2';

-- What about dropping the table?

DROP TABLE IF EXISTS dbo.TimeTravelTest;

SELECT *
FROM dbo.TimeTravelTest
AT (OFFSET => -60*1);

SHOW TABLES HISTORY;

UNDROP TABLE dbo.TimeTravelTest;

SELECT *
FROM dbo.TimeTravelTest;

SELECT *
FROM dbo.TimeTravelTest
BEFORE (STATEMENT => '018b8993-009b-96fe-0000-0819000b6536');


/**********
* CLONING *
**********/

CREATE OR REPLACE DATABASE STACKOVERFLOW_CLONE CLONE STACKOVERFLOW;

-- Clean-up
DROP DATABASE STACKOVERFLOW_CLONE;