@echo off
if "%1"=="" echo Use:
if "%1"=="" echo    prog508 filename.hex comport [oscval]
if "%1"=="" echo.
if not "%1"=="" prog50x $204 $200 $8 %1 %2 1 5 1 4 %3
