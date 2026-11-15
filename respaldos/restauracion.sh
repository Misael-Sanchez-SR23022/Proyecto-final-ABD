#!/bin/bash

export PGPASSWORD="NuncaFuimos3"
PG_USER="postgres"
DB_ORIGINAL="hospital_san_lucas"
DB_RESTAURADA="hospital_san_lucas_restaurada"
BACKUP_DIR="/backups"
FECHA=$(date +%Y-%m-%d_%H%M%S)

ARCHIVO_DUMP=$(ls -t $BACKUP_DIR/hospital_*.dump | head -n 1)

if [ -z "$ARCHIVO_DUMP" ]; then
    echo "No se encontró ningún archivo de respaldo en $BACKUP_DIR"
    exit 1
fi

echo "1. Eliminando base de datos de prueba..."
dropdb -U $PG_USER --if-exists $DB_RESTAURADA

echo "2. Creando base de datos vacía..."
createdb -U $PG_USER $DB_RESTAURADA

echo "3. Restaurando desde: $ARCHIVO_DUMP"
pg_restore -U $PG_USER -d $DB_RESTAURADA --no-owner --no-privileges -v "$ARCHIVO_DUMP"

echo "4. Verificando la restauración..."
psql -U $PG_USER -d $DB_RESTAURADA -c "
SELECT 'persona' AS tabla, COUNT(*) AS registros FROM persona
UNION ALL
SELECT 'consulta', COUNT(*) FROM consulta
UNION ALL
SELECT 'cirugia', COUNT(*) FROM cirugia;
"

echo "Restauración completada."