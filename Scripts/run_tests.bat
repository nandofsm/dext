@echo off
setlocal enabledelayedexpansion

REM Common environment setup
call "%~dp0set_env.bat" Win32

echo.
echo ==========================================
echo Building and Running Dext Tests
echo ==========================================
echo.

REM 1. Check for Skip Build argument
set "SKIP_BUILD_FLAG=0"
if /i "%~1"=="--no-build" set "SKIP_BUILD_FLAG=1"
if /i "%~1"=="-nb" set "SKIP_BUILD_FLAG=1"

REM 2. Define Paths
set "FAILED_TESTS="
set /a "SUCCESS_COUNT=0"
set /a "FAIL_COUNT=0"
set "TESTS_OUTPUT=%DEXT%\Tests\Output"

REM Ensure output directory exists
if not exist "%TESTS_OUTPUT%" mkdir "%TESTS_OUTPUT%"

REM --- STEP 1: BUILD ---
if "%SKIP_BUILD_FLAG%"=="1" goto :skip_build_msg

echo ==========================================
echo Step 1: Building All Tests (Discovery Mode)
echo ==========================================

cd /d "%DEXT%\Tests"

REM Discover and Build each project that contains "test" in the name
for /r %%f in (*.dproj) do (
    set "PROJECT_NAME=%%~nf"
    
    echo !PROJECT_NAME! | findstr /i "test" >nul
    if !ERRORLEVEL! EQU 0 (
        echo [BUILD] Project: !PROJECT_NAME!
        msbuild "%%f" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_ExeOutput="%TESTS_OUTPUT%" /p:DCC_DcuOutput="%OUTPUT_PATH%" /p:DCC_UnitSearchPath="%SEARCH_PATH%" /v:minimal /nologo
    )
)
goto :run_step

:skip_build_msg
echo [SKIP] Building All Tests (parameter --no-build detected)
goto :run_step

:run_step
echo.
echo ==========================================
echo Step 2: Running All Tests
echo ==========================================
echo.

REM Change to output directory for execution context
if not exist "%TESTS_OUTPUT%" goto :no_output_folder
pushd "%TESTS_OUTPUT%"

REM Run each test that was successfully built
for %%e in (*.exe) do (
    set "EXE_NAME=%%~ne"
    echo.
    echo ------------------------------------------
    echo Testing: !EXE_NAME!
    echo ------------------------------------------
    
    REM Run the test
    "!EXE_NAME!.exe" -no-wait
    
    if !ERRORLEVEL! EQU 0 (
        echo [PASSED] !EXE_NAME!
        set /a SUCCESS_COUNT+=1
    ) else (
        echo [FAILED] !EXE_NAME! - Exit code: !ERRORLEVEL!
        set "FAILED_TESTS=!FAILED_TESTS! !EXE_NAME!"
        set /a FAIL_COUNT+=1
    )
)

popd

:summary
echo.
echo ==========================================
echo Test Summary
echo ==========================================
echo Tests Passed:   %SUCCESS_COUNT%
echo Tests Failed:   %FAIL_COUNT%

if not "%FAILED_TESTS%"=="" (
    echo.
    echo Failed Tests:
    for %%p in (%FAILED_TESTS%) do echo   - %%p
    echo.
    echo ==========================================
    echo TESTS COMPLETED WITH FAILURES
    echo ==========================================
    exit /b 1
)

if %SUCCESS_COUNT% EQU 0 (
    echo.
    echo ==========================================
    echo NO TESTS FOUND TO RUN
    echo ==========================================
    exit /b 0
)

echo ALL TESTS PASSED!
echo ==========================================
exit /b 0

:no_output_folder
echo.
echo [ERROR] Output directory not found: "%TESTS_OUTPUT%"
exit /b 1
