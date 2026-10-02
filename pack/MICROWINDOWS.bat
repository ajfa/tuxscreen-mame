@echo off
rem Microwindows / Nano-X with touchscreen (Steve Merrifield, 2002-04).
rem Logs in as "root" and runs "startx" on the IR keyboard.
cd /d "%~dp0."
set "OSDIR=state\microwindows"
if not exist "%OSDIR%\tuxscreen\flash" (
    mkdir "%OSDIR%\tuxscreen" 2>nul
    copy /y "flash-original\microwindows\flash" "%OSDIR%\tuxscreen\flash" >nul
)
set "TUX_LOGIN=root"
set "TUX_START=startx"
"%~dp0tuxscreen.exe" tuxscreen -rompath "%~dp0roms" -inipath "%~dp0ini" ^
    -nvram_directory "%~dp0%OSDIR%" -cfg_directory "%~dp0%OSDIR%\cfg" ^
    -snapshot_directory "%~dp0snapshots" -window -nomaximize -skip_gameinfo ^
    -lightgun -lightgunprovider win32 -autoboot_script "%~dp0lua\desktop.lua" %*
if errorlevel 1 pause
