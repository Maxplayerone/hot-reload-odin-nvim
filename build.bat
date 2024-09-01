@echo off

rem odin build . -show-timings -out:game.exe 
rem game.exe

rem building the dll
odin build src -show-timings -build-mode:dll -out:game.dll

rem If game.exe already running: Then only compile game.dll and exit cleanly
set EXE=game.exe
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF %%x == %EXE% exit /b 1

rem build game.exe
odin build main_hot_reload -out:game.exe %BUILD_PARAMS%
IF %ERRORLEVEL% NEQ 0 exit /b 1
game.exe
