# Question and Approach
## 1. High-Value Customers with Multiple Products
### Objective:
Estimate CLV using the formula: This was to find high value customers with multiple plans

CLV = (Total_Transactions / Tenure_Months) * 12 * (0.001 * Avg_Transaction_Value)

### Approach:

Joined users_customuser with savings_savingsaccount.

Used TIMESTAMPDIFF to calculate tenure.

Counted successful transactions.

Applied CLV formula with rounding and null-safe division using NULLIF.

## 2. Inactive Plans Identification
### Objective:
Identify savings and investment plans with no transaction in the past 12 months.

### Approach:

For investments: Used last_charge_date or fallback to start_date.

For savings: Used MAX(transaction_date) and grouped by plan_id.

Used DATEDIFF(CURDATE(), last_transaction_date) to find inactivity duration.

Filtered those inactive for over 365 days.

## 3. Transaction Frequency Categorization
### Objective:
Group customers based on average number of monthly transactions into:

High Frequency (≥10/month)

Medium Frequency (3–9/month)

Low Frequency (<3/month)

### Approach:

Created a CTE to compute active months and total transactions.

Calculated average transactions/month.

Assigned categories using a CASE statement.

Aggregated by category for count and average.

## 4. Customer Investment & Savings Summary
### Objective:
Show overall activity of each user across investment and savings.

### Approach:

Joined users_customuser with both savings_savingsaccount and plans_plan.

Counted distinct savings and investment plans per user.

Summed up total deposits (amount field from savings).

 # Challenges & Solutions
## Missing or Misleading Column Names
Issue: Assumed column last_transaction_date existed in savings_savingsaccount, but it did not.

Fix: Used MAX(transaction_date) instead to derive last transaction.

 ## MySQL Date Functions
Issue: PostgreSQL functions like AGE() or DATE_TRUNC() are not available in MySQL.

Fix: Used MySQL equivalents like TIMESTAMPDIFF, DATE_FORMAT, and PERIOD_DIFF.

## Preventing Division by Zero
Issue: Some users had zero-month tenure.

Fix: Wrapped division with NULLIF(..., 0) to avoid runtime errors.

## Performance with Large Joins
Issue: Joining large tables like savings_savingsaccount and plans_plan led to slow queries.

Fix: Indexed key fields (owner_id, plan_id) and used filtering conditions early in WHERE.
