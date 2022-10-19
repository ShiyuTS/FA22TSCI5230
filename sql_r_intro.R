library(RPostgres)
library(DBI) # DBI is a generic data accessing tool
source("local_config.R")
con <- dbConnect(RPostgres::Postgres(),dbname = 'postgres',
                 host = my_server, # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                 port = 5432, # or any other port specified by your DBA
                 user = my_user,
                 password = my_pwd)

con <- dbConnect(RPostgres::Postgres(),dbname = 'postgres',host = 'db.zgqkukklhncxcctlqpvg.supabase.co', port = 5432, user = 'student', password = 'tsci5230')


dbGetQuery(con, "SELECT * FROM patients LIMIT 10")
dbListTables(con)
