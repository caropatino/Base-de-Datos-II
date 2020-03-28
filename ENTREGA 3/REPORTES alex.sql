------------ REPORTE OCHO --------
create or replace NONEDITIONABLE procedure reporteOcho(rep_cursor out sys_refcursor, fecha_inicio date, fecha_fin date, origen varchar2, destino varchar2)
is
begin
    if(fecha_inicio is null and fecha_fin is null and origen is null and destino is null) then
        open rep_cursor for
        select *
        from(
        select aero_foto, TOTAL.fini, total.ffin, total.inicio, total.fin, total.conteo,  row_number() over(partition by TOTAL.fini, total.ffin, total.inicio, total.fin order by TOTAL.fini, total.ffin, total.inicio, total.fin) RW
        from aerolinea ae, (select vu.vue_fecha.fecha_inicio as FINI,  vu.vue_fecha.fecha_fin as FFIN, a.lug_nombre as INICIO, b.lug_nombre as FIN, count(vu.vue_id) as Conteo
                from Vuelo vu, Lugar a, lugar b, ruta rut, mod_flota mf, aerolinea aero
                where rut.fk_rut_llegada = b.lug_id
                 and rut.fk_rut_salida = a.lug_id
                 and vu.fk_vue_ruta = rut.rut_id
                 and vu.fk_vue_flota = mf.mofl_id
                 and mf.fk_mofl_aerolinea = aero.aero_id
                group by vu.vue_fecha.fecha_inicio,  vu.vue_fecha.fecha_fin, a.lug_nombre, b.lug_nombre) TOTAL
                order by total.conteo desc
        )
        where RW = 1
        FETCH NEXT 5 ROWS ONLY;
    end if;

    if (fecha_fin is null and origen is null and destino is null and fecha_inicio is not null) then
        open rep_cursor for
        select *
        from(
        select aero_foto, CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas, total.inicio, total.fin, total.conteo,  row_number() over(partition by TOTAL.fini, total.ffin, total.inicio, total.fin order by TOTAL.fini, total.ffin, total.inicio, total.fin) RW
        from aerolinea ae, (select vu.vue_fecha.fecha_inicio as FINI,  vu.vue_fecha.fecha_fin as FFIN, a.lug_nombre as INICIO, b.lug_nombre as FIN, count(vu.vue_id) as Conteo
                from Vuelo vu, Lugar a, lugar b, ruta rut, mod_flota mf, aerolinea aero
                where rut.fk_rut_llegada = b.lug_id
                 and rut.fk_rut_salida = a.lug_id
                 and vu.fk_vue_ruta = rut.rut_id
                 and vu.fk_vue_flota = mf.mofl_id
                 and mf.fk_mofl_aerolinea = aero.aero_id
                 and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(vu.vue_fecha.fecha_inicio, 'DD-MM-YYYY')
                group by vu.vue_fecha.fecha_inicio,  vu.vue_fecha.fecha_fin, a.lug_nombre, b.lug_nombre) TOTAL
                order by total.conteo desc
        )
        where RW = 1
        FETCH NEXT 5 ROWS ONLY;
    end if;

    if (fecha_inicio is not null and fecha_fin is not null and origen is not null and destino is not null) then
    open rep_cursor for
        select *
        from(
        select aero_foto,  CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas, total.inicio, total.fin, total.conteo,  row_number() over(partition by TOTAL.fini, total.ffin, total.inicio, total.fin order by TOTAL.fini, total.ffin, total.inicio, total.fin) RW
        from aerolinea ae, (select vu.vue_fecha.fecha_inicio as FINI,  vu.vue_fecha.fecha_fin as FFIN, a.lug_nombre as INICIO, b.lug_nombre as FIN, count(vu.vue_id) as Conteo
                from Vuelo vu, Lugar a, lugar b, ruta rut, mod_flota mf, aerolinea aero
                where rut.fk_rut_llegada = b.lug_id
                 and rut.fk_rut_salida = a.lug_id
                 and vu.fk_vue_ruta = rut.rut_id
                 and vu.fk_vue_flota = mf.mofl_id
                 and mf.fk_mofl_aerolinea = aero.aero_id
                 and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(vu.vue_fecha.fecha_inicio, 'DD-MM-YYYY')
                 and to_char(fecha_fin, 'DD-MM-YYYY') = to_char(vu.vue_fecha.fecha_fin, 'DD-MM-YYYY')
                 and origen = a.lug_nombre
                 and destino = b.lug_nombre
                group by vu.vue_fecha.fecha_inicio,  vu.vue_fecha.fecha_fin, a.lug_nombre, b.lug_nombre) TOTAL
                order by total.conteo desc
        )
        where RW = 1
        FETCH NEXT 5 ROWS ONLY;
    end if;
    
    if (fecha_inicio is not null and origen is not null and destino is not null) then
    open rep_cursor for
        select *
        from(
        select aero_foto,  CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas, total.inicio, total.fin, total.conteo,  row_number() over(partition by TOTAL.fini, total.ffin, total.inicio, total.fin order by TOTAL.fini, total.ffin, total.inicio, total.fin) RW
        from aerolinea ae, (select vu.vue_fecha.fecha_inicio as FINI,  vu.vue_fecha.fecha_fin as FFIN, a.lug_nombre as INICIO, b.lug_nombre as FIN, count(vu.vue_id) as Conteo
                from Vuelo vu, Lugar a, lugar b, ruta rut, mod_flota mf, aerolinea aero
                where rut.fk_rut_llegada = b.lug_id
                 and rut.fk_rut_salida = a.lug_id
                 and vu.fk_vue_ruta = rut.rut_id
                 and vu.fk_vue_flota = mf.mofl_id
                 and mf.fk_mofl_aerolinea = aero.aero_id
                 and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(vu.vue_fecha.fecha_inicio, 'DD-MM-YYYY')
                 and origen = a.lug_nombre
                 and destino = b.lug_nombre
                group by vu.vue_fecha.fecha_inicio,  vu.vue_fecha.fecha_fin, a.lug_nombre, b.lug_nombre) TOTAL
                order by total.conteo desc
        )
        where RW = 1
        FETCH NEXT 5 ROWS ONLY;
    end if;

end;

----------------- REPORTE 10---------------

create or replace NONEDITIONABLE procedure reporteDiez(rep_cursor out sys_refcursor, fecha_inicio date, fecha_fin date, lugar varchar2)
is
begin
    if(fecha_inicio is null and fecha_fin is null and lugar is null) then
        open rep_cursor for
        select *
        from(
            select h.hot_foto, total.nombhot, total.inicio, total.fin, total.cantreservas, total.puntuacion, row_number() over(partition by total.nombhot, total.inicio, total.fin order by  total.nombhot, total.inicio, total.fin) RW
            from hotel h, (select h.hot_nombre as NOMBHOT, rh.reho_fecha.fecha_inicio as INICIO,  rh.reho_fecha.fecha_fin as FIN, count(rh.reho_id) as CANTRESERVAS ,h.hot_puntuacion as PUNTUACION
                from Hotel h, res_hot rh, hot_lugar hl, habitacion hab
                where hl.fk_hot_hotel = h.hot_id
                    and hab.fk_hab_holu = hl.holu_id
                    and rh.fk_reho_reserva = hab.hab_id
                    group by  h.hot_nombre, rh.reho_fecha.fecha_inicio,  rh.reho_fecha.fecha_fin,h.hot_puntuacion
                    order by CANTRESERVAS desc) TOTAL)
        where RW = 1
        fetch next 1 rows only;
    end if;

    if (fecha_fin is null and lugar is null and fecha_inicio is not null) then
        open rep_cursor for
        select *
        from(
            select h.hot_foto, total.nombhot, total.inicio, total.fin, total.cantreservas, total.puntuacion, row_number() over(partition by total.nombhot, total.inicio, total.fin order by  total.nombhot, total.inicio, total.fin) RW
            from hotel h, (select h.hot_nombre as NOMBHOT, rh.reho_fecha.fecha_inicio as INICIO,  rh.reho_fecha.fecha_fin as FIN, count(rh.reho_id) as CANTRESERVAS ,h.hot_puntuacion as PUNTUACION
                from Hotel h, res_hot rh, hot_lugar hl, habitacion hab
                where hl.fk_hot_hotel = h.hot_id
                    and hab.fk_hab_holu = hl.holu_id
                    and rh.fk_reho_reserva = hab.hab_id
                    and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(rh.reho_fecha.fecha_inicio, 'DD-MM-YYYY')
                    group by  h.hot_nombre, rh.reho_fecha.fecha_inicio,  rh.reho_fecha.fecha_fin,h.hot_puntuacion
                    order by CANTRESERVAS desc) TOTAL)
        where RW = 1
        fetch next 1 rows only;
    end if;

    if (fecha_inicio is not null and fecha_fin is not null and lugar is not null) then
    open rep_cursor for
        select *
            from(
                select h.hot_foto, total.nombhot, total.inicio, total.fin, total.cantreservas, total.puntuacion, row_number() over(partition by total.nombhot, total.inicio, total.fin order by  total.nombhot, total.inicio, total.fin) RW
                from hotel h, (select h.hot_nombre as NOMBHOT, rh.reho_fecha.fecha_inicio as INICIO,  rh.reho_fecha.fecha_fin as FIN, count(rh.reho_id) as CANTRESERVAS ,h.hot_puntuacion as PUNTUACION
                    from Hotel h, res_hot rh, hot_lugar hl, habitacion hab
                    where hl.fk_hot_hotel = h.hot_id
                        and hab.fk_hab_holu = hl.holu_id
                        and rh.fk_reho_reserva = hab.hab_id
                        and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(rh.reho_fecha.fecha_inicio, 'DD-MM-YYYY')
                        and to_char(fecha_fin, 'DD-MM-YYYY') = to_char(rh.reho_fecha.fecha_fin, 'DD-MM-YYYY')
                        and lugar = h.hot_nombre                       
                        group by  h.hot_nombre, rh.reho_fecha.fecha_inicio,  rh.reho_fecha.fecha_fin,h.hot_puntuacion
                        order by CANTRESERVAS desc) TOTAL)
            where RW = 1
            fetch next 1 rows only;
    end if;
    
    if (fecha_inicio is not null and fecha_fin is null and lugar is not null) then
    open rep_cursor for
        select *
            from(
                select h.hot_foto, total.nombhot, total.inicio, total.fin, total.cantreservas, total.puntuacion, row_number() over(partition by total.nombhot, total.inicio, total.fin order by  total.nombhot, total.inicio, total.fin) RW
                from hotel h, (select h.hot_nombre as NOMBHOT, rh.reho_fecha.fecha_inicio as INICIO,  rh.reho_fecha.fecha_fin as FIN, count(rh.reho_id) as CANTRESERVAS ,h.hot_puntuacion as PUNTUACION
                    from Hotel h, res_hot rh, hot_lugar hl, habitacion hab
                    where hl.fk_hot_hotel = h.hot_id
                        and hab.fk_hab_holu = hl.holu_id
                        and rh.fk_reho_reserva = hab.hab_id
                        and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(rh.reho_fecha.fecha_inicio, 'DD-MM-YYYY')
                        and lugar = h.hot_nombre                       
                        group by  h.hot_nombre, rh.reho_fecha.fecha_inicio,  rh.reho_fecha.fecha_fin,h.hot_puntuacion
                        order by CANTRESERVAS desc) TOTAL)
            where RW = 1
            fetch next 1 rows only;
    end if;
end;
--------------- REPORTE 11 ----------------
create or replace procedure reporteOnce(rep_cursor out sys_refcursor, fecha_inicio date, fecha_fin date, origen varchar)
is
begin
    if (correo is null and fecha_inicio is null and fecha_fin is null) then
    open rep_cursor for
    select aut.aut_foto, aut.aut_marcamodelo, prov.pro_foto, usr.usu_correo, sedr.sed_nombre as recogida, sedd.sed_nombre as devolucion, ra.reau_fecha.fecha_inicio, to_char(ra.reau_fecha.fecha_inicio, 'HH24:mi'), ra.reau_fecha.fecha_fin, to_char(ra.reau_fecha.fecha_fin, 'HH24:mi'), pa.prau_precio_dia.precio, pa.prau_precio_dia.conv,ra.reau_monto.precio, ra.reau_monto.conv 
        from automovil aut, proveedor prov, prov_auto pa, sede sedr, sede sedd, res_aut ra, reserva res, usuario usr
        where prov.pro_id = pa.fk_prau_proveedor
            and aut.aut_id = pa.fk_prau_automovil
            and sedr.sed_id = ra.fk_reau_recibe
            and sedd.sed_id = ra.fk_reau_recoge
            and ra.fk_reau_proveedor = prov.pro_id
            and res.res_id = ra.fk_reau_reserva
            and usr.usu_id = res.fk_res_usuario;
    end if;
    if (correo is not null and fecha_inicio is null and fecha_fin is null) then
    open rep_cursor for
    select aut.aut_foto, aut.aut_marcamodelo, prov.pro_foto, usr.usu_correo, sedr.sed_nombre as recogida, sedd.sed_nombre as devolucion, ra.reau_fecha.fecha_inicio, to_char(ra.reau_fecha.fecha_inicio, 'HH24:mi'), ra.reau_fecha.fecha_fin, to_char(ra.reau_fecha.fecha_fin, 'HH24:mi'), pa.prau_precio_dia.precio, pa.prau_precio_dia.conv,ra.reau_monto.precio, ra.reau_monto.conv 
        from automovil aut, proveedor prov, prov_auto pa, sede sedr, sede sedd, res_aut ra, reserva res, usuario usr
        where prov.pro_id = pa.fk_prau_proveedor
            and aut.aut_id = pa.fk_prau_automovil
            and sedr.sed_id = ra.fk_reau_recibe
            and sedd.sed_id = ra.fk_reau_recoge
            and ra.fk_reau_proveedor = prov.pro_id
            and res.res_id = ra.fk_reau_reserva
            and usr.usu_id = res.fk_res_usuario
            and usr.usu_correo = correo;
    end if;    
    if (correo is not null and fecha_inicio is not null and fecha_fin is null) then
    open rep_cursor for
    select aut.aut_foto, aut.aut_marcamodelo, prov.pro_foto, usr.usu_correo, sedr.sed_nombre as recogida, sedd.sed_nombre as devolucion, ra.reau_fecha.fecha_inicio, to_char(ra.reau_fecha.fecha_inicio, 'HH24:mi'), ra.reau_fecha.fecha_fin, to_char(ra.reau_fecha.fecha_fin, 'HH24:mi'), pa.prau_precio_dia.precio, pa.prau_precio_dia.conv,ra.reau_monto.precio, ra.reau_monto.conv 
        from automovil aut, proveedor prov, prov_auto pa, sede sedr, sede sedd, res_aut ra, reserva res, usuario usr
        where prov.pro_id = pa.fk_prau_proveedor
            and aut.aut_id = pa.fk_prau_automovil
            and sedr.sed_id = ra.fk_reau_recibe
            and sedd.sed_id = ra.fk_reau_recoge
            and ra.fk_reau_proveedor = prov.pro_id
            and res.res_id = ra.fk_reau_reserva
            and usr.usu_id = res.fk_res_usuario
            and usr.usu_correo = correo
            and to_char(ra.reau_fecha.fecha_inicio, 'DD-MM-YYYY') = to_char(fecha_inicio, 'DD-MM-YYYY');
    end if;
    if (correo is not null and fecha_inicio is not null and fecha_fin is not null) then
    open rep_cursor for
    select aut.aut_foto, aut.aut_marcamodelo, prov.pro_foto, usr.usu_correo, sedr.sed_nombre as recogida, sedd.sed_nombre as devolucion, ra.reau_fecha.fecha_inicio, to_char(ra.reau_fecha.fecha_inicio, 'HH24:mi'), ra.reau_fecha.fecha_fin, to_char(ra.reau_fecha.fecha_fin, 'HH24:mi'), pa.prau_precio_dia.precio, pa.prau_precio_dia.conv,ra.reau_monto.precio, ra.reau_monto.conv 
        from automovil aut, proveedor prov, prov_auto pa, sede sedr, sede sedd, res_aut ra, reserva res, usuario usr
        where prov.pro_id = pa.fk_prau_proveedor
            and aut.aut_id = pa.fk_prau_automovil
            and sedr.sed_id = ra.fk_reau_recibe
            and sedd.sed_id = ra.fk_reau_recoge
            and ra.fk_reau_proveedor = prov.pro_id
            and res.res_id = ra.fk_reau_reserva
            and usr.usu_id = res.fk_res_usuario
            and usr.usu_correo = correo
            and to_char(ra.reau_fecha.fecha_inicio, 'DD-MM-YYYY') = to_char(fecha_inicio, 'DD-MM-YYYY')
            and to_char(ra.reau_fecha.fecha_fin, 'DD-MM-YYYY') = to_char(fecha_fin, 'DD-MM-YYYY');
    end if;
end;

--------------- REPORTE 12 -----------------

create or replace procedure reporteDoce(rep_cursor out sys_refcursor, fecha_vuelo date)
is
begin
    if (fecha_vuelo is null) then
    open rep_cursor for
        select vu.vue_fecha.fecha_inicio, orig.lug_nombre as origen ,aero.aero_foto, dest.lug_nombre as destino, to_char(vu.vue_hora_salida,'HH24:mi:ss'), estatus.est_nombre, vu.vue_fecha.fecha_fin,  to_char(vu.vue_hora_llegada,'HH24:mi:ss')
        from vuelo vu, estatus, lugar dest, lugar orig, ruta rut, aerolinea aero, mod_flota mofl
        where estatus.est_id = vu.fk_vue_estatus
            and rut.rut_id = vu.fk_vue_ruta
            and rut.fk_rut_salida = orig.lug_id
            and rut.fk_rut_llegada = dest.lug_id
            and aero.aero_id = mofl.fk_mofl_aerolinea
            and vu.fk_vue_flota = mofl.mofl_id;
    end if;

    if (fecha_vuelo is not null) then
    open rep_cursor for
        select vu.vue_fecha.fecha_inicio, orig.lug_nombre as origen ,aero.aero_foto, dest.lug_nombre as destino, to_char(vu.vue_hora_salida,'HH24:mi:ss'), estatus.est_nombre, vu.vue_fecha.fecha_fin,  to_char(vu.vue_hora_llegada,'HH24:mi:ss')
        from vuelo vu, estatus, lugar dest, lugar orig, ruta rut, aerolinea aero, mod_flota mofl
        where estatus.est_id = vu.fk_vue_estatus
            and rut.rut_id = vu.fk_vue_ruta
            and rut.fk_rut_salida = orig.lug_id
            and rut.fk_rut_llegada = dest.lug_id
            and aero.aero_id = mofl.fk_mofl_aerolinea
            and vu.fk_vue_flota = mofl.mofl_id
            and to_char(vu.vue_fecha.fecha_inicio, 'DD-MM-YYYY') = to_char(fecha_vuelo, 'DD-MM-YYYY');
    end if;
end;
--------------- REPORTE 13 -----------------

create or replace procedure reporteTrece(rep_cursor out sys_refcursor, fecha_inicio date, fecha_fin date, lugar varchar2)
is
begin
    if(fecha_inicio is null and fecha_fin is null) then
        open rep_cursor for
        select *
        from (
                select seg.seg_foto,CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas , total.salida, total.llegada,total.cantreservas, row_number() over (partition by total.fini, total.ffin order by total.fini, total.ffin ) RW
                from seguro seg, (select sr.sere_fecha.fecha_inicio AS FINI, sr.sere_fecha.fecha_fin as FFIN, a.lug_nombre AS SALIDA, b.lug_nombre as LLEGADA, count (sr.sere_id) as CANTRESERVAS
                    from seguro seg, seg_res sr, seg_serv ss, servicio svc, reserva res, res_vue rv, vuelo vu, ruta rut, lugar a, lugar b
                    where ss.fk_sese_seguro = seg.seg_id
                        and ss.fk_sese_servicio = svc.ser_id
                        and sr.fk_sere_servicio = ss.sese_id
                        and sr.fk_sere_reserva = res.res_id
                        and rv.fk_revu_reserva =  res.res_id
                        and rv.fk_revu_vuelo = vu.vue_id
                        and vu.fk_vue_ruta = rut.rut_id
                        and rut.fk_rut_salida = a.lug_id
                        and rut.fk_rut_llegada = b.lug_id
                    group by sr.sere_fecha.fecha_inicio, sr.sere_fecha.fecha_fin, a.lug_nombre, b.lug_nombre
                    order by CANTRESERVAS desc) TOTAL)
        where RW = 1
        fetch next 1 rows only;
    end if;
    
    if (fecha_fin is null and fecha_inicio is not null) then
        open rep_cursor for
        select *
        from (
                select seg.seg_foto,CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas, total.salida, total.llegada,total.cantreservas, row_number() over (partition by total.fini, total.ffin order by total.fini, total.ffin ) RW
                from seguro seg, (select sr.sere_fecha.fecha_inicio AS FINI, sr.sere_fecha.fecha_fin as FFIN, a.lug_nombre AS SALIDA, b.lug_nombre as LLEGADA, count (sr.sere_id) as CANTRESERVAS
                    from seguro seg, seg_res sr, seg_serv ss, servicio svc, reserva res, res_vue rv, vuelo vu, ruta rut, lugar a, lugar b
                    where ss.fk_sese_seguro = seg.seg_id
                        and ss.fk_sese_servicio = svc.ser_id
                        and sr.fk_sere_servicio = ss.sese_id
                        and sr.fk_sere_reserva = res.res_id
                        and rv.fk_revu_reserva =  res.res_id
                        and rv.fk_revu_vuelo = vu.vue_id
                        and vu.fk_vue_ruta = rut.rut_id
                        and rut.fk_rut_salida = a.lug_id
                        and rut.fk_rut_llegada = b.lug_id
                        and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(sr.sere_fecha.fecha_inicio, 'DD-MM-YYYY')
                    group by sr.sere_fecha.fecha_inicio, sr.sere_fecha.fecha_fin, a.lug_nombre, b.lug_nombre
                    order by CANTRESERVAS desc) TOTAL)
        where RW = 1
        fetch next 1 rows only;
    end if;
    
    if (fecha_inicio is not null and fecha_fin is not null) then
    open rep_cursor for
        select *
        from (
                select seg.seg_foto,CONCAT(CONCAT (TOTAL.fini,'-'), total.ffin) as fechas, total.salida, total.llegada,total.cantreservas, row_number() over (partition by total.fini, total.ffin order by total.fini, total.ffin ) RW
                from seguro seg, (select sr.sere_fecha.fecha_inicio AS FINI, sr.sere_fecha.fecha_fin as FFIN, a.lug_nombre AS SALIDA, b.lug_nombre as LLEGADA, count (sr.sere_id) as CANTRESERVAS
                    from seguro seg, seg_res sr, seg_serv ss, servicio svc, reserva res, res_vue rv, vuelo vu, ruta rut, lugar a, lugar b
                    where ss.fk_sese_seguro = seg.seg_id
                        and ss.fk_sese_servicio = svc.ser_id
                        and sr.fk_sere_servicio = ss.sese_id
                        and sr.fk_sere_reserva = res.res_id
                        and rv.fk_revu_reserva =  res.res_id
                        and rv.fk_revu_vuelo = vu.vue_id
                        and vu.fk_vue_ruta = rut.rut_id
                        and rut.fk_rut_salida = a.lug_id
                        and rut.fk_rut_llegada = b.lug_id
                        and to_char(fecha_inicio, 'DD-MM-YYYY') = to_char(sr.sere_fecha.fecha_inicio, 'DD-MM-YYYY')
                        and to_char(fecha_fin, 'DD-MM-YYYY') = to_char(sr.sere_fecha.fecha_fin, 'DD-MM-YYYY')
                    group by sr.sere_fecha.fecha_inicio, sr.sere_fecha.fecha_fin, a.lug_nombre, b.lug_nombre
                    order by CANTRESERVAS desc) TOTAL)
        where RW = 1
        fetch next 1 rows only;
    end if;
end;
