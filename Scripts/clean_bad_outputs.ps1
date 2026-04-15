# Dext Output Cleanup Script
# This script handles cleaning up bad build artifacts to resolve DCU staleness.

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DextRoot = Split-Path -Parent $PSScriptRoot

Write-Host "`n[CLEAN] Purging all output directories..." -ForegroundColor Yellow

$OutputDirs = Get-ChildItem -Path $DextRoot -Directory -Filter "Output" -Recurse
foreach ($dir in $OutputDirs) {
    # Check if this is a framework output directory
    if ($dir.FullName -match "Sources\\Output" -or $dir.FullName -match "Examples\\Output" -or $dir.FullName -match "Tests\\Output") {
        Write-Host "  Clearing: $($dir.FullName)" -ForegroundColor Gray
        Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path $dir.FullName -Force | Out-Null
    }
}

# Clean all DCU and other transient files in project directories
Write-Host "`n[CLEAN] Removing transient files (*.dcu, *.identcache, *.stat, *.~*)..." -ForegroundColor Yellow
$Extensions = @("*.dcu", "*.identcache", "*.stat", "*.~*")
foreach ($ext in $Extensions) {
    Get-ChildItem -Path $DextRoot -Include $ext -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  Deleting: $($_.FullName)" -ForegroundColor Gray
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }
}

Write-Success "`nCLEAN COMPLETE" -ForegroundColor Green
exit 0
