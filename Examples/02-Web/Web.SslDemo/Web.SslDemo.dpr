program Web.SslDemo;

{$APPTYPE CONSOLE}

uses
  Dext.MM,
  System.SysUtils,
  System.IOUtils,
  Dext,
  Dext.Utils,
  Dext.Web,
  Dext.Web.Interfaces,
  Dext.Configuration.Interfaces;

procedure EnsureAppSettings;
const
  DEFAULT_SETTINGS = 
    '{' + sLineBreak +
    '    "Server": {' + sLineBreak +
    '        "Port": 8080,' + sLineBreak +
    '        "UseHttps": "true",' + sLineBreak +
    '        "SslProvider": "OpenSSL",' + sLineBreak + 
    '        "SslCert": "server.crt",' + sLineBreak +
    '        "SslKey": "server.key",' + sLineBreak +
    '        "SslRootCert": ""' + sLineBreak +
    '    },' + sLineBreak +
    '    "Logging": {' + sLineBreak +
    '        "LogLevel": "Information"' + sLineBreak +
    '    }' + sLineBreak +
    '}';
begin
  Writeln('Creating/Updating default appsettings.json...');
  TFile.WriteAllText('appsettings.json', DEFAULT_SETTINGS);
end;

procedure EnsureCertificates;
var
  SourcePath: string;
begin
  // Se os certificados já existem, ok
  if FileExists('server.crt') and FileExists('server.key') then
    Exit;
    
  Writeln('Certificates not found in output directory.');
  
  // Tentar encontrar na pasta raiz do exemplo (Source)
  // Assumindo estrutura Output\Platform\Config -> ..\..\..\Examples\Web.SslDemo
  // Vou procurar recursivamente para simplificar
  
  // Try common relative paths
  var Paths: TArray<string> := [
    '..\Examples\Web.SslDemo', 
    '..\..\Examples\Web.SslDemo', 
    '..\..\..\Examples\Web.SslDemo',
    '..\..\..\..\Examples\Web.SslDemo'
  ];
  
  SourcePath := '';
  for var Path in Paths do
  begin
    var CheckPath := TPath.GetFullPath(Path);
    if FileExists(TPath.Combine(CheckPath, 'server.crt')) then
    begin
      SourcePath := CheckPath;
      Break;
    end;
  end;  
  
  if (SourcePath <> '') and FileExists(TPath.Combine(SourcePath, 'server.crt')) then
  begin
    Writeln('Copying certificates from source directory: ', SourcePath);
    TFile.Copy(TPath.Combine(SourcePath, 'server.crt'), 'server.crt', True);
    TFile.Copy(TPath.Combine(SourcePath, 'server.key'), 'server.key', True);
    Exit;
  end;
  
  Writeln('[WARNING] Certificates not found! Please run generate_certs.bat in the example folder.');
end;

procedure EnsureOpenSSLDlls;
const
  DLL_SSL = 'ssleay32.dll';
  DLL_LIB = 'libeay32.dll';
begin
  if (not FileExists(DLL_SSL)) or (not FileExists(DLL_LIB)) then
  begin
    Writeln('');
    Writeln('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    Writeln('[WARNING] OpenSSL DLLs not found in application directory!');
    Writeln('To avoid "ERR_SSL_PROTOCOL_ERROR" / "TIMED_OUT":');
    Writeln('You MUST use OpenSSL 1.0.2 compatible DLLs.');
    Writeln('');
    Writeln('DOWNLOAD INSTRUCTIONS:');
    Writeln('1. Go to: https://indy.fulgan.com/SSL/');
    Writeln('2. Download: "openssl-1.0.2u-i386-win32.zip" (for 32-bit app)');
    Writeln('   OR "openssl-1.0.2u-x64_86-win64.zip" (for 64-bit app)');
    Writeln('3. Extract "libeay32.dll" and "ssleay32.dll" to this folder.');
    Writeln('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    Writeln('');
  end;
end;

begin
  try
    Writeln('Dext SSL/HTTPS Demo');
    Writeln('-------------------');
    
    // 1. Ensure configuration, certificates and DLLs
    EnsureAppSettings;
    EnsureCertificates;
    EnsureOpenSSLDlls;

    var App: IWebApplication := TDextApplication.Create;

    // 2. Report Configuration Status
    var Config := App.Configuration.GetSection('Server');
    var Port := 8080;
    var UseHttps := False;
    
    if Config <> nil then
    begin
      Port := StrToIntDef(Config['Port'], 8080);
      UseHttps := SameText(Config['UseHttps'], 'true');
    end;
    
    Writeln('Configuration Loaded:');
    Writeln('  Port:     ', Port);
    Writeln('  Protocol: ', Copy('HTTP HTTPS', 1 + Ord(UseHttps)*5, 4 + Ord(UseHttps)));
    
    if UseHttps then
    begin
      Writeln('  Provider: ', Config['SslProvider']);
      Writeln('  Cert:     ', Config['SslCert']);
      Writeln('  Key:      ', Config['SslKey']);
      
      if not FileExists(Config['SslCert']) then
        Writeln('  [ERROR] Certificate file not found: ', Config['SslCert']);
      if not FileExists(Config['SslKey']) then
        Writeln('  [ERROR] Key file not found: ', Config['SslKey']);
    end
    else
    begin
      Writeln('  Note: SSL is disabled in appsettings.json (UseHttps: false)');
    end;
    Writeln('');

    App.Builder
      .MapGet('/', procedure(Context: IHttpContext)
      begin
        Context.Response.SetStatusCode(200);
        Context.Response.SetContentType('text/html');
        Context.Response.Write('<h1>Dext SSL Demo</h1>' +
          '<p>If you see this, the server is running over a secure connection!</p>' +
          '<p>Check the browser address bar for the lock icon.</p>');
      end);
      
    App.Run(Port);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ConsolePause;
end.
