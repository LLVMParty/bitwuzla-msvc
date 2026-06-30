@echo off
rem Shared MSVC + vcpkg environment, sourced by build_msvc.bat / test_msvc.bat
rem (also usable directly to open an interactive shell ready for meson/ninja).
rem
rem Deliberately has NO `setlocal`: the sets must propagate to the caller. The
rem caller is expected to have run `setlocal` already.
rem
rem Portable: locates vcvars64.bat by edition (Community/Enterprise/Professional/
rem BuildTools), so it works on a dev box and on GitHub Actions windows-* runners.
rem Override VCVARS / VCPKG_INSTALLED / VCPKG_TOOLS / PY via env for non-default
rem layouts (the workflow sets VCPKG_INSTALLED / VCPKG_TOOLS to C:\vcpkg\installed).
rem
rem Triplet: x64-windows-static-md  (static GMP/MPFR + dynamic /MD CRT).
rem Static libs + dynamic CRT matches the Rust consumer's /MD -- no CRT
rem mismatch, no GMP/MPFR DLL deps at runtime. (x64-windows-static is /MT and
rem would mismatch.)

rem --- locate vcvars64.bat (explicit VCVARS override > edition chain) ---
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS (
  echo [msvc_env] vcvars64.bat not found under VS 2022; set VCVARS to its path.
  exit /b 1
)
call "%VCVARS%"
if errorlevel 1 (
  echo [msvc_env] vcvars64 failed: "%VCVARS%"
  exit /b 1
)

rem --- vcpkg static-md install root + tools (overridable) ---
if not defined VCPKG_INSTALLED set "VCPKG_INSTALLED=F:\Repos\vcpkg\installed\x64-windows-static-md"
if not defined VCPKG_TOOLS      set "VCPKG_TOOLS=F:\Repos\vcpkg\installed\x64-windows\tools\pkgconf"
if not defined PY              set "PY=C:\Users\B\AppData\Local\Programs\Python\Python311\Scripts"

rem vcpkg ships pkgconf.exe; meson (via msvc_native.ini) looks up "pkg-config".
if not exist "%VCPKG_TOOLS%\pkg-config.exe" copy "%VCPKG_TOOLS%\pkgconf.exe" "%VCPKG_TOOLS%\pkg-config.exe" >nul 2>nul

if exist "%PY%" ( set "PATH=%VCPKG_TOOLS%;%PY%;%PATH%" ) else ( set "PATH=%VCPKG_TOOLS%;%PATH%" )
set "PKG_CONFIG_PATH=%VCPKG_INSTALLED%\lib\pkgconfig"

rem Shim headers: cl.exe reads INCLUDE for #include <...> and /FI lookups.
rem msvc_compat.h (force-included by the native file) and unistd.h live here.
set "INCLUDE=%~dp0msvc_shim;%INCLUDE%"
