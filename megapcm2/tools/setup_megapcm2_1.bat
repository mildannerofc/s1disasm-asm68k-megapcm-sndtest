@echo off
setlocal
cd /d "%~dp0..\.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_megapcm2_1.ps1" -Force
if errorlevel 1 (
    echo.
    echo MegaPCM 2.1 setup failed.
    pause
    exit /b 1
)
echo.
echo MegaPCM 2.1 files installed successfully.
pause
