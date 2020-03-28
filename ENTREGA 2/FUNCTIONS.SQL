/* ----------------------SELECCIONA LA FLOTA QUE TENGA EL ALCANCE ADECUADO -----------------------*/


CREATE OR REPLACE FUNCTION SELECCIONAR_FLOTA (DISTANCIA NUMBER) RETURN NUMBER
IS
	avion Mod_flota.mofl_id%type;
BEGIN
	Select mofl_id 
	into avion 
	from mod_flota a, flota f
	where  a.fk_mofl_flota = f.flo_id 
	and f.flo_alcance_millas > distancia
	and rownum = 1;

	dbms_output.put_line('(F_Seleccionar_Flota) El avion seleccionado para recorrer la distancia seleccionada es el avion '||AVION);

	RETURN avion;
END;

/*------------------------CALCULA LA CANTIDAD DE ESCALAS --------------------*/

CREATE OR REPLACE PROCEDURE ESCALAS (MILLAS NUMBER) RETURN NUMBER
IS 
 NUMESCALA Escala.escala%type;
BEGIN 
	
	Select es.escala 
	into numescala 
	from Escala es 
	where rownum = 1;
	and es. milla > millas or es.milla = millas;

	dbs.output.put_line (numescala);

	return numescala;

END; 


