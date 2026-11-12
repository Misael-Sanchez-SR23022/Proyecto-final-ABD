@echo off
SETLOCAL

:: Configuración
SET PGUSER=postgres
SET PGPASSWORD=NuncaFuimos3
SET DB_NAME=hospital_san_lucas
SET BACKUP_DIR=C:\respaldos_hospital

:: Obtener fecha
for /f "usebackq" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmmss'"`) do set TIMESTAMP=%%i

:: Crear carpeta base
IF NOT EXIST "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

echo
REM ====================================================
echo Iniciando respaldo LOGICO (Base de Datos)...
REM ====================================================
"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -U %PGUSER% -h localhost -d %DB_NAME% -F c -f "%BACKUP_DIR%\hospital_%TIMESTAMP%.dump"

echo
REM ====================================================
echo Iniciando respaldo de ROLES (Globals)...
REM ====================================================
"C:\Program Files\PostgreSQL\18\bin\pg_dumpall.exe" -U %PGUSER% -h localhost --globals-only -f "%BACKUP_DIR%\roles_%TIMESTAMP%.sql"

echo
REM ====================================================
echo Iniciando respaldo FISICO (pg_basebackup)...
REM ====================================================

"C:\Program Files\PostgreSQL\18\bin\pg_basebackup.exe" -U %PGUSER% -h localhost -D "%BACKUP_DIR%\fisico_%TIMESTAMP%" -F t -P -z

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [EXITO] Todos los respaldos (Logico, Roles y Fisico) se generaron correctamente.
    echo Ubicacion: %BACKUP_DIR%
) ELSE (
    echo.
    echo [ERROR] Ocurrio un fallo durante el respaldo. Verifique las credenciales o el servicio.
)