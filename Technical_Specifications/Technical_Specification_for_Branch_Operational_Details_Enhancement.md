# =============================================
Author: Ascendion AVA+
Date: 
Description: Technical specification for integrating BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT
# =============================================

# Technical Specification for Branch Operational Details Enhancement

## Introduction
This document outlines the technical specification for enhancing the BRANCH_SUMMARY_REPORT logic to integrate the newly introduced BRANCH_OPERATIONAL_DETAILS source table. The enhancement aims to improve compliance and audit readiness by incorporating branch-level operational metadata (region, manager name, audit date, active status) into the reporting layer.

## Code Changes
### Impacted Areas
- **Snowflake Stored Procedure Logic:**
  - Update the stored procedure responsible for populating BRANCH_SUMMARY_REPORT to join with BRANCH_OPERATIONAL_DETAILS using BRANCH_ID.
  - Add logic to conditionally populate REGION and LAST_AUDIT_DATE columns based on IS_ACTIVE = 'Y'.
  - Ensure backward compatibility for records without operational details.

### Logic Changes
- **Join Logic:**
  - Join BRANCH_SUMMARY_REPORT with BRANCH_OPERATIONAL_DETAILS on BRANCH_ID.
- **Conditional Population:**
  - If BRANCH_OPERATIONAL_DETAILS.IS_ACTIVE = 'Y', populate REGION and LAST_AUDIT_DATE; else, leave as NULL or default.
- **Pseudocode Example:**
  ```sql
  UPDATE BRANCH_SUMMARY_REPORT BSR
  SET
    REGION = BOD.REGION,
    LAST_AUDIT_DATE = BOD.LAST_AUDIT_DATE
  FROM BRANCH_OPERATIONAL_DETAILS BOD
  WHERE BSR.BRANCH_ID = BOD.BRANCH_ID
    AND BOD.IS_ACTIVE = 'Y';
  ```

## Data Model Updates
### Source Data Model
- **New Table:** BRANCH_OPERATIONAL_DETAILS
  - Columns: BRANCH_ID (PK), REGION, MANAGER_NAME, LAST_AUDIT_DATE, IS_ACTIVE

### Target Data Model
- **BRANCH_SUMMARY_REPORT**
  - Add columns: REGION (STRING), LAST_AUDIT_DATE (DATE)

### Diagram
```
BRANCH_OPERATIONAL_DETAILS
+-----------+--------+--------------+------------------+----------+
| BRANCH_ID | REGION | MANAGER_NAME | LAST_AUDIT_DATE  | IS_ACTIVE|
+-----------+--------+--------------+------------------+----------+

BRANCH_SUMMARY_REPORT
+-----------+--------------+-------------------+--------------+------------------+
| BRANCH_ID | BRANCH_NAME  | TOTAL_TRANSACTIONS| TOTAL_AMOUNT | REGION           | LAST_AUDIT_DATE |
+-----------+--------------+-------------------+--------------+------------------+
```

## Source-to-Target Mapping
| Source Table                | Source Column         | Target Table           | Target Column      | Transformation Rule                         |
|----------------------------|----------------------|------------------------|--------------------|----------------------------------------------|
| BRANCH_OPERATIONAL_DETAILS | REGION               | BRANCH_SUMMARY_REPORT  | REGION             | Populate if IS_ACTIVE = 'Y'                  |
| BRANCH_OPERATIONAL_DETAILS | LAST_AUDIT_DATE      | BRANCH_SUMMARY_REPORT  | LAST_AUDIT_DATE    | Populate if IS_ACTIVE = 'Y'                  |

## Assumptions and Constraints
- Only active branches (IS_ACTIVE = 'Y') will have REGION and LAST_AUDIT_DATE populated in BRANCH_SUMMARY_REPORT.
- Backward compatibility is maintained for branches without operational details.
- Full reload of BRANCH_SUMMARY_REPORT is required upon deployment.
- Data governance and security standards must be adhered to during ETL changes.

## References
- JIRA Story: Extend BRANCH_SUMMARY_REPORT Logic to Integrate New Source Table
- Confluence Documentation: ETL Change - Integration of BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT
- Source DDL: BRANCH_OPERATIONAL_DETAILS
- Target DDL: BRANCH_SUMMARY_REPORT

---

## Cost Estimation and Justification

### Token Usage
- **Input Tokens:**
  - Prompt + SQL/DDL/Context files: Estimated 2,800 tokens
- **Output Tokens:**
  - Markdown specification + explanation: Estimated 1,200 tokens

### Model Used
- Automatically detected: GPT-4

### Pricing (as of current environment)
- **GPT-4 Input:** $0.03 per 1,000 tokens
- **GPT-4 Output:** $0.06 per 1,000 tokens

### Cost Calculation
- **Input Cost:** 2,800 tokens * $0.03 / 1,000 = $0.084
- **Output Cost:** 1,200 tokens * $0.06 / 1,000 = $0.072
- **Total Cost:** $0.084 + $0.072 = $0.156

#### Formula:
- Input Cost = input_tokens * input_cost_per_token
- Output Cost = output_tokens * output_cost_per_token
- Total Cost = Input Cost + Output Cost

#### Breakdown:
| Type   | Tokens | Rate per 1k | Cost   |
|--------|--------|-------------|--------|
| Input  | 2,800  | $0.03       | $0.084 |
| Output | 1,200  | $0.06       | $0.072 |
| **Total** |      |             | $0.156 |
