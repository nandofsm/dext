@echo off
setlocal enabledelayedexpansion

REM Common environment setup
call "%~dp0set_env.bat" Win32

echo.
echo ==========================================
echo Building and Running Dext Examples Tests
echo ==========================================
echo.

set FAILED_EXAMPLES=
set /a SUCCESS_COUNT=0
set /a FAIL_COUNT=0
set "EXAMPLES_OUTPUT=%DEXT%\Examples\Output"

REM Create output directory if not exists
if not exist "%EXAMPLES_OUTPUT%" mkdir "%EXAMPLES_OUTPUT%"

echo ==========================================
echo Step 1: Building and Running Examples
echo ==========================================
echo.

REM Iterate through each directory in Examples
for /d %%d in ("%DEXT%\Examples\*") do (
    set "DIR_NAME=%%~nxd"
    set "PROCESSED_IN_DIR=0"
    
    REM Only process if it's not Output and contains a .dproj
    if /i "!DIR_NAME!" NEQ "Output" (
        if exist "%%d\*.dproj" (
            
            for %%f in ("%%d\*.dproj") do (
                set "PROJECT_NAME=%%~nf"
                set "PROJECT_FILE=%%f"
                
                REM Find the Test.*.ps1 script
                set "TEST_SCRIPT="
                for %%s in ("%%d\Test.*.ps1") do (
                    set "TEST_SCRIPT=%%s"
                )
                
                if "!TEST_SCRIPT!" NEQ "" (
                    echo.
                    echo ------------------------------------------
                    echo Processing: !PROJECT_NAME!
                    echo ------------------------------------------
                    
                    REM 1. Build project
                    echo [BUILD] Building: !PROJECT_NAME!
                    msbuild "!PROJECT_FILE!" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_ExeOutput="%EXAMPLES_OUTPUT%" /p:DCC_DcuOutput="%OUTPUT_PATH%" /p:DCC_UnitSearchPath="%SEARCH_PATH%" /v:minimal /nologo
                    
                    if !ERRORLEVEL! EQU 0 (
                        REM 2. Run Example
                        set "EXE_FILE=%EXAMPLES_OUTPUT%\!PROJECT_NAME!.exe"
                        if exist "!EXE_FILE!" (
                            pushd "%EXAMPLES_OUTPUT%"
                            
                            echo [RUN] Starting backend: !PROJECT_NAME!
                            start "" "!EXE_FILE!"
                            
                            echo [WAIT] Waiting for server to initialize...
                            timeout /t 3 /nobreak >nul
                            
                            echo [TEST] Running Test Script: !TEST_SCRIPT!
                            powershell -NoProfile -ExecutionPolicy Bypass -File "!TEST_SCRIPT!"
                            set "TEST_RESULT=!ERRORLEVEL!"
                            
                            echo [STOP] Stopping backend...
                            taskkill /f /im "!PROJECT_NAME!.exe" >nul 2>&1
                            
                            popd
                            
                            if !TEST_RESULT! EQU 0 (
                                echo [PASSED] !PROJECT_NAME!
                                set /a SUCCESS_COUNT+=1
                            ) else (
                                echo [FAILED] !PROJECT_NAME! - exit code !TEST_RESULT!
                                set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!(Test)"
                                set /a FAIL_COUNT+=1
                            )
                        ) else (
                            echo [ERROR] Executable not found: !EXE_FILE!
                            set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!(NotFound)"
                            set /a FAIL_COUNT+=1
                        )
                    ) else (
                        echo [ERROR] Build failed for !PROJECT_NAME!
                        set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!(Build)"
                        set /a FAIL_COUNT+=1
                    )
                )
            )
        )
    )
)

echo.
echo ==========================================
echo Examples Test Summary
echo ==========================================
echo Tests Passed:   %SUCCESS_COUNT%
echo Tests Failed:   %FAIL_COUNT%

if not "%FAILED_EXAMPLES%"=="" (
    echo.
    echo Failed Examples:
    for %%p in (%FAILED_EXAMPLES%) do echo   - %%p
    echo.
    exit /b 1
)

echo.
echo ALL EXAMPLES PASSED SUCCESSFULLY!
echo ==========================================
exit /b 0
