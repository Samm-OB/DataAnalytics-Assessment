-- Step 1: Get total transactions and active months for each customer
WITH customer_txn_stats AS (
    SELECT
        sa.owner_id,
        -- Count of all successful transactions
        COUNT(*) AS total_transactions,
        -- First transaction month (formatted as first day of the month)
        MIN(DATE_FORMAT(sa.transaction_date, '%Y-%m-01')) AS first_month,
        -- Last transaction month (formatted similarly)
        MAX(DATE_FORMAT(sa.transaction_date, '%Y-%m-01')) AS last_month,
        -- Calculate number of active months (difference in months between first and last transaction)
        -- Add 1 to include the current month in the range
        -- GREATEST ensures minimum of 1 (to avoid division by zero)
        GREATEST(
            PERIOD_DIFF(
                DATE_FORMAT(MAX(sa.transaction_date), '%Y%m'),
                DATE_FORMAT(MIN(sa.transaction_date), '%Y%m')
            ) + 1,
            1
        ) AS active_months
    FROM savings_savingsaccount sa
    -- Only consider successful transactions
    WHERE sa.transaction_status = 'success'
    GROUP BY sa.owner_id
),

-- Step 2: Calculate average transactions per active month for each customer
avg_txn_per_customer AS (
    SELECT
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 2) AS avg_transactions_per_month
    FROM customer_txn_stats
),
categorized_customers AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_transactions_per_month
    FROM avg_txn_per_customer
)

-- Step 4: Aggregate final results per frequency category
SELECT
	-- High, Medium, or Low Frequency
    frequency_category,
    -- Number of customers in this group
    COUNT(*) AS customer_count,
    -- Group average
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
-- Ensure High > Medium > Low in display order
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
