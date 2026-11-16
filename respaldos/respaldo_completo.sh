#!/bin/bash

# Configuración (toma valores del entorno si existen, o usa los valores por defecto)
PG_USER="${PGUSER:-postgres}"
DB_NAME="${PGDATABASE:-hospital_san_lucas}"
BACKUP_DIR="${BACKUP_DIR:-/backups}"
FECHA=$(date +%Y-%m-%d_%H%M%S)

# Crear carpeta si no existe
mkdir -p "$BACKUP_DIR"

echo "===================================================="
echo "Iniciando respaldo LOGICO (Base de Datos)..."
echo "===================================================="
pg_dump -U "$PG_USER" -d "$DB_NAME" -F c -f "$BACKUP_DIR/hospital_$FECHA.dump"

echo "===================================================="
echo "Iniciando respaldo de ROLES (Globals)..."
echo "===================================================="
pg_dumpall -U "$PG_USER" --globals-only -f "$BACKUP_DIR/roles_$FECHA.sql"

echo "===================================================="
echo "Iniciando respaldo FISICO (pg_basebackup)..."
echo "===================================================="
pg_basebackup -U "$PG_USER" -D "$BACKUP_DIR/base_fisica_$FECHA" -F t -P -z

echo "Respaldo completado: $FECHA"