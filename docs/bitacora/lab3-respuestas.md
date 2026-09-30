# Respuestas del laboratorio 3

1. Una imagen es como una plantilla. Un contenedor es esa plantilla funcionando.
2. Hello-world se ejecuta con la opción --rm, que borra el contenedor al terminar.
3. docker ps enseña los contenedores activos. docker ps -a también enseña los parados.
4. En -p 1521:1521, el primer puerto es del ordenador y el segundo es del contenedor.
5. Oracle tiene que seguir funcionando para que podamos conectarnos a la base de datos. Hello-world solo muestra un mensaje y termina.
6. El digest identifica una versión concreta de la imagen. latest puede cambiar, así que guardar el digest nos dice qué versión descargamos.
7. Para borrar los datos también hay que borrar el volumen: primero docker rm -f oralab-26ai y luego docker volume rm oralab-26ai-data. docker rm solo borra el contenedor; los datos están guardados aparte en el volumen.

## 8.1.2. Git, organización y evidencia

8. Así tenemos el trabajo ordenado y guardado en un sitio común. El Issue explica la tarea, la rama guarda los cambios y el Pull Request permite revisarlos antes de unirlos al proyecto.
9. source carga el archivo en la terminal que ya estamos usando, así que podemos usar sus variables. Si usamos bash, se ejecuta aparte y esas variables no se quedan en nuestra terminal.
10. En 20260915T091230Z_02-docker.script.log, 20260915 es la fecha, 091230 es la hora, Z indica que está en horario UTC, 02 es el número del paso y docker.script.log dice que es un registro del ejercicio de Docker.
11. .gitattributes sirve para indicar cómo guardar los archivos, por ejemplo, para evitar problemas con los finales de línea entre Windows y Linux. Este archivo está vacío, así que ahora mismo no tiene reglas.
12. Elegimos Create a merge commit para conservar los commits de la rama y que quede registrado cuándo se unió el trabajo. Con Squash quedarían todos juntos en un solo commit.

## 8.1.3. Seguridad

13. Primero ponemos contraseñas seguras y distintas; luego las guardamos en config/.env, que no se sube a Git; después los scripts las leen desde ahí; y por último comprobamos que no aparezcan en commits o registros. Si nos saltamos el primer paso, podríamos dejar una contraseña fácil como change_me.
14. Si escribimos la contraseña directamente, puede quedarse en el historial de comandos o en un archivo. Por eso el script la lee de config/.env, que no se sube al repositorio.
15. No basta con borrarla en otro commit, porque sigue apareciendo en el historial. Hay que cambiar la contraseña y quitarla del historial publicado.

## 8.1.4. Oracle y herramientas

16. Pasamos el archivo SQL a sqlplus desde el ordenador y guardamos la respuesta con tee. Así no hace falta copiar archivos dentro del contenedor para ejecutarlos o guardar allí los resultados.
17. Esa línea hace que sqlplus termine con error si falla una instrucción. Sin ella, el script podría seguir y parecer que todo salió bien.
18. Una migración es un cambio que hacemos a la base de datos. Si ya se ha aplicado, no debemos editarla porque otros podrían tener una versión distinta; los cambios nuevos van en otra migración.
19. FREEPDB1 es donde creamos las tablas y usuarios del laboratorio. FREE es la base principal y el SID identifica la instancia, por eso usamos el servicio FREEPDB1.
20. SQLcl es una herramienta más nueva y cómoda. SQL*Plus se sigue usando en muchos sitios, así que un DBA debería conocer las dos.

## 8.1.5. Entorno de trabajo

21. Ubuntu en WSL funciona como Linux y es más compatible con los scripts del curso. En Git Bash pueden fallar las rutas y no existe /proc/version, que usamos para comprobar si estamos en WSL.
22. En ~/oracle-database-lab los archivos están dentro de Linux y funcionan mejor que en /mnt/c, donde pueden aparecer problemas de velocidad y permisos. Recomendamos Bash porque Ubuntu ya lo trae y los scripts del curso están escritos para Bash.
