@echo off
REM =====================================================================
REM SCRIPT DE RESPALDO AUTOMATIZADO - HOSPITAL SAN LUCAS
REM (Módulo de Respaldos y Recuperación)
REM =====================================================================

:: Configuración de credenciales y rutas
SET PGUSER=postgres
:: Cambiar contraseña de progrest:
SET PGPASSWORD=NuncaFuimos3
SET DB_NAME=hospital_san_lucas
SET BACKUP_DIR=C:\respaldos_hospital

:: Crear la carpeta de respaldos por si no existe
IF NOT EXIST "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

:: Obtener fecha y hora limpia y segura usando PowerShell
for /f "usebackq" %%i in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmmss'"`) do set TIMESTAMP=%%i

echo Iniciando respaldo de la base de datos %DB_NAME%...

:: Ejecución de pg_dump en formato personalizado (.custom) con la ruta completa
"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -U %PGUSER% -h localhost -d %DB_NAME% -F c -f "%BACKUP_DIR%\hospital_%TIMESTAMP%.custom"

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [EXITO] Respaldo generado correctamente en: %BACKUP_DIR%
) ELSE (
    echo.
    echo [ERROR] Ocurrio un fallo al generar el respaldo. Verifique sus credenciales.
)

pause