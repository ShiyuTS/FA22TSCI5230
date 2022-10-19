-- !preview conn=DBI::dbConnect(RPostgres::Postgres(),dbname = 'postgres',host = 'db.zgqkukklhncxcctlqpvg.supabase.co', port = 5432, user = 'student', password = 'xxx')
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

SELECT COUNT(*)
FROM sl_demographics
GROUP_BY language_demo
--table(admissions$language)



