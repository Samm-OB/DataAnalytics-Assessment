-- Select the user ID as owner_id
select u.id as owner_id,
-- Concatenate the first and last names to display full name
concat(u.first_name, ' ', u.last_name) as name,
-- Count the number of unique savings accounts for each user
count(distinct s.id) as savings_count,
-- Count the number of unique investment plans for each user
count(distinct p.id) as investment_count,
-- Sum up the total deposit amounts across all savings accounts for each user
sum(s.amount) as total_deposits

-- From the users table
from users_customuser u
-- Join with the savings table on owner_id to get savings info per user
join savings_savingsaccount s on u.id = s.owner_id
-- Join with the investment plans table on owner_id to get investment info per user
join plans_plan p on u.id = p.owner_id
-- Group the results by user ID and name to get one row per user
group by u.id, u.first_name, u.last_name

-- order by total_deposits desc;


