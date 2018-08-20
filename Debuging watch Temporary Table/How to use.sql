--Examples
--Run the following code in one query window:

    CREATE TABLE #temp (id int, name varchar(200))
    INSERT INTO #temp VALUES (1, 'Filip')
    INSERT INTO #temp VALUES (2, 'Sam')
--Now open a second query and run the following statement:

    exec sp_select 'tempdb..#temp'
--The result will be

--id	name
--1	Filip
--2	Sam
--When you want to see the rowcount you run

    exec sp_select_get_rowcount 'tempdb..#temp'
--The result will be

--rows
--2