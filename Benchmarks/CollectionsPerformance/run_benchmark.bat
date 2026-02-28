@echo off
setlocal

echo Setting up Delphi environment...
set RS_VARS="C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat"
if not exist %RS_VARS% set RS_VARS="C:\Program Files (x86)\Embarcadero\Studio\23.0\bin\rsvars.bat"
if not exist %RS_VARS% set RS_VARS="C:\Program Files (x86)\Embarcadero\Studio\22.0\bin\rsvars.bat"

if not exist %RS_VARS% (
    echo [ERROR] rsvars.bat not found.
    exit /b 1
)

call %RS_VARS%

echo.
echo ==========================================================
echo  Building Performance Benchmark (Win32)
echo ==========================================================
msbuild "Benchmarks.Performance.dproj" /t:Build /p:Config=Release /p:Platform=Win32 /v:minimal
if errorlevel 1 goto Error

echo.
echo ==========================================================
echo  Running Performance Benchmark...
echo ==========================================================
.\Win32\Release\Benchmarks.Performance.exe --no-pause

echo.
echo ==========================================================
echo  Benchmark Finished!
echo  Check performance_results.md for detailed report.
echo ==========================================================
pause
exit /b 0

:Error
echo.
echo [ERROR] Build failed!
pause
exit /b 1
