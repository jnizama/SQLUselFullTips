
GO
/****** Object:  StoredProcedure [Tramite].[BusquedaGeneralSolicitud]    Script Date: 04/24/2013 12:49:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [Tramite].[BusquedaGeneralSolicitud] (@SedeID smallint = 2 , @OficinaID smallint = 2, @Tramite bit = 1,
@Cancelado bit = 1, @Atendido bit = 1)
  
AS
       select s.SolicitudID, NumeroSolicitud, t.CodTramite + ' - ' + t.Descripcion as NomTramite, t.CodTramite as NumeroTramite ,         
       dbo.ufu_buscaNombresAlumnos(s.codalu)  as NomAlumno, 
	   convert(datetime, FechaEmision, 103) FechaEmision, convert(datetime, FechaRecepcion, 103) FechaRecepcion, 
	   s.Comentario, s.CodAlu,
	   case isnull(tsoli.TipCom,'') when '04' then 'BV' when '06' then 'FA' when '01' then 'RC' else '' end + '-'+
	   isnull(substring(isnull(tsoli.NumCom,''),1,3)+ '-'+ substring(isnull(tsoli.NumCom,''), 4, len(isnull(tsoli.NumCom,''))),'')  as NumComprobante,   
       isnull(mtdEstado.Descripcion,'') as Estado, CASE Observada WHEN 0 THEN 'NO' ELSE 'SI' END Observada, 
	   isnull(mtdEfecTerminado.Descripcion,'') EfectoTerminada, case isnull(tsoli.NumCom,'') when '' then 1 else 0 end as EstadoFalla -- EstadoFalla indica que el registro no encuentra su relación en la tabla tescsoli
       from Tramite.Solicitud s  
       INNER JOIN Tramite.Tramite t on s.TramiteID = t.TramiteID         
	   LEFT JOIN academico.MultiTablaDetalle mtdEstado on s.Estado = mtdEstado.Valor LEFT JOIN academico.MultiTabla mt on 
	   mtdEstado.MultitablaID = mt.MultitablaID and mt.valorEntidad = 'TRM' and mtdEstado.Auxiliar1 = 2
	   LEFT JOIN academico.MultiTablaDetalle mtdEfecTerminado on s.EfectoTerminada = mtdEfecTerminado.Valor LEFT JOIN academico.MultiTabla mt2 on 
	   mtdEfecTerminado.MultitablaID = mt2.MultitablaID and mt2.valorEntidad = 'TRM'  and mtdEstado.Auxiliar1 = 1
	   LEFT JOIN Server.BaseDatos.dbo.tescsoli tsoli on s.NumeroSolicitud = tsoli.CodSol
	   left JOIN Tramite.SolicitudDerivacion solideriv on s.SolicitudID = solideriv.SolicitudID
	   WHERE isnull(solideriv.EstadoDetalle,'') not in ('P','A') 	   
	   AND (s.SedeID = @SedeID and s.OficinaID = @OficinaID ) --and s.Estado = 'T'	   
	   AND (ISNULL(solideriv.SedeOrigenID,'') <> @SedeID and ISNULL(solideriv.OficinaOrigenID,'') <> @OficinaID)
	   and (s.Estado = case @Tramite when 1 then 'TR' end or 
	   s.Estado = case @Cancelado when 1 then 'CA' end or
	   s.Estado = case @Atendido when 1 then 'AT' end )
	   
  

