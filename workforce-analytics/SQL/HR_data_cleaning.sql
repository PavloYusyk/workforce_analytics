	CREATE DATABASE Human_Resources

USE human_resources

SELECT * FROM hr

CREATE TABLE `hr_editing` (
  `id` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `birthdate` varchar(50) DEFAULT NULL,
  `gender` varchar(50) DEFAULT NULL,
  `race` varchar(50) DEFAULT NULL,
  `department` varchar(50) DEFAULT NULL,
  `jobtitle` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `hire_date` varchar(50) DEFAULT NULL,
  `termdate` varchar(50) DEFAULT NULL,
  `location_city` varchar(50) DEFAULT NULL,
  `location_state` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO hr_editing
SELECT * FROM hr

SELECT * FROM hr_editing

-- data cleaning

SELECT id, COUNT(*)
FROM hr_editing
GROUP BY id
HAVING COUNT(*) > 1

/* birthdate */
SELECT
	birthdate,
	CASE 
		WHEN birthdate LIKE '%/%' THEN str_to_date(birthdate, '%m/%d/%Y')
	    WHEN birthdate LIKE '%-%' AND LENGTH(birthdate) = 8 
      		THEN CASE 
        		WHEN YEAR(str_to_date(birthdate, '%m-%d-%Y')) > YEAR(CURDATE())
          		THEN DATE_ADD(str_to_date(birthdate, '%m-%d-%Y'), INTERVAL -100 YEAR)
       			ELSE str_to_date(birthdate, '%m-%d-%Y')
      		END
        ELSE null
	END AS birthdate_edit
FROM hr_editing

UPDATE hr_editing
SET birthdate = CASE 
		WHEN birthdate LIKE '%/%' THEN str_to_date(birthdate, '%m/%d/%Y')
	    WHEN birthdate LIKE '%-%' AND LENGTH(birthdate) = 8 
      		THEN CASE 
        		WHEN YEAR(str_to_date(birthdate, '%m-%d-%Y')) > YEAR(CURDATE())
          		THEN DATE_ADD(str_to_date(birthdate, '%m-%d-%Y'), INTERVAL -100 YEAR)
       			ELSE str_to_date(birthdate, '%m-%d-%Y')
      		END
        ELSE null
	END

ALTER TABLE hr_editing
MODIFY COLUMN birthdate date

/* hire_date */
SELECT
	hire_date,
	CASE 
		WHEN hire_date LIKE '%/%' THEN str_to_date(hire_date, '%m/%d/%Y')
	    WHEN hire_date LIKE '%-%' AND LENGTH(hire_date) = 8 
      		THEN CASE 
        		WHEN YEAR(str_to_date(hire_date, '%m-%d-%Y')) > YEAR(CURDATE())
          		THEN DATE_ADD(str_to_date(hire_date, '%m-%d-%Y'), INTERVAL -100 YEAR)
       			ELSE str_to_date(hire_date, '%m-%d-%Y')
      		END
        ELSE null
	END AS hire_date_edit
FROM hr_editing

UPDATE hr_editing
SET hire_date = CASE 
		WHEN hire_date LIKE '%/%' THEN str_to_date(hire_date, '%m/%d/%Y')
	    WHEN hire_date LIKE '%-%' AND LENGTH(hire_date) = 8 
      		THEN CASE 
        		WHEN YEAR(str_to_date(hire_date, '%m-%d-%Y')) > YEAR(CURDATE())
          		THEN DATE_ADD(str_to_date(hire_date, '%m-%d-%Y'), INTERVAL -100 YEAR)
       			ELSE str_to_date(hire_date, '%m-%d-%Y')
      		END
        ELSE null
	END

ALTER TABLE hr_editing
MODIFY COLUMN hire_date date

/* termdate */
SELECT
	termdate
	, CASE 
		WHEN termdate = '' THEN NULL
		ELSE date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
	END	AS termdate_edit
FROM hr_editing
WHERE termdate IS NOT NULL

UPDATE hr_editing
SET termdate = CASE 
		WHEN termdate = '' THEN NULL
		ELSE date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
	END
WHERE termdate IS NOT NULL

ALTER TABLE hr_editing
MODIFY COLUMN termdate date

/* age */
ALTER TABLE hr_editing ADD COLUMN age int 

SELECT
	birthdate
	, CURDATE()
	, timestampdiff(YEAR,birthdate,CURDATE())
FROM hr_editing

UPDATE hr_editing
SET age = timestampdiff(YEAR,birthdate,CURDATE())















