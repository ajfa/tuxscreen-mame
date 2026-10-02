@echo off
rem PicoGUI 0.1 for the TuxScreen: starts its desktop on its own.
cd /d "%~dp0."
set "OSDIR=state\picogui"
if not exist "%OSDIR%\tuxscreen\flash" (
    mkdir "%OSDIR%\tuxscreen" 2>nul
    copy /y "flash-original\picogui\flash" "%OSDIR%\tuxscreen\flash" >nul
)
set "TUX_LOGIN="
set "TUX_START="
set "TUX_PICO=1"
set "TUX_MENU=60"
"%~dp0tuxscreen.exe" tuxscreen -rompath "%~dp0roms" -inipath "%~dp0ini" ^
    -nvram_directory "%~dp0%OSDIR%" -cfg_directory "%~dp0%OSDIR%\cfg" ^
    -snapshot_directory "%~dp0snapshots" -window -nomaximize -skip_gameinfo ^
    -lightgun -lightgunprovider win32 -autoboot_script "%~dp0lua\desktop.lua" %*
if errorlevel 1 pause
