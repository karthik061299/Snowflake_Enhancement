=============================================
Author: Ascendion AVA+
Date: 
Description: Technical specification for integrating BRANCH_OPERATIONAL_DETAILS into BRANCH_SUMMARY_REPORT
=============================================

# Technical Specification for BRANCH_SUMMARY_REPORT Enhancement

## Introduction
This document outlines the technical specifications for enhancing the BRANCH_SUMMARY_REPORT table to integrate data from the newly introduced BRANCH_OPERATIONAL_DETAILS table. The enhancement aims to improve compliance and audit readiness by incorporating branch-level operational metadata.

## Code Changes
### Impacted Areas
- **Snowflake Stored Procedure Logic**: Update the stored procedure to join BRANCH_OPERATIONAL_DETAILS using BRANCH_ID.
- **Conditional Logic**: Populate REGION and LAST_AUDIT_DATE columns based on IS_ACTIVE = 'Y'.

### Pseudocode
```sql
-- Example Logic
UPDATE BRANCH_SUMMARY_REPORT
SET REGION = BOD.REGION,
    LAST_AUDIT_DATE = BOD.LAST_AUDIT_DATE
FROM BRANCH_OPERATIONAL_DETAILS BOD
WHERE BRANCH_SUMMARY_REPORT.BRANCH_ID = BOD.BRANCH_ID
  AND BOD.IS_ACTIVE = 'Y';
```

## Data Model Updates
### Source Data Model
**BRANCH_OPERATIONAL_DETAILS**
| Column Name       | Data Type     | Description                      |
|-------------------|---------------|----------------------------------|
| BRANCH_ID         | INT           | Unique identifier for the branch |
| REGION            | VARCHAR2(50)  | Region name                      |
| MANAGER_NAME      | VARCHAR2(100) | Branch manager name              |
| LAST_AUDIT_DATE   | DATE          | Date of the last audit           |
| IS_ACTIVE         | CHAR(1)       | Active status                    |

### Target Data Model
**BRANCH_SUMMARY_REPORT**
| Column Name       | Data Type     | Description                      |
|-------------------|---------------|----------------------------------|
| BRANCH_ID         | INT           | Unique identifier for the branch |
| BRANCH_NAME       | STRING        | Name of the branch               |
| TOTAL_TRANSACTIONS| BIGINT        | Total transactions count         |
| TOTAL_AMOUNT      | DOUBLE        | Total transaction amount         |
| REGION            | STRING        | Region name                      |
| LAST_AUDIT_DATE   | DATE          | Date of the last audit           |

## Source-to-Target Mapping
| Source Column                    | Target Column                    | Transformation Logic                |
|----------------------------------|----------------------------------|-------------------------------------|
| BRANCH_OPERATIONAL_DETAILS.REGION| BRANCH_SUMMARY_REPORT.REGION     | Direct Mapping                     |
| BRANCH_OPERATIONAL_DETAILS.LAST_AUDIT_DATE | BRANCH_SUMMARY_REPORT.LAST_AUDIT_DATE | Direct Mapping                     |

## Assumptions and Constraints
- **Backward Compatibility**: Older records remain unaffected.
- **Data Governance**: Ensure compliance with security standards.
- **Deployment**: Requires full reload of BRANCH_SUMMARY_REPORT.

## References
- JIRA Story: Extend BRANCH_SUMMARY_REPORT Logic to Integrate New Source Table
- Confluence Documentation: ETL Change - Integration of BRANCH_OPERATIONAL_DETAILS
- Source DDL: BRANCH_OPERATIONAL_DETAILS
- Target DDL: BRANCH_SUMMARY_REPORT