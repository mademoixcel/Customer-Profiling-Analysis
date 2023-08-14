SET SEARCH_PATH = "3rd_project";

SELECT * FROM customer_data;

-- PROJECT TITLE : CUSTOMER PROFILING ANALYSIS AND SEGMENTATION

-- *  DEMOGRAPHIC PROFILE
-- 1. What's the average age of customers?
SELECT AVG(age) FROM customer_data

-- 2. How does the distribution of education levels vary among customers?

SELECT 
age_distribution, COUNT(*)
FROM customer_data
GROUP BY age_distribution

-- 3. What's the predominant marital status among customers?

SELECT 
marital_status, COUNT(*)
FROM customer_data
GROUP BY marital_status

-- *  SPENDING BEHAVIOR 
-- 4. Which product do high-income customers tend to spend on?

SELECT
ROUND(AVG(mnt_wine)) AS avg_wine_purchase, 
ROUND(AVG(mnt_fruit)) AS avg_fruit_purchase,
ROUND(AVG(mnt_meat_product)) AS avg_meat_purchase,
ROUND(AVG(mnt_fish_product)) AS avg_fish_purchase,
ROUND(AVG(mnt_sweet_products)) AS avg_sweet_purchase,
ROUND(AVG(mnt_gold_prod)) AS avg_gold_purchase
FROM customer_data
WHERE income >
(SELECT AVG(income) FROM customer_data)

-- 5. How does the spending behavior of customers with children differ from those without children?

SELECT kid_home, teen_home,
ROUND(AVG(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod))
FROM customer_data 
GROUP BY kid_home, teen_home
ORDER BY kid_home, teen_home;

-- 6. Are there any specific age groups that spend more on luxury items like gold products?

SELECT
age_distribution,
ROUND(AVG(mnt_gold_prod)) AS avg_gold_purchase
FROM customer_data
GROUP BY age_distribution
ORDER BY avg_gold_purchase DESC

-- * CAMPAIGN RESPONSE PROFILE
-- 7. Which customer segment have the highest response rate to the marketing campaigns

SELECT age_distribution, marital_status, education, (scc1+scc2+scc3+scc4+scc5) AS accepted
FROM
(SELECT age_distribution, marital_status, education,
SUM (CASE WHEN accepted_cmp1 = 1 THEN 1 END) AS scc1,
SUM (CASE WHEN accepted_cmp2 = 1 THEN 1 END) AS scc2,
SUM (CASE WHEN accepted_cmp3 = 1 THEN 1 END) AS scc3,
SUM (CASE WHEN accepted_cmp4 = 1 THEN 1 END) AS scc4,
SUM (CASE WHEN accepted_cmp5 = 1 THEN 1 END) AS scc5
FROM customer_data
GROUP BY age_distribution, marital_status, education
ORDER BY
scc1 DESC,
scc2 DESC,
scc3 DESC,
scc4 DESC,
scc5 DESC) AS inner_query
WHERE (scc1+scc2+scc3+scc4+scc5)
IS NOT NULL

-- *  CHANNEL PREFERENCE
-- 8. Do customers with higher education levels prefer making purchases through the website or in stores?
SELECT education,
ROUND(AVG(num_web_purchase)) AS web_purchase,
ROUND(AVG(num_store_purchase)) AS store_purchase
FROM customer_data
GROUP BY education
HAVING education='Master' OR education='PhD';

-- 9. How does the number of web visits vary among different age groups?

SELECT 
age_distribution, ROUND(AVG(num_webvisits_month)) AS avg_webvisit
FROM customer_data
GROUP BY age_distribution

-- *   CHURN RISK PROFILE
-- 10. Are there any specific customer segments that have a higher churn rate based on their recency of purchases and complaints?

SELECT
age_distribution, marital_status, education, COUNT(*)
FROM customer_data
WHERE recency > 50
AND complain = 1
GROUP BY 
age_distribution, marital_status, education

-- 11. Do customers who have accepted previous campaigns show a lower churn rate?

SELECT avg_recency, age_distribution, marital_status, (scc1+scc2+scc3+scc4+scc5) AS accepted
FROM
(SELECT ROUND(AVG(recency)) AS avg_recency, age_distribution, marital_status,
SUM (CASE WHEN accepted_cmp1 = 1 THEN 1 END) AS scc1,
SUM (CASE WHEN accepted_cmp2 = 1 THEN 1 END) AS scc2,
SUM (CASE WHEN accepted_cmp3 = 1 THEN 1 END) AS scc3,
SUM (CASE WHEN accepted_cmp4 = 1 THEN 1 END) AS scc4,
SUM (CASE WHEN accepted_cmp5 = 1 THEN 1 END) AS scc5
FROM customer_data
GROUP BY age_distribution, marital_status
ORDER BY
scc1 DESC,
scc2 DESC,
scc3 DESC,
scc4 DESC,
scc5 DESC) AS inner_query
WHERE (scc1+scc2+scc3+scc4+scc5)
IS NOT NULL

-- *   LIFETIME VALUE PROFILE
-- 12. Which customer segments have the highest lifetime value based on their historical spending patterns and recency of purchases?

SELECT
COUNT(*) AS total,
ROUND(AVG(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)) AS avg_spent,
ROUND(AVG(recency)) AS avg_recency,
age_distribution,
marital_status
FROM customer_data
GROUP BY age_distribution, marital_status
ORDER BY total DESC, avg_spent DESC


-- * MULTI-CHANNEL BEHAVIOR
-- 13. How many customers frequently make purchases through multiple channels (web, catalog, store)?
SELECT COUNT(*)
FROM
(SELECT COUNT(*) AS total_customer,
num_web_purchase, num_catalogue_purchase, num_store_purchase
FROM customer_data
GROUP BY 
num_web_purchase, num_catalogue_purchase, num_store_purchase
HAVING num_web_purchase > (SELECT AVG(num_web_purchase) FROM customer_data )
AND
num_catalogue_purchase > (SELECT AVG(num_catalogue_purchase) FROM customer_data )
AND
num_store_purchase > (SELECT AVG(num_store_purchase) FROM customer_data )) AS multiple_channel_customers

-- 14. Do customers who make purchases through multiple channels tend to have higher spending?

SELECT ROUND(AVG(spent))
FROM
(SELECT COUNT(*) AS total_customer, ROUND((mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)) AS spent,
num_web_purchase, num_catalogue_purchase, num_store_purchase
FROM customer_data
GROUP BY
mnt_wine, mnt_fruit, mnt_meat_product, mnt_fish_product, mnt_sweet_products, mnt_gold_prod,
num_web_purchase, num_catalogue_purchase, num_store_purchase
HAVING num_web_purchase > (SELECT AVG(num_web_purchase) FROM customer_data )
AND
num_catalogue_purchase > (SELECT AVG(num_catalogue_purchase) FROM customer_data )
AND
num_store_purchase > (SELECT AVG(num_store_purchase) FROM customer_data)) avg_spent_by_multiple_channel_customers

-- What campaign was most succesful

SELECT 
SUM (CASE WHEN accepted_cmp1 = 1 THEN 1 END) AS scc1,
SUM (CASE WHEN accepted_cmp2 = 1 THEN 1 END) AS scc2,
SUM (CASE WHEN accepted_cmp3 = 1 THEN 1 END) AS scc3,
SUM (CASE WHEN accepted_cmp4 = 1 THEN 1 END) AS scc4,
SUM (CASE WHEN accepted_cmp5 = 1 THEN 1 END) AS scc5
FROM customer_data

-- *   SEGMENT CHARACTERISTICS 
-- 15. Can we characterize each customer segment with a unique label or description based on a combination of demographics, spending, and behavior?
-- Available demographics (age, income, education)


--  "Engagement Seekers"

SELECT 
COUNT(*), age_distribution, education, marital_status,
ROUND(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod) AS spent,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5
FROM customer_data
GROUP BY 
age_distribution, education, marital_status,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5,
mnt_wine, mnt_fruit , mnt_meat_product , mnt_fish_product , mnt_sweet_products , mnt_gold_prod
HAVING
(accepted_cmp1=1 OR accepted_cmp2=1
OR accepted_cmp3=1 OR accepted_cmp4=1 OR
accepted_cmp5=1)
AND 
ROUND(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)
>(SELECT 
ROUND(AVG(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)) FROM customer_data)


--  "Non-Responders"

SELECT 
COUNT(*) AS total_customers, age_distribution,
education, marital_status,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5
FROM customer_data
GROUP BY 
age_distribution,
education, marital_status,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5
HAVING
(accepted_cmp1=0 AND accepted_cmp2=0
AND accepted_cmp3=0 AND accepted_cmp4=0 AND
accepted_cmp5=0)
ORDER BY total_customers DESC


-- "Elite Patrons"
SELECT 
COUNT(*) AS total_customers, age_distribution,
ROUND(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod) AS spent,
education, marital_status,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5
FROM customer_data
GROUP BY 
age_distribution,
education, marital_status,
accepted_cmp1, accepted_cmp2, accepted_cmp3,
accepted_cmp4, accepted_cmp5,
mnt_wine, mnt_fruit , mnt_meat_product , mnt_fish_product , mnt_sweet_products , mnt_gold_prod
HAVING
(accepted_cmp1=0 AND accepted_cmp2=0 AND accepted_cmp3=0 AND accepted_cmp4=1 AND accepted_cmp5=0)
AND
ROUND(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)
<(SELECT 
ROUND(AVG(mnt_wine + mnt_fruit + mnt_meat_product + mnt_fish_product + mnt_sweet_products + mnt_gold_prod)) FROM customer_data)
ORDER BY total_customers DESC