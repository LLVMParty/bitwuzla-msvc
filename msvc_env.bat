@echo off
rem Shared MSVC + vcpkg environment, sourced by build_msvc.bat / test_msvc.bat
rem (also usable directly to open an interactive shell ready for meson/ninja).
rem
rem Deliberately has NO `setlocal`: the sets must propagate to the caller. The
rem caller is expected to have run `setlocal` already.
rem
rem Portable: locates vcvars64.bat via vswhere (any VS version/install path on
rem GitHub Actions) with an edition-chain fallback (Community/Enterprise/...).
rem vswhere is restricted to full IDE editions (Community/Enterprise/Professional)
rem because the BuildTools SKU often omits the Windows SDK (no psapi.lib etc.).
rem Override VCVARS / VCPKG_INSTALLED / VCPKG_TOOLS / PY via env.
rem
rem Triplet: x64-windows-static-md  (static GMP/MPFR + dynamic /MD CRT).
rem Static libs + dynamic CRT matches the Rust consumer's /MD -- no CRT
rem mismatch, no GMP/MPFR DLL deps at runtime. (x64-windows-static is /MT and
rem would mismatch.)

rem --- locate vcvars64.bat: explicit VCVARS override > vswhere > edition chain ---
rem vswhere output captured to a temp file (not a for/f backtick) because the
rem vswhere path contains "(x86)", which trips cmd's backtick parser. Standalone
rem lines avoid the delayed-expansion trap (sets are read on later lines, not
rem within a paren block).
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VSWHERE_OUT=%TEMP%\bzsrc_vswhere.txt"
if not defined VCVARS if exist "%VSWHERE%" "%VSWHERE%" -latest -products Microsoft.VisualStudio.Product.Community Microsoft.VisualStudio.Product.Enterprise Microsoft.VisualStudio.Product.Professional -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath > "%VSWHERE_OUT%" 2>nul
if not defined VCVARS if exist "%VSWHERE_OUT%" for /f "usebackq delims=" %%i in ("%VSWHERE_OUT%") do if exist "%%i\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%%i\VC\Auxiliary\Build\vcvars64.bat"
if exist "%VSWHERE_OUT%" del "%VSWHERE_OUT%" >nul 2>nul
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" set "VCVARS=%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
if not defined VCVARS (
  echo [msvc_env] vcvars64.bat not found; set VCVARS to its path.
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
