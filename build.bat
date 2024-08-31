@echo off

rem odin build . -show-timings -out:game.exe 
rem game.exe

rem building the dll
odin build game.odin -file -build-mode:dll -out:game.dll

rem If game.exe already running: Then only compile game.dll and exit cleanly
QPROCESS "game.exe">NUL
IF %ERRORLEVEL% EQU 0 exit 0

rem build game.exe
odin build . -out:game.exe 
IF %ERRORLEVEL% NEQ 0 exit 1
game.exe
