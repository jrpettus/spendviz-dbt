USE ROLE procure_role;
USE DATABASE PROCURE_AGENT;
USE SCHEMA PUBLIC;
USE WAREHOUSE PROCURE_WAREHOUSE;


-- Create a view that will be used for capturing contract metadata
CREATE OR REPLACE VIEW CONTRACTS_META AS (
    SELECT 
        DISTINCT METADATA$FILENAME AS METADATA_FILENAME, 
        METADATA$FILE_CONTENT_KEY AS METADATA_CONTENT_KEY, 
        METADATA$FILE_LAST_MODIFIED AS METADATA_LAST_MODIFIED, 
        REPLACE(METADATA$FILENAME,'contracts/','') as FILE_NAME,
        TRIM(REPLACE(SPLIT_PART(METADATA$FILENAME,'__',2),'.txt','')) AS SUPPLIER_NAME 
    FROM @files/contracts
);


-- create user defined funtion that will hit the retrieval service /retrieve
CREATE OR REPLACE FUNCTION load_documents(input string )
RETURNS STRING
SERVICE=RETRIEVAL_APP      // Container service
ENDPOINT='retrieval-app'   // Endpoint in the container
MAX_BATCH_ROWS=32                                // limit batch size
AS '/load'; 

-- create user defined funtion that will hit the retrieval service /retrieve
CREATE OR REPLACE FUNCTION retrieve_context(input string )
RETURNS STRING
SERVICE=RETRIEVAL_APP      // Container service
ENDPOINT='retrieval-app'   // Endpoint in the container
MAX_BATCH_ROWS=32                                // limit batch size
AS '/retrieve'; 


-- test the load 
SELECT load_documents(supplier) AS load_status
FROM (
    VALUES ('Marketing & Advertising__ BrandBoosters.txt') ,
           ('Office Supplies__ Desk Dynasty.txt')
     ) AS v1 (supplier);

-- test the retrieval service
SELECT retrieve_context(question) AS retrieved_context
FROM (
    VALUES ('payment term discounts | SmartSparks') ,
           ('warranty | Refreshing Reprieve')
     ) AS v1 (question);

SELECT *
FROM PROCURE_AGENT.DBT_RPETTUS.INT_CONTRACTS_LOAD_INTO_VECTORDB;

SELECT *
FROM PROCURE_AGENT.DBT_RPETTUS.INT_CONTRACTS_EXTRACT_TERMS;

