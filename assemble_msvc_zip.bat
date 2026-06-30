@echo off
setlocal enableextensions
rem Stage the self-contained MSVC static archive zip for the smt-server release
rem (GitHub tag bitwuzla-msvc-0.9.1, asset Bitwuzla-Win64-x86_64-msvc-static.zip).
rem
rem lib/: the six Bitwuzla static archives from build_msvc (built with cl.exe
rem against the static-md GMP/MPFR headers, so direct __gmpz_*/mpfr_* symbols)
rem plus the statically-linked GMP/MPFR (vcpkg x64-windows-static-md: static lib
rem + dynamic /MD CRT, matching Rust's /MD -- no CRT mismatch, no DLLs).
rem
rem Run build_msvc.bat first.

set "BZ=%~dp0"
set "BUILD=%BZ%build_msvc"
set "VCPKG=F:\Repos\vcpkg\installed\x64-windows-static-md"
set "STAGE=%BZ%msvc_pkg\Bitwuzla-Win64-x86_64-msvc-static"

if not exist "%BUILD%\src\libbitwuzla.a" (
  echo [assemble] build_msvc not built; run build_msvc.bat first.
  exit /b 1
)

if exist "%BZ%msvc_pkg" rmdir /s /q "%BZ%msvc_pkg"
mkdir "%STAGE%\lib"

copy "%BUILD%\src\libbitwuzla.a"       "%STAGE%\lib\" >nul
copy "%BUILD%\src\libbzlautil.a"       "%STAGE%\lib\" >nul
copy "%BUILD%\src\lib\libbitwuzlals.a" "%STAGE%\lib\" >nul
copy "%BUILD%\src\lib\libbitwuzlabv.a" "%STAGE%\lib\" >nul
copy "%BUILD%\src\lib\libbitwuzlabb.a" "%STAGE%\lib\" >nul
copy "%BUILD%\src\lib\libbzlarng.a"    "%STAGE%\lib\" >nul
copy "%VCPKG%\lib\gmp.lib"             "%STAGE%\lib\" >nul
copy "%VCPKG%\lib\mpfr.lib"            "%STAGE%\lib\" >nul

echo === staged lib/ ===
dir "%STAGE%\lib"

cd /d "%BZ%msvc_pkg"
tar -caf "Bitwuzla-Win64-x86_64-msvc-static.zip" "Bitwuzla-Win64-x86_64-msvc-static"
if errorlevel 1 exit /b 1

echo === zip ===
dir "Bitwuzla-Win64-x86_64-msvc-static.zip"
