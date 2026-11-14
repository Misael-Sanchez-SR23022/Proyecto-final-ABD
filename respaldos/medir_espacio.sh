#!/usr/bin/env bash
# Recolector de espacio REAL del filesystem donde reside PGDATA.
# Requisitos: bash, df (GNU coreutils) y psql. Configurar PGHOST, PGPORT,
# PGDATABASE, PGUSER y autenticación segura mediante .pgpass/variables secretas.
set -euo pipefail

: "\${PGDATABASE:?Define PGDATABASE}"
: "\${PGUSER:?Define PGUSER}"
MOUNT_POINT="\${PGDATA:-}"
if [[ -z "$MOUNT_POINT" ]]; then
  echo "Define PGDATA con la ruta del directorio de datos de PostgreSQL." >&2
  exit 2
fi
if [[ ! -d "$MOUNT_POINT" ]]; then
  echo "PGDATA no es un directorio válido: $MOUNT_POINT" >&2
  exit 2
fi

read -r CAPACITY USED AVAILABLE PCT < <(
  df -P -B1 "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/,"",$5); print $2, $3, $4, $5}'
)
if [[ -z "\${CAPACITY:-}" || "$CAPACITY" -le 0 ]]; then
  echo "No fue posible obtener métricas de filesystem con df." >&2
  exit 3
fi

psql -X -v ON_ERROR_STOP=1 \
  -v mount_point="$MOUNT_POINT" \
  -v capacity="$CAPACITY" \
  -v used="$USED" \
  -v available="$AVAILABLE" \
  -v pct="$PCT" <<'SQL'
INSERT INTO monitoreo.medicion_filesystem
    (punto_montaje, capacidad_bytes, usado_bytes, disponible_bytes, porcentaje_usado)
VALUES
    (:'mount_point', :capacity, :used, :available, :pct);
SQL

echo "Métrica guardada: $MOUNT_POINT usado \${PCT}%"
