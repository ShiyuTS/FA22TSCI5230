/*SELECT COUNT(DISTINCT hadm_id::text||';'||day::text), COUNT(*)
FROM sl_antibiotics_cr;

SELECT * 
FROM sl_antibiotics_cr
LIMIT 100;

WITH q5 AS (SELECT 
		 AVG(CAST(value AS numeric)) OVER (PARTITION BY hadm_id, charttime::date) AS average_Cr,
	   --MAX(CAST(value AS numeric)) AS max_Cr, 
	   FIRST_VALUE(CAST(value AS numeric)) OVER (PARTITION BY hadm_id, charttime::date ORDER BY charttime DESC) AS last_Cr, 
	   CAST(value AS NUMERIC), flag, hadm_id, 
	   charttime, 
	   ROW_NUMBER() OVER (PARTITION BY hadm_id, charttime::date ORDER BY charttime DESC)
	   --SUM(CASE WHEN flag IS NOT null THEN 1 ELSE 0 END) AS abnormal_count
FROM sl_d_labitems AS items
INNER JOIN sl_labevents AS le ON items.itemid = le.itemid
WHERE label LIKE '%reatinine%'
AND fluid = 'Blood'
		--GROUP BY hadm_id, charttime::date)
		ORDER BY hadm_id, charttime)

SELECT 
	AVG(value) AS average_Cr,
	MAX(value) AS max_Cr, 
	MAX(last_Cr) AS last_Cr,
	value, 
	hadm_id, 
	flag,
	charttime::date AS charttime,
	SUM(CASE WHEN flag IS NOT null THEN 1 ELSE 0 END) AS abnormal_count
FROM q5
GROUP BY hadm_id, charttime::date*/

SELECT * 
FROM sl_antibiotics_cr
LIMIT 10
	   