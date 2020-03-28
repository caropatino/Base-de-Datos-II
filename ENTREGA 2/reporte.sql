-------------------------/* QUERY REPORTE 1 */------------------------

create or replace procedure reporteUno(rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
    select AERO_NOMBRE,AERO_FOTO, AERO_TIPO, LISTAGG(FLOTAA, ', ') WITHIN GROUP(ORDER BY FLO_NOMBRE) over(partition by AERO_NOMBRE) FLOTAS
    from (select AERO_ID, FLO_ID, AERO_NOMBRE,  AERO_FOTO, AERO_TIPO, FLO_NOMBRE, LISTAGG(FLO_NOMBRE, ' ') WITHIN GROUP(ORDER BY AERO_NOMBRE) over(partition by AERO_NOMBRE) FLOTAA, row_number() over(partition by AERO_ID order by AERO_NOMBRE) rw
          FROM AEROLINEA, FLOTA, MOD_FLOTA
          where AERO_ID = fk_MOFL_aerolinea and FLO_ID = FK_MOFL_FLOTA)
    where RW = 1;
end;

-------------------------/* QUERY REPORTE 2 */------------------------
create or replace procedure reporteDos(aeroline in varchar2, rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
    Select AERO_FOTO, FLO_NOMBRE, FLO_FOTO, MOD_TIPO, LISTAGG(CLASEE,',') WITHIN GROUP (ORDER BY FLO_NOMBRE) OVER (PARTITION BY AERO_ID,FLO_ID,MOD_TIPO) FLOTAS
    FROM (Select AERO_FOTO, FLO_NOMBRE, FLO_ID, AERO_ID,FLO_FOTO, MOD_TIPO, LISTAGG (CONCAT (CONCAT (TO_CHAR(ASCL_CANTIDAD),' '), CLA_NOMBRE), ',') WITHIN GROUP (ORDER BY CLA_ID)
      OVER (PARTITION BY AERO_ID,FLO_ID,MOD_TIPO) CLASEE, ROW_NUMBER() over(PARTITION by FLO_ID order by AERO_NOMBRE) rw
      FROM AEROLINEA , FLOTA , MOD_FLOTA , ASI_CLA , CLASE , MODELO
      WHERE AERO_ID = FK_MOFL_AEROLINEA 
        AND AEROLINE =  AERO_NOMBRE
        AND FLO_ID = FK_MOFL_FLOTA
        AND MOD_ID= FK_MOFL_MODELO
        AND FK_ASCL_CLASE = CLA_ID
        AND FLO_ID = FK_ASCL_FLOTA)
WHERE RW=1;
end;

-------------------------/* QUERY REPORTE 3 */------------------------

create or replace procedure reporteTres(avion in varchar2, modelo in varchar2, rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
    select a.AERO_FOTO, f.FLO_NOMBRE, f.FLO_FOTO, m.mod_tipo, f.flo_velocidad_max, f.flo_alcance_millas, f.flo_altitud_max_ft, f.flo_envergadura_m, f.flo_ancho_cabina_m, f.flo_altura_cabina_m 
    from AEROLINEA a, FLOTA f, MODELO m, MOD_FLOTA mf
    where avion = f.flo_nombre and modelo = m.mod_tipo and f.flo_id = mf.fk_mofl_flota and m.mod_id = mf.fk_mofl_modelo and a.aero_id = mf.fk_MOFL_aerolinea;
end;


-------------------------/* QUERY REPORTE 4 */------------------------

create or replace procedure reporteCuatro(rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
    select usr.USU_CORREO, usr.USU_FOTO, usr.USU_DATOS.PRIMER_NOMBRE, usr.USU_DATOS.SEGUNDO_NOMBRE, usr.USU_DATOS.PRIMER_APELLIDO, usr.USU_DATOS.SEGUNDO_APELLIDO, usr.USU_TELEFONO
    from   USUARIO usr;
end;


-------------------------/* QUERY REPORTE 5 */------------------------

create or replace procedure reporteCinco(fecha_salida in varchar2, fecha_llegada in varchar2, correo in varchar2, rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
    select AERO_FOTO, USU_CORREO, a.LUG_NOMBRE as l_salida, a.SIGLAS as s_salida, b.LUG_NOMBRE l_llegada, b.SIGLAS as s_llegada, VU.VUE_FECHA.FECHA_INICIO, VU.VUE_FECHA.FECHA_FIN,
       (to_char(VU.VUE_HORA_SALIDA, 'HH24:MI:SS')) salida, (to_char(VU.VUE_HORA_LLEGADA, 'HH24:MI:SS')) llegada,ROUND( 24 * (to_date(to_char(VU.VUE_FECHA.FECHA_FIN, 'YYYY-MM-DD hh24:mi:ss'), 'YYYY-MM-DD hh24:mi:ss') - to_date(VU.VUE_FECHA.FECHA_INICIO, 'YYYY-MM-DD hh24:mi:ss')),2) as "Duracion (horas)", pa.PAG_MONTO.PRECIO
    from LUGAR a, LUGAR b, VUELO VU, RUTA, AEROLINEA, USUARIO, FLOTA, MOD_FLOTA, PAGO pa, RESERVA, res_vue, USU_RES_VUE
    where a.lug_id = fk_rut_salida
        and b.lug_id = fk_rut_llegada
        and rut_id = vu.fk_vue_ruta
        and FK_VUE_FLOTA = FLO_ID
        and AERO_ID = FK_MOFL_AEROLINEA
        and FLO_ID = FK_MOFL_FLOTA
        and USU_ID = FK_RES_USUARIO
        and RES_ID = pa.FK_PAG_RESERVA
        and RES_ID = FK_REVU_RESERVA
        and REVU_ID = FK_URV_RESVUE
        and USU_ID = FK_URV_USUARIO
        and vu.VUE_ID = fk_REVU_VUELO
        and USU_CORREO = correo
        and TO_CHAR( vu.VUE_FECHA.FECHA_INICIO, 'YYYY-MM-DD' )= fecha_salida
        and TO_CHAR( vu.VUE_FECHA.FECHA_FIN, 'YYYY-MM-DD' )= fecha_llegada;
end;

create or replace procedure reporteCinco(fecha_salida in varchar2, fecha_llegada in varchar2, correo in varchar2, rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
     select  ae.aero_foto, us.USU_CORREO, VU.VUE_FECHA.FECHA_INICIO, VU.VUE_FECHA.FECHA_FIN, a.LUG_NOMBRE as l_salida, a.SIGLAS as s_salida, b.LUG_NOMBRE l_llegada, b.SIGLAS as s_llegada, rv.revu_monto.precio,
    (to_char(VU.VUE_HORA_SALIDA, 'HH24:MI:SS')) salida, (to_char(VU.VUE_HORA_LLEGADA, 'HH24:MI:SS')) llegada,
    ROUND( 24 * (to_date(to_char(VU.VUE_FECHA.FECHA_FIN, 'YYYY-MM-DD hh24:mi:ss'), 'YYYY-MM-DD hh24:mi:ss') - to_date(VU.VUE_FECHA.FECHA_INICIO, 'YYYY-MM-DD hh24:mi:ss')),2) as "Duracion (horas)"
       from vuelo vu, USUARIO us, RESERVA res, res_vue rv,ruta ru, lugar a, lugar b, mod_flota mf, aerolinea ae
    where 
        res.res_id = rv.fk_revu_reserva 
        and us.usu_id = res.fk_res_usuario  
        and us.usu_correo = correo
        and rv.fk_revu_vuelo = vu.vue_id
        and vu.fk_vue_ruta = ru.rut_id
        and ru.fk_rut_llegada = a.lug_id
        and ru.fk_rut_salida = b.lug_id
        and vu.fk_vue_flota = mf.mofl_id
        and mf.fk_mofl_aerolinea = ae.aero_id
        and TO_CHAR( vu.VUE_FECHA.FECHA_INICIO, 'YYYY-MM-DD' )= fecha_salida
        and TO_CHAR( vu.VUE_FECHA.FECHA_FIN, 'YYYY-MM-DD' )= fecha_llegada;

end;


 


-------------------------/* QUERY REPORTE 6 */------------------------
create or replace procedure reporteSeis(reserva in number, rep_cursor1 out SYS_REFCURSOR)
is
begin
    open rep_cursor1 for
    select AERO_FOTO, USU_CORREO, a.LUG_NOMBRE as l_salida, a.SIGLAS as s_salida, b.LUG_NOMBRE l_llegada, b.SIGLAS as s_llegada, VU.VUE_FECHA.FECHA_INICIO, VU.VUE_FECHA.FECHA_FIN, rv.revu_monto.precio, PAG_TIPO ,TPD_NUMERO as DEBITO, TPC_TIPOCREDITO ,TPC_NUMERO as CREDITO, MIUS_ACUMULADO as MILLA_ACUM, pa.PAG_MONTO.PRECIO as "Monto Pagado"
    from LUGAR a, LUGAR b, VUELO VU, RUTA, AEROLINEA, USUARIO, FLOTA, MOD_FLOTA, PAGO pa, RESERVA res, res_vue rv, USU_RES_VUE, TP_DEBITO, TP_CREDITO, MILLA,MIL_USU
    where a.lug_id = fk_rut_salida
        and b.lug_id = fk_rut_llegada
        and rut_id = vu.fk_vue_ruta
        and FK_VUE_FLOTA = MOFL_ID
        and AERO_ID = FK_MOFL_AEROLINEA
        and FLO_ID = FK_MOFL_FLOTA
        and USU_ID = res.FK_RES_USUARIO
        and res.RES_ID = pa.FK_PAG_RESERVA
        and res.RES_ID = rv.FK_REVU_RESERVA
        and rv.REVU_ID = FK_URV_RESVUE
        and USU_ID = FK_URV_USUARIO
        and vu.VUE_ID = rv.fk_REVU_VUELO
        and TPD_ID = pa.FK_PAG_DEBITO
        and RES_ID = reserva
        or TPC_ID = pa.FK_PAG_CREDITO
        and a.lug_id = fk_rut_salida
        and b.lug_id = fk_rut_llegada
        and rut_id = vu.fk_vue_ruta
        and FK_VUE_FLOTA = MOFL_ID
        and AERO_ID = FK_MOFL_AEROLINEA
        and FLO_ID = FK_MOFL_FLOTA
        and USU_ID = res.FK_RES_USUARIO
        and res.RES_ID = pa.FK_PAG_RESERVA
        and res.RES_ID = rv.FK_REVU_RESERVA
        and rv.REVU_ID = FK_URV_RESVUE
        and USU_ID = FK_URV_USUARIO
        and vu.VUE_ID = rv.fk_REVU_VUELO
        and RES_ID = reserva
        or TPC_ID = pa.FK_PAG_MILLA
        and a.lug_id = fk_rut_salida
        and b.lug_id = fk_rut_llegada
        and rut_id = vu.fk_vue_ruta
        and FK_VUE_FLOTA = MOFL_ID
        and AERO_ID = FK_MOFL_AEROLINEA
        and FLO_ID = FK_MOFL_FLOTA
        and USU_ID = res.FK_RES_USUARIO
        and res.RES_ID = pa.FK_PAG_RESERVA
        and res.RES_ID = rv.FK_REVU_RESERVA
        and rv.REVU_ID = FK_URV_RESVUE
        and USU_ID = FK_URV_USUARIO
        and vu.VUE_ID = rv.fk_REVU_VUELO
        and MIL_ID = FK_MIUS_MILLA
        and USU_ID = FK_MIUS_USUARIO
        and RES_ID = reserva;
end;


create or replace procedure reporteCinco(fecha_salida in varchar2, fecha_llegada in varchar2, correo in varchar2, rep_cursor out sys_refcursor)
is
begin
    open rep_cursor for
     select  ae.aero_foto, us.USU_CORREO, VU.VUE_FECHA.FECHA_INICIO, VU.VUE_FECHA.FECHA_FIN, a.LUG_NOMBRE as l_salida, a.SIGLAS as s_salida, b.LUG_NOMBRE l_llegada, b.SIGLAS as s_llegada, rv.revu_monto.precio,
   tip.pag_tipo
       from vuelo vu, USUARIO us, RESERVA res, res_vue rv,ruta ru, lugar a, lugar b, mod_flota mf, aerolinea ae
    where 
        res.res_id = rv.fk_revu_reserva 
        and us.usu_id = res.fk_res_usuario  
        and rv.fk_revu_vuelo = vu.vue_id
        and vu.fk_vue_ruta = ru.rut_id
        and ru.fk_rut_llegada = a.lug_id
        and ru.fk_rut_salida = b.lug_id
        and vu.fk_vue_flota = mf.mofl_id
        and mf.fk_mofl_aerolinea = ae.aero_id

end;