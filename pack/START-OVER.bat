@echo off
rem Throws away every change made inside the four systems and puts back the
rem flash of each one exactly as it came.
cd /d "%~dp0."
echo.
echo This deletes every change made inside the four systems and puts
echo each flash back the way it came.
echo.
choice /c YN /m "Are you sure"
if errorlevel 2 exit /b
if exist state rmdir /s /q state
echo Done. Next time you open a system it starts from scratch.
pause
