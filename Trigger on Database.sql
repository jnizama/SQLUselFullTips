-- Create trigger over a database

CREATE TABLE log_createTable
(
 id int identity(1,1) primary key,
 msg XML)

GO
 
create trigger t_registre_new_tablas on database FOR CREATE_TABLE
AS
	INSERT INTO log_createTable (msg)	 values (EVENTDATA())
GO
