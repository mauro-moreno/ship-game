@echo off
setlocal

set TARGET=%1
if "%TARGET%"=="" set TARGET=all

if /I "%TARGET%"=="test" goto test
if /I "%TARGET%"=="dev" goto dev
if /I "%TARGET%"=="release" goto release
if /I "%TARGET%"=="all" goto all

echo Unknown build target: %TARGET%
echo Usage: build.bat [dev^|test^|release^|all]
exit /b 1

:test
odin test src/game -collection:ship=src -define:SHIP_BUILD_MODE=test
exit /b %ERRORLEVEL%

:dev
if not exist build mkdir build
odin build src/app -collection:ship=src -define:SHIP_BUILD_MODE=dev -debug -out:build\ship-game-dev.exe
exit /b %ERRORLEVEL%

:release
if not exist build mkdir build
odin build src/app -collection:ship=src -define:SHIP_BUILD_MODE=release -o:speed -out:build\ship-game.exe
exit /b %ERRORLEVEL%

:all
call "%~f0" test
if errorlevel 1 exit /b %ERRORLEVEL%
call "%~f0" dev
if errorlevel 1 exit /b %ERRORLEVEL%
call "%~f0" release
exit /b %ERRORLEVEL%
