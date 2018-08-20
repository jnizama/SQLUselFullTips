IF OBJECT_ID('sp_select') is null
  BEGIN
    PRINT 'Creating procedure sp_select...'
    EXEC ('CREATE PROCEDURE sp_select AS RETURN(-1)')
  END
 GO

PRINT 'Altering procedure sp_select...'
GO
ALTER PROCEDURE dbo.sp_select(@table_name sysname, @spid int = NULL, @max_pages int = 1000)
AS
  SET NOCOUNT ON
  
  DECLARE @status int
        , @object_id int
        , @db_id int

  EXEC @status = sp_select_get_object_id @table_name = @table_name
                                       , @spid = @spid 
                                       , @object_id = @object_id output
  
  IF @object_id IS NULL
    BEGIN 
      RAISERROR('The table [%s] does not exist', 16, 1, @table_name)
      RETURN (-1)
    END
  
  SET @db_id = DB_ID(PARSENAME(@table_name, 3))
    
  EXEC @status = sp_selectpages @object_id = @object_id, @db_id = @db_id, @max_pages = @max_pages
  
  RETURN (@status)
GO
if OBJECT_ID('sp_select') is null
  PRINT 'Failed to create procedure sp_select...'
ELSE
  PRINT 'Correctly created procedure sp_select...'
GO