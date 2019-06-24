USE DATABASE TEST;
USE SCHEMA dbo;

/********** Finding Previous Non-null Value **********/

CREATE OR REPLACE TABLE dbo.TestWindow
(ID INT IDENTITY(1,1) NOT NULL
,ColA INT NULL);

INSERT INTO dbo.TestWindow(ColA)
 VALUES  (5)
        ,(NULL)
        ,(-10)
        ,(20)
        ,(NULL)
        ,(NULL)
        ,(NULL)
        ,(NULL)
        ,(25)
        ,(30);

SELECT *
FROM dbo.TestWindow;

SELECT
     ID
    ,ColA
    ,LAG(ColA) OVER (ORDER BY ID) previousnull
    ,LAG(ColA) IGNORE NULLS OVER (ORDER BY ID) previousnonnull
FROM dbo.TestWindow;

/********** GET_DDL **********/

SELECT GET_DDL('SCHEMA','STACKOVERFLOW.dbo');

/********** Query History **********/

USE ROLE accountadmin; -- default only role that has access
USE SCHEMA snowflake.account_usage;
SELECT *
FROM snowflake.account_usage.QUERY_HISTORY;