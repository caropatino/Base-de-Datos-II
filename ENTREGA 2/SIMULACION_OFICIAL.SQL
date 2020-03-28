/* ------------------------------------------------------------------ GENERA NUMERO RANDOM ENTRE UN MINIMO Y MAXIMO DADO -------------------------------------------------------------------------------------------- */
create or replace function RANDOM(minimo NUMBER, maximo NUMBER) return number 
    is 
        a number; 
    begin
        select round(dbms_random.value(minimo, maximo)) rnum into a 
        from dual;
        return a;
    end;
 /* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */  
 
/* ------------------------------------------------------------------ GENERAR UNA RESERVA -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION crearReserva(id_usuario NUMBER, usuario_name VARCHAR) RETURN NUMBER
IS
    id_usuario_asignar NUMBER;
    id_reserva_creada NUMBER;
    user_name VARCHAR(50);
    hora_registro VARCHAR(30);
BEGIN
    id_usuario_asignar := id_usuario;
    user_name := usuario_name;
    INSERT INTO RESERVA(RES_FECHA, TOTAL, FK_RES_USUARIO) VALUES((SELECT (CURRENT_DATE) FROM dual), MONTOS(0, 'D'),id_usuario_asignar) RETURNING RES_ID INTO id_reserva_creada;
    SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
    dbms_output.put_line('(CrearReserva)'||hora_registro || ': ' || 'Se ha generado una nueva reservación para el usuario: ' || user_name || '. Numero de identicación de Reserva: ' || id_reserva_creada);
    
    RETURN id_reserva_creada;
END;
 /* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */  

/* ------------------------------------------------------------------ SELECCIONAR AUTO -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION seleccionarAutomovil(ruta NUMBER, estado NUMBER, pais NUMBER) RETURN NUMBER
IS
    id_automovil NUMBER;
    id_estado NUMBER; /*estado de LUGAR*/
BEGIN  
    id_estado := estado;    /*estado de LUGAR*/
    if(id_estado = 0) then  /* Si es 0 significa que el usuario esta haciendo la reserva de un automovil de manera independiente, es decir, no ha realizado ningun otro tipo de reservación tal como vuelo o habitación de hotel. */ 
        begin        
            select AUTOMOVIL into id_automovil from (select aut.AUT_ID AS AUTOMOVIL from automovil aut, prov_auto pa where PA.FK_PRAU_ESTATUS = 1 and pa.FK_PRAU_AUTOMOVIL = aut.AUT_ID order by dbms_random.value) where rownum = 1;
            exception 
                when NO_DATA_FOUND then
                    id_automovil := null;                  
        end;
        if id_automovil IS NULL THEN
            return 0;
        end if;
    end if;
    
    if(id_estado != 0) then
        begin        
            select AUTOMOVIL into id_automovil from (select aut.AUT_ID AS AUTOMOVIL from automovil aut, prov_auto pa, proveedor pro, sede se where PA.FK_PRAU_ESTATUS = 1 and pa.FK_PRAU_AUTOMOVIL = aut.AUT_ID and pa.FK_PRAU_PROVEEDOR = pro.PRO_ID and se.FK_SED_PROVEEDOR = pro.PRO_ID and se.FK_SED_LUGAR = id_estado order by dbms_random.value) where rownum = 1;
            exception 
                    when NO_DATA_FOUND then
                        id_automovil := null;                  
        end;
        if id_automovil IS NULL THEN
            return 0;
        end if;
    end if;
RETURN id_automovil;
END;

/* ------------------------------------------------------------------ SELECCIONAR PROVEEDOR -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION seleccionarProveedor(automovil NUMBER, estado NUMBER) RETURN NUMBER
IS
    id_proveedor NUMBER;
    id_automovil NUMBER;
    id_estado NUMBER;   /*estado de LUGAR*/
BEGIN   

    id_automovil := automovil;
    id_estado := estado;  /*estado de LUGAR*/
     
    if(id_estado = 0) then        
        begin
            select proveedor into id_proveedor from (select PRO.PRO_ID AS proveedor FROM PROVEEDOR PRO, PROV_AUTO PA WHERE PRO.PRO_ID = PA.FK_PRAU_PROVEEDOR AND id_automovil = PA.FK_PRAU_AUTOMOVIL order by dbms_random.value) WHERE rownum = 1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    id_proveedor := null;
        end;
        if id_proveedor IS NULL THEN
            return 0;
        end if;
    end if;
    
    if (id_estado != 0) then       
        begin
            select proveedor into id_proveedor from (select PRO.PRO_ID AS proveedor FROM PROVEEDOR PRO, PROV_AUTO PA, sede se WHERE PRO.PRO_ID = PA.FK_PRAU_PROVEEDOR AND id_automovil = PA.FK_PRAU_AUTOMOVIL and se.FK_SED_PROVEEDOR = pro.PRO_ID and se.FK_SED_LUGAR = id_estado order by dbms_random.value)WHERE rownum = 1;
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN 
                        id_proveedor := null;
        end;
        if id_proveedor IS NULL THEN
            return 0;
        end if;
    end if;    

RETURN id_proveedor;
END;

/* ------------------------------------------------------------------ RESERVAR AUTOMOVIL -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reservarAutomovil(id_reserva NUMBER, usuario_name VARCHAR, ruta NUMBER, estado NUMBER, pais NUMBER) RETURN NUMBER
IS
    id_reserva_asignar NUMBER;
    id_automovil NUMBER;
    id_proveedor NUMBER;
    id_sede NUMBER;
    id_estado_recogida NUMBER;
    id_pais NUMBER;
    id_sede_entrega NUMBER;
    id_reserva_auto NUMBER;
    id_ruta NUMBER;
    id_estado NUMBER;
    id_paisLlegada NUMBER;
    id_sede_recogida NUMBER;    
    hora_registro VARCHAR(30);
    user_name VARCHAR(50);
    fecha_ini date;
    fecha_fin date;
    precio_dia NUMBER;
    dias_reserva number;
     fecha1 date;
    
    vehiculo automovil%rowtype;   
    
    id_prov_auto NUMBER;
BEGIN
    id_reserva_asignar := id_reserva;
    user_name := usuario_name;
    id_ruta := ruta;
    id_estado := estado;
    id_paisLlegada := pais;
        
    id_automovil := seleccionarAutomovil(id_ruta, id_estado, id_paisLlegada); /*listo*/
    
    if(id_automovil = 0) then
        SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
        dbms_output.put_line(hora_registro || ': ' || 'El usuario decidió cancelar la reserva de un automóvil.');
        return 0;
    end if;
    if(id_automovil != 0) then            
        id_proveedor := seleccionarProveedor(id_automovil, id_estado);          
    end if;
    
    if(id_proveedor != 0 and id_automovil != 0) then
        dbms_output.put_line('(ReservarAutomovil) id del automovil asignado: ' || id_automovil);        
        dbms_output.put_line('(ReservarAutomovil) id del proveedor de dicho automovil: ' || id_proveedor);
        
        if(id_estado = 0) then            
            begin
                select sede into id_sede from (select se.SED_ID as sede from sede se where se.FK_SED_PROVEEDOR = id_proveedor order by dbms_random.value) where rownum = 1;
                EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    id_sede := null;
            end;          
            select fk_sed_lugar into id_estado_recogida from sede se where se.SED_ID = id_sede;
        end if;
        if(id_estado != 0) then         
            begin            
                select sede into id_sede from (select se.SED_ID as sede from sede se where se.FK_SED_PROVEEDOR = id_proveedor and se.FK_SED_LUGAR = id_estado order by dbms_random.value) where rownum = 1;
                EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    id_sede := null;
            end;            
            id_estado_recogida := id_estado;          
        end if;
        select FK_LUG_LUGAR into id_pais from lugar se where se.LUG_ID = id_estado_recogida;
        begin
            select sede_entrega into id_sede_entrega from (select se.SED_ID as sede_entrega from sede se, lugar lu where se.fk_sed_lugar = lu.lug_id and lu.fk_lug_lugar = id_pais and se.fk_sed_proveedor = id_proveedor order by dbms_random.value) where rownum = 1;
            EXCEPTION 
                WHEN NO_DATA_FOUND THEN 
                    id_sede_entrega := null;
        end; 
        
        
       
        select SED_ID into id_sede_recogida from sede, lugar l where FK_SED_PROVEEDOR = id_proveedor and FK_SED_LUGAR = l.LUG_ID and l.FK_LUG_LUGAR = id_pais;        
        begin
        dbms_output.put_line('(ReservarAutomovil) Id sede de recogida = ' || id_sede_recogida);
        select montoDia into precio_dia from (select pa.PRAU_PRECIO_DIA.precio as montoDia from PROV_AUTO pa, sede se, proveedor pro, automovil aut where se.SED_ID = id_sede_recogida and se.FK_SED_PROVEEDOR = pro.PRO_ID and pa.FK_PRAU_PROVEEDOR = pro.PRO_ID and aut.AUT_ID = pa.PRAU_ID order by dbms_random.value) where rownum = 1;
            EXCEPTION 
                WHEN NO_DATA_FOUND 
                    THEN /*precio_dia := 0;*/
                    dbms_output.put_line('(ReservarAutomovil) El Usuario decidió cancelar la reserva del Automóvil.');
                    return 0;
        end;
      
        select id_provaut into id_prov_auto from (select pa.PRAU_ID as id_provaut from PROV_AUTO pa where pa.FK_PRAU_AUTOMOVIL = id_automovil and pa.FK_PRAU_PROVEEDOR = id_proveedor) where rownum = 1;
        
         fecha1:= to_date('2018-01-01', 'yyyy-mm-dd')+dbms_random.value(1,1000);  
        insert into RES_AUT(REAU_MONTO, FK_REAU_PROVEEDOR, FK_REAU_RECOGE, FK_REAU_RECIBE, FK_REAU_RESERVA, REAU_FECHA) values (MONTOS(0, 'D'), id_proveedor, id_sede, id_sede_entrega, id_reserva_asignar, FECHAS(fecha1 , fechas.validar_fechas (fecha1,to_date('2018-01-01', 'yyyy-mm-dd')+dbms_random.value(1,1000)))) RETURNING REAU_ID INTO id_reserva_auto;
        
        select ra.REAU_FECHA.FECHA_INICIO into fecha_ini from RES_AUT ra where ra.REAU_ID = id_reserva_auto;
        select ra.REAU_FECHA.FECHA_FIN into fecha_fin from RES_AUT ra where ra.REAU_ID = id_reserva_auto;
        dbms_output.put_line('(ReservarAutomovil) Se procede a realizar el calculo del monto a pagar por la reserva del automovil.');
        dbms_output.put_line('(ReservarAutomovil) Id del proveedor: ' || id_proveedor || ' y id del automovil: ' || id_automovil);        
        dbms_output.put_line('(ReservarAutomovil) Dado el auto y el proveedor, resulto ser que idd del PROV_AUTO = ' || id_prov_auto);
        SELECT trunc(fecha_fin) - trunc(fecha_ini) INTO dias_reserva from dual;  /*obtengo la cantidad de dias que es reservado el auto*/
        if(dias_reserva < 0) then
            dias_reserva := dias_reserva * -1; /*solo por si acaso, pues lo que importa es el nùmero no su signo*/
        end if; 
        update RES_AUT reau set reau.REAU_MONTO.precio = reau.REAU_MONTO.precio + (precio_dia * dias_reserva) where REAU_ID = id_reserva_auto;
        dbms_output.put_line('(ReservarAutomovil) Se ha realizado el calculo del monto a pagar por la reserva del automovil exitosamente.');
        SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;        
        dbms_output.put_line(hora_registro || ': ' || '¡Se ha reservado un vehiculo exitosamente!');
        
        update RESERVA re set re.TOTAL.precio = re.TOTAL.precio + (precio_dia * dias_reserva) where id_reserva_asignar = re.RES_ID;         
        
        update PROV_AUTO set FK_PRAU_ESTATUS = 4 where FK_PRAU_AUTOMOVIL = id_automovil;
        
    end if;
    
    if(id_proveedor = 0) then
        dbms_output.put_line('(ReservarAutomovil) Ha ocurrido un error durante la insercion del automovil. id de proveedor devuelto resultó ser 0.');
        id_reserva_auto := 0;
    end if;
    
    select * into vehiculo from automovil where AUT_ID = id_automovil;
    SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
    
    dbms_output.put_line('(ReservarAutomovil) '|| hora_registro || ': ' || 'Se encuentra disponible el vehículo número: ' || vehiculo.AUT_ID || ' cuya marca es: ' || vehiculo.AUT_MARCAMODELO);
    dbms_output.put_line('(ReservarAutomovil) '|| hora_registro || ': ' || user_name || ' ha realizado la reservación de un vehículo con las siguientes especificaciones: ');
    dbms_output.put_line('(ReservarAutomovil)           * Numero de Identificacion del vehículo: ' || vehiculo.AUT_ID);
    dbms_output.put_line('(ReservarAutomovil)          * Marca: '  || vehiculo.AUT_MARCAMODELO);
    dbms_output.put_line('(ReservarAutomovil)           * Tipo de vehículo: '  || vehiculo.AUT_TIPO);
    dbms_output.put_line('(ReservarAutomovil)           * Capacidad: ' || vehiculo.AUT_CAPACIDAD);
    dbms_output.put_line('(ReservarAutomovil)           * Cantidad de puertas: '  || vehiculo.AUT_PUERTAS);
    dbms_output.put_line('(ReservarAutomovil)           * Tipo de cambio: '  || vehiculo.AUT_CAMBIO);
    
RETURN id_reserva_auto;
END;
 /* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */ 
 
/* ------------------------------------------------------------------ ESCOGER HABITACION AL AZAR -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION seleccionarHabitacion(estado NUMBER) RETURN NUMBER
IS
    id_habitacion NUMBER;
    id_estado NUMBER;
    datos_hotel Hotel%rowtype;
    random_holu number(5);
    capacidad number(5);

BEGIN
    id_estado := estado;
    capacidad  := dbms_random.value(1,10);
    if(id_estado = 0) then
        begin
            random_holu := dbms_random.value(1,100);
            Select h.* into datos_hotel from hotel h, HOT_LUGAR hl where hl.holu_id = random_holu and hl.fk_hot_hotel = h.hot_id;
            dbms_output.put_line('(seleccionarHabitacion) El usuario ha escogido el Hotel ' || datos_hotel.hot_nombre);
            dbms_output.put_line('(seleccionarHabitacion) Se desea una habitación con capacidad para  ' || capacidad || ' personas ');
            select habitacion into id_habitacion from (select hab.HAB_ID as habitacion from habitacion hab where hab.FK_HAB_ESTATUS = 1 and hab.FK_HAB_HOLU = random_holu
                and hab_capacidad > = capacidad
                order by dbms_random.value) where rownum = 1; 
            EXCEPTION 
                WHEN NO_DATA_FOUND 
                    THEN id_habitacion := null;
        end;
        if id_habitacion is null then
            return 0;
        end if;
    end if;   
    if(id_estado != 0) then
        begin
            Select holu_id into random_holu from HOT_LUGAR hl where hl.FK_HOT_LUGAR = id_estado;
            Select h.* into datos_hotel from hotel h, HOT_LUGAR hl where hl.holu_id = random_holu and hl.fk_hot_hotel = h.hot_id;
            dbms_output.put_line('(seleccionarHabitacion) El usuario ha escogido el Hotel ' || datos_hotel.hot_nombre);
            dbms_output.put_line('(seleccionarHabitacion) Se desea una habitación con capacidad para  ' || capacidad || ' personas ');
            select habitacion into id_habitacion from (select hab.HAB_ID as habitacion from habitacion hab where hab.FK_HAB_ESTATUS = 1 and hab.FK_HAB_HOLU = random_holu
                and hab_capacidad > = capacidad
                order by dbms_random.value) where rownum = 1; 
            EXCEPTION 
                WHEN NO_DATA_FOUND 
                    THEN id_habitacion := null;
        end;
        if id_habitacion is null then
            return 0;
        end if;
    end if;
    update habitacion  set FK_HAB_ESTATUS= 4 where hab_id = id_habitacion;
RETURN id_habitacion;
END;

/* ------------------------------------------------------------------ RESERVAR HABITACION DE HOTEL -------------------------------------------------------------------------------------------- */
create or replace NONEDITIONABLE FUNCTION reservarHabitacion(id_reserva NUMBER, usuario_name VARCHAR, estado NUMBER) RETURN NUMBER
IS
    id_reserva_asignar NUMBER;
    user_name VARCHAR(50);
    hora_registro VARCHAR(30);

    id_habitacion NUMBER;
    id_reserva_habitacion NUMBER;
    id_estado NUMBER;    /*estado de lugar*/

    fecha_ini date;
    fecha_fin date;
    fecha1 date;

    precio_dia number;
    dias_reserva number;
BEGIN
    id_reserva_asignar := id_reserva;
    user_name := usuario_name;
    id_estado := estado;

    id_habitacion := seleccionarHabitacion(id_estado);

    if (id_habitacion = 0) then
        SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
        dbms_output.put_line('(reservarHabitacion)'|| hora_registro || ': ' || 'Lamentamos informar que no contamos con habitaciones disponibles en este momento. Por favor, vuelva a intentarlo más tarde.');
        return 0;
    end if;

    if (id_habitacion != 0) then
        dbms_output.put_line('(reservarHabitacion) Id de habitación asignado / reservado: ' || id_habitacion);
        fecha1:= to_date('2018-01-01 11:00', 'yyyy-mm-dd HH24:MI:SS')+dbms_random.value(1,1000);
        insert into RES_HOT(REHO_FECHA, REHO_MONTO, FK_REHO_HABITACION, FK_REHO_RESERVA) VALUES(FECHAS(fecha1 , fechas.validar_fechas(fecha1,to_date('2018-01-01 11:00', 'yyyy-mm-dd HH24:MI:SS')+dbms_random.value(1,1000))), MONTOS(0, 'D'), id_habitacion, id_reserva_asignar) RETURNING REHO_ID INTO id_reserva_habitacion;
        select hab.HAB_PRECIOXDIA.PRECIO into precio_dia from habitacion hab where hab.HAB_ID = id_habitacion;        
        select rh.REHO_FECHA.FECHA_INICIO into fecha_ini from RES_HOT rh where rh.REHO_ID = id_reserva_habitacion;
        select rh.REHO_FECHA.FECHA_FIN into fecha_fin from RES_HOT rh where rh.REHO_ID = id_reserva_habitacion;
        SELECT trunc(fecha_fin) - trunc(fecha_ini) INTO dias_reserva from dual;  /*obtengo la cantidad de dias que es reservado el auto*/
        dbms_output.put_line('Se procede a realizar el calculo del monto a pagar por la reserva de la habitacion.');
        if(dias_reserva < 0) then
            dias_reserva := dias_reserva * -1; /*solo por si acaso, pues lo que importa es el número no su signo*/
        end if; 
        update RES_HOT rh set rh.REHO_MONTO.precio = rh.REHO_MONTO.precio + (precio_dia * dias_reserva) where rh.REHO_ID = id_reserva_habitacion;
        dbms_output.put_line('(reservarHabitacion) Calculo del monto a pagar por la reserva de la habitación realizado exitosamente.');

        update RESERVA re set re.TOTAL.precio = re.TOTAL.precio + (precio_dia * dias_reserva) where id_reserva_asignar = re.RES_ID;     

    end if;

RETURN id_reserva_habitacion;
END;
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------ OBTENER ASIENTO LIBRE -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION obtenerAsiento(vuelo NUMBER, clase NUMBER) RETURN NUMBER
IS
    id_asiento NUMBER;
    id_vuelo NUMBER;
    id_clase NUMBER;
BEGIN
    id_vuelo := vuelo;
    id_clase := clase;
    begin        
        select asiento into id_asiento from (select a.asi_id as asiento from vuelo vue, mod_flota mf, flota f, asi_cla ac, clase c, asiento a where vue.VUE_ID = id_vuelo and vue.FK_VUE_FLOTA = mf.MOFL_ID and mf.FK_MOFL_FLOTA = f.FLO_ID and ac.FK_ASCL_FLOTA = f.FLO_ID and c.CLA_ID = id_clase and a.FK_ASI_CLASE = ac.ASCL_ID and a.FK_ASI_ESTATUS = 1 order by dbms_random.value) where rownum = 1;
        EXCEPTION 
            WHEN NO_DATA_FOUND 
                THEN id_asiento := null;   
    end;
    if id_asiento is null then
        return 0;
    end if;
RETURN id_asiento;
END;


CREATE OR REPLACE FUNCTION obtenerClaseAsiento(vuelo NUMBER) RETURN NUMBER
IS
    id_clase NUMBER;
    id_vuelo NUMBER;
BEGIN
    id_vuelo := vuelo;
    begin
        select clase into id_clase from (select c.CLA_ID as clase from vuelo vue, mod_flota mf, flota f, asi_cla ac, clase c, asiento a where vue.VUE_ID = id_vuelo and vue.FK_VUE_FLOTA = mf.MOFL_ID and mf.FK_MOFL_FLOTA = f.FLO_ID and ac.FK_ASCL_FLOTA = f.FLO_ID and c.CLA_ID = ac.FK_ASCL_CLASE and a.FK_ASI_CLASE = ac.ASCL_ID and a.FK_ASI_ESTATUS = 1 order by dbms_random.value) where rownum = 1; 
        EXCEPTION 
            WHEN NO_DATA_FOUND 
                THEN id_clase := null;   
    end;
    if id_clase is null then
        return 0;
    end if;
RETURN id_clase;
END;

/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

/* ------------------------------------------------------------------ OBTENER SERVICIO DE SEGURO -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION obtenerServicio(reserva NUMBER) RETURN NUMBER
IS   
    id_seguro_servicio NUMBER;
BEGIN    
    begin
        select seguroServicio into id_seguro_servicio FROM (select SESE_ID as seguroServicio from SEG_SERV order by dbms_random.value) where rownum = 1;
        EXCEPTION 
            WHEN NO_DATA_FOUND 
                THEN id_seguro_servicio := null; 
    end;
    if id_seguro_servicio is null then
        return 0;
    end if;
RETURN id_seguro_servicio;
END;

/* ------------------------------------------------------------------ RESERVAR SEGURO -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reservarSeguro(reserva NUMBER) RETURN NUMBER
IS
    id_reserva_asignar NUMBER;
    id_seguro_servicio NUMBER;
    id_reserva_seguro NUMBER;
    precio_dia NUMBER;
    fecha_ini date;
    fecha_fin date;
    dias_reserva NUMBER;
    fecha1 date;
BEGIN
    id_reserva_asignar := reserva;
    id_seguro_servicio := obtenerServicio(id_reserva_asignar);
    dbms_output.put_line('(reservarSeguro) id de servicio seguro escogido: ' || id_seguro_servicio);
    
    fecha1:= to_date('2018-01-01', 'yyyy-mm-dd')+dbms_random.value(1,1000);
    insert into SEG_RES(SERE_FECHA, FK_SERE_SERVICIO, SERE_TOTAL, FK_SERE_RESERVA) values(FECHAS(fecha1 , fechas.validar_fechas(fecha1,to_date('2018-01-01', 'yyyy-mm-dd')+dbms_random.value(1,1000))), id_seguro_servicio, MONTOS(0, 'D'), id_reserva_asignar) RETURNING SERE_ID INTO id_reserva_seguro;
    
    select ser.SER_PRECIO.precio into precio_dia from servicio ser, seg_serv ss where ss.SESE_ID = id_seguro_servicio and ss.FK_SESE_SEGURO = ser.SER_ID;        
    select sr.SERE_FECHA.FECHA_INICIO into fecha_ini from SEG_RES sr where sr.SERE_ID = id_reserva_seguro;
    select sr.SERE_FECHA.FECHA_FIN into fecha_fin from SEG_RES sr where sr.SERE_ID = id_reserva_seguro;
    SELECT trunc(fecha_fin) - trunc(fecha_ini) INTO dias_reserva from dual;  /*obtengo la cantidad de dias que es reservado el auto*/
    dbms_output.put_line('(reservarSeguro) Se calcula el monto a pagar por la reserva del servicio de seguro escogido.');
    if(dias_reserva < 0) then
        dias_reserva := dias_reserva * -1; /*solo por si acaso, pues lo que importa es el nùmero no su signo*/
    end if; 
    update SEG_RES sr set sr.SERE_TOTAL.precio = sr.SERE_TOTAL.precio + (precio_dia * dias_reserva) where sr.SERE_ID = id_reserva_seguro;
    dbms_output.put_line('(reservarSeguro) Monto de reserva de servicio de seguro calculado exitosamente.');
    
    update RESERVA re set re.TOTAL.precio = re.TOTAL.precio + (precio_dia * dias_reserva) where id_reserva_asignar = re.RES_ID;
    
RETURN id_reserva_seguro;
END;

/* ------------------------------------------------------------------ RESERVAR VUELO -------------------------------------------------------------------------------------------- */
CREATE OR REPLACE FUNCTION reservarVuelo(id_reserva NUMBER, usuario_name VARCHAR, usuario_id NUMBER) RETURN NUMBER
IS
    id_reserva_asignar NUMBER;
    user_name VARCHAR(50);
    hora_registro VARCHAR(30);
    user_id NUMBER;
    
    id_vuelo NUMBER;
    id_reserva_vuelo NUMBER;
    id_clase NUMBER;
    id_asiento NUMBER;
    nombreclase varchar (20);
    
    reservar_habitacion NUMBER; /*booleano 1 = usuario quiere reservar habitacion / 0 = usuario no quiere reservar habitación*/
    reservar_vehiculo NUMBER; /*booleano 1 = usuario quiere reservar habitacion / 0 = usuario no quiere reservar habitación*/
    reservar_seguro NUMBER; /*booleano 1 = usuario quiere reservar habitacion / 0 = usuario no quiere reservar habitación*/
    
    id_habitacion NUMBER;
    id_vehiculo NUMBER;
    id_seguro NUMBER;
    
    id_ruta NUMBER;
    id_estado NUMBER;
    id_pais NUMBER;
    
    cant_km NUMBER;
    precio_km NUMBER;
    incremento_asiento NUMBER;
    
    quedan_asientos NUMBER;
       fecha date;
    mes varchar(20);
BEGIN
    id_reserva_asignar := id_reserva;
    user_name := usuario_name;
    user_id := usuario_id;
 
    begin
        select vuelo into id_vuelo from (select vue.VUE_ID as vuelo from vuelo vue where vue.FK_VUE_ESTATUS = 9  order by dbms_random.value) where rownum = 1;  
        EXCEPTION 
            WHEN NO_DATA_FOUND 
                THEN id_vuelo := null;  
    end;
    if id_vuelo is not null then
    dbms_output.put_line('(ReservarVuelo)Se asigno el id de vuelo: ' || id_vuelo);
        insert into RES_VUE(REVU_MONTO, FK_REVU_RESERVA, FK_REVU_VUELO) VALUES(MONTOS(0, 'D'), id_reserva_asignar, id_vuelo) RETURNING REVU_ID INTO id_reserva_vuelo;    
        insert into usu_res_vue (FK_URV_USUARIO, FK_URV_RESVUE) VALUES (user_id, id_reserva_vuelo);
        id_clase := obtenerClaseAsiento(id_vuelo);
        select cla_nombre into nombreclase from clase where cla_id = id_clase;
        dbms_output.put_line('(ReservarVuelo) Se buscará un asiento en la clase ' || nombreclase);
        id_asiento := obtenerAsiento(id_vuelo, id_clase);
        if id_asiento is not null then
        dbms_output.put_line('(ReservarVuelo)Se asigno id de asiento: ' || id_asiento );
            UPDATE USUARIO SET FK_USU_ASIENTO = id_asiento where USU_ID = user_id;
            dbms_output.put_line('(ReservarVuelo)Listo. Reservo un vuelo y asigno el id del asiento al usuario. id del usuario: ' || user_id); 
            
            update asiento set FK_ASI_ESTATUS = 4 where ASI_ID = id_asiento;
            quedan_asientos := obtenerAsiento(id_vuelo,id_clase);
            if(quedan_asientos = 0) then
                update vuelo set FK_VUE_ESTATUS = 2 where VUE_ID = id_vuelo;  
            end if;
            
            
            dbms_output.put_line ('(ReservarVuelo)Se procede a realizar el cálculo de la reserva del vuelo.');            
            select rut.RUT_DISTANCIA into cant_km from ruta rut, vuelo vue where rut.RUT_ID = vue.FK_VUE_RUTA and vue.VUE_ID = id_vuelo; /* obtener cant km */
            select a.PRECIO_KM.PRECIO into precio_km from aerolinea a, vuelo vue, mod_flota mf where a.AERO_ID = mf.FK_MOFL_AEROLINEA and mf.MOFL_ID = vue.FK_VUE_FLOTA and vue.VUE_ID = id_vuelo; /* obtener precio por km */
            select c.CLA_INCREMENTO into incremento_asiento from clase c where cla_id= id_clase; /* obtener incremento por clase de asiento */
            dbms_output.put_line ('(ReservarVuelo) Se aplicará un incremento del ' || incremento_asiento || '% al boleto por haber seleccionado la clase ' || nombreclase );      
            
            select v.vue_fecha.fecha_inicio into fecha from vuelo v where vue_id = id_vuelo;    
select to_char(to_date('15-11-2010', 'DD-MM-YYYY'), 'Month') into mes from dual ;
            
            if (mes = 'Julio') or (mes = 'Agosto') or (mes = 'Septiembre') or (mes = 'Diciembre') then 
            dbms_output.put_line ('(ReservarVuelo) Se aplicará un incremento del 15 % al boleto por tratarse de temporada alta ');   
              update RES_VUE rv set rv.REVU_MONTO.precio = ( rv.REVU_MONTO.precio + ((cant_km / precio_km) + incremento_asiento)) * 1.15 where rv.REVU_ID = id_reserva_vuelo;
            
            update RESERVA re set re.TOTAL.precio = (re.TOTAL.precio + ((cant_km / precio_km) + incremento_asiento)) * 1.15 where id_reserva_asignar = re.RES_ID;
            dbms_output.put_line('(ReservarVuelo) Se realizó el calculo del precio de la reserva del vuelo exitosamente.');
            

            else 
              update RES_VUE rv set rv.REVU_MONTO.precio = rv.REVU_MONTO.precio + ((cant_km / precio_km) + incremento_asiento) where rv.REVU_ID = id_reserva_vuelo;
            
            update RESERVA re set re.TOTAL.precio = re.TOTAL.precio + ((cant_km / precio_km) + incremento_asiento) where id_reserva_asignar = re.RES_ID;
            dbms_output.put_line('(ReservarVuelo) Se realizó el calculo del precio de la reserva del vuelo exitosamente.');

            end if;   
            

          
            dbms_output.put_line('(ReservarVuelo) Se procede a agregar en millas acumulado del Usuario.');
            update MIL_USU mu set mu.MIUS_ACUMULADO = mu.MIUS_ACUMULADO + cant_km where mu.FK_MIUS_USUARIO = user_id;
            dbms_output.put_line('(ReservarVuelo) Se aumento exitosamente el acumulado de millas del usuario.');
            
            begin
                select ruta into id_ruta from (select ru.RUT_ID as ruta from ruta ru, vuelo vue where vue.FK_VUE_RUTA = RUT_ID and vue.VUE_ID = id_vuelo order by dbms_random.value) where rownum = 1;
                EXCEPTION 
                    WHEN NO_DATA_FOUND 
                        THEN id_ruta := null;
            end;
            if id_ruta is not null then
                begin
                    select estado into id_estado from (select es.LUG_ID as estado from lugar es, ruta rut where es.LUG_ID = rut.FK_RUT_LLEGADA and rut.RUT_ID = id_ruta order by dbms_random.value) where rownum = 1;
                    EXCEPTION 
                        WHEN NO_DATA_FOUND 
                            THEN id_estado := null;
                end;
                if id_estado is not null then
                    begin
                        select pais into id_pais from (select pa.LUG_ID as pais from lugar pa, lugar es where es.LUG_ID = id_estado and pa.LUG_ID = es.FK_LUG_LUGAR order by dbms_random.value) where rownum = 1;
                        EXCEPTION 
                            WHEN NO_DATA_FOUND 
                                THEN id_pais := null;
                    end;
                    if id_pais is not null then
                    dbms_output.put_line('¿Desea escoger algun tipo de servicio adicional? --> HABITACION | AUTOMOVIL | HOTEL');
                        SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
                        select Random(0,1) into reservar_habitacion from dual; /*¿Usuario desea reservar una habitación?*/                        
                        if(reservar_habitacion = 1) then
                            dbms_output.put_line('ReservarVuelo)'|| hora_registro || ': ' || 'El usuario desea incluir en su reserva el alquiler una habitación.');
                            id_habitacion := reservarHabitacion(id_reserva, usuario_name, id_estado);
                        end if;
                    
                        select Random(0,1) into reservar_vehiculo from dual; /*¿Usuario desea reservar un vehículo?*/                        
                        if(reservar_vehiculo = 1) then
                            dbms_output.put_line('ReservarVuelo)'|| hora_registro || ': ' || 'El usuario desea incluir en su reserva el alquler de un vehículo');                
                            id_vehiculo := reservarAutomovil(id_reserva, usuario_name, id_ruta, id_estado, id_pais);   
                        end if;
                    
                        select Random(0,1) into reservar_seguro from dual; /*¿Usuario desea reservar un seguro?*/
                        if(reservar_seguro = 1) then
                            dbms_output.put_line('ReservarVuelo)'|| hora_registro || ': ' || 'El usuario desea incluir en su reserva la contratación de un seguro');
                            id_seguro := reservarSeguro(id_reserva);
                        end if;
                     end if;
                end if;
            end if;
                   
        end if;
        return id_reserva_vuelo;
    end if;   
RETURN 0;
end;
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */

CREATE OR REPLACE PROCEDURE SIMULACION(id_assigned NUMBER) 

IS

    contador NUMBER(10);  /*cantida de veces en que se va a repetir la simulación */
    tipo_servicio NUMBER(1);
    cantidad_usuarios NUMBER(20);
    usuario_nombre VARCHAR(50);
    hora_registro VARCHAR(30);
    
    /* ----- ids ----*/
    usuario_id NUMBER;
    id_reserva NUMBER;
    id_res_aut NUMBER;
    id_res_hab NUMBER;
    id_res_vue NUMBER;
    /*---------------*/
    
    monto_a_pagar NUMBER;
    millas_acumuladas NUMBER;
    
BEGIN    
    contador := 4; 
    usuario_id := id_assigned;

    while (contador > 0)        
        LOOP
         dbms_output.put_line('   ');
         dbms_output.put_line('-------------------------------------------NUEVA RESERVA ---------------------------------------------');
         dbms_output.put_line('   ');
         dbms_output.put_line('   ');

        /* ------------------------------------------------------------------ ESCOGER USUARIO A REALIZAR RESERVA -------------------------------------------------------------------------------------------- */
            IF (usuario_id = 0) THEN  /* Si no hay ningun usuario asignado... */               
                select user_id into usuario_id from (select u.usu_id as user_id from usuario u order by dbms_random.value) where rownum = 1;
                select usua.usu_datos.primer_nombre into usuario_nombre from usuario usua where usua.usu_id = usuario_id;
                SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;
                dbms_output.put_line('(Simulacion)'||hora_registro || ': ' || 'El usuario ' || usuario_nombre || ' con numero de identificación ' || usuario_id || ' va a realizar una reserva.');
            END IF;
        /* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */    
        
        /* ------------------------------------------------------------------ REALIZAR UNA RESERVA -------------------------------------------------------------------------------------------- */
            id_reserva := crearReserva(usuario_id, usuario_nombre);
            dbms_output.put_line(hora_registro || ': El usuario procede a escoger los detalles de su reservación. RESERVATION_ID:  ' || id_reserva);
            select Random(1,3) into tipo_servicio from dual;
            SELECT TO_CHAR(CURRENT_DATE, 'HH:MI') INTO hora_registro FROM dual;         
            IF (tipo_servicio = 1) THEN
                dbms_output.put_line('   ');
                dbms_output.put_line('(Simulacion)'|| hora_registro || ': ' || usuario_nombre || ' escogió como servicio: BOLETO AEREO. ');
                id_res_vue := reservarVuelo(id_reserva, usuario_nombre, usuario_id);
            END IF;

            IF (tipo_servicio = 2) THEN
                dbms_output.put_line('   ');
                dbms_output.put_line('(Simulacion)'|| hora_registro || ': ' || usuario_nombre || ' escogió como servicio: ALQUILER DE AUTOMOVIL.');
                id_res_aut := (id_reserva, usuario_nombre, 0, 0, 0);
            END IF;

            IF (tipo_servicio = 3) THEN
            dbms_output.put_line('   ');
                dbms_output.put_line('(Simulacion)'|| hora_registro || ': ' || usuario_nombre || ' escogió como servicio: RESERVA DE HABITACION.');
                id_res_hab := reservarHabitacion(id_reserva, usuario_nombre, 0);
            END IF;
        /* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */  

            SELECT RE.TOTAL.PRECIO INTO monto_a_pagar FROM RESERVA RE WHERE RE.RES_ID = id_reserva;
            dbms_output.put_line('(Simulacion) Lista la reservación. Monto a pagar: ' || monto_a_pagar);
           /* select MIUS_ACUMULADO into millas_acumuladas from MIL_USU where FK_MIUS_USUARIO = usuario_id;
            dbms_output.put_line('(Simulacion) Acumulado de millas del Usuario: ' || millas_acumuladas);*/
            dbms_output.put_line('(Simulacion)Reserva de usuario finalizada exitosamente. Se procede a atender al próximo cliente.');
            REALIZAR_PAGO1 (id_reserva);
            usuario_id := 0;
            contador := contador - 1;
        END LOOP;   
END;

/*------------------------------------------PAGOS ----------------------------------------*/

CREATE OR REPLACE PROCEDURE insertar_pago(subtotal float, id_reserva number, tipo_pago number)
IS 
    tarjeta number(20);
    tipo_random number(3);
    id number (5);
    acumulado  MIL_USU.mius_acumulado%Type;
    user MIL_USU.fk_mius_usuario%Type;
    restante float (20);
    canje number (10):=1;
BEGIN 

    if (tipo_pago = 1 ) then 

        SELECT m.mius_acumulado into acumulado
        from reserva r, mil_usu m where r.res_id = id_reserva and r.fk_res_usuario = m.fk_mius_usuario and rownum=1
        order by m.mius_fecha desc;

        if (acumulado < subtotal) then 
            dbms_output.put_line('(P_Insertar_Pago) No posee suficiente millas para realizar el canje');
            canje:=0;
            
        else 

            INSERT INTO MILLA (MIL_CONVERSION) VALUES (SUBTOTAL);
            SELECT MIL_ID INTO ID FROM MILLA WHERE ROWNUM =1 ORDER BY MIL_ID DESC;

            INSERT INTO PAGO (PAG_MONTO,FK_PAG_MILLA,FK_PAG_CREDITO,FK_PAG_DEBITO,FK_PAG_RESERVA,PAG_TIPO)
            VALUES (MONTOS(SUBTOTAL, 'D'),  ID ,NULL,NULL, ID_RESERVA, 'MILLA');
            dbms_output.put_line('(P_Insertar_Pago) El pago se ha insertado satisfactoriamente en Milla');

            SELECT m.fk_mius_usuario into user 
            from reserva r, mil_usu m where r.res_id = id_reserva and r.fk_res_usuario = m.fk_mius_usuario and rownum=1
            order by m.mius_fecha desc;

            restante := acumulado - subtotal;

            IF RESTANTE IS NOT NULL THEN
            INSERT INTO MIL_USU (MIUS_FECHA,MIUS_ACUMULADO, FK_MIUS_MILLA, FK_MIUS_USUARIO) VALUES 
            (to_date('18-01-01', 'yy-mm-dd'), restante , id, user);
            
            dbms_output.put_line('(P_Insertar_Pago) Al usuario le quedan' || restante || 'millas');
            END IF;
            
        end if;


    elsif (tipo_pago = 2) or (canje = 0 ) then 
        dbms_output.put_line('(F_Realizar_Pago) El pago será realizado en TDC');
        tarjeta:= dbms_random.value(10000000,100000000);
        tipo_random := dbms_random.value(1,3);

        if (tipo_random = 1) then 

            INSERT INTO TP_CREDITO (TPC_NUMERO, TPC_TIPOCREDITO) VALUES (TARJETA,'VISA');

        elsif (tipo_random = 2) then

            INSERT INTO TP_CREDITO (TPC_NUMERO, TPC_TIPOCREDITO) VALUES (TARJETA,'MASTER');

        elsif (tipo_random = 3) then 

            INSERT INTO TP_CREDITO (TPC_NUMERO, TPC_TIPOCREDITO) VALUES (TARJETA,'AMERICAN EXPRESS');

        end if; 
            SELECT TPC_ID INTO ID FROM TP_CREDITO WHERE ROWNUM =1 ORDER BY TPC_ID DESC;
            INSERT INTO PAGO (PAG_MONTO,FK_PAG_MILLA,FK_PAG_CREDITO,FK_PAG_DEBITO,FK_PAG_RESERVA,PAG_TIPO)
            VALUES (MONTOS(SUBTOTAL, 'D'), NULL, ID,NULL, ID_RESERVA, 'TDC');
            dbms_output.put_line('(P_Insertar_Pago) El pago se ha insertado satisfactoriamente en TP_CREDITO');


    elsif (tipo_pago = 3) then 
       
        tarjeta:= dbms_random.value(10000000,100000000);
        INSERT INTO TP_DEBITO (TPD_NUMERO) VALUES (TARJETA);
        SELECT TPD_ID INTO ID FROM TP_DEBITO WHERE ROWNUM =1 ORDER BY TPD_ID DESC;
        INSERT INTO PAGO (PAG_MONTO,FK_PAG_MILLA,FK_PAG_CREDITO,FK_PAG_DEBITO,FK_PAG_RESERVA,PAG_TIPO)
        VALUES (MONTOS(SUBTOTAL, 'D'), NULL,NULL, ID , ID_RESERVA, 'TDD');
        dbms_output.put_line('(P_Insertar_Pago) El pago será ha insertado satisfactoriamente en TP_DEBITO');

    end if;

END; 


CREATE OR REPLACE procedure REALIZAR_PAGO1 (ID_RESERVA NUMBER) 
IS
pago float(30);
tipo_pago number(5);
porcentaje number(5);
subtotal float (30);
monto float (30):= 0 ;
porc number(5);

BEGIN
     dbms_output.put_line('__________ PAGO _____________');

    SELECT r.total.precio into pago FROM RESERVA r WHERE RES_ID = ID_RESERVA;
    dbms_output.put_line('(F_Realizar_Pago) El total a pagar es'|| pago);

    if (pago = 0) then 
        dbms_output.put_line('(F_Realizar_Pago) No hay nada que cancelar porque el total es 0');
    else 
    
    tipo_pago :=  dbms_random.value(1,3);
    if (tipo_pago = 1) then 
        dbms_output.put_line('(F_Realizar_Pago) El pago será realizado en millas');
        insertar_pago(pago,id_reserva,1);

    else 

        while (monto < 100 )
        loop 
            porcentaje :=  dbms_random.value(10,100);
            if (tipo_pago = 2 ) or (tipo_pago = 3) then /*PAGO CON TARJETA*/
                if (100-monto < porcentaje) then 
                    porc:= 100- monto;
                    dbms_output.put_line('(F_Realizar_Pago) Se pagará' || porc || 'en tarjeta');
                    subtotal :=(pago * (100-monto))/100;
                    monto:= monto +(100-monto);
                    insertar_pago (subtotal, id_reserva, tipo_pago); 
                else 
                    dbms_output.put_line('(F_Realizar_Pago) Se pagará' || porcentaje || 'en tarjeta');
                     subtotal :=(pago * porcentaje)/100;
                    monto:= monto + porcentaje;
                    insertar_pago (subtotal, id_reserva, tipo_pago); 
                end if;
               
            end if;
            tipo_pago := dbms_random.value(2,3);
        end loop;
    end if;
    dbms_output.put_line('(F_Realizar_Pago) Se ha realizado el pago del total de la reserva');
    end if; 
END;






SET SERVEROUTPUT ON
EXECUTE SIMULACION(0);