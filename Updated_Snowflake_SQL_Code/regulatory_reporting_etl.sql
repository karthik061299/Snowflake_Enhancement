====================================================================
Author: AVA
Date: 
Description: Enhanced ETL procedure to integrate BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT with conditional logic for REGION and LAST_AUDIT_DATE.
Updated by: AVA
Updated on: 
Description: This procedure creates AML_CUSTOMER_TRANSACTIONS and an enhanced BRANCH_SUMMARY_REPORT that joins with BRANCH_OPERATIONAL_DETAILS to include branch region and last audit date for active branches.
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
    -- Step 2: Create BRANCH_SUMMARY_REPORT (Deprecated logic below)
    -------------------------------------------------------------------
    /*
    CREATE OR REPLACE TABLE BRANCH_SUMMARY_REPORT AS
    SELECT 
        b.BRANCH_ID,
        b.BRANCH_NAME,
        COUNT(*) AS TOTAL_TRANSACTIONS,
        SUM(t.AMOUNT) AS TOTAL_AMOUNT
    FROM TRANSACTION t
    INNER JOIN ACCOUNT a ON t.ACCOUNT_ID = a.ACCOUNT_ID
    INNER JOIN BRANCH b ON a.BRANCH_ID = b.BRANCH_ID
    GROUP BY b.BRANCH_ID, b.BRANCH_NAME;
    -- [DEPRECATED] This logic is replaced by an enhanced version that joins with BRANCH_OPERATIONAL_DETAILS.
    */

    -------------------------------------------------------------------
    -- [ADDED] Step 2: Enhanced BRANCH_SUMMARY_REPORT with operational details
    -------------------------------------------------------------------
    CREATE OR REPLACE TABLE BRANCH_SUMMARY_REPORT AS
    SELECT 
        b.BRANCH_ID,
        b.BRANCH_NAME,
        COUNT(*) AS TOTAL_TRANSACTIONS,
        SUM(t.AMOUNT) AS TOTAL_AMOUNT,
        /* [ADDED] REGION and LAST_AUDIT_DATE populated only for active branches */
        CASE WHEN bod.IS_ACTIVE = 'Y' THEN bod.REGION ELSE NULL END AS REGION, -- [ADDED]
        CASE WHEN bod.IS_ACTIVE = 'Y' THEN bod.LAST_AUDIT_DATE ELSE NULL END AS LAST_AUDIT_DATE -- [ADDED]
    FROM TRANSACTION t
    INNER JOIN ACCOUNT a ON t.ACCOUNT_ID = a.ACCOUNT_ID
    INNER JOIN BRANCH b ON a.BRANCH_ID = b.BRANCH_ID
    LEFT JOIN BRANCH_OPERATIONAL_DETAILS bod ON b.BRANCH_ID = bod.BRANCH_ID -- [ADDED]
    GROUP BY b.BRANCH_ID, b.BRANCH_NAME, bod.REGION, bod.LAST_AUDIT_DATE, bod.IS_ACTIVE; -- [MODIFIED]

    /*
    [ADDED] The above logic ensures REGION and LAST_AUDIT_DATE are only populated for active branches (IS_ACTIVE = 'Y').
    For branches without operational details, these columns will be NULL.
    */

    -------------------------------------------------------------------
    -- Final Message
    -------------------------------------------------------------------
    RETURN 'ETL job completed successfully: AML_CUSTOMER_TRANSACTIONS and enhanced BRANCH_SUMMARY_REPORT created/updated'; -- [MODIFIED]
END;
$$;

/*
====================================================================
Cost Estimation and Justification
====================================================================
Input Tokens: ~2,800
Output Tokens: ~1,200
Model: GPT-4
Input Cost: $0.084
Output Cost: $0.072
Total Cost: $0.156
See Technical_Specification.txt for detailed calculation.
====================================================================
*/
