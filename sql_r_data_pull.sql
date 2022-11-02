-- !preview conn=DBI::dbConnect(RPostgres::Postgres(),dbname = 'postgres',host = 'xx', port = 5432, user = 'xx', password = 'xxx')
/*
SELECT *
FROM patients
Limit 10
*/
--DROP TABLE IF EXISTS sl_demographics;
/*CREATE TABLE sl_demographics AS
SELECT
  subject_id, --dischtime, admittime, ethnicity,
  COUNT(DISTINCT ethnicity) AS ethnicity_demo,
  CAST(array_agg(ethnicity) AS  character(20)) AS ethnicity_combo,
  max(language) AS language_demo,
  max(deathtime) AS death,
  COUNT(*) AS admits,
  COUNT(edregtime) AS num_ED,
  AVG(DATE_PART('day', dischtime - admittime)) AS los
  --language, deathtime, edregtime
FROM sl_admissions GROUP BY subject_id
*/


/*
select * 
from patients
limit 10;

CREATE TABLE sl_patients AS SELECT * FROM patients; 
CREATE TABLE sl_admissions AS SELECT * FROM admissions; 
CREATE TABLE sl_transfers AS SELECT * FROM transfers; 
CREATE TABLE sl_d_items AS SELECT * FROM d_items;
CREATE TABLE sl_inputevents AS SELECT * FROM inputevents;
CREATE TABLE sl_d_labitems AS SELECT * FROM d_labitems;
CREATE TABLE sl_labevents AS SELECT * FROM labevents;
*/

--table(admissions$language)
/*SELECT COUNT(*), language_demo
FROM sl_demographics
GROUP BY language_demo
*/

--setdiff(Demographics$subject_id, patients$subject_id)
/*
SELECT subject_id FROM sl_demographics
EXCEPT 
SELECT subject_id FROM sl_patients

SELECT subject_id FROM sl_patients
EXCEPT 
SELECT subject_id FROM sl_demographics


--Demographics1 <- left_join(Demographics, select(patients, -dod), by = c("subject_id"))
CREATE TABLE sl_demographics1 AS 
SELECT demo.*, pt.gender, anchor_age, anchor_year, anchor_year_group
FROM sl_demographics AS demo
LEFT JOIN sl_patients AS pt 
ON demo.subject_id = pt.subject_id
--nrow = 100


--create a column of dates named "day" (placeholders)

--CREATE Table sl_given_abx AS*/
DROP TABLE sl_antibiotics_Cr;
CREATE TABLE sl_antibiotics_Cr AS
WITH q0 AS 
	(SELECT GENERATE_SERIES(MIN(admittime), MAX(dischtime), INTERVAL '1 DAY') 
	AS day
	FROM sl_admissions)
, q1 AS (
	SELECT hadm_id, day::DATE
	FROM q0
	INNER JOIN sl_admissions AS adm ON q0.day BETWEEN adm.admittime::DATE AND adm.dischtime::DATE)
, q2 AS(
	SELECT inp.hadm_id, items.abbreviation, starttime::DATE, endtime::DATE
	FROM sl_d_items AS items
	INNER JOIN inputevents AS inp ON items.itemid = inp.itemid
	WHERE (label LIKE '%anco%'
		OR label LIKE '%iperacillin%'
		OR label LIKE '%rtapenem%'
		OR label LIKE '%efepime%'
		OR label LIKE '%evofloxacin%')
		AND category = 'Antibiotics')
		

,q3 AS 
(SELECT abbreviation, q1.*
FROM q1 LEFT JOIN q2
on q1.hadm_id = q2.hadm_id AND
q1.day BETWEEN starttime::DATE AND endtime::DATE)

, q4 AS 
(SELECT hadm_id, day,
SUM(CASE WHEN abbreviation = 'Vancomycin' THEN 1 ELSE 0 END) AS Vanc,
SUM(CASE WHEN abbreviation LIKE '%Zosyn%' THEN 1 ELSE 0 END) AS Zosyn,
SUM(CASE WHEN abbreviation NOT LIKE '%Zosyn%' AND abbreviation != 'Vancomysin' THEN 1 ELSE 0 END) AS Other
FROM q3
GROUP BY hadm_id, day)

, q5 AS (
	SELECT 
	AVG(CAST(value AS numeric))OVER (PARTITION BY hadm_id, charttime::date) AS average_Cr,
	FIRST_VALUE(CAST(value AS numeric)) OVER (PARTITION BY hadm_id, charttime::date ORDER BY charttime DESC) AS last_Cr, 
	CAST(value AS NUMERIC), 
	flag, 
	hadm_id, 
	charttime, 
	row_number() OVER (Partition By hadm_id, charttime::date ORDER BY charttime)
FROM sl_d_labitems AS items
INNER JOIN sl_labevents AS le ON items.itemid = le.itemid
WHERE label LIKE '%reatinine%'
AND fluid = 'Blood'
		--GROUP BY hadm_id, charttime::date)
		ORDER BY hadm_id, charttime)


	
, q6 AS 
(SELECT 
	AVG(value) AS average_Cr,
	MAX(value) AS max_Cr, 
	MAX(last_Cr) AS last_Cr,
	hadm_id, 
	charttime::date AS charttime,
	SUM(CASE WHEN flag IS NOT null THEN 1 ELSE 0 END) AS abnormal_count
FROM q5
GROUP BY hadm_id, charttime::date)


SELECT q4.*, average_Cr, max_Cr, abnormal_count,
CASE
	WHEN vanc > 0 AND zosyn > 0 THEN 'Vanc&Zosyn'
	WHEN vanc > 0 AND other > 0 THEN 'Vanc&Other'
	WHEN zosyn > 0 OR other > 0 THEN 'Other'
	WHEN vanc + zosyn + other = 0 THEN 'None' 
	ELSE 'Undefined' END as Antibiotic 
FROM q4

LEFT JOIN q6 ON q4.hadm_id = q6.hadm_id::bigint AND q4.day = q6.charttime




