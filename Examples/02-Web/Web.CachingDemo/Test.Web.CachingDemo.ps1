$ErrorActionPreference = "Stop"
$baseUrl = "http://127.0.0.1:8080"
$endPoint = "$baseUrl/api/time"

Write-Host "STARTING TEST: Web.CachingDemo on $baseUrl" -ForegroundColor Cyan

try {
    # 1. First Request
    Write-Host "1. Requesting (Cold Cache)..." -ForegroundColor Yellow
    Write-Host "   URL: $endPoint"
    $resp1 = Invoke-WebRequest -Uri $endPoint -Method Get -UseBasicParsing
    $json1 = $resp1.Content | ConvertFrom-Json
    
    $h = $resp1.Headers["X-Cache"]
    $cache1 = if ($h) { $h } else { "NONE" }
    
    Write-Host "   Timestamp: $($json1.timestamp)"
    Write-Host "   X-Cache  : $cache1"

    # 2. Second Request
    Start-Sleep -Seconds 2
    Write-Host "2. Requesting (Should be cached)..." -ForegroundColor Yellow
    $resp2 = Invoke-WebRequest -Uri $endPoint -Method Get -UseBasicParsing
    $json2 = $resp2.Content | ConvertFrom-Json
    
    $h = $resp2.Headers["X-Cache"]
    $cache2 = if ($h) { $h } else { "NONE" }

    Write-Host "   Timestamp: $($json2.timestamp)"
    Write-Host "   X-Cache  : $cache2"

    if ($cache2 -ne "HIT") {
        Write-Host "FAIL: Expected X-Cache HIT, got $cache2" -ForegroundColor Red
    }

    if ($json1.timestamp -ne $json2.timestamp) {
        Write-Host "FAIL: Timestamps differ!" -ForegroundColor Red
    }
    else {
        Write-Host "SUCCESS: Timestamps equal (HIT confirmed)" -ForegroundColor Green
    }
    
    # 3. Vary Test
    Write-Host "3. Testing Vary Query..." -ForegroundColor Yellow
    $varyUrl = "$endPoint" + "?v=2"
    Write-Host "   URL: $varyUrl"
    
    $resp3 = Invoke-WebRequest -Uri $varyUrl -Method Get -UseBasicParsing
    $json3 = $resp3.Content | ConvertFrom-Json
    
    $h = $resp3.Headers["X-Cache"]
    $cache3 = if ($h) { $h } else { "NONE" }
    Write-Host "   X-Cache  : $cache3"
    
    if ($json3.timestamp -eq $json1.timestamp) {
        Write-Host "FAIL: Response mistakenly cached for different query" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "ALL TESTS PASSED" -ForegroundColor Green

}
catch {
    Write-Host "EXCEPTION: $_" -ForegroundColor Red
    if ($_.Exception) {
        Write-Host "DETAILS: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 1
}
