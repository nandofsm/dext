@echo off
set OPENSSL_CONF=openssl.cnf
if not exist openssl.cnf (
  echo [req] > openssl.cnf
  echo default_bits = 2048 >> openssl.cnf
  echo prompt = no >> openssl.cnf
  echo default_md = sha256 >> openssl.cnf
  echo distinguished_name = dn >> openssl.cnf
  echo [dn] >> openssl.cnf
  echo C=BR >> openssl.cnf
  echo ST=SP >> openssl.cnf
  echo L=Sao Paulo >> openssl.cnf
  echo O=Dext Framework >> openssl.cnf
  echo OU=Dext Examples >> openssl.cnf
  echo CN=localhost >> openssl.cnf
)

:: Try to find openssl in common paths
set OPENSSL_EXE=openssl
where openssl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  if exist "C:\Program Files\Git\usr\bin\openssl.exe" set OPENSSL_EXE="C:\Program Files\Git\usr\bin\openssl.exe"
  if exist "C:\Program Files (x86)\Git\usr\bin\openssl.exe" set OPENSSL_EXE="C:\Program Files (x86)\Git\usr\bin\openssl.exe"
)

%OPENSSL_EXE% req -new -x509 -nodes -keyout server.key -out server.crt -days 3650 -config openssl.cnf
if %ERRORLEVEL% NEQ 0 (
  echo Error generating certificates. Please ensure OpenSSL is installed/in PATH.
  exit /b 1
)

echo Certificates generated successfully!
pause
