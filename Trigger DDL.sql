--Create rows on a table when user create tables.
--It is used for register DDL on a database
DROP TABLE log_createTable
GO
CREATE TABLE log_createTable
(
 id int identity(1,1) primary key,
 msg XML)
 go
 
create trigger t_registre_new_tablas on database FOR CREATE_TABLE
AS
	INSERT INTO log_createTable (msg)	 values (EVENTDATA())
GO
