#!/bin/bash
cd /tmp

PRIMARIO="100.108.117.45"
DATA="/var/lib/postgresql/16/main"
TS_ORIGEN="/home/cesiamariena/AH23007"
TS_DESTINO="/var/lib/postgresql/tablespaces"

echo "=== Fecha: $(date) ==="
echo "=== Versión ==="
psql --version

echo "=== 1. Detener PostgreSQL y limpiar datos ==="
sudo systemctl stop postgresql
sudo -u postgres find "$DATA" -mindepth 1 -delete

echo "=== 2. pg_basebackup desde el primario ==="
sudo -u postgres pg_basebackup \
  -d "host=$PRIMARIO port=5432 user=replicador application_name=replica_hospital" \
  -D "$DATA" -R -X stream -P \
  --tablespace-mapping="$TS_ORIGEN/Datos=$TS_DESTINO/Datos" \
  --tablespace-mapping="$TS_ORIGEN/Bitacoras=$TS_DESTINO/Bitacoras" \
  --tablespace-mapping="$TS_ORIGEN/Historicos=$TS_DESTINO/Historicos" \
  --tablespace-mapping="$TS_ORIGEN/Indices=$TS_DESTINO/Indices" \
  || { echo "ERROR: pg_basebackup falló"; exit 1; }

echo "=== 3. Arrancar réplica ==="
sudo systemctl start postgresql
sleep 3
sudo systemctl status postgresql --no-pager | head -5

echo "=== 4. Archivos de réplica ==="
sudo ls -l "$DATA/standby.signal"
sudo sed 's/password=[^ ]*/password=***/' "$DATA/postgresql.auto.conf"

echo "=== 5. Verificar modo recuperación ==="
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
