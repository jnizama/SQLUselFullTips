USE [AUPSJB]
GO
/****** Object:  StoredProcedure [Tramite].[BusquedaReporteGeneralSolicitudes]    Script Date: 05/14/2013 09:24:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
ALTER proc [Tramite].[BusquedaReporteGeneralSolicitudes] (@SedeID smallint = 2 , @OficinaIDOrigen smallint = 2, @OficinaIDActual smallint = 2,   
@Operador int = 0, @estado varchar(10) = '', @FechaTramiteInicio datetime, @FechaTramiteFin datetime )  
as
begin
declare @oficinaOrigen varchar(100), @oficinaOrigenID int, @LastOperator varchar(200), @PersonaOficinaID int ,@solicitudID bigint , @count int
declare @diasUltRecepcion SMALLINT

--set @FechaTramiteFin = dateadd(day, 1, @FechaTramiteFin) 
--set @FechaTramiteFin = dateadd(minute, -1, @FechaTramiteFin) 
-- ********** VERIFICAR RANGO DE FECHA POR TIEMPO Y HORAS ************ -
set @FechaTramiteFin = convert(datetime, convert(varchar, @FechaTramiteFin, 103))
set @FechaTramiteFin = @FechaTramiteFin  + cast('23:59' as datetime)

print @FechaTramiteInicio
print @FechaTramiteFin
	create table #Solicitudes
	(
	  id int identity(1,1), SolicitudID bigint	, NumeroSolicitud varchar(12) , sede varchar(50),
	  OficinaOrigen varchar(100),	oficinaOrigenID int,   OficinaActual varchar(100), OficinaActualID int, Usuario varchar(1000),
	  UltimoOperador varchar(200),	PersonaOficinaID int,  Tramite varchar(100),
	  FechaInicioTramite datetime,	  TUR varchar(50),
	  TTT varchar(50),	  Estado varchar(2), FlagTiempoTranscurrido smallint
	)
	
	DECLARE @sql VARCHAR(8000) 
	set @sql = ''
	SET @sql = ' INSERT INTO #Solicitudes (SolicitudID, NumeroSolicitud, Usuario, sede, OficinaActual, OficinaActualID, Tramite, FechaInicioTramite, Estado, TTT, FlagTiempoTranscurrido) 
		SELECT
			 sol.SolicitudID, sol.NumeroSolicitud , dbo.ufu_buscaNombresAlumnos(sol.codalu),sede.Abreviatura, ofi.Descripcion, ofi.OficinaID , trm.Descripcion, sol.FechaRecepcion, sol.estado,
			 datediff(day, sol.FechaRecepcion, getdate())  , 
			 CASE
				WHEN datediff(day, sol.FechaRecepcion, getdate()) >  trm.NumeroDias THEN 3
				WHEN datediff(day, sol.FechaRecepcion, getdate()) >=  ROUND(trm.NumeroDias / 2, 0) THEN 2
				WHEN datediff(day, sol.FechaRecepcion, getdate()) <=  trm.NumeroDias THEN 1		
				END			 	
			 from Tramite.Solicitud sol
			 inner join Academico.Sede sede on sol.SedeID = sede.SedeID
			 inner join Academico.Oficina ofi on sol.OficinaID = ofi.OficinaID
			 inner join Tramite.Tramite trm on sol.TramiteID = trm.TramiteID'

	select @sql = @sql + ' WHERE sol.FechaRecepcion >=  ''' + convert(varchar, @FechaTramiteInicio, 103)  + ''' ' 
	select @sql = @sql + ' and sol.FechaRecepcion <=  ''' + convert(varchar, @FechaTramiteFin, 103)  + ''' ' 
	--AND  ''' + convert(varchar, @FechaTramiteFin, 103)  + ''' '
	--PRINT @SQL
	
	if @SedeID <> 0
		SELECT @sql = @sql + ' AND sol.sedeID = ' + CAST(@SedeID as varchar)
	if @OficinaIDActual <> 0
		set @sql = @sql + ' AND sol.OficinaID = ' + CAST(@OficinaIDActual as varchar)
	if @estado <> ''
		set @sql = @sql + ' AND sol.estado = ''' + CAST(@estado as varchar) + ''''
	
	EXEC (@sql)
	
  
  select @count = count(*) from #Solicitudes
  
  while @count > 0
  begin
    select @solicitudID = SolicitudID from #Solicitudes where id = @count
    
    select top 1 @oficinaOrigen = ofi.Descripcion, @oficinaOrigenID = ofi.OficinaID from Tramite.SolicitudDerivacion solderiv inner join Academico.Oficina ofi
    on solderiv.OficinaOrigenID = ofi.OficinaID where solderiv.SolicitudID = @solicitudID
    order by solderiv.solicitudDerivacionID 
    
		IF ISNULL(@oficinaOrigen,'') = ''
		UPDATE #Solicitudes set OficinaOrigen = OficinaActual, oficinaOrigenID = OficinaActualID where id = @count
		else
		UPDATE #Solicitudes set OficinaOrigen = @oficinaOrigen, oficinaOrigenID = @oficinaOrigenID where id = @count
		
	-- getting last Operator.
	select top 1 @LastOperator = oper.Nombre, @PersonaOficinaID = oper.PersonaOficinaID , 
	@diasUltRecepcion = datediff(day, FechaCargoEnvio, getdate()) from Tramite.SolicitudDerivacion solderiv inner join Tramite.PersonaOficina oper
    on solderiv.PersonaOficinaRecepcionaID = oper.PersonaOficinaID where solderiv.SolicitudID = @solicitudID
    order by solderiv.solicitudDerivacionID desc
    --getting last dia Recepcion (TUR)
    IF ISNULL(@diasUltRecepcion,'') = ''
		select @diasUltRecepcion =  datediff(day, FechaInicioTramite, getdate()) from #Solicitudes  where id = @count
		
	--getting operator that sent.
	IF ISNULL(@LastOperator,'') = ''
		select top 1 @LastOperator = oper.Nombre, @PersonaOficinaID = oper.PersonaOficinaID from Tramite.SolicitudDerivacion solderiv inner join Tramite.PersonaOficina oper
		on solderiv.PersonaOficinaOrigenID = oper.PersonaOficinaID where solderiv.SolicitudID = @solicitudID
		order by solderiv.solicitudDerivacionID desc
    --getting operator according log.
    IF ISNULL(@LastOperator,'') = ''
		select top 1 @LastOperator = oper.Nombre, @PersonaOficinaID = oper.PersonaOficinaID From Tramite.SolicitudLOG solog inner join Tramite.PersonaOficina oper
		on solog.PersonaOficinaID = oper.PersonaOficinaID and SolicitudID = @solicitudID
		order by solog.solicitudlogid desc
	
	UPDATE #Solicitudes set UltimoOperador = @LastOperator, PersonaOficinaID = @PersonaOficinaID, TUR = @diasUltRecepcion where id = @count
	
	set @count = @count - 1
	set @diasUltRecepcion = 0
	
  end
  IF @Operador <> 0
	DELETE #Solicitudes WHERE PersonaOficinaID <> @Operador 
	   
  IF @OficinaIDOrigen <> 0
	
  	DELETE #Solicitudes WHERE oficinaOrigenID <> @OficinaIDOrigen 
  	
   UPDATE 	#Solicitudes SET TUR = TUR + ' DIAS' , TTT = TTT + ' DIAS' 
   SELECT * FROM #Solicitudes
   DROP TABLE #Solicitudes
end

GO

/******PROBANTO EL PROCEDIMIENTO ALMACENADO ***********/
exec [Tramite].[BusquedaReporteGeneralSolicitudes] 0, 0, 0, 0, '', '28/04/2013', '14/05/2013'

