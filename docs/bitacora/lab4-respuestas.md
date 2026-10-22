LAB 4 — RESPUESTAS

PREGUNTAS DE COMPROBACIÓN

Respaldo

1. La copia es consistente porque primero se apagó la base con SHUTDOWN IMMEDIATE y después se copió el volumen. Si la base siguiera abierta, los archivos podrían copiarse en estados distintos y necesitar recuperación.

2. El manifiesto describe la copia y SHA256SUMS permite comprobar que no se haya alterado. Antes de restaurar, el script verifica las sumas y pide confirmar el volumen.

3. El RPO indica cuántos datos se podrían perder. A la hora de la verificación, la copia tenía unos 61 minutos de antigüedad. El RTO es el tiempo necesario para recuperar el servicio, pero no lo medí.

Diagnóstico y correcciones

4. Oracle creó los datafiles bajo el directorio dbs de su instalación porque V000 indicó nombres relativos. Configurar DB_CREATE_FILE_DEST habría permitido definir un destino persistente.

5. RENAME DATAFILE solo cambia la ruta que Oracle tiene registrada; no mueve el archivo. Hay que poner el tablespace offline, copiar el archivo, actualizar la ruta y volverlo online.

6. V000 se conserva porque es una migración que ya se ejecutó; V003 registra la corrección sin alterar el historial. Borrar una contraseña del archivo no la elimina del historial de Git, así que hay que invalidarla.

7. La prueba comprueba que los datos sobreviven al borrar y recrear el contenedor, porque permanecen en el volumen. Se hace después de reubicar los datafiles para verificar que también quedaron en ese volumen.

Instancia y arranque

8. De la instancia: nombre FREE, estado OPEN y hora de arranque 2026-10-22 16:21:41. De la base de datos: DBID 1509902213, modo ARCHIVELOG y fecha de creación 2026-07-05.

9. En NOMOUNT Oracle lee el fichero de parámetros e inicia la instancia; todavía no puede consultar la base y aparece ORA-01507. En MOUNT abre los control files, pero el diccionario aún no está disponible y aparece ORA-01219. En OPEN abre los datafiles y permite consultar el diccionario.

10. FREEPDB1 se abre sola porque tiene guardado el estado OPEN. Si no se abriera, la abriría manualmente y guardaría ese estado para el siguiente arranque.

11. ORA-00800 es un aviso conocido: el contenedor no permite ajustar la prioridad de ciertos procesos, pero la base sigue funcionando. ORA-20013 indica que no se pudo leer el inventario de parches en la imagen del contenedor; tampoco impide el funcionamiento.

Parámetros

12. V$PARAMETER muestra el valor actual en memoria y V$SPPARAMETER el valor guardado para próximos arranques. En la prueba de DB_FILES, la memoria tenía 200 y el SPFILE 300, por lo que el cambio estaba pendiente.

13. SCOPE=BOTH cambia el valor en memoria y lo guarda en el SPFILE. Si la instancia arrancó con SPFILE, ese es el ámbito predeterminado.

14. En la salida, PROCESSES aparece como IMMEDIATE, pero al intentar cambiarlo en memoria se obtuvo ORA-02095. Hay una discrepancia entre ese indicador y el resultado observado; el cambio requiere guardarse en el SPFILE y aplicarse al reiniciar.

15. Versionar el PFILE permite revisar y recuperar la configuración. Configuration drift es la diferencia que aparece con el tiempo entre la configuración documentada y la que realmente usa el servidor.

Memoria y procesos

16. La instancia usa ASMM para repartir la SGA y gestiona la PGA por separado. Se ve en SGA_TARGET=1536M, MEMORY_TARGET=0 y PGA_AGGREGATE_TARGET=512M.

17. En la primera ronda hubo 359 lecturas lógicas y 260 físicas; en la segunda, 247 lógicas y ninguna física. Los 245 bloques de la tabla estaban en caché. Con esos contadores, el acierto aproximado fue 27,6 % en la primera ronda y 100 % en la segunda.

18. No se debe sumar el RSS porque varios procesos comparten páginas de la SGA y se contarían más de una vez. La memoria del contenedor se observa directamente con docker stats.

19. LGWR tenía el SPID 2407, que es el PID que Oracle ve dentro del contenedor y coincide con /proc/2407. Docker top muestra el PID desde el espacio de procesos del host, por eso el número es diferente.

20. PMON limpia recursos de sesiones que terminan de forma anormal. SMON realiza la recuperación de la instancia después de un fallo y otras tareas de limpieza.

Seguridad y trabajo profesional

21. C##OPS_RO permite consultar información de la base con permisos limitados, mientras SYSTEM es una cuenta administrativa. C##OPS_RO puede consultar vistas de catálogo y cambiar de contenedor, pero no administrar la base ni modificar sus parámetros.

22. Se corrigen las contraseñas literales de las cuentas ADMIN_* guardadas en la migración y la contraseña de SYS que antes se pasaba como argumento de línea de comandos. La primera exposición se corrige invalidando las contraseñas y la segunda usando autenticación del sistema operativo.

PREGUNTAS TIPO EXAMEN

P1 — A y D. El apagado limpio deja la copia fría consistente y permite restaurarla directamente.
P2 — B. Para mover un datafile hay que dejarlo offline, copiarlo, actualizar su ruta y volverlo online.
P3 — A y C. STARTUP_TIME corresponde al arranque de la instancia y CREATED a la creación de la base de datos.
P4 — A y C. En NOMOUNT ya se pueden consultar los parámetros y crear el control file.
P5 — B. En MOUNT se abren los control files y se conoce la estructura de la base.
P6 — B. Con SPFILE, el ámbito predeterminado es BOTH.
P7 — C. PROCESSES es un parámetro de instancia y no se puede modificar desde una PDB.
P8 — A y C. Se puede iniciar con un PFILE y crear después un SPFILE a partir de él.
P9 — B. DB_CACHE_SIZE fija el tamaño mínimo del buffer cache cuando se usa ASMM.
P10 — A y D. El área de ordenación y la memoria privada de una sesión dedicada pertenecen a la PGA.
P11 — C. LGWR escribe el redo del COMMIT antes de confirmarlo al cliente.
P12 — B y D. PMON limpia procesos fallidos y SMON participa en la recuperación de la instancia.
