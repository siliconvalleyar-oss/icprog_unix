@echo off
if "%1"=="" echo Use:
if "%1"=="" echo    read508 filename.hex comport
if "%1"=="" echo.
if not "%1"=="" read50x $204 $200 %1 %2 1 5 1
