USE human_resources

SELECT * 
FROM hr_editing

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT
	gender
	, COUNT(*) AS count
FROM hr_editing	
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY gender 


-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT
	race
	, COUNT(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY race 
ORDER BY COUNT(*) DESC 

-- 3. What is the age distribution of employees in the company?
SELECT 
	CASE 
		WHEN age >= 18 AND age <= 24 THEN '18-24'
		WHEN age >= 25 AND age <= 34 THEN '25-34'
		WHEN age >= 35 AND age <= 44 THEN '35-44'
		WHEN age >= 45 AND age <= 54 THEN '45-54'
		ELSE '55+'
	END AS age_group
	, count(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY age_group
ORDER BY age_group 

-- 4. How many employees work at headquarters versus remote locations?
SELECT 
	location 
	, count(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY location 

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	round(avg(DATEDIFF(termdate, hire_date))/ 365, 0) AS avg_length_employment
FROM hr_editing
WHERE termdate IS NOT NULL AND termdate <= curdate()

-- 6. How does the gender distribution vary across departments and job titles?

-- =========================
-- Alternative: Pivot format
-- =========================

/*
 * SELECT 
	department 
	, jobtitle 
	, SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS male
	, SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS female
	, sum(CASE WHEN gender = 'Non-Conforming' THEN 1 ELSE 0 END) AS Non_Conforming
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY 
	department 
	, jobtitle 
ORDER BY 
	department
*/ 	
	
SELECT 
	department 
	, jobtitle 
	, (CASE
		WHEN gender = 'Male' THEN 'male'
		WHEN gender = 'Female' THEN 'female'
		ELSE 'Non-Conforming'
	END) AS genders
	, count(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= CURDATE()
GROUP BY 
	department 
	, jobtitle 
	, genders
ORDER BY 
	department 
	, jobtitle 
	, genders

-- 7. What is the distribution of job titles across the company?
SELECT 
	jobtitle 
	, COUNT(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY jobtitle 
ORDER BY jobtitle

-- 8. Which department has the highest turnover rate?
WITH select_options AS (
    SELECT
        YEAR(hire_date) AS `year`
        , department
         , COUNT(*) AS hires
        , 0 AS terminations
    FROM hr_editing
    GROUP BY `year`, department  
    
    UNION ALL 
    
    SELECT 
        YEAR(termdate) AS `year`
        , department
        , 0 AS hires
        , COUNT(*) AS terminations
    FROM hr_editing
    WHERE termdate IS NOT NULL AND termdate <= CURDATE()
    GROUP BY `year`, department  
), agg AS (
    SELECT 
        `year`
    	, department
        , SUM(hires) AS hires
        , SUM(terminations) AS terminations
    FROM select_options
    GROUP BY `year`, department
), headcount AS (
    SELECT 
        `year`
	    , department
        , SUM(hires - terminations) OVER (PARTITION BY department ORDER BY year) AS employees 
        , terminations
    FROM agg
)
SELECT 
	`year`
	, department 
	, ROUND((terminations / employees) * 100, 2) AS turnover_rate
FROM headcount
ORDER BY department, year;

-- 9. What is the distribution of employees across locations by city and state?
SELECT 
	location_state
	, location_city 
	, COUNT(*) AS count
FROM hr_editing
WHERE termdate IS NULL OR termdate >= curdate()
GROUP BY location_state, location_city 
ORDER BY location_state, count DESC 

-- 10. How has the company's employee count changed over time based on hire and term dates?
WITH count_by_year AS(
	SELECT 
		YEAR(hire_date) AS `year`
		, count(*) AS hires
		, 0 AS terminations
	FROM hr_editing
	GROUP BY `year`
	
	UNION ALL 
	
	SELECT
		YEAR(termdate) AS `year`
		, 0 AS hires
		, count(*) AS terminations
	FROM hr_editing
	WHERE termdate IS NOT NULL AND termdate <= curdate()
	GROUP BY `year`	
), agg AS (
 	SELECT 
		`year` 
		, sum(hires) AS hires 
		, sum(terminations) AS terminations 
	FROM count_by_year
	GROUP BY `year` 
	ORDER BY `year` 
)
SELECT 
	`year` 
	, hires 
	, terminations 
	, sum(hires - terminations) OVER (ORDER BY `year`) AS headcount
FROM agg
ORDER BY `year` 


-- 11. What is the tenure distribution for each department?
/*
WITH emp_years AS (
	SELECT 
		id
		, department 
		, CASE 
			WHEN termdate <= CURDATE() AND termdate IS NOT NULL THEN DATEDIFF(termdate, hire_date)/365.0
			ELSE DATEDIFF(CURDATE(), hire_date)/365
		END AS years_of_employee
	FROM hr_editing
)
SELECT
	department 
	, SUM(CASE WHEN years_of_employee < 1 THEN 1 end) AS `0-1 year`
	, SUM(CASE WHEN years_of_employee >= 1 AND  years_of_employee < 3 THEN 1 ELSE 0 end) AS `1-3 years`
	, SUM(CASE WHEN years_of_employee >= 3 AND  years_of_employee < 5 THEN 1 ELSE 0 end) AS `3-5 years`
	, SUM(CASE WHEN years_of_employee >= 5 AND  years_of_employee < 10 THEN 1 ELSE 0 end) AS `5-10 years`
	, SUM(CASE WHEN years_of_employee >= 10 AND  years_of_employee < 15 THEN 1 ELSE 0 end) AS `10-15 years`
	, SUM(CASE WHEN years_of_employee >= 15 AND  years_of_employee < 20 THEN 1 ELSE 0 end) AS `15-20 years`
	, SUM(CASE WHEN years_of_employee >= 20  THEN 1 ELSE 0 end) AS `20+ years`
FROM emp_years 	
GROUP BY department 
*/

WITH emp_years AS (
	SELECT 
		id
		, department 
		, CASE 
			WHEN termdate <= CURDATE() AND termdate IS NOT NULL THEN DATEDIFF(termdate, hire_date)/365.0
			ELSE DATEDIFF(CURDATE(), hire_date)/365
		END AS years_of_employee
	FROM hr_editing
)
SELECT
	department 
	, CASE 
		WHEN years_of_employee < 1 THEN '0-1 year'
		WHEN years_of_employee >= 1 AND  years_of_employee < 3 THEN  '1-3 years'
		WHEN years_of_employee >= 3 AND  years_of_employee < 5 THEN '3-5 years'
		WHEN years_of_employee >= 5 AND  years_of_employee < 10 THEN '5-10 years'
		WHEN years_of_employee >= 10 AND  years_of_employee < 15 THEN '10-15 years'
		WHEN years_of_employee >= 15 AND  years_of_employee < 20 THEN '15-20 years'
		ELSE '20+ years'
	END AS 	tenure_destribution
	, CASE 
	    WHEN years_of_employee < 1 THEN 1
	    WHEN years_of_employee < 3 THEN 2
	    WHEN years_of_employee < 5 THEN	 3
	    WHEN years_of_employee < 10 THEN 4
	    WHEN years_of_employee < 15 THEN 5
	    WHEN years_of_employee < 20 THEN 6
	    ELSE 7
	END AS sort_order
	, count(*) AS count_tenure
FROM emp_years 	
GROUP BY department , tenure_destribution, sort_order