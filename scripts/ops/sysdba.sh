#!/usr/bin/env bash
# scripts/ops/sysdba.sh — ejecuta un .sql como SYSDBA con autenticación del sistema operativo (sin contraseña).
# Uso: bash scripts/ops/sysdba.sh <archivo.sql> [archivo.log]
set -euo pipefail
source scripts/deployment/env/00-config.sh
[ $# -ge 1 ] && [ $# -le 2 ] || { echo "Uso: $0 <archivo.sql> [archivo.log]"; exit 2; }
SQL_FILE=$1
run_sql() { docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba < "$SQL_FILE"; }
if [ $# -eq 2 ]; then
  mkdir -p "$(dirname "$2")"
  run_sql 2>&1 | tee "$2"
else
  run_sql
fi
