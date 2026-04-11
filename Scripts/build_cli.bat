@echo off
setlocal enabledelayedexpansion

REM Common environment setup
call "%~dp0set_env.bat"

echo.
echo ==========================================
echo Building Dext CLI Tool
echo ==========================================
echo.

set "PROJ_FILE=%DEXT%\Apps\CLI\DextTool.dproj"

echo Building: %PROJ_FILE%
msbuild "%PROJ_FILE%" /t:Build /p:Configuration=%BUILD_CONFIG% /p:Platform=%PLATFORM% ^
    /p:DCC_DcuOutput="%OUTPUT_PATH%" ^
    /p:DCC_ExeOutput="%OUTPUT_PATH%" ^
    /p:DCC_UnitSearchPath="%SEARCH_PATH%" ^
    /v:minimal /nologo

if %ERRORLEVEL% NEQ 0 goto Error

REM Rename to desired executable name if it was built
if exist "%OUTPUT_PATH%\DextTool.exe" (
    echo Renaming DextTool.exe to dext.exe...
    move /Y "%OUTPUT_PATH%\DextTool.exe" "%OUTPUT_PATH%\dext.exe"
)

echo.
echo ==========================================
echo CLI Build Completed Successfully!
echo Output: %OUTPUT_PATH%\dext.exe
echo ==========================================
if not "%1"=="--no-wait" pause
exit /b 0

:Error
echo.
echo ==========================================
echo CLI BUILD FAILED!
echo ==========================================
if not "%1"=="--no-wait" pause
exit /b 1
