@echo off
title Persona 3 Dancing Launcher
cd /d "%~dp0"

set "PYW="
if exist "%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe" set "PYW=%LOCALAPPDATA%\Programs\Python\Python312\pythonw.exe"
if not defined PYW (
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\pythonw.exe" set "PYW=%%D\pythonw.exe"
)
if not defined PYW (
    where pythonw >nul 2>nul && set "PYW=pythonw"
)

if defined PYW (
    start "" "%PYW%" "%~dp0p3d_launcher.pyw"
    exit /b 0
)

set "PY="
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
if not defined PY (
    for /d %%D in ("%LOCALAPPDATA%\Programs\Python\Python3*") do if exist "%%D\python.exe" set "PY=%%D\python.exe"
)
if not defined PY (
    where python >nul 2>nul && set "PY=python"
)

if defined PY (
    start "" "%PY%" "%~dp0p3d_launcher.py"
    exit /b 0
)

echo.
echo [AVISO] No se encontro Python en el sistema.
echo Ejecutando el juego directamente mediante el motor nativo...
call "%~dp0Jugar.bat"
