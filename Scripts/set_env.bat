@echo off

REM Common environment setup for Dext Framework Build Scripts
REM argument 1: Platform (Win32, Win64, Linux64)
REM argument 2: Configuration (Debug, Release)
REM argument 3: DelphiVersion (e.g., 37.0) - Optional

REM 1. Priority Platform and Config Setup
set "PLATFORM=%~1"
if "%PLATFORM%"=="" set "PLATFORM=Win32"

set "BUILD_CONFIG=%~2"
if "%BUILD_CONFIG%"=="" set "BUILD_CONFIG=Debug"

REM 2. Dynamic Delphi Discovery
if not "%BDS%"=="" goto :env_done

set "VERSION_TO_FIND=%~3"
if "%VERSION_TO_FIND%"=="" goto :auto_detect

set "RSVARS_PATH=C:\Program Files (x86)\Embarcadero\Studio\%VERSION_TO_FIND%\bin\rsvars.bat"
if exist "%RSVARS_PATH%" goto :call_rsvars
echo [ERROR] Requested Delphi version %VERSION_TO_FIND% not found at: %RSVARS_PATH%
exit /b 1

:auto_detect
REM Priority 1: Delphi 37.0 (Preferred)
set "RSVARS_PATH=C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
if exist "%RSVARS_PATH%" goto :call_rsvars

REM Priority 2: Registry Search (via powershell to temp file to avoid backtick expansion bugs)
set "TEMP_OUT=%TEMP%\dext_delphi_rs.txt"
set "PS_SCRIPT=Get-ItemProperty -Path 'HKLM:\SOFTWARE\WOW6432Node\Embarcadero\BDS\*', 'HKLM:\SOFTWARE\Embarcadero\BDS\*' -ErrorAction SilentlyContinue | Sort-Object PSChildName -Descending | Select-Object -First 1 | ForEach-Object { (Join-Path $_.RootDir 'bin\rsvars.bat').TrimEnd('\') }"
powershell -NoProfile -Command "%PS_SCRIPT%" > "%TEMP_OUT%"
set /p RSVARS_PATH=<"%TEMP_OUT%"
del /q "%TEMP_OUT%"

if not "%RSVARS_PATH%"=="" goto :call_rsvars

echo [ERROR] Could not auto-detect any Delphi version.
exit /b 1

:call_rsvars
echo [ENV] Setting up Delphi environment...
set "BK_PLAT=%PLATFORM%"
call "%RSVARS_PATH%"
set "PLATFORM=%BK_PLAT%"

:env_done

REM 3. Extract ProductVersion from BDS (Absolute Folder Name)
if "%BDS%"=="" echo [ERROR] BDS environment variable not set. & exit /b 1

set "PRODUCT_VERSION="
for %%i in ("%BDS%") do set "PRODUCT_VERSION=%%~nxi"

REM 4. Define Dext Root Path
pushd "%~dp0.."
set "DEXT=%CD%"
popd

REM 5. Standardize BDSCOMMONDIR and BPL/DCP Outputs
set "BDSCOMMONDIR=%PUBLIC%\Documents\Embarcadero\Studio\%PRODUCT_VERSION%"
set "COMMON_BPL_OUTPUT=%BDSCOMMONDIR%\Bpl"
set "COMMON_DCP_OUTPUT=%BDSCOMMONDIR%\Dcp"

if /i "%PLATFORM%"=="Win32" goto :skip_platform_sub
set "COMMON_BPL_OUTPUT=%COMMON_BPL_OUTPUT%\%PLATFORM%"
set "COMMON_DCP_OUTPUT=%COMMON_DCP_OUTPUT%\%PLATFORM%"
:skip_platform_sub

REM 6. Global Output path pattern
set "OUTPUT_PATH=%DEXT%\Output\%PRODUCT_VERSION%_%PLATFORM%_%BUILD_CONFIG%"

REM 7. Search Paths
set "SEARCH_PATH=%OUTPUT_PATH%;%DEXT%\External\DelphiAST\Source;%DEXT%\External\DelphiAST\Source\SimpleParser"

REM 8. Create common directories
if not exist "%DEXT%\Output" mkdir "%DEXT%\Output"
if not exist "%OUTPUT_PATH%" mkdir "%OUTPUT_PATH%"
if not exist "%COMMON_BPL_OUTPUT%" mkdir "%COMMON_BPL_OUTPUT%"
if not exist "%COMMON_DCP_OUTPUT%" mkdir "%COMMON_DCP_OUTPUT%"

echo [ENV] Product Version: %PRODUCT_VERSION%
echo [ENV] Platform:        %PLATFORM%
echo [ENV] Configuration:   %BUILD_CONFIG%
echo [ENV] Base Directory:  %DEXT%
echo [ENV] Output Path:     %OUTPUT_PATH%
echo [ENV] BPL Output:      %COMMON_BPL_OUTPUT%
echo.
