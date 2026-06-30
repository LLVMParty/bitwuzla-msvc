@echo off
setlocal enableextensions
rem Build bitwuzla (lib + CLI) with MSVC against the static-md vcpkg triplet.
rem
rem All port flags live in msvc_native.ini (additive -- no upstream meson.build
rem touch); all machine paths live in msvc_env.bat. This script just wires them
rem together: env -> meson setup --native-file -> ninja.

call "%~dp0msvc_env.bat"
if errorlevel 1 exit /b 1

cd /d "%~dp0"
if exist build_msvc rmdir /s /q build_msvc

echo === meson setup (MSVC native file, static-md) ===
meson setup build_msvc --native-file msvc_native.ini -Dpython=false -Dtesting=disabled -Dunit_testing=disabled
if errorlevel 1 exit /b 1

echo === ninja (lib + deps + CLI link check) ===
ninja -C build_msvc
if errorlevel 1 exit /b 1

echo === artifacts (deliverable: the .a static archives) ===
dir build_msvc\src\*.a 2>nul
dir build_msvc\src\lib\*.a 2>nul
