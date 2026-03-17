@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo Building and Running Dext Examples Tests
echo ==========================================
echo.

REM Setup Delphi environment
if exist "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat" (
    call "C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
) else (
    echo [WARNING] Delphi 37.0 environment variables script not found.
    echo Trying to use current environment path for MSBuild...
)

set FAILED_EXAMPLES=
set SUCCESS_COUNT=0
set FAIL_COUNT=0
set BUILD_FAIL_COUNT=0
set BUILD_SUCCESS_COUNT=0
set "OUTPUT_DIR=%~dp0..\Examples\Output"

REM Create output directory if not exists
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo ==========================================
echo Step 1: Building and Running Examples
echo ==========================================
echo.

set /A buildnbr=0
set /A buildcnt=0

REM Count projects with tests
for /d %%d in ("%~dp0..\Examples\*") do (
    set "DIR_NAME=%%~nxd"
    if exist "%%d\*.dproj" (
        if exist "%%d\Test.*.ps1" (
            set /A buildcnt+=1
        )
    )
)

echo Found %buildcnt% examples with tests.
echo.

REM Iterate and run each example
for /d %%d in ("%~dp0..\Examples\*") do (
    set "DIR_NAME=%%~nxd"
    set "P_DIR=%%d"
    
    if exist "%%d\*.dproj" (
        for %%f in ("%%d\*.dproj") do (
            set "PROJECT_NAME=%%~nf"
            set "PROJECT_FILE=%%f"
            
            REM Find the Test.*.ps1 script
            set "TEST_SCRIPT="
            for %%s in ("%%d\Test.*.ps1") do (
                set "TEST_SCRIPT=%%s"
            )
            
            if not "!TEST_SCRIPT!"=="" (
                set /A buildnbr+=1
                echo ------------------------------------------
                echo [!buildnbr!/%buildcnt%] Processing: !PROJECT_NAME!
                echo ------------------------------------------
                
                REM 1. Build project
                echo Building: !PROJECT_NAME!
                msbuild "!PROJECT_FILE!" /t:Make /p:Config=Debug /p:Platform=Win32 /p:DCC_ExeOutput="%OUTPUT_DIR%" /v:minimal /nologo
                
                if !ERRORLEVEL! NEQ 0 (
                    echo [BUILD FAILED] !PROJECT_NAME!
                    set /a BUILD_FAIL_COUNT+=1
                    set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!(Build)"
                ) else (
                    echo [BUILD OK] !PROJECT_NAME!
                    set /a BUILD_SUCCESS_COUNT+=1
                    
                    set "EXE_FILE=%OUTPUT_DIR%\!PROJECT_NAME!.exe"
                    
                    if exist "!EXE_FILE!" (
                        REM 2. Start backend in background
                        echo Starting backend: !PROJECT_NAME!
                        start "" "!EXE_FILE!"
                        
                        REM Wait for server to start up
                        echo Waiting for server to initialize...
                        timeout /t 3 /nobreak >nul
                        
                        REM 3. Run Test Script
                        echo Running Test Script: !TEST_SCRIPT!
                        powershell -ExecutionPolicy Bypass -File "!TEST_SCRIPT!"
                        
                        set "TEST_RESULT=!ERRORLEVEL!"
                        
                        REM 4. Finalize Backend
                        echo Stopping backend...
                        taskkill /f /im "!PROJECT_NAME!.exe" >nul 2>&1
                        
                        if !TEST_RESULT! EQU 0 (
                            echo [PASSED] !PROJECT_NAME!
                            set /a SUCCESS_COUNT+=1
                        ) else (
                            echo [FAILED] !PROJECT_NAME! - Test exit code: !TEST_RESULT!
                            set /a FAIL_COUNT+=1
                            set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!_Test"
                        )
                    ) else (
                        echo [ERROR] Executable not found: !EXE_FILE!
                        set /a FAIL_COUNT+=1
                        set "FAILED_EXAMPLES=!FAILED_EXAMPLES! !PROJECT_NAME!_NotFound"
                    )
                )
                echo.
            )
        )
    )
)

echo ==========================================
echo Examples Test Summary
echo ==========================================
echo Build Success:  %BUILD_SUCCESS_COUNT%
echo Build Failures: %BUILD_FAIL_COUNT%
echo.
echo Tests Passed:   %SUCCESS_COUNT%
echo Tests Failed:   %FAIL_COUNT%

if not "%FAILED_EXAMPLES%"=="" (
    echo.
    echo Failed Examples:
    for %%p in (%FAILED_EXAMPLES%) do echo   - %%p
    echo.
    echo ==========================================
    echo TESTS COMPLETED WITH FAILURES
    echo ==========================================
    exit /b 1
) else (
    echo.
    echo ==========================================
    echo ALL EXAMPLES PASSED SUCCESSFULY! 🚀
    echo ==========================================
    exit /b 0
)
