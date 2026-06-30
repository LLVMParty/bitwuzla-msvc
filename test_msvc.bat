@echo off
setlocal enableextensions
rem Reconfigure the build_msvc tree with the regression suite enabled, then run
rem it. Reuses the same env/native-file as build_msvc.bat.

call "%~dp0msvc_env.bat"
if errorlevel 1 exit /b 1

cd /d "%~dp0"
echo === reconfigure build_msvc with testing enabled ===
meson setup --reconfigure -Dtesting=enabled -Dunit_testing=disabled build_msvc
if errorlevel 1 exit /b 1

echo === meson test ===
meson test -C build_msvc --print-errorlogs
