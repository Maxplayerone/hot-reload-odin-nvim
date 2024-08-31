@echo off

rem odin build . -show-timings -out:game.exe 
rem game.exe

odin build game.odin -file -build-mode:dll -out:game.dll
