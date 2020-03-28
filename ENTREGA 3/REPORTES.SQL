create or replace procedure reporteSiete(rep_cursor out sys_refcursor, fecha_salida in varchar2, fecha_llegada in varchar2)
is
begin
        if (fecha_salida is not null and fecha_llegada is not null) then

            open rep_cursor for
            select t.fechas, t.origen, t.destino, t.cantidad 
            from 
            (select count (vu.vue_id) as cantidad ,ori.lug_nombre as origen, des.lug_nombre as destino, concat (concat(vu.vue_fecha.fecha_inicio, '-'), vu.vue_fecha.fecha_fin) as fechas
            from ruta rut, lugar ori, lugar des, res_vue rv, vuelo vu
            where rut.fk_rut_salida = ori.lug_id
            and rut.fk_rut_llegada = des.lug_id 
            and rv.fk_revu_vuelo = vu.vue_id 
            and vu.fk_vue_ruta = rut.rut_id
            and vu.VUE_FECHA.FECHA_INICIO >fecha_salida
            and vu.VUE_FECHA.FECHA_FIN < fecha_llegada
            group by vu.vue_id, ori.lug_nombre, des.lug_nombre, vu.vue_fecha.fecha_inicio, vu.vue_fecha.fecha_fin) t
            where rownum < 11
            order by t.cantidad desc;
        end if; 

        if (fecha_salida is null and fecha_llegada is null) then 

            open rep_cursor for
            select t.fechas, t.origen, t.destino, t.cantidad 
            from 
            (select count (vu.vue_id) as cantidad ,ori.lug_nombre as origen, des.lug_nombre as destino, concat (concat(vu.vue_fecha.fecha_inicio, '-'), vu.vue_fecha.fecha_fin) as fechas
            from ruta rut, lugar ori, lugar des, res_vue rv, vuelo vu
            where rut.fk_rut_salida = ori.lug_id
            and rut.fk_rut_llegada = des.lug_id 
            and rv.fk_revu_vuelo = vu.vue_id 
            and vu.fk_vue_ruta = rut.rut_id
            group by vu.vue_id, ori.lug_nombre, des.lug_nombre, vu.vue_fecha.fecha_inicio, vu.vue_fecha.fecha_fin) t
            where rownum < 11
            order by t.cantidad desc;
        end if; 
end;



--------------------REPORTE NUEVE OPCION SIN PARAMETROS ---------------------------------------------------
create or replace procedure reporteNueve (rep_cursor out sys_refcursor, fecha_salida in varchar2, fecha_llegada in varchar2, correo in varchar2)
is
begin
        if (fecha_salida is null and fecha_llegada is null and correo is null ) then 
         open rep_cursor for
            select  h.hot_foto, h.hot_nombre, us.usu_correo as correo, 
            concat(concat (rh.reho_fecha.fecha_inicio, ' '), to_char(rh.reho_fecha.fecha_inicio,'hh24:mi:ss')) as fechaentrada,
            concat(concat (rh.reho_fecha.fecha_fin, ' '), to_char(rh.reho_fecha.fecha_fin,'hh24:mi:ss')) as fechasalida,
            concat(concat (hab.hab_capacidad, ' '),'personas') as capacidad, hab.hab_descripcion as descripción, concat(concat (l.lug_nombre,', '), p.lug_nombre), 
            concat(concat (h.hot_puntuacion, ''),'/10'),concat (concat (rh.reho_monto.precio, ' '), '$')
            from usuario us, res_hot rh, reserva res, habitacion hab, hot_lugar hl, hotel h, lugar l, lugar p
            where rh.fk_reho_reserva = res.res_id 
            and res.fk_res_usuario = us.usu_id
            and rh.fk_reho_habitacion = hab.hab_id
            and hab.fk_hab_holu = hl.holu_id 
            and hl.fk_hot_lugar = l.lug_id
            and hl.fk_hot_hotel = h.hot_id
            and l.fk_lug_lugar = p.lug_id;
        end if; 
        
         if (fecha_salida is not null and fecha_llegada is not null and correo is not null ) then 
        open rep_cursor for
        select  h.hot_foto, h.hot_nombre, us.usu_correo as correo, 
        concat(concat (rh.reho_fecha.fecha_inicio, ' '), to_char(rh.reho_fecha.fecha_inicio,'hh24:mi:ss')) as fechaentrada,
        concat(concat (rh.reho_fecha.fecha_fin, ' '), to_char(rh.reho_fecha.fecha_fin,'hh24:mi:ss')) as fechasalida,
        concat(concat (hab.hab_capacidad, ' '),'personas') as capacidad, hab.hab_descripcion as descripción, concat(concat (l.lug_nombre,', '), p.lug_nombre), 
        concat(concat (h.hot_puntuacion, ''),'/10'),concat (concat (rh.reho_monto.precio, ' '), '$')
        from usuario us, res_hot rh, reserva res, habitacion hab, hot_lugar hl, hotel h, lugar l, lugar p
        where rh.fk_reho_reserva = res.res_id 
        and res.fk_res_usuario = us.usu_id
        and rh.fk_reho_habitacion = hab.hab_id
        and hab.fk_hab_holu = hl.holu_id 
        and hl.fk_hot_lugar = l.lug_id
        and hl.fk_hot_hotel = h.hot_id
        and l.fk_lug_lugar = p.lug_id
        and us.usu_correo = correo
        and rh.reho_fecha.fecha_inicio > = fecha_salida
        and rh.reho_fecha.fecha_fin < fecha_llegada;
        end if;
end;