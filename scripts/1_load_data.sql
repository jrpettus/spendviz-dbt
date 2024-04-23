GRANT ROLE PROCURE_ROLE TO USER <your_user>;
GRANT CREATE STAGE ON SCHEMA PROCURE_AGENT.PUBLIC TO ROLE PROCURE_ROLE;

USE DATABASE PROCURE_AGENT;

CREATE SCHEMA PROCUREMENT_USA;
CREATE SCHEMA PROCUREMENT_FRANCE;

GRANT ALL PRIVILEGES ON SCHEMA procure_agent.procurement_usa TO PROCURE_ROLE;
GRANT ALL PRIVILEGES ON SCHEMA procure_agent.procurement_france TO PROCURE_ROLE;

-- CREATE TABLES
USE WAREHOUSE PROCURE_WAREHOUSE;

CREATE STAGE procurement_usa.procure_stage
  FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY = '"', SKIP_HEADER = 1);

CREATE STAGE procurement_france.procure_stage
  FILE_FORMAT = (TYPE = 'CSV', FIELD_OPTIONALLY_ENCLOSED_BY = '"', SKIP_HEADER = 1);

CREATE TABLE procure_agent.procurement_usa.invoice_headers (
    invoice_number VARCHAR,
    order_number VARCHAR,
    order_date DATE,
    supplier_id VARCHAR,
    location VARCHAR,
    supplier_invoice VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);


CREATE TABLE procure_agent.procurement_france.invoice_headers (
    invoice_number VARCHAR,
    order_number VARCHAR,
    order_date DATE,
    supplier_id VARCHAR,
    location VARCHAR,
    supplier_invoice VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_usa.invoice_lines (
    invoice_number VARCHAR,
    order_line_number INTEGER,
    order_number VARCHAR,
    supplier_part VARCHAR,
    description VARCHAR,
    price FLOAT,
    quantity INTEGER,
    amount FLOAT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_france.invoice_lines (
    invoice_number VARCHAR,
    order_line_number INTEGER,
    order_number VARCHAR,
    supplier_part VARCHAR,
    description VARCHAR,
    price FLOAT,
    quantity INTEGER,
    amount FLOAT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_usa.items (
    item_number VARCHAR,
    price FLOAT,
    description VARCHAR(255),
    supplier_part VARCHAR,
    supplier_id VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_france.items (
    item_number VARCHAR,
    price FLOAT,
    description VARCHAR(255),
    supplier_part VARCHAR,
    supplier_id VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_usa.order_headers (
    order_number VARCHAR,
    order_date DATE,
    supplier_id VARCHAR,
    location VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_france.order_headers (
    order_number VARCHAR,
    order_date DATE,
    supplier_id VARCHAR,
    location VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_usa.order_lines (
    order_number VARCHAR,
    order_line_number VARCHAR,
    item_number VARCHAR,
    supplier_part VARCHAR,
    description VARCHAR,
    price FLOAT,
    quantity INTEGER,
    amount FLOAT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE procure_agent.procurement_france.order_lines (
    order_number VARCHAR,
    order_line_number VARCHAR,
    item_number VARCHAR,
    supplier_part VARCHAR,
    description VARCHAR,
    price FLOAT,
    quantity INTEGER,
    amount FLOAT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE procure_agent.procurement_usa.suppliers (
    supplier_id VARCHAR,
    supplier VARCHAR,
    primary_category VARCHAR,
    country VARCHAR,
    address VARCHAR,
    phone_number VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE  procure_agent.procurement_france.suppliers (
    supplier_id VARCHAR,
    supplier VARCHAR,
    primary_category VARCHAR,
    country VARCHAR,
    address VARCHAR,
    phone_number VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE TABLE  procure_agent.procurement_usa.locations (
    location_id VARCHAR,
    name VARCHAR,
    address VARCHAR,
    location VARCHAR,
    country VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE procure_agent.procurement_usa.contracts (
    supplier_id VARCHAR,
    supplier VARCHAR,
    contract_name VARCHAR,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- RUN THESE FROM YOUR TERMINAL VIA SNOWSQL
-- PUT file:////procure-agent/data/usa/invoice_headers.csv @procurement_usa.procure_stage;
-- PUT file://///procure-agent/data/france/invoice_headers.csv @procurement_france.procure_stage;
-- etc for all the files...


-- Load data for USA invoice headers
COPY INTO procure_agent.procurement_usa.invoice_headers
(invoice_number, order_number, order_date, supplier_id, location, supplier_invoice)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_usa.procure_stage');
PATTERN = '.*invoice_headers.*';

SELECT *
FROM procure_agent.procurement_usa.invoice_headers
LIMIT 10;

-- Load data for FRANCE
COPY INTO procure_agent.procurement_france.invoice_headers
(invoice_number, order_number, order_date, supplier_id, location, supplier_invoice)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*invoice_headers.*';

COPY INTO procure_agent.procurement_usa.invoice_lines
(invoice_number,order_line_number,order_number,supplier_part,description,price,quantity,amount)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*invoice_lines.*';

COPY INTO procure_agent.procurement_france.invoice_lines
(invoice_number,order_line_number,order_number,supplier_part,description,price,quantity,amount)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*invoice_lines.*';

-- items
COPY INTO procure_agent.procurement_usa.items
(item_number,price,description,supplier_part,supplier_id)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*items.*';

COPY INTO procure_agent.procurement_france.items
(item_number,price,description,supplier_part,supplier_id)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*items.*';

-- order headers
COPY INTO procure_agent.procurement_usa.order_headers
(order_number,order_date,supplier_id,location)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*order_headers.*';

COPY INTO procure_agent.procurement_france.order_headers
(order_number,order_date,supplier_id,location)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*order_headers.*';


-- order lines
COPY INTO procure_agent.procurement_usa.order_lines
( order_number,order_line_number,
    item_number,
    supplier_part,
    description,
    price,
    quantity,
    amount)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*order_lines.*';

COPY INTO procure_agent.procurement_france.order_lines
( order_number,order_line_number,
    item_number,
    supplier_part,
    description,
    price,
    quantity,
    amount)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*order_lines.*';

-- order headers
COPY INTO procure_agent.procurement_usa.suppliers
(supplier_id,supplier,primary_category,country,address,phone_number)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*suppliers.*';

COPY INTO procure_agent.procurement_france.suppliers
(supplier_id,supplier,primary_category,country,address,phone_number)
FROM @procurement_france.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*suppliers.*';

COPY INTO procure_agent.procurement_usa.locations
(location_id, name ,address, location, country)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*locations.*';

COPY INTO procure_agent.procurement_usa.contracts
(supplier_id, supplier ,contract_name)
FROM @procurement_usa.procure_stage
--FILE_FORMAT = (FORMAT_NAME = 'procurement_france.procure_stage')
PATTERN = '.*contracts.*';

-- now change the loaded_at to the invoice date for testing purposes
UPDATE procure_agent.procurement_usa.invoice_headers
SET loaded_at = DATEADD(day, 1, order_date);

-- now change the loaded_at to the invoice date for testing purposes
UPDATE procure_agent.procurement_france.invoice_headers
SET loaded_at = DATEADD(day, 1, order_date);

















-- OTHER RANDOM COMMANDS
;
/-
use role sysadmin;
grant all PRIVILEGES on stage FILES to PROCURE_ROLE;


grant all PRIVILEGES on view contracts_meta to accountadmin;



---- used for giving all access to procure role -------
USE ROLE ACCOUNTADMIN;

--DROP SCHEMA IF EXISTS procure_agent.dbt_rpettus CASCADE;

GRANT USAGE ON DATABASE procure_agent TO ROLE PROCURE_ROLE;
GRANT USAGE ON ALL SCHEMAS IN DATABASE procure_agent TO ROLE PROCURE_ROLE;

GRANT CREATE TABLE ON SCHEMA procure_agent.dbt_rpettus TO ROLE PROCURE_ROLE;
GRANT CREATE VIEW ON SCHEMA procure_agent.dbt_rpettus TO ROLE PROCURE_ROLE;

GRANT CREATE TABLE ON SCHEMA procure_agent.production TO ROLE PROCURE_ROLE;
GRANT CREATE VIEW ON SCHEMA procure_agent.production TO ROLE PROCURE_ROLE;

-- To grant permissions on all existing tables
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES ON ALL TABLES IN SCHEMA procure_agent.dbt_rpettus TO ROLE PROCURE_ROLE;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES ON ALL TABLES IN SCHEMA procure_agent.production TO ROLE PROCURE_ROLE;

-- To grant permissions on all existing views
GRANT SELECT ON ALL VIEWS IN SCHEMA procure_agent.dbt_rpettus TO ROLE PROCURE_ROLE;
GRANT SELECT ON ALL VIEWS IN SCHEMA procure_agent.production TO ROLE PROCURE_ROLE;

GRANT USAGE ON FUTURE SCHEMAS IN DATABASE procure_agent TO ROLE PROCURE_ROLE;
GRANT CREATE TABLE ON FUTURE SCHEMAS IN DATABASE procure_agent TO ROLE PROCURE_ROLE;
GRANT CREATE VIEW ON FUTURE SCHEMAS IN DATABASE procure_agent TO ROLE PROCURE_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES ON FUTURE TABLES IN DATABASE procure_agent TO ROLE PROCURE_ROLE;
GRANT SELECT ON FUTURE VIEWS IN DATABASE procure_agent TO ROLE PROCURE_ROLE;

GRANT DELETE ON ALL VIEWS IN SCHEMA procure_agent.dbt_rpettus TO ROLE PROCURE_ROLE;

-- 
'''
;

USE ROLE SECURITYADMIN;  -- or another high-level role that can manage privileges

GRANT USAGE ON SCHEMA procure_agent.dbt_rpettus TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA procure_agent.dbt_rpettus TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA procure_agent.dbt_rpettus TO ROLE ACCOUNTADMIN;

GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA procure_agent.dbt_rpettus TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA procure_agent.dbt_rpettus TO ROLE ACCOUNTADMIN;
-- 
'''



