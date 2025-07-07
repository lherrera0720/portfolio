-- Exploratory Data Analysis on Casino Dataset using PostgreSQL
-- Author: Lemuel D. Herrera
-- Date: 20June2025
-------------------------------------------------------------------------------------------------------
-- 0. Dataset Setup and Initial Checks.
-- Creates the casino_data table with all relevant columns.
-- Performs initial inspection and updates column types as needed.

CREATE TABLE casino_data
(membership_no VARCHAR(20) PRIMARY KEY,
membership_date INT,
gender VARCHAR(20),
age INT,
age_group VARCHAR(20),
state VARCHAR(50),
membership_tier VARCHAR (20),
preferred_game_type VARCHAR (20),
total_visits INT,
average_session_duration INT,
churned VARCHAR (20),
jackpot VARCHAR (20),
amount_bet INT,
in_house_spent INT,
online_gaming_spent INT,
jackpot_amount INT,
total_bet_table INT,
total_bet_slots INT,
total_winnings INT,
revenue INT);

-- Preview all data

SELECT *
FROM casino_data;

-- Alter column for correct numeric precision

ALTER TABLE casino_data
ALTER COLUMN average_session_duration TYPE FLOAT;

-- Count total rows

SELECT COUNT(*)
FROM casino_data;

-- Preview first 10 rows

SELECT *
FROM casino_data
LIMIT 10;

--1. Churn Rate Analysis

SELECT churned, COUNT(*),
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS churn_rate_percentage
FROM casino_data
GROUP BY churned;

--Summary:
-- Calculates the overall churn rate,
-- showing what percentage of total members have churned vs. remained active.

--2. Churn by Membership Tier

SELECT membership_tier, churned, COUNT(*) AS count_of_churn
FROM casino_data
GROUP BY membership_tier, churned
ORDER BY membership_tier, churned;

--Summary:
-- Displays how churn is distributed across membership tiers
-- and identifies which tier has the most churned users.

--3. Churn Rate by Age Group

SELECT age_group,
ROUND(COUNT(*) FILTER (WHERE churned = 'Yes') * 100.0 / COUNT(*), 2) AS churn_rate_percentage 
FROM casino_data
GROUP BY age_group
ORDER BY churn_rate_percentage DESC;

--Summary:
-- Calculates the churn percentage within each age group to see which age groups are most likely to churn.

--4. Churn Rate by Gender

SELECT gender,
ROUND(COUNT(*) FILTER (WHERE churned = 'Yes') * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM casino_data
GROUP BY gender
ORDER BY churn_rate_percentage DESC;

--Summary:
-- Shows the difference in churn rates between male and female members.

--5. Churn Rate by State

SELECT state,
ROUND(COUNT(*) FILTER (WHERE churned = 'Yes') * 100.0 / COUNT(*), 2) AS churn_rate_percentage
FROM casino_data
GROUP BY state
ORDER BY churn_rate_percentage DESC;

--Summary:
-- Analyzes churn rates per state, useful for identifying regions with high member loss.

--6. Churn Rate by Membership Year

SELECT membership_date,
ROUND(COUNT(*) FILTER (WHERE churned = 'Yes') * 100 / COUNT(*), 2) AS churn_rate_percentage
FROM casino_data
GROUP BY membership_date
ORDER BY membership_date;

--Summary:
-- Breaks down churn rate based on membership start year.

--7. Revenue by Year

SELECT membership_date, SUM(revenue) AS total_revenue
FROM casino_data
GROUP BY membership_date
ORDER BY membership_date;

--Summary:
-- Sums total revenue per membership year, revealing trends in income over time.

--8. Revenue: Male vs. Female

SELECT gender, SUM(revenue) AS total_revenue
FROM casino_data
GROUP BY gender
ORDER BY total_revenue DESC;

--Summary:
-- Compares total revenue contributed by male vs. female members.

--9. Members with Negative Revenue

SELECT membership_no, revenue
FROM casino_data
WHERE revenue < 0
ORDER BY revenue;

--Summary:
-- Shows players who profited from the casino, resulting in negative revenue.

--10. Top 10 Winning Members

SELECT membership_no, total_winnings
FROM casino_data
ORDER BY total_winnings DESC
LIMIT 10;

--Summary:
-- Lists the top 10 members with the highest total winnings in the dataset.

--11. Average Session Duration by Age Group

SELECT age_group, ROUND(AVG(average_session_duration::numeric), 2) AS avg_duration
FROM casino_data
GROUP BY age_group
ORDER BY avg_duration DESC;

--Summary:
-- Measures average gaming session length by age group to understand engagement levels.

--12. Average Revenue by Membership Tier

SELECT membership_tier, ROUND(AVG(revenue),2) AS avg_revenue
FROM casino_data
GROUP BY membership_tier
ORDER BY avg_revenue DESC;

--Summary:
-- Displays average revenue per member within each tier to identify spending patterns.

--13. Revenue: Churned vs. Active

SELECT churned, ROUND(AVG(revenue), 2) AS avg_revenue
FROM casino_data
GROUP BY churned
ORDER BY avg_revenue DESC;

--Summary:
-- Compares average revenue between churned and active members.

--14. Top States by Revenue

SELECT state, SUM(revenue) AS total_revenue
FROM casino_data
GROUP BY state
ORDER BY total_revenue DESC;

--Summary:
-- Ranks states by total revenue, highlighting which regions generate the most income.

--15. Percentage Contribution by Revenue

SELECT Membership_Tier, SUM(Revenue) AS total_revenue,
ROUND(SUM(Revenue) * 100.0 / SUM(SUM(Revenue)) OVER (), 2) AS percentage_contribution
FROM casino_data
GROUP BY Membership_Tier
ORDER BY percentage_contribution DESC;

--Summary:
-- Shows the percentage contribution of each membership tier to total revenue.

--16. Popular Game Types

SELECT preferred_game_type, COUNT(*) AS player_count
FROM casino_data
GROUP BY preferred_game_type
ORDER BY player_count DESC;

--Summary:
-- Identifies the most preferred game types based on player count.

--17. Age Group Distribution

SELECT age_group, COUNT(*) AS members
FROM casino_data
GROUP BY age_group
ORDER BY members DESC;

--Summary:
-- Shows how many players belong to each age group, helping visualize the customer base.

--18. Jackpot Winners

SELECT COUNT(*) AS jackpot_winners, SUM(Jackpot_Amount) AS total_jackpot
FROM casino_data
WHERE Jackpot = 'Yes';

--Summary:
-- Summarizes total jackpot winners and the total amount won.

--19. Jackpot Winners by Tier

SELECT membership_tier, COUNT(*) AS winners
FROM casino_data
WHERE jackpot = 'Yes'
GROUP BY membership_tier, jackpot
ORDER BY winners DESC;

--Summary:
-- Counts how many jackpot winners are from each membership tier.

--20. Jackpot Impact on Revenue

SELECT jackpot, ROUND(AVG(revenue), 2) AS avg_revenue
FROM casino_data
GROUP BY jackpot;

--Summary:
-- Compares average revenue between jackpot winners and non-winners.

--21. Top 10 High Rollers

SELECT membership_no, revenue
FROM casino_data
ORDER BY revenue DESC
LIMIT 10;

--Summary:
-- Lists members with the highest revenue contribution.

--22. Most Loyal Members

SELECT membership_no, total_visits
FROM casino_data
ORDER BY total_visits DESC
LIMIT 10;

--Summary:
-- Displays the top 10 most frequent visitors.

--23. Online vs. In-House Spending

SELECT ROUND(AVG(in_house_spent), 2) AS avg_in_house,
	   ROUND(AVG(online_gaming_spent), 2) AS avg_online
FROM casino_data;

--Summary:
-- Highlights the difference in average spend between online gaming and in-person visits.

--24. Average table vs. slot betting per user

SELECT 
  ROUND(AVG(total_bet_table), 2) AS avg_table_bets,
  ROUND(AVG(total_bet_slots), 2) AS avg_slot_bets
FROM casino_data;

--Summary:
-- Compares average total bets made on table games vs. slot machines.

--25. Betting Preference: Slot vs. Table

SELECT 
CASE 
    WHEN total_bet_table > total_bet_slots THEN 'Table Games'
    WHEN total_bet_table < total_bet_slots THEN 'Slot Machines'
    ELSE 'Equal'
END AS betting_preference,
COUNT(*) AS members
FROM casino_data
GROUP BY betting_preference
ORDER BY members DESC;

--Summary:
-- Shows how many users prefer betting on table games vs. slot machines.

--26. Churn Rank Based on Age Group

WITH churn_rank AS 
(
	SELECT age_group, COUNT(*) FILTER(WHERE churned = 'Yes') AS churned,
	COUNT(*) AS total_players,
	ROUND(COUNT(*) FILTER (WHERE churned = 'Yes') * 100.0 / COUNT(*), 2) AS percentage
	FROM casino_data
	GROUP BY age_group
)
SELECT *,
RANK() OVER (ORDER BY percentage DESC) AS rank
FROM churn_rank;

--Summary:
-- Ranks age groups by churn percentage to identify which groups are most likely to churn.


--------------------------------Final Summary (Formatted for Readability)------------------------------

--Total Revenue

SELECT TO_CHAR(SUM(revenue), 'FM$999G999G999') AS total_revenue
FROM casino_data;

--Revenue by Year

SELECT membership_date, TO_CHAR(SUM(revenue), 'FM$999G999G999') AS total_revenue
FROM casino_data
GROUP BY membership_date
ORDER BY membership_date;

--Revenue: Male vs. Female

SELECT gender, TO_CHAR(SUM(revenue), 'FM$999G999G999') AS total_revenue
FROM casino_data
GROUP BY gender
ORDER BY total_revenue DESC;

--Members with Negative Revenue

SELECT membership_no, TO_CHAR(revenue, 'FM$999G999G999') AS negative_revenue
FROM casino_data
WHERE revenue < 0
ORDER BY revenue;

--Top 10 Winning Members

SELECT membership_no, TO_CHAR(total_winnings, 'FM$999G999G999')
FROM casino_data
ORDER BY total_winnings DESC
LIMIT 10;

--Average Revenue by Membership Tier

SELECT membership_tier, TO_CHAR(ROUND(AVG(revenue),2), 'FM$999G999G999D00') AS avg_revenue
FROM casino_data
GROUP BY membership_tier
ORDER BY avg_revenue DESC;

--Revenue: Churned vs. Active

SELECT churned, TO_CHAR(ROUND(AVG(revenue), 2), 'FM$999G999G999D00') AS avg_revenue
FROM casino_data
GROUP BY churned
ORDER BY avg_revenue DESC;

--Top States by Revenue

SELECT state, TO_CHAR(SUM(revenue), 'FM$999G999G999') AS total_revenue
FROM casino_data
GROUP BY state
ORDER BY total_revenue DESC;

--Jackpot Winners

SELECT COUNT(*) AS jackpot_winners, TO_CHAR(SUM(Jackpot_Amount), 'FM$999G999G999') AS total_jackpot
FROM casino_data
WHERE Jackpot = 'Yes';

--Jackpot Impact on Revenue

SELECT jackpot, TO_CHAR(ROUND(AVG(revenue), 2), 'FM$999G999G999D00') AS avg_revenue
FROM casino_data
GROUP BY jackpot;

--Top 10 High Rollers

SELECT membership_no, TO_CHAR(revenue, 'FM$999G999G999')
FROM casino_data
ORDER BY revenue DESC
LIMIT 10;

--Online vs. In-House Spending

SELECT TO_CHAR(ROUND(AVG(in_house_spent), 2), 'FM$999G999G999D00') AS avg_in_house,
	   TO_CHAR(ROUND(AVG(online_gaming_spent), 2), 'FM$999G999G999D00') AS avg_online
FROM casino_data;

--Average table vs. slot betting per user

SELECT 
  TO_CHAR(ROUND(AVG(total_bet_table), 2), 'FM$999G999G999D00') AS avg_table_bets,
  TO_CHAR(ROUND(AVG(total_bet_slots), 2), 'FM$999G999G999D00') AS avg_slot_bets
FROM casino_data;