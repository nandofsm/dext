param(
    [Parameter(Mandatory=$true)]
    [string]$Connection,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "TestOutput",
    
    [Parameter(Mandatory=$false)]
    [string]$Schema,
    
    [Parameter(Mandatory=$false)]
    [switch]$Smart,
    
    [Parameter(Mandatory=$false)]
    [switch]$NoMetadata,
    
    [Parameter(Mandatory=$false)]
    [switch]$WithMetadata,
    
    [Parameter(Mandatory=$false)]
    [switch]$Poco
)

$ErrorActionPreference = "Stop"

# Localizar dext.exe
$DextExe = Join-Path $PSScriptRoot "..\..\Apps\dext.exe"
if (-not (Test-Path $DextExe)) {
    $DextExe = "dext.exe" 
}

Write-Host "--- Dext Scaffolding Test (PostgreSQL) ---" -ForegroundColor Cyan
Write-Host "Connection: $Connection"
Write-Host "Output Dir: $OutputDir"
Write-Host ""

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

function Run-Scaffold {
    param($Name, [string[]]$ExtraArgs)
    
    Write-Host "Testing Option: $Name" -ForegroundColor Yellow
    $OutputFile = Join-Path $OutputDir "$Name.pas"
    
    # Montar array de argumentos (evita problemas de escape com ;)
    $AllArgs = @("scaffold", "-c", $Connection, "-d", "pg", "-o", $OutputFile)
    if ($Schema) { $AllArgs += @("-s", $Schema) }
    if ($Smart) { $AllArgs += @("--smart") }
    if ($Poco) { $AllArgs += @("--poco") }
    if ($NoMetadata) { $AllArgs += @("--no-metadata") }
    if ($WithMetadata) { $AllArgs += @("--with-metadata") }
    if ($ExtraArgs) { $AllArgs += $ExtraArgs }
    
    Write-Host "Running: $DextExe $($AllArgs -join ' ')" -ForegroundColor Gray
    
    try {
        # Executa usando o operador & que trata cada item do array como um argumento literal
        & $DextExe $AllArgs
        
        if (Test-Path $OutputFile) {
            Write-Host "PASS: File generated at $OutputFile" -ForegroundColor Green
        } else {
            Write-Host "FAIL: Command finished but file was not created." -ForegroundColor Red
        }
    } catch {
        Write-Host "FAIL: Error during execution." -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
    Write-Host ""
}

# 1. Default (Attributes)
Run-Scaffold "Entities_Default"

# 2. Fluent Mapping
Run-Scaffold "Entities_Fluent" -ExtraArgs "--fluent"

# 3. Custom Unit Name
Run-Scaffold "Entities_CustomUnit" -ExtraArgs "-u", "MyCustomNamespace.Entities"

# 4. Filter Tables
Run-Scaffold "Entities_Filtered" -ExtraArgs "-t", "cad_empresa,cad_visita"

Write-Host "Scaffold Tests Completed." -ForegroundColor Cyan
