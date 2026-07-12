create database iap;
use iap;

-- 1- What is the total number of customers available in the policy database?
select count("Customer ID") as total_customer from customer;

-- 2- What is the total number of policies issued?
select count("policy ID") as total_policy_issued from policy ;

-- 3- What is the total claim amount generated from all policies?
select sum(`claim amount`) as total_claim_amount from claims;

-- 4- What is the average coverage amount per policy?
select round(avg(`coverage amount`),2) as avg_coverage_amount from policy;


-- 5- What is the average premium amount collected per policy?

select round(avg(`premium amount`),2)as avg_premium_amount from policy;

-- 6- What percentage of policies are currently active?

select round(count(case when status = "active" then 1 end)*100 / count(*),2) as active_policy_percentge from policy ;

-- 7- How many policies are in active, lapsed, and terminated status?

select status, count(*) as total_policies from policy group by status; 


-- 8- Which policy status has the highest number of policies?

select status, count(*) as total_policies from policy group by status order by total_policies desc  limit 1; 


-- 9- What is the ratio between active policies and inactive policies?

select sum(status= "active") as active_policies,
sum(status in ("lapsed" , "terminated"))as inactive_policies ,
concat(sum(status= "active"),":",sum(status in ("lapsed" , "terminated"))) as active_inaactive_ratio from policy;
 
 
 -- 10-  Which age group has the highest number of policies?

select case when c.age between 18 and 25 then "18-25"
when c.age between 26 and 35 then "26-35"
when c.age between 36 and 45 then "36-45"
when c.age between 46 and 55 then "46-55"
when c.age between 56 and 65 then "56-65"
else "66+"
end as age_group, count(*) as total_policies
from customer c join policy p on c.`customer id` = p.`customer id` group by age_group order by total_policies desc limit 1;


-- 11- Identify the top three age groups by policy count.
select case when c.age between 18 and 25 then "18-25"
when c.age between 26 and 35 then "26-35"
when c.age between 36 and 45 then "36-45"
when c.age between 46 and 55 then "46-55"
when c.age between 56 and 65 then "56-65"
else "66+"
end as age_group, count(*) as total_policies
from customer c join policy p on c.`customer id` = p.`customer id` group by age_group order by total_policies desc limit 3;


-- 12-Which gender has the highest policy participation?

select gender ,count(*) as policy_participation from customer group by gender order by policy_participation  desc limit 1 ; 

-- 13-What is the difference between male and female policy counts?

SELECT
SUM(CASE WHEN c.gender = 'Male' THEN 1 ELSE 0 END) AS Male_Policies,
SUM(CASE WHEN c.gender = 'Female' THEN 1 ELSE 0 END) AS Female_Policies,
ABS(SUM(CASE WHEN c.gender = 'Male' THEN 1 ELSE 0 END) -SUM(CASE WHEN c.gender = 'Female' THEN 1 ELSE 0 END)) AS Difference
FROM customer c
JOIN policy p
ON c.`Customer ID` = p.`Customer ID`;


-- 14- Which policy type has the maximum number of policies?

select `policy type`, count(*) as total_policies from policy group by `policy type` order by total_policies desc  limit 1; 

-- 15- Which policy type has the minimum number of policies?
select `policy type`, count(*) as total_policies from policy group by `policy type` order by total_policies asc  limit 1; 


-- 16- Compare Auto and Health policy counts.
select sum(`policy type` = "auto")as auto_policy, sum(`policy type` = "health")as health_policy from policy  ;

-- 17- What is the total number of policies across all policy types?

select count(`policy id`)as total_policies from policy ;

-- 18- What is the average premium growth rate over all years?

WITH yearly_premium AS (
    SELECT
        YEAR(`Policy Start Date`) AS Year,
        SUM(`Premium Amount`) AS Total_Premium
    FROM policy
    GROUP BY YEAR(`Policy Start Date`)
),
growth AS (
    SELECT
        Year,
        Total_Premium,
        ((Total_Premium - LAG(Total_Premium) OVER (ORDER BY Year))
        / LAG(Total_Premium) OVER (ORDER BY Year)) * 100 AS Growth_Rate
    FROM yearly_premium
)
SELECT ROUND(AVG(Growth_Rate), 2) AS Average_Premium_Growth_Rate
FROM growth
WHERE Growth_Rate IS NOT NULL;

-- 19- Is the premium growth trend increasing or decreasing over time?

WITH yearly_premium AS (
    SELECT
        YEAR(`Policy Start Date`) AS Year,
        SUM(`Premium Amount`) AS Total_Premium
    FROM policy
    GROUP BY YEAR(`Policy Start Date`)
)
SELECT
    Year,
    Total_Premium,
    CASE
        WHEN Total_Premium > LAG(Total_Premium) OVER (ORDER BY Year)
            THEN 'Increasing'
        WHEN Total_Premium < LAG(Total_Premium) OVER (ORDER BY Year)
            THEN 'Decreasing'
        ELSE 'No Change'
    END AS Trend
FROM yearly_premium;


-- 20- Calculate the difference between the highest and lowest premium growth rates.

WITH yearly_premium AS (
    SELECT
        YEAR(`Policy Start Date`) AS Year,
        SUM(`Premium Amount`) AS Total_Premium
    FROM policy
    GROUP BY YEAR(`Policy Start Date`)
),
growth_rate AS (
    SELECT
        Year,
        ROUND(
            ((Total_Premium - LAG(Total_Premium) OVER (ORDER BY Year))
            / LAG(Total_Premium) OVER (ORDER BY Year)) * 100,
            2
        ) AS Growth_Rate
    FROM yearly_premium
)
SELECT
    MAX(Growth_Rate) AS Highest_Growth_Rate,
    MIN(Growth_Rate) AS Lowest_Growth_Rate,
    ROUND(MAX(Growth_Rate) - MIN(Growth_Rate), 2) AS Difference
FROM growth_rate
WHERE Growth_Rate IS NOT NULL;

-- 21- What is the yearly trend of policies ending from 2016 to 2034? 

SELECT
    YEAR(`Policy End Date`) AS End_Year,
    COUNT(*) AS Total_Policies_Ended
FROM policy
WHERE YEAR(`Policy End Date`) BETWEEN 2016 AND 2034
GROUP BY YEAR(`Policy End Date`)
ORDER BY End_Year;