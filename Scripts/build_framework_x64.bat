@echo off
setlocal enabledelayedexpansion

REM Determine Configuration (Debug/Release) from first argument
set "B_CONFIG=%~1"
if /i "%B_CONFIG%"=="--no-wait" set "B_CONFIG=Debug"
if "%B_CONFIG%"=="" set "B_CONFIG=Debug"

REM Common environment setup
call "%~dp0set_env.bat" Win64 %B_CONFIG%

echo.
echo ==========================================
echo Building Dext Framework Packages (Win64)
echo ==========================================
echo.

REM 1. Build Dashboard Resources (No changes needed for x64 here, usually same files)
if not exist "%DEXT%\Sources\Dashboard" goto :skip_dashboard
cd /d "%DEXT%\Sources\Dashboard"
echo Building Dashboard Resources...
powershell -NoProfile -ExecutionPolicy Bypass -File "build-resources.ps1" -OutputPath "%OUTPUT_PATH%"
if !ERRORLEVEL! NEQ 0 goto :Error

:skip_dashboard

REM 2. Discover and Build Packages in Sources
echo.
echo Discovering and building packages in Sources...
cd /d "%DEXT%\Sources"

REM We use the groupproj to ensure correct dependency order
if not exist "DextFramework.groupproj" goto :discovery_mode

echo [BUILD] Using DextFramework.groupproj for reliable dependency ordering...
msbuild "DextFramework.groupproj" /t:Build /p:Configuration=%BUILD_CONFIG% /p:Platform=%PLATFORM% ^
    /p:DCC_DcuOutput="%OUTPUT_PATH%" ^
    /p:DCC_BplOutput="%COMMON_BPL_OUTPUT%" ^
    /p:DCC_DcpOutput="%COMMON_DCP_OUTPUT%" ^
    /p:DCC_UnitSearchPath="%SEARCH_PATH%" ^
    /v:minimal /nologo
if !ERRORLEVEL! NEQ 0 goto :Error
goto :Finalize

:discovery_mode
REM Fallback to discovery if groupproj is missing
for %%f in (*.dproj) do (
    echo [BUILD] Package: %%f
    msbuild "%%f" /t:Build /p:Configuration=%BUILD_CONFIG% /p:Platform=%PLATFORM% ^
        /p:DCC_DcuOutput="%OUTPUT_PATH%" ^
        /p:DCC_BplOutput="%COMMON_BPL_OUTPUT%" ^
        /p:DCC_DcpOutput="%COMMON_DCP_OUTPUT%" ^
        /p:DCC_UnitSearchPath="%SEARCH_PATH%" ^
        /v:minimal /nologo
    if !ERRORLEVEL! NEQ 0 goto :Error
)

:Finalize
echo.
echo ==========================================
echo Build Completed Successfully (Win64)!
echo Output: %OUTPUT_PATH%
echo BPLs:   %COMMON_BPL_OUTPUT%
echo ==========================================
if not "%1"=="--no-wait" pause
exit /b 0

:Error
echo.
echo ==========================================
echo BUILD FAILED (Win64)!
echo ==========================================
if not "%1"=="--no-wait" pause
exit /b 1
