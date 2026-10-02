@echo off
rem Tinyx 0.6 (Tim Riker, 2002-05): Tinyx X server, Matchbox, rxvt.
rem Logs in as "default" and runs "startx & exit" on the IR keyboard.
cd /d "%~dp0."
set "OSDIR=state\tinyx-0.6"
if not exist "%OSDIR%\tuxscreen\flash" (
    mkdir "%OSDIR%\tuxscreen" 2>nul
    copy /y "flash-original\tinyx-0.6\flash" "%OSDIR%\tuxscreen\flash" >nul
)
set "TUX_LOGIN=default"
set "TUX_START=startx & exit"
"%~dp0tuxscreen.exe" tuxscreen -rompath "%~dp0roms" -inipath "%~dp0ini" ^
    -nvram_directory "%~dp0%OSDIR%" -cfg_directory "%~dp0%OSDIR%\cfg" ^
    -snapshot_directory "%~dp0snapshots" -window -nomaximize -skip_gameinfo ^
    -lightgun -lightgunprovider win32 -autoboot_script "%~dp0lua\desktop.lua" %*
if errorlevel 1 pause
