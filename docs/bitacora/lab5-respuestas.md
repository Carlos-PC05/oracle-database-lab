# Lab 5: preguntas de comprobación

## Punto de partida y banco de medida

1. En mis manifiestos, tanto `20261022T155517Z_lab3-final/manifiesto.txt` como `20261022T173856Z_lab4-final/manifiesto.txt` indican **0 archivos fuera del volumen**; los dos `extras.lst` están vacíos. No hay una diferencia que pueda demostrar con estas copias. El paso 6 de `20261022T173856Z_00-backup-lab4.script.log` también dice «ninguno»; eso acredita lo que detectó la comprobación, no que la copia se haya restaurado con éxito.

2. En la evidencia `20261027T165549Z_02-anatomia-indice.script.log`, CLIENTE tiene 100.000 filas y 244 bloques: **bfr ≈ 410**. PEDIDO tiene 1.000.000 y 2.638: **bfr ≈ 379**. En mi banco inicial PEDIDO no cabía casi el triple; esa premisa no coincide con estos datos. El bfr depende del tamaño de las filas y del espacio disponible en cada bloque.

3. La primera ejecución calienta la caché y puede incluir trabajo inicial; la segunda mide una consulta ya calentada. En `20261027T165549Z_02-anatomia-indice.script.log`, sección 3, la segunda búsqueda de pedido por clave muestra **4 lecturas lógicas**. Esto sirve para comparar en caliente, pero no representa una caché fría.

## Anatomía y tipos de índice

4. `20261027T165549Z_02-anatomia-indice.script.log`, sección 2: IX_PED_CLIENTE tiene **altura 3, 2.216 hojas y fan-out real 370**. La proyección del propio script da **altura 4** para mil millones de filas, suponiendo la capacidad y el fan-out máximo usados en el cálculo.

5. En el mismo archivo, sección 4, la primera entrada tiene `00 00 03 0b 00 00`: los cuatro primeros bytes son el bloque **779** (`0x30b`) y los dos últimos la ranura **0**. La consulta posterior confirma ambos valores. El ROWID corto no necesita identificar el archivo porque la tabla está en un tablespace bigfile, con un único datafile.

6. En `20261027T170520Z_03-tipos-indice.script.log`:
   - DNI: **1.886 → 4 lecturas** con UNIQUE, porque localiza directamente la clave y además impide duplicados.
   - Historial Q7: **16 → 8 → 3** con índice por cliente, compuesto y cubriente; el último también evita acceder a la tabla.
   - Q14: **4.073 → 528** con cuatro bitmap, que permiten combinar los filtros antes de leer las filas.

## Agrupamiento, equilibrio y sargabilidad

7. Mi evidencia no confirma que IX_PED_FECHA tenga buen agrupamiento: `20261027T170636Z_04-agrupamiento-equilibrio.script.log` calcula **979.382** para fecha y **1.000.000** para cliente, frente a 9.077 bloques. Ambos están cerca del número de filas. Además, IX_PED_FECHA no aparece en el listado inicial del diccionario, por lo que la prueba no demuestra su CF real. Un REBUILD reorganiza el índice, no las filas de la tabla, así que no corrige su orden físico.

8. En esa misma curva, el índice por cliente pasa de **8.262 lecturas al 0,5 %** a **16.507 al 1 %**, frente a 8.347 del recorrido completo; el cruce está entre ambos porcentajes. La fórmula con bfr 110 estima **0,91 %** en lecturas lógicas. No puedo dar el punto de equilibrio del índice de fecha: la columna «CF bueno» da siempre 8.347 lecturas y no prueba un recorrido por ese índice.

9. Mi resultado contradice la pregunta: `20261027T170710Z_05-sargabilidad.script.log`, regla 4, muestra que `Gonz%` usa el índice y lee **2 bloques**, frente a **1.886** del recorrido completo, con **0 filas** encontradas. Si coincidieran muchas filas dispersas, sí podría leer más bloques al visitar la tabla mediante sus ROWID.

## Coste de escritura y mantenimiento

10. Para 2.000 INSERT, `20261027T170909Z_06-indices.script.log` mide **20.363 bloques con 4 índices**, **40.654 con 9** y **24.477 con 5**. Rechacé los índices simples de canal y estado: en la observación no se usaron y sus valores medios abarcan el **100 %** y el **50 %** de la tabla. Conservé código postal; el índice por cliente y fecha se sustituyó por el cubriente. El de fecha y cliente se retiró, aunque sí se usó en Q9, por lo que esa decisión merece observarse más tiempo.

11. En `20261027T171007Z_07a-crecimiento.script.log`, las claves aleatorias causaron **595 divisiones**, ninguna 90/10, frente a **398 divisiones 90/10** de la clave creciente. Los gráficos `20261027T171007Z_07a-grafico-IX_AZAR.script.log` y `20261027T171007Z_07a-grafico-IX_CRECIENTE.script.log` muestran ocupaciones medias de **75,4 %** y **99,9 %**. En `20261027T171007Z_07b-grafico-IX_COLA-antes.script.log`, la cola tiene **232 hojas vacías** a la izquierda y las llenas a la derecha.

12. Elegiría **COALESCE** en horario de servicio: en `20261027T171007Z_07c-remedios.script.log` reduce la búsqueda del siguiente mensaje de **234 a 2 lecturas** y no necesita reconstruir todo el índice. No devuelve espacio al tablespace y el patrón puede reaparecer; si es habitual, estudiaría particionar la cola.

## SCN, control files, redo y FRA

13. Oracle compara los SCN de checkpoint guardados en el control file con los de las cabeceras de los datafiles para detectar archivos que necesitan recuperación. En `20261027T171102Z_08-scn-checkpoint.script.log`, antes del checkpoint ambos valores de `system01.dbf` son **3.266.029** y después **3.271.683**.

14. Tener varias copias protege frente a la pérdida o corrupción de un control file concreto, pero no frente a perder el volumen común. `20261027T171152Z_09-multiplexar-controlfile.script.log` muestra **3 copias** bajo `/opt/oracle/oradata/FREE`. En producción las distribuiría en volúmenes o dispositivos independientes y mantendría copias de seguridad.

15. CURRENT recibe el redo ahora; ACTIVE ya no es el actual, pero todavía puede necesitarse para recuperar; INACTIVE ya no se necesita para recuperación de instancia. En `20261027T171222Z_10-redo.script.log`, tras dos cambios el grupo **2** está CURRENT y los grupos **1 y 3** ACTIVE. Los borrados fallan por **ORA-01623** (grupo actual), **ORA-01609** (miembro del actual) y **ORA-00350** (el grupo 1 necesita archivarse). El último error observado no demuestra el motivo alternativo de quedarse con un solo grupo.

16. Una FRA llena puede causar **ORA-19815** como aviso; si no queda espacio, el archivado falla, los grupos de redo no se pueden reutilizar y, al agotarse los disponibles, las escrituras esperan. Pero `20261027T171253Z_11-fra-llena.script.log` no recoge esos ORA ni una parada de escrituras: solo muestra el límite restaurado a **4.096 MB** y 1,8 MB usados. La cadena es teórica, no un resultado demostrado por mi prueba.

## Undo, WAL y simulacros

17. En `20261027T171351Z_12-lectura-consistente.script.log`, A modifica la fila **101** sin confirmar y B sigue leyendo **ACTIVO** gracias al undo. La transacción usa **1 bloque y 1 registro de undo**. Solo cuando B pide `FOR UPDATE` espera y recibe **ORA-00054** tras 3 segundos; leer normalmente no esperó al escritor.

18. DELETE debe guardar los datos necesarios para recuperar la fila y sus entradas de índice; INSERT necesita menos información para deshacer la inserción. En `20261027T171424Z_12-undo-y-redo.script.log`, para 10.000 filas, INSERT usa **159 bloques de undo** y DELETE **497**. ROLLBACK también modifica bloques y esos cambios necesitan redo: el rollback del DELETE genera **5.962 KB**.

19. Justo después del COMMIT, la durabilidad depende del **redo persistido por LGWR**; los bloques de datos pueden seguir sucios en memoria. Tras el checkpoint, DBWn los vuelca a los datafiles. En `20261027T171447Z_13-lgwr-dbwn.script.log`, el COMMIT deja **231 bloques sucios** y el checkpoint los reduce a **0**, con 556 escrituras de bloques DBWn en la instancia.

20. En `20261027T171707Z_14a-caida-instancia.script.log`, la fila **102** queda EGRESADO porque estaba confirmada y la **103** vuelve a ACTIVO porque no lo estaba. La recuperación rehace el redo desde el checkpoint (**roll forward**) y luego deshace lo no confirmado con undo (**roll back**). El alert log registra **24 KB de redo leídos** y **19 bloques** que necesitaban recuperación; el resultado de las filas evidencia el desenlace de ambas transacciones.

21. No tengo cifras válidas de RTO ni RPO para C y D. El archivo de evidencia 14c, cuyo nombre `20261027T171735Z_14c-simulacro-` está partido por un salto de línea antes de `restauracion.script.log`, solo contiene «**1. Copia previa al simulacro**» y no hay evidencia 14d completada. En teoría, C restaura una copia completa y puede perder cambios posteriores a ella; D restaura el datafile y aplica redo, pudiendo lograr RPO 0 si dispone de todo el redo. Los tiempos y la pérdida reales deben medirse en una ejecución completa.

22. No puedo clasificar cada error del bloque 5: no hay una evidencia del **healthcheck 15** con ese bloque. Como ejemplos de las pruebas disponibles, **ORA-00054** fue provocado en el ejercicio de bloqueo (`20261027T171351Z_12-lectura-consistente.script.log`) y **ORA-00205/ORA-00202/ORA-27037** corresponden a la pérdida simulada de `control03.ctl` (`20261027T171721Z_14b-perdida-controlfile.script.log`). **ORA-00800** por prioridad de LGWR/VKTM aparece en `20261022T164308Z_06-alert-log.script.log`; es un aviso observado, cuya gravedad debe valorarse en su contexto, no descartarse automáticamente como ruido.
