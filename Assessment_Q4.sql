SELECT
    u.id AS customer_id,  -- Unique customer ID
    CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name of the customer
    TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,  -- How long the user has had an account, in months
    COUNT(s.id) AS total_transactions,  -- Number of transactions made by the customer

    -- Estimated CLV calculation:
    -- Formula: (total_transactions / tenure_months) * 12 * average profit per transaction
    -- Profit per transaction = 0.1% = 0.001 * average transaction amount
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()), 0)) * 12 * (0.001 * AVG(s.amount)),
        2
    ) AS estimated_clv

FROM
    users_customuser u
JOIN
    savings_savingsaccount s ON u.id = s.owner_id  -- Join savings data to each user

WHERE
    s.transaction_status = 'successful'  -- Optional: only consider successful transactions

GROUP BY
    u.id, name
-- ORDER BY
--     estimated_clv DESC;
