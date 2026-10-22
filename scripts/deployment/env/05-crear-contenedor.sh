#!/usr/bin/env bash
# scripts/deployment/env/05-crear-contenedor.sh — versión 2 (Lab 4)
# Sin el puerto 8181 (ORDS vive fuera del contenedor) y sin contraseñas: SYSDBA entra por
# autenticación del sistema operativo y las cuentas de negocio son schema-only.
set -euo pipefail
source scripts/deployment/env/00-config.sh
# Idempotencia: si el contenedor ya existe, no se intenta crear otra vez.
if docker ps -a --format '{{.Names}}' | grep -qx "$CONT_NAME"; then
  echo "El contenedor $CONT_NAME ya existe; no se crea de nuevo."
  docker ps -a --filter "name=$CONT_NAME"
  exit 0
fi
echo "El volumen $VOL_NAME ya contiene la base FREE: se reutiliza (sin contraseñas)."
docker run -d \
  --name "$CONT_NAME" \
  -p "$PORT_DB":1521 \
  -v "$VOL_NAME":/opt/oracle/oradata \
  "$IMG"
echo "Contenedor $CONT_NAME creado."
docker ps --filter "name=$CONT_NAME"
