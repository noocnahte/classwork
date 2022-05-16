/*
AWS RDS Database Connection Details
Host: lmu-dev-sql.c7huj6y1fkyn.us-east-2.rds.amazonaws.com
Username: admin
Password: sql_2022
*/

CREATE DATABASE assignment_02;
/*
3. SQL - Create a table named nyt_article with a column for each of these JSON keys in the API result:
nyt_article_id (set as an auto-incrementing primary key)
web_url (set as a unique key)
main_headline
document_type
pub_date
word_count
type_of_material
*/
CREATE TABLE nyt_article (
nyt_article_id INT NOT NULL AUTO_INCREMENT,
web_url VARCHAR(255) NOT NULL,
main_headline VARCHAR(255) NOT NULL,
document_type VARCHAR(255) NOT NULL,
pub_date DATETIME NOT NULL,
word_count INT NOT NULL,
type_of_material VARCHAR(255) NOT NULL,
PRIMARY KEY (nyt_article_id),
UNIQUE KEY (web_url)
);

-- 5. SQL - How many articles were published between December 1, 2021 and December 25, 2021 in the nyt_article table?
SELECT COUNT(*) 
FROM nyt_article
WHERE pub_date BETWEEN '2021-12-01' AND '2021-12-25 23:59:59'; 


-- 6. SQL - What is the average word count per article for articles published on and after November 2, 2021 in the nyt_article table?
SELECT AVG(word_count)
FROM nyt_article
WHERE pub_date >= '2021-11-02';

-- 7. SQL - What is the minimum and maximum pub_date for articles published between October 1, 2021 and October 31, 2021 in the nyt_article table?
SELECT
	MIN(pub_date),
	MAX(pub_date)
FROM nyt_article
WHERE pub_date BETWEEN '2021-10-01' AND '2021-10-31 23:59:59';

-- 8. SQL - How many total words were published for articles published in November 2021 in the nyt_article table?
SELECT SUM(word_count)
FROM nyt_article
WHERE pub_date BETWEEN '2021-11-01' AND '2021-11-30 23:59:59';

/*
10. SQL - Create a table named simplyhired_job with a column for each of these job components:
simplyhired_job_id (set as an auto-incrementing primary key)
title
company
location
link (link to the job details - the link is a relative link without a domain)
*/

CREATE TABLE simplyhired_job (
simplyhired_job_id INT NOT NULL AUTO_INCREMENT,
title VARCHAR(255) NOT NULL,
company VARCHAR(255) NOT NULL,
location VARCHAR(255) NOT NULL,
link VARCHAR(255) NOT NULL,
PRIMARY KEY (simplyhired_job_id)
);