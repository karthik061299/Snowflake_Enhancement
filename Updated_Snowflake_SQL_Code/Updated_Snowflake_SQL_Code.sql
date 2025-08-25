====================================================================
Author: Ascendion AVA+
Date: 
Description: ETL procedure for regulatory reporting, enhanced to integrate branch operational details into BRANCH_SUMMARY_REPORT for compliance and audit readiness.
Updated by: AVA
Updated on: 
Description: Adds REGION and LAST_AUDIT_DATE columns to BRANCH_SUMMARY_REPORT, joins with BRANCH_OPERATIONAL_DETAILS, and conditionally populates based on IS_ACTIVE status.
====================================================================

CREATE OR REPLACE PROCEDURE RUN_ETL_JOB()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    -------------------------------------------------------------------
    -- Step 1: Create AML_CUSTOMER_TRANSACTIONS
    -------------------------------------------------------------------
    CREATE OR REPLACE TABLE AML_CUSTOMER_TRANSACTIONS AS
    SELECT 
        c.CUSTOMER_ID,
        c.NAME,
        a.ACCOUNT_ID,
        t.TRANSACTION_ID,
        t.AMOUNT,
        t.TRANSACTION_TYPE,
        t.TRANSACTION_DATE
    FROM CUSTOMER c
    INNER JOIN ACCOUNT a ON c.CUSTOMER_ID = a.CUSTOMER_ID
    INNER JOIN TRANSACTION t ON a.ACCOUNT_ID = t.ACCOUNT_ID;

    -------------------------------------------------------------------
    -- Step 2: Create BRANCH_SUMMARY_REPORT (Enhanced for operational details)
    -------------------------------------------------------------------
    -- [MODIFIED] Added REGION and LAST_AUDIT_DATE columns, joined with BRANCH_OPERATIONAL_DETAILS
    CREATE OR REPLACE TABLE BRANCH_SUMMARY_REPORT AS
    SELECT 
        b.BRANCH_ID,
        b.BRANCH_NAME,
        COUNT(*) AS TOTAL_TRANSACTIONS,
        SUM(t.AMOUNT) AS TOTAL_AMOUNT,
        -- [ADDED] Populate REGION only for active branches
        CASE WHEN bod.IS_ACTIVE = 'Y' THEN bod.REGION ELSE NULL END AS REGION,
        -- [ADDED] Populate LAST_AUDIT_DATE only for active branches
        CASE WHEN bod.IS_ACTIVE = 'Y' THEN bod.LAST_AUDIT_DATE ELSE NULL END AS LAST_AUDIT_DATE
    FROM TRANSACTION t
    INNER JOIN ACCOUNT a ON t.ACCOUNT_ID = a.ACCOUNT_ID
    INNER JOIN BRANCH b ON a.BRANCH_ID = b.BRANCH_ID
    LEFT JOIN BRANCH_OPERATIONAL_DETAILS bod ON b.BRANCH_ID = bod.BRANCH_ID
    GROUP BY b.BRANCH_ID, b.BRANCH_NAME, bod.REGION, bod.LAST_AUDIT_DATE, bod.IS_ACTIVE;

    -------------------------------------------------------------------
    -- [DEPRECATED] Original BRANCH_SUMMARY_REPORT logic (commented out for traceability)
    -- CREATE OR REPLACE TABLE BRANCH_SUMMARY_REPORT AS
    -- SELECT 
    --     b.BRANCH_ID,
    --     b.BRANCH_NAME,
    --     COUNT(*) AS TOTAL_TRANSACTIONS,
    --     SUM(t.AMOUNT) AS TOTAL_AMOUNT
    -- FROM TRANSACTION t
    -- INNER JOIN ACCOUNT a ON t.ACCOUNT_ID = a.ACCOUNT_ID
    -- INNER JOIN BRANCH b ON a.BRANCH_ID = b.BRANCH_ID
    -- GROUP BY b.BRANCH_ID, b.BRANCH_NAME;
    -- [DEPRECATED END]

    -------------------------------------------------------------------
    -- Final Message
    -------------------------------------------------------------------
    RETURN 'ETL job completed successfully: AML_CUSTOMER_TRANSACTIONS and BRANCH_SUMMARY_REPORT created/updated with operational details.';
END;
$$;

-- [ADDED] DDL for BRANCH_OPERATIONAL_DETAILS (for reference)
CREATE TABLE IF NOT EXISTS BRANCH_OPERATIONAL_DETAILS (
    BRANCH_ID INT,
    REGION VARCHAR2(50),
    MANAGER_NAME VARCHAR2(100),
    LAST_AUDIT_DATE DATE,
    IS_ACTIVE CHAR(1),
    PRIMARY KEY (BRANCH_ID)
);

-- [MODIFIED] DDL for BRANCH_SUMMARY_REPORT (now includes REGION and LAST_AUDIT_DATE)
CREATE TABLE IF NOT EXISTS BRANCH_SUMMARY_REPORT (
    BRANCH_ID INT,
    BRANCH_NAME STRING,
    TOTAL_TRANSACTIONS BIGINT,
    TOTAL_AMOUNT DOUBLE,
    REGION STRING,
    LAST_AUDIT_DATE DATE
);

-- [INLINE DOCUMENTATION]
-- The procedure now integrates branch operational metadata for enhanced compliance and audit readiness.
-- REGION and LAST_AUDIT_DATE are only populated for branches marked as active in BRANCH_OPERATIONAL_DETAILS.
-- Deprecated logic is commented for traceability and rollback if needed.
-- All changes are annotated for audit and developer reference.
