@echo off
REM =====================================================================
REM SCRIPT DE RESPALDO FÍSICO (BASEBACKUP) - HOSPITAL SAN LUCAS
REM (Módulo de Respaldos y Recuperación)
REM =====================================================================

SET PGUSER=postgres
SET PGPASSWORD=NuncaFuimos3
SET BACKUP_DIR=C:\respaldos_hospital\fisico_base

:: Crear la carpeta destino si no existe
IF NOT EXIST "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
)

echo Iniciando respaldo fisico del cluster completo de PostgreSQL...

"C:\Program Files\PostgreSQL\18\bin\pg_basebackup.exe" -h localhost -U %PGUSER% -D "%BACKUP_DIR%" -F t -P -z

IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [EXITO] Respaldo fisico generado correctamente en: %BACKUP_DIR%
) ELSE (
    echo.
    echo [ERROR] Ocurrio un fallo al generar el respaldo fisico.
)

pause