@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fix_soundtest_returnmode.ps1" %*
if errorlevel 1 pause
endlocal
