=============================================
Author: Ascendion AVA+
Date: <Leave it blank>
Description: Integration of BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT
=============================================

# Technical Specification for Integration of BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT

## Introduction
This document outlines the technical specifications for integrating the BRANCH_OPERATIONAL_DETAILS table into the BRANCH_SUMMARY_REPORT table. The enhancement aims to improve compliance and audit readiness by incorporating branch-level operational metadata.

## Code Changes
### Impacted Areas
- Snowflake stored procedure logic
- Snowflake table structure
- Data validation and reconciliation routines

### Logic Enhancements
1. **Join Logic**:
   - Join BRANCH_OPERATIONAL_DETAILS using `BRANCH_ID`.
   - Populate `REGION` and `LAST_AUDIT_DATE` conditionally based on `IS_ACTIVE = 'Y'`.

2. **Stored Procedure Updates**:
   - Modify the existing procedure to include the new join and conditional logic.

### Pseudocode
```sql
UPDATE BRANCH_SUMMARY_REPORT
SET REGION = (SELECT REGION FROM BRANCH_OPERATIONAL_DETAILS WHERE BRANCH_OPERATIONAL_DETAILS.BRANCH_ID = BRANCH_SUMMARY_REPORT.BRANCH_ID AND IS_ACTIVE = 'Y'),
    LAST_AUDIT_DATE = (SELECT LAST_AUDIT_DATE FROM BRANCH_OPERATIONAL_DETAILS WHERE BRANCH_OPERATIONAL_DETAILS.BRANCH_ID = BRANCH_SUMMARY_REPORT.BRANCH_ID AND IS_ACTIVE = 'Y');
```

## Data Model Updates
### Source Data Model
#### BRANCH_OPERATIONAL_DETAILS
- **Columns**:
  - BRANCH_ID (Primary Key)
  - REGION
  - MANAGER_NAME
  - LAST_AUDIT_DATE
  - IS_ACTIVE

### Target Data Model
#### BRANCH_SUMMARY_REPORT
- **Existing Columns**:
  - BRANCH_ID
  - BRANCH_NAME
  - TOTAL_TRANSACTIONS
  - TOTAL_AMOUNT
- **New Columns**:
  - REGION
  - LAST_AUDIT_DATE

## Source-to-Target Mapping
| Source Column                  | Target Column                  | Transformation Rule                  |
|--------------------------------|---------------------------------|---------------------------------------|
| BRANCH_OPERATIONAL_DETAILS.REGION | BRANCH_SUMMARY_REPORT.REGION | Populate if IS_ACTIVE = 'Y'          |
| BRANCH_OPERATIONAL_DETAILS.LAST_AUDIT_DATE | BRANCH_SUMMARY_REPORT.LAST_AUDIT_DATE | Populate if IS_ACTIVE = 'Y' |

## Assumptions and Constraints
- Full reload of BRANCH_SUMMARY_REPORT is required.
- Backward compatibility with older records must be maintained.
- Data governance and security standards must be adhered to.

## References
- JIRA Story: Extend BRANCH_SUMMARY_REPORT Logic to Integrate New Source Table
- Confluence Documentation: ETL Change - Integration of BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT
- Source DDL: BRANCH_OPERATIONAL_DETAILS
- Target DDL: BRANCH_SUMMARY_REPORT