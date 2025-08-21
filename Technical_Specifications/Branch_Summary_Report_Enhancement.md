=============================================
Author: Ascendion AVA+
Date: 
Description: Technical specification for integrating BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT.
=============================================

# Technical Specification for Branch Summary Report Enhancement

## Introduction
This document outlines the technical specifications for integrating the new Snowflake source table `BRANCH_OPERATIONAL_DETAILS` into the existing `BRANCH_SUMMARY_REPORT` table. The enhancement aims to improve compliance and audit readiness by incorporating branch-level operational metadata.

## Code Changes
### Impacted Areas
- **Stored Procedure Logic**: Enhance the existing stored procedure to join the `BRANCH_OPERATIONAL_DETAILS` table using `BRANCH_ID`.
- **Conditional Logic**: Populate `REGION` and `LAST_AUDIT_DATE` columns based on the condition `IS_ACTIVE = 'Y'`.

### Pseudocode
```sql
-- Join Logic
SELECT
    BR.BRANCH_ID,
    BR.BRANCH_NAME,
    SUM(T.AMOUNT) AS TOTAL_AMOUNT,
    COUNT(T.TRANSACTION_ID) AS TOTAL_TRANSACTIONS,
    BOD.REGION,
    BOD.LAST_AUDIT_DATE
FROM
    BRANCH BR
LEFT JOIN TRANSACTION T ON BR.BRANCH_ID = T.BRANCH_ID
LEFT JOIN BRANCH_OPERATIONAL_DETAILS BOD ON BR.BRANCH_ID = BOD.BRANCH_ID
WHERE
    BOD.IS_ACTIVE = 'Y'
GROUP BY
    BR.BRANCH_ID, BR.BRANCH_NAME, BOD.REGION, BOD.LAST_AUDIT_DATE;
```

## Data Model Updates
### Source Data Model
New table `BRANCH_OPERATIONAL_DETAILS` includes the following columns:
- `BRANCH_ID`: Primary key.
- `REGION`: Region of the branch.
- `MANAGER_NAME`: Name of the branch manager.
- `LAST_AUDIT_DATE`: Date of the last audit.
- `IS_ACTIVE`: Indicates if the branch is active.

### Target Data Model
Updated table `BRANCH_SUMMARY_REPORT` includes two new columns:
- `REGION`
- `LAST_AUDIT_DATE`

## Source-to-Target Mapping
| Source Column                     | Target Column                     | Transformation Rule                |
|-----------------------------------|-----------------------------------|-------------------------------------|
| BRANCH_OPERATIONAL_DETAILS.REGION | BRANCH_SUMMARY_REPORT.REGION      | Direct mapping                     |
| BRANCH_OPERATIONAL_DETAILS.LAST_AUDIT_DATE | BRANCH_SUMMARY_REPORT.LAST_AUDIT_DATE | Direct mapping                     |

## Assumptions and Constraints
- **Backward Compatibility**: Ensure older records remain unaffected.
- **Deployment**: Requires a full reload of `BRANCH_SUMMARY_REPORT`.
- **Data Governance**: Adhere to compliance and security standards.

## References
- JIRA Story: Extend BRANCH_SUMMARY_REPORT Logic to Integrate New Source Table.
- Confluence Documentation: ETL Change - Integration of BRANCH_OPERATIONAL_DETAILS.
- Source DDL: `BRANCH_OPERATIONAL_DETAILS` schema.
- Target DDL: `BRANCH_SUMMARY_REPORT` schema.