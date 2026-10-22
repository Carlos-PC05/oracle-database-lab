#!/usr/bin/env bash
# scripts/ops/sysdba.sh — ejecuta un .sql como SYSDBA con autenticación del sistema operativo (sin contraseña).
# Uso: bash scripts/ops/sysdba.sh scripts/lab4/03-verificar-negocio.sql
set -euo pipefail
source scripts/deployment/env/00-config.sh
[ $# -eq 1 ] || { echo "Uso: $0 <archivo.sql>"; exit 2; }
docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba < "$1"
