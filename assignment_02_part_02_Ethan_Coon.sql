/*
13. TBA
*/
WITH AgentPriceTotals AS(
	SELECT
		CONCAT(a.AgtFirstName, " ", a.AgtLastName) AS AgentName,
		SUM(e.ContractPrice) AS AgentContractPriceTotal
	FROM Agents a
	JOIN Engagements e
		ON a.AgentID = e.AgentID
	WHERE e.StartDate >= '2018-01-01'
		AND e.EndDate <= '2018-01-31 23:59:59'
	GROUP BY e.AgentID
)
SELECT
	RANK() OVER(
		ORDER BY apt.AgentContractPriceTotal DESC
	) AS SalesRank,
	apt.*,
	SUM(apt.AgentContractPriceTotal) OVER() AS AgencyContractPriceTotal,
	ROUND(
		apt.AgentContractPriceTotal / SUM(apt.AgentContractPriceTotal) OVER() * 100, 2
	) AS PercentageOfAgencyTotal
FROM AgentPriceTotals apt;

/*
14. TBA
*/
WITH TopCustomers AS(
	SELECT
		RANK() OVER(
			PARTITION BY ms.StyleName
			ORDER BY COUNT(e.EngagementNumber) DESC
		) AS BookingRank,
		ms.StyleName AS MusicalStyle,
		c.CustFirstName,
		c.CustLastName,
		COUNT(e.EngagementNumber) AS EngagementsBooked
	FROM Engagements e
	JOIN Musical_Preferences mp 
		ON e.CustomerID = mp.CustomerID
	JOIN Customers c 
		ON c.CustomerID = e.CustomerID 
	JOIN Musical_Styles ms 
		ON ms.StyleID = mp.StyleID 
	WHERE ms.StyleName = "Jazz" OR ms.StyleName = "Contemporary"
	GROUP BY e.CustomerID
)
SELECT *
FROM TopCustomers
WHERE TopCustomers.BookingRank<=2;

/*
15. TBA
*/
WITH solo_acts AS(
	SELECT
		e.EntertainerID
	FROM Entertainers e
	JOIN Entertainer_Members em
		ON e.EntertainerID = em.EntertainerID
	GROUP BY e.EntertainerID
	HAVING COUNT(em.MemberID) = 1
), month_revenue_bookings AS (
	SELECT
		sa.EntertainerID,
		MONTH(e.EndDate) AS EndDateMonth,
		SUM(ContractPrice) OVER(
			PARTITION BY MONTH(e.EndDate)
			ORDER BY MONTH(e.EndDate)
	) AS Revenue,
		COUNT(e.EngagementNumber) OVER(
			PARTITION BY MONTH(e.EndDate)
			ORDER BY MONTH(e.EndDate)
		) AS Bookings
	FROM solo_acts sa
	JOIN Engagements e
		ON sa.EntertainerID = e.EntertainerID
	GROUP BY sa.EntertainerID, MONTH(e.EndDate)
	ORDER BY EntertainerID
), running_total AS(
	SELECT 
		mr.*,
		SUM(mr.Revenue) OVER(
			PARTITION BY EntertainerID
			ORDER BY EndDateMonth
		) AS RevenueRunningTotal,
		SUM(mr.Bookings) OVER(
			PARTITION BY EntertainerID
			ORDER BY EndDateMonth
		) AS BookingsRunningTotal
	FROM month_revenue_bookings mr
)
SELECT
	rt.EntertainerID,
	rt.EndDateMonth,
	rt.Revenue,
	rt.RevenueRunningTotal,
	ROUND((RevenueRunningTotal / LAG(RevenueRunningTotal, 1) OVER(
		PARTITION BY EntertainerID
	) - 1 ) * 100, 2) AS RevenuePercentageGrowth,
	rt.Bookings,
	rt.BookingsRunningTotal
FROM running_total rt;
/*
Custom Data Request

Question: Which types of music are the most and least popular with customers?
Q2: How has the most popular genre changed with each month?
Q3: How do the customer's indicated "musical preference" compare with the shows that they actually see?


Business Justification: It's important to know what music is popular so that the company can focus more on finding new artists within these genres.

*/


-- Custom Data Request SQL 1
SELECT 
	DENSE_RANK() OVER(
		ORDER BY COUNT(e.EngagementNumber) DESC
	) AS StyleRank,
	ms.StyleName,
	COUNT(e.EngagementNumber) AS EngagementCount,
	SUM(e.ContractPrice) AS MoneyEarned
FROM Engagements e
JOIN Entertainer_Styles es 
	ON e.EntertainerID = es.EntertainerID
JOIN Musical_Styles ms
	ON es.StyleID = ms.StyleID
GROUP BY es.StyleID;

/*
Custom Data Request SQL 1 Results Summary: 

The musical styles that are most popular with customers are 60's music, country, and contemporary.
The least popular genres are Motown, Chamber Music, and Country Rock

*/

-- Custom Data Request SQL 2

WITH engagements_all AS(
	SELECT 
		e.EndDate,
		ms.StyleName
	FROM Engagements e
	JOIN Entertainer_Styles es 
		ON e.EntertainerID = es.EntertainerID 
	JOIN Musical_Styles ms 
		ON es.StyleID = ms.StyleID
), Engagements_Month AS(
	SELECT
		EndDate,
		StyleName,
		COUNT(*) OVER(
			PARTITION BY StyleName, MONTH(EndDate)
		) AS MonthlyEngagements
	FROM engagements_all ea
), Max_Engagements AS(
	SELECT
		EndDate,
		StyleName,
		MonthlyEngagements,
		MAX(MonthlyEngagements) OVER(
			PARTITION BY MONTH(EndDate)
		) AS Most_Engagements
	FROM Engagements_Month
)
SELECT
	CONCAT(MONTH(EndDate), "/", YEAR(EndDate)) AS EndMonth,
	StyleName AS TopStyle,
	MonthlyEngagements
FROM Max_Engagements
WHERE MonthlyEngagements = Most_Engagements
GROUP BY MONTH(EndDate), StyleName
ORDER BY EndDate;

/*
Custom Data Request SQL 2 Results Summary: 

If we had data over a longer period of time, we could identify any trends, as some types of music may become more "in season" during different
parts of the year. However, because of the lack of long term data, it is hard to identify any trends from this data. However, this query was
way too difficult for me to write for me to scrap it in favor of a different one.

*/

-- Custom Data Request SQL 3
WITH Favorite_Styles AS (
	SELECT 
		DENSE_RANK() OVER(
			ORDER BY COUNT(e.EngagementNumber) DESC
		) AS StyleRank,
		ms.StyleName,
		COUNT(e.EngagementNumber) AS EngagementCount,
		SUM(e.ContractPrice) AS MoneyEarned
	FROM Engagements e
	JOIN Entertainer_Styles es 
		ON e.EntertainerID = es.EntertainerID
	JOIN Musical_Styles ms
		ON es.StyleID = ms.StyleID
	GROUP BY es.StyleID
)
SELECT
	ms.StyleName,
	DENSE_RANK() OVER(
		ORDER BY COUNT(mp.CustomerID) DESC
	) AS CustStyleRank,
	fs.StyleRank AS EngagementsStyleRank,
	COUNT(mp.CustomerID) AS Num_Cust_Favorite_Style,
	fs.EngagementCount AS Num_Engagements_By_Style
FROM Musical_Styles ms
JOIN Musical_Preferences mp 
	ON ms.StyleID = mp.StyleID
JOIN Favorite_Styles fs
	ON fs.StyleName = ms.StyleName
GROUP BY StyleName
ORDER BY COUNT(CustomerID) DESC;

/*
Custom Data Request SQL 3 Results Summary: 
Even though "Standards" is the #1 picked preference of customers, it is tied for 4th in terms of the money made from these shows. 
In fact, the #1 most popular style by revenue, "60's music", is tied for last place for customer preference.

BUSINESS RECOMMENDATION: Even though the customer preferences would indicated "60's music" and "country" as unpopular genres, they bring
in the most revenue for the company and should not be ignored. Furthermore, "chamber music" and "folk" are low on the popularity list
for both revenue AND customer preference, and so finding artists in these genres should not be a priority.

*/


