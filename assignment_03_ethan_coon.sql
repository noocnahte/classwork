/*
https://r.isba.co/sql-assignment-03-s22
Assignment 03: Business Analytics SQL - Board Meeting Presentation
Due: Tuesday, April 26, 1:00 PM
Overall Grade %: 10
Total Points: 100
1 point for SQL formatting and the correct filename

Database Connection Details:
hostname: lmu-dev-01.isba.co
username: lmu_dba
password: go_lions
database: tahoe_fuzzy_factory
port: 3306

Situation:
Tahoe Fuzzy Factory has been live for about 8 months. Your CEO is due to present company performance metrics to the board next week.
You'll be the one tasked with preparing relevant metrics to show the company's promising growth.

Objective:
Extract and analyze website traffic and performance data from the Tahoe Fuzzy Factory database to quantify the company's growth and
to tell the story of how you have been able to generate that growth.

As an analyst, the first part of your job is extracting and analyzing the requested data. The next part of your job is effectively 
communicating the story to your stakeholders.

Restrict to data before November 27, 2012, when the CEO made the email request.

Provide 2+ sentences of insight for each task. Keep in mind the tests ran and the changes made by the business leading up to this point.
Refer to the previous business analytics SQL exercises to explain the story behind the results.
*/


/*
4.0 - Board Meeting Presentation Project
From: Kara (CEO)
Subject: Board Meeting Next Week
Date: November 27, 2012
I need help preparing a presentation for the board meeting next week.
The board would like to have a better understanding of our growth story over our first 8 months.

Objectives:
- Tell the story of the company's growth using trended performance data
- Use the database to explain some of the details around the growth story and quantify the revenue impact of some of the wins
- Analyze current performance and use that data to assess upcoming opportunities
*/


/*
4.1 - SQL (5 points)
Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for the # of gsearch sessions and orders
so that we can showcase the growth there? Include the conversion rate.

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1843|    59|           3.20|
        2012|            4|    3569|    93|           2.61|
        2012|            5|    3405|    96|           2.82|
        2012|            6|    3590|   121|           3.37|
        2012|            7|    3797|   145|           3.82|
        2012|            8|    4887|   184|           3.77|
        2012|            9|    4487|   186|           4.15|
        2012|           10|    5519|   237|           4.29|
        2012|           11|    8586|   360|           4.19|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders,
	ROUND(COUNT(o.order_id) / COUNT(ws.website_session_id) * 100, 2) AS conversion_rate
FROM website_sessions ws
LEFT JOIN orders o
	ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < "2012-11-26 23:59:59"
AND utm_source = 'gsearch'
GROUP BY MONTH(ws.created_at);
/*
4.1 - Insight (3 points)
Sessions, orders, and conversion rate are all trending upwards and we are getting more traffic with each month. We should strive to keep up what we are doing.
*/

/*
4.2 - SQL (10 points)
It would be great to see a similar monthly trend for gsearch but this time splitting out nonbrand and brand campaigns separately.
I wonder if brand is picking up at all. If so, this is a good story to tell.

Expected results:
session_year|session_month|nonbrand_sessions|nonbrand_orders|brand_sessions|brand_orders|
------------+-------------+-----------------+---------------+--------------+------------+
        2012|            3|             1835|             59|             8|           0|
        2012|            4|             3505|             87|            64|           6|
        2012|            5|             3292|             90|           113|           6|
        2012|            6|             3449|            115|           141|           6|
        2012|            7|             3647|            135|           150|          10|
        2012|            8|             4683|            174|           204|          10|
        2012|            9|             4222|            170|           265|          16|
        2012|           10|             5186|            222|           333|          15|
        2012|           11|             8208|            343|           378|          17|
*/

SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	SUM(ws.utm_campaign = 'nonbrand') AS nonbrand_sessions,
	SUM(ws.utm_campaign = 'nonbrand' AND ws.website_session_id = o.website_session_id) AS nonbrand_orders,
	SUM(ws.utm_campaign = 'brand') AS brand_sessions,
	SUM(ws.utm_campaign = 'brand' AND ws.website_session_id = o.website_session_id) AS brand_orders
FROM website_sessions ws
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < "2012-11-26 23:59:59"
	AND utm_source = 'gsearch'
GROUP BY MONTH(ws.created_at);


/*
4.2 - Insight (3 points)
Branded searches are increasing in number with each month but still make up a very small proportion of total sessions. 
We should try to increase brand sessions, as just from a quick glance I can tell that it has a much higher conversion rate than nonbrand sessions.
*/

/*
4.3 - SQL (10 points)
While we're on gsearch, could you dive into nonbrand and pull monthly sessions and orders split by device type?
I want to show the board we really know our traffic sources.

Expected results:
session_year|session_month|desktop_sessions|desktop_orders|mobile_sessions|mobile_orders|
------------+-------------+----------------+--------------+---------------+-------------+
        2012|            3|            1119|            49|            716|           10|
        2012|            4|            2135|            76|           1370|           11|
        2012|            5|            2271|            82|           1021|            8|
        2012|            6|            2678|           107|            771|            8|
        2012|            7|            2768|           121|            879|           14|
        2012|            8|            3519|           165|           1164|            9|
        2012|            9|            3169|           154|           1053|           16|
        2012|           10|            3929|           203|           1257|           19|
        2012|           11|            6233|           311|           1975|           32|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	SUM(ws.device_type = 'desktop') AS desktop_sessions,
	SUM(ws.device_type = 'desktop' AND ws.website_session_id = o.website_session_id) AS desktop_orders,
	SUM(ws.device_type = 'mobile') AS mobile_sessions,
	SUM(ws.device_type = 'mobile' AND ws.website_session_id = o.website_session_id) AS mobile_orders
FROM website_sessions ws 
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < "2012-11-26 23:59:59"
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
GROUP BY MONTH(ws.created_at);

/*
4.3 - Insight (3 points)
Desktop sessions and orders have been steadily increasing with each month.
However, mobile sessions and orders do not show as consistent of growth as desktop, and so we should prioritize improving the mobile user's experience.
*/

/*
4.4 - SQL (10 points)
I'm worried that one of our more pessimistic board members may be concerned about the large % of traffic from gsearch.
Can you pull monthly trends for gsearch, alongside monthly trends for each of our other channels?

Hint: CASE can have an AND operator to check against multiple conditions

Expected results:
session_year|session_month|gsearch_paid_sessions|bsearch_paid_sessions|organic_search_sessions|direct_type_in_sessions|
------------+-------------+---------------------+---------------------+-----------------------+-----------------------+
        2012|            3|                 1843|                    2|                      8|                      9|
        2012|            4|                 3569|                   11|                     76|                     71|
        2012|            5|                 3405|                   25|                    148|                    150|
        2012|            6|                 3590|                   25|                    194|                    169|
        2012|            7|                 3797|                   44|                    206|                    188|
        2012|            8|                 4887|                  696|                    265|                    250|
        2012|            9|                 4487|                 1438|                    332|                    284|
        2012|           10|                 5519|                 1770|                    427|                    442|
        2012|           11|                 8586|                 2752|                    525|                    475|
*/

-- find the various utm sources and referers to see the traffic we're getting
SELECT 
	DISTINCT
		utm_source,
		utm_campaign,
		http_referer
FROM website_sessions ws 
WHERE created_at < '2012-11-27';

/*
utm_source|utm_campaign|http_referer           |
----------+------------+-----------------------+
gsearch   |nonbrand    |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |NULL                   | direct_type_in_session
gsearch   |brand       |https://www.gsearch.com| gsearch_paid_session
NULL      |NULL        |https://www.gsearch.com| organic_search_session
bsearch   |brand       |https://www.bsearch.com| bsearch_paid_session
NULL      |NULL        |https://www.bsearch.com| organic_search_session
bsearch   |nonbrand    |https://www.bsearch.com| bsearch_paid_session
 */
SELECT 
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	SUM(ws.utm_source = 'gsearch') AS gsearch_paid_sessions,
	SUM(ws.utm_source = 'bsearch') AS bsearch_paid_sessions,
	SUM(ws.http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') AND ws.utm_source IS NULL) AS organic_search_sessions,
	SUM(ws.http_referer IS NULL) AS direct_type_in_session
FROM website_sessions ws 
WHERE created_at < '2012-11-27'
GROUP BY MONTH(ws.created_at);

/*
4.4 - Insight (3 points)
All channels are seeing considerable growth with each month, with "bsearch paid sessions" showing the most growth. 
While gsearch does get a lot more traffic, bsearch has been catching up and looks like it will continue to increase in traffic.
*/


/*
4.5 - SQL (10 points)
I'd like to tell the story of our website performance over the course of the first 8 months. 
Could you pull session to order conversion rates by month?

Expected results:
session_year|session_month|sessions|orders|conversion_rate|
------------+-------------+--------+------+---------------+
        2012|            3|    1862|    59|           3.17|
        2012|            4|    3727|   100|           2.68|
        2012|            5|    3728|   107|           2.87|
        2012|            6|    3978|   140|           3.52|
        2012|            7|    4235|   169|           3.99|
        2012|            8|    6098|   228|           3.74|
        2012|            9|    6541|   285|           4.36|
        2012|           10|    8158|   368|           4.51|
        2012|           11|   12338|   547|           4.43|
*/
SELECT
	YEAR(ws.created_at) AS session_year,
	MONTH(ws.created_at) AS session_month,
	COUNT(ws.website_session_id) AS sessions,
	COUNT(o.order_id) AS orders,
	ROUND(COUNT(o.order_id) / COUNT(ws.website_session_id) * 100, 2) AS conversion_rate
FROM website_sessions ws 
LEFT JOIN orders o
	ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '2012-11-27'
GROUP BY MONTH(ws.created_at);

/*
4.5 - Insight (3 points)
The website has been seeing steady growth in both users and the conversion rate. 
Orders have increased tenfold and we should continue making improvements to try to maintain conversion rate growth.
*/


/*
4.6 - SQL (15 points)
For the landing page test, it would be great to show a full conversion funnel from each of the two landing pages 
(/home, /lander-1) to orders. Use the time period when the test was running (Jun 19 - Jul 28).

Expected results:
landing_page_version_seen|lander_ctr|products_ctr|mrfuzzy_ctr|cart_ctr|shipping_ctr|billing_ctr|
-------------------------+----------+------------+-----------+--------+------------+-----------+
homepage                 |     46.82|       71.00|      42.84|   67.29|       85.76|      46.56|
custom_lander            |     46.79|       71.34|      44.99|   66.47|       85.22|      47.96|
*/

WITH conversion_funnel AS(
	SELECT
		ws.website_session_id,
		ws.created_at,
		wp.pageview_url,
		CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
		CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
	FROM website_sessions ws
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id
	WHERE ws.created_at BETWEEN '2012-06-19' AND '2012-07-28 23:59:59'
), session_level_made_it_flag AS (
	SELECT
		website_session_id,
		pageview_url,
		MAX(products_page) AS product_made_it,
		MAX(fuzzy_page) AS fuzzy_made_it,
		MAX(cart_page) AS cart_made_it,
		MAX(shipping_page) AS shipping_made_it,
		MAX(billing_page) AS billing_made_it,
		MAX(thank_you_page) AS thank_you_made_it
	FROM conversion_funnel
	GROUP BY website_session_id
)
SELECT
	pageview_url AS landing_page_version_seen,
	ROUND(SUM(product_made_it)/COUNT(website_session_id) * 100, 2) AS lander_ctr,
	ROUND(SUM(fuzzy_made_it)/SUM(product_made_it) * 100, 2) AS product_ctr,
	ROUND(SUM(cart_made_it)/SUM(fuzzy_made_it) * 100, 2) AS fuzzy_ctr,
	ROUND(SUM(shipping_made_it)/SUM(cart_made_it) * 100, 2) AS cart_ctr,
	ROUND(SUM(billing_made_it)/SUM(shipping_made_it) * 100, 2) AS shipping_ctr,
	ROUND(SUM(thank_you_made_it)/SUM(billing_made_it) * 100, 2) AS billing_ctr
FROM session_level_made_it_flag
GROUP BY pageview_url;

/*
4.6 - Insight (3 points)
First off, my numbers are slightly different from yours and I'm not sure why.
However, from this we can see that most people that leave the site do it from the Mr. Fuzzy page, the home page, and the billing page.
In order to minimize this, we should focus on making the home page as clean and easy to navigate as possible, as well as improve the
Mr. Fuzzy product page to make the product look more appealing.

*/


/*
4.7 - SQL (10 points)
I'd love for you to quantify the impact of our billing page A/B test. Please analyze the lift generated from the test
(Sep 10 - Nov 10) in terms of revenue per billing page session. Manually calculate the revenue per billing page session
difference between the old and new billing page versions. 

Expected results:
billing_version_seen|sessions|revenue_per_billing_page_seen|
--------------------+--------+-----------------------------+
/billing            |     657|                        22.90|
/billing-2          |     653|                        31.39|
*/
WITH session_revenue AS (
	SELECT
		wp.website_session_id,
		wp.pageview_url,
		o.price_usd
	FROM website_pageviews wp
	LEFT JOIN orders o
		ON wp.website_session_id = o.website_session_id
	WHERE wp.pageview_url IN ('/billing', '/billing-2')
		AND wp.created_at BETWEEN '2012-09-10' AND '2012-11-10 23:59:59'
)
SELECT
	pageview_url AS billing_version_seen,
	COUNT(pageview_url) AS sessions,
	SUM(price_usd) / COUNT(pageview_url) AS revenue_per_billing_page_screen
FROM session_revenue
GROUP BY pageview_url;


/*
4.7 - Insight (3 points)
Again, my numbers are slightly different and I can't determine why.
However, in both my results and the expected results, it is obvious that "billing-2" is significantly outperforming "billing."
The updated billing page should be deployed immediately.

 */


/*
4.8 - SQL (5 points)
Pull the number of billing page sessions (sessions that saw '/billing' or '/billing-2') for the past month and multiply that value
by the lift generated from the test (Sep 10 - Nov 10) to understand the monthly impact. 
You manually calculated the lift by taking the revenue per billing page session difference between /billing and /billing-2. 
You can hard code the revenue lift per billing session into the query.

Expected results:
past_month_billing_sessions|billing_test_value|
---------------------------+------------------+
                       1161|           9856.89|
*/
-- LIFT = 8.325

SELECT
	SUM(wp.pageview_url IN ('/billing', '/billing-2')) AS past_month_billing_sessions,
	SUM(wp.pageview_url IN ('/billing', '/billing-2')) * 8.325 AS billing_test_value
FROM website_pageviews wp
JOIN website_sessions ws 
	ON wp.website_session_id = ws.website_session_id
JOIN orders o
	ON wp.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-10-26' AND '2012-11-26 23:59:59';
-- result: 618 billing sessions, 5144.85 billing test value

WITH page_views AS(
	SELECT
		ws.website_session_id,
		wp.pageview_url
	FROM website_sessions ws 
	JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id 
	WHERE ws.created_at BETWEEN '2012-10-26' AND '2012-11-26 23:59:59'
)
SELECT
COUNT(website_session_id) AS past_month_billing_sessions,
COUNT(website_session_id) * 8.325 AS billing_test_value
FROM page_views
WHERE pageview_url IN ('/billing', '/billing2')
-- 609 billing sessions, 5069.93 billing test value

/*
4.8 - Insight (3 points)
I probably did something wrong, but by my query it looks like if we used exclusively '/billing-2', we would have made an estimated
$5,144.85 more money than if we only used '/billing'. My recommendation is to stop using the original billing page immediately.
 */