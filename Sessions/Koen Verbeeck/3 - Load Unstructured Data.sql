-- Show Stage First.

USE SCHEMA STAGE;

-- Create Stage Table to hold XML
CREATE OR REPLACE TABLE STAGE.Demo_PostLinks_XML(src_xml VARIANT);

-- Strip root element, so individual elements are loaded as separate rows.
-- Otherwise the XML is too big (16MB limit per row)
-- 50 seconds on XS --> 5,292,624
COPY INTO STAGE.Demo_PostLinks_XML
FROM @AZURESTAGINGDEV/PostLinks.xml.gz
    FILE_FORMAT=(TYPE=XML STRIP_OUTER_ELEMENT = TRUE)
    ON_ERROR='CONTINUE';
    
SELECT COUNT(1) FROM STAGE.Demo_PostLinks_XML;

SELECT *
FROM STAGE.Demo_PostLinks_XML
LIMIT 10;

-- Create Staging Table for relational data:
CREATE OR REPLACE TABLE STAGE.Demo_PostLinks
(
     CreationDate TIMESTAMP_NTZ
    ,Id INTEGER
    ,LinkTypeID INTEGER
    ,PostId INTEGER
    ,RelatedPostId INTEGER
);

INSERT INTO STAGE.Demo_PostLinks -- 3.68 seconds on XS
SELECT
     TO_TIMESTAMP_NTZ(src_XML:"@CreationDate") AS CreationDate
    ,src_XML:"@Id"::INTEGER AS Id
    ,src_XML:"@LinkTypeId"::INTEGER AS LinkTypeId -- case sensitive!
    ,src_XML:"@PostId"::INTEGER AS PostId
    ,src_XML:"@RelatedPostId"::INTEGER AS RelatedPostId
FROM STAGE.Demo_PostLinks_XML;