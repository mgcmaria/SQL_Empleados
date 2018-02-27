set serveroutput on;

DECLARE
   v_Dep departments.department_id%type := &id_departamento;
   dept_no_existe EXCEPTION;
   v_nombredep departments.department_name%type;
   v_sumsalario employees.salary%type;
   v_mediasalario employees.salary%type;
   v_existe pls_integer;
   
   CURSOR f_emp IS 
        SELECT last_name, salary, hire_date
        FROM employees
        WHERE department_id = v_Dep;
    
   reg_emp f_emp%rowtype;
   
BEGIN    
      
    SELECT COUNT(*) INTO v_existe
    FROM DEPARTMENTS
    WHERE DEPARTMENT_ID=v_Dep;
    
    IF v_existe=0 THEN
    RAISE dept_no_existe;
    END IF;
    
    SELECT department_name into v_nombredep
    from DEPARTMENTS
    where department_id=v_Dep;
    
    dbms_output.put_line(' ');
    dbms_output.put_line('EMPLEADOS DEL DEPARTAMENTO: '||v_Dep||' ( '||v_nombredep||' )');
    dbms_output.put_line(rpad('-',65,'-'));
    dbms_output.put_line(rpad('EMPLEADO',16)||' '||(rpad('SALARIO',13)||' '||'FECHA INGRESO'));
    dbms_output.put_line(rpad('-',12,'-')||'    '||rpad('-',8,'-')||'       '||rpad('-',13,'-'));
    
    open f_emp;
    
    LOOP
        FETCH f_emp INTO reg_emp;
        EXIT WHEN f_emp%notfound;
        dbms_output.put_line(rpad(reg_emp.last_name,16)|| rpad(to_char(reg_emp.salary,'99G999'),7)||' €'
        ||rpad(' ',8,' ')|| TO_CHAR(reg_emp.hire_date,'DD-MM-YYYY'));                                                 
    END LOOP;
     
    dbms_output.put_line(rpad('-',65,'-'));
     
    IF f_emp%rowcount = 0 THEN 
        dbms_output.put_line('Departamento sin empleados');
        dbms_output.put_line(' ');
    END IF;
    
    SELECT SUM(employees.salary) into v_sumsalario
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID=v_Dep;
    
    SELECT AVG(employees.salary) INTO v_mediasalario
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID=v_Dep;
    
    dbms_output.put_line('Suma de salarios: '||to_char(v_sumsalario,'999G999')||' €');
    dbms_output.put_line('Media de salarios: '||to_char(v_mediasalario,'99G999')||' €');
    dbms_output.put_line('Empleados leídos: '||f_emp%rowcount);
     
    CLOSE f_emp;
        
    EXCEPTION
        WHEN dept_no_existe THEN 
        dbms_output.put_line('El departamento no existe');
        WHEN OTHERS THEN
        dbms_output.put_line('Fallo en el bloque principal'||SQLERRM);
END;

/*2.	Vamos a crear una tabla denominada nuevos_empleados, con las columnas seleccionadas en el apartado anterior, 
más el código de empleado (employee_id), y el código de departamento (department_id).
Y vamos a almacenar las filas seleccionadas en el ejercicio anterior, para lo cual dispondrás de las tablas 
anidadas que te hagan falta, y vas a usar la sentencia FORALL.*/

CREATE TABLE nuevos_empleados AS
SELECT last_name, salary, hire_date, employee_id, department_id
FROM EMPLOYEES
WHERE 1=0;

ALTER TABLE nuevos_empleados ADD PRIMARY KEY(employee_id);
ALTER TABLE nuevos_empleados ADD FOREIGN KEY(department_id) REFERENCES DEPARTMENTS;

------------------------------------------------------------------------------------

DECLARE
    v_Dep EMPLOYEES.department_id%type := &id_departamento;
    type tab_nuevos_empleados IS TABLE OF nuevos_empleados%rowtype;
    tabla_nueva tab_nuevos_empleados;
    
BEGIN

    SELECT last_name, salary, hire_date, employee_id, department_id
    BULK COLLECT INTO tabla_nueva
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = v_Dep;
    
    FORALL i IN tabla_nueva.first .. tabla_nueva.last
        insert into NUEVOS_EMPLEADOS values tabla_nueva(i);
             
    dbms_output.put_line('Filas insertadas: '||SQL%ROWCOUNT);
        
    EXCEPTION
    WHEN OTHERS THEN 
        dbms_output.put_line('Error en el programa: '||SQLERRM);
END;

 SELECT *
 FROM NUEVOS_EMPLEADOS;

 delete 
 from nuevos_empleados;





