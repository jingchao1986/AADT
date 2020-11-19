--assume I am running the command under the User 'user', Create Database
Create Database AADT2;

--create tables and insert records
\i /Users/user/Documents/GisticResearch/Research/SQL/test/SQLscripts.sql;


--create user jingchao
CREATE USER jingchao1 WITH PASSWORD '123456';


--grant previlidge

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO jingchao1;


-- connect to the database with the new user 'jingchao

\c AADT2 jingchao;

-- test connection with 'SELECT * FROM edges'

