@echo off
rem Tinyx of April 2002 (Tom Walsh): Tinyx X server, Matchbox, rxvt.
rem Logs in as "root" and runs "startx & exit" on the IR keyboard; with plain
rem "startx" the text console left on tty1 repaints its palette over X's.
cd /d "%~dp0."
set "OSDIR=state\tinyx-2002-04"
if not exist "%OSDIR%\tuxscreen\flash" (
    mkdir "%OSDIR%\tuxscreen" 2>nul
    copy /y "flash-original\tinyx-2002-04\flash" "%OSDIR%\tuxscreen\flash" >nul
)
set "TUX_LOGIN=root"
set "TUX_START=startx & exit"
"%~dp0tuxscreen.exe" tuxscreen -rompath "%~dp0roms" -inipath "%~dp0ini" ^
    -nvram_directory "%~dp0%OSDIR%" -cfg_directory "%~dp0%OSDIR%\cfg" ^
    -snapshot_directory "%~dp0snapshots" -window -nomaximize -skip_gameinfo ^
    -lightgun -lightgunprovider win32 -autoboot_script "%~dp0lua\desktop.lua" %*
if errorlevel 1 pause
