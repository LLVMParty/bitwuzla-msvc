@echo off
rem Shared MSVC + vcpkg environment, sourced by build_msvc.bat / test_msvc.bat
rem (also usable directly to open an interactive shell ready for meson/ninja).
rem
rem Deliberately has NO `setlocal`: the sets must propagate to the caller. The
rem caller is expected to have run `setlocal` already.
rem
rem Triplet: x64-windows-static-md  (static GMP/MPFR + dynamic /MD CRT).
rem Static libs + dynamic CRT matches the Rust consumer's /MD -- no CRT
rem mismatch, no GMP/MPFR DLL deps at runtime. (x64-windows-static is /MT and
rem would mismatch.)

set "VS=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
set "VCPKG=F:\Repos\vcpkg\installed\x64-windows-static-md"
set "VCPKG_TOOLS=F:\Repos\vcpkg\installed\x64-windows\tools\pkgconf"
set "PY=C:\Users\B\AppData\Local\Programs\Python\Python311\Scripts"

call "%VS%"
if errorlevel 1 (
  echo [msvc_env] vcvars64 not found or failed: "%VS%"
  exit /b 1
)

rem vcpkg ships pkgconf.exe; meson (via msvc_native.ini) looks up "pkg-config".
if not exist "%VCPKG_TOOLS%\pkg-config.exe" copy "%VCPKG_TOOLS%\pkgconf.exe" "%VCPKG_TOOLS%\pkg-config.exe" >nul

set "PATH=%VCPKG_TOOLS%;%PY%;%PATH%"
set "PKG_CONFIG_PATH=%VCPKG%\lib\pkgconfig"

rem Shim headers: cl.exe reads INCLUDE for #include <...> and /FI lookups.
rem msvc_compat.h (force-included by the native file) and unistd.h live here.
set "INCLUDE=%~dp0msvc_shim;%INCLUDE%"
