CREATE OR REPLACE WAREHOUSE "SAMPLE_DEMO"
WITH    WAREHOUSE_SIZE = 'XSMALL'
        AUTO_SUSPEND = 60
        AUTO_RESUME = TRUE
        INITIALLY_SUSPENDED = TRUE;
        
-- Set Session Environment
USE DATABASE STACKOVERFLOW;
USE SCHEMA dbo;
USE WAREHOUSE SAMPLE_DEMO;

ALTER SESSION SET USE_CACHED_RESULT = FALSE; -- disable caching

-- Test Query
-- How Unsung am I?
-- Zero and non-zero accepted count. Self-accepted answers do not count.

SELECT
     COUNT(a.PostID)                                                                    AS AcceptedAnswers
    ,SUM(CASE WHEN a.PostScore = 0 THEN 0 ELSE 1 END)                                   AS ScoredAnswers
    ,SUM(CASE WHEN a.PostScore = 0 THEN 1 ELSE 0 END)                                   AS UnscoredAnswers
    ,SUM(CASE WHEN a.PostScore = 0 THEN 1 ELSE 0 END) * 1000 / COUNT(a.PostID) / 10.0   AS PercentageUnscored
FROM dbo.Posts q
JOIN dbo.Posts a ON a.PostID = q.AcceptedAnswerId
WHERE 1 = 1
  AND a.PostCommunityOwnedDate is null
  AND a.PostOwnerUserId = 26837
  AND q.PostOwnerUserId != 26837
  AND a.PostTypeId = 2 -- answer
;
/*
SELECT *
FROM dbo.Users
WHERE DISPLAYNAME LIKE '%Ozar%' -- 26837
*/

-- Make query run faster
ALTER WAREHOUSE "SAMPLE_DEMO"
SET WAREHOUSE_SIZE = 'LARGE';

-- Clean-up
DROP WAREHOUSE IF EXISTS "SAMPLE_DEMO";