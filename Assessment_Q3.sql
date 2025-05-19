-- Investment Plans
SELECT
    p.id AS plan_id,  -- Unique ID of the plan
    p.owner_id,       -- Owner (customer) of the plan
    'Investment' AS type,  -- Static label
    COALESCE(p.last_charge_date, p.start_date) AS last_transaction_date,  -- Use last charge date if available, else fallback to start
    DATEDIFF(CURDATE(), COALESCE(p.last_charge_date, p.start_date)) AS inactivity_days  -- Days since last activity
FROM
    plans_plan p
WHERE
    p.is_archived = 0
    AND p.is_deleted = 0
    AND p.plan_type_id IN (1, 4)  -- adjust based on investment-related plan types
    AND DATEDIFF(CURDATE(), COALESCE(p.last_charge_date, p.start_date)) > 365

UNION

-- Inactive Savings Accounts
SELECT
    s.plan_id AS plan_id,  -- Plan ID attached to savings account
    s.owner_id,            -- Customer ID
    'Savings' AS type,     -- Static label
    MAX(s.transaction_date) AS last_transaction_date,  -- Most recent transaction
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days  -- Days since last transaction
FROM
    savings_savingsaccount s
WHERE
    s.transaction_date IS NOT NULL
GROUP BY
    s.plan_id, s.owner_id
HAVING
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) > 365;  -- Inactive for more than a year
