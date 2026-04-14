$ErrorActionPreference = "Stop"
$baseUrl = "http://localhost:9000"

function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Result($method, $path, $response) {
    $status = [int]$response.StatusCode
    if ($status -ge 200 -and $status -lt 300) {
        Write-Host "[OK] " -NoNewline -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] " -NoNewline -ForegroundColor Red
    }
    Write-Host "$method $path - Status: $status $($response.StatusDescription)"
}

try {
    # 1. Health Check
    Write-Header "Checking System Health"
    $health = Invoke-WebRequest -Uri "$baseUrl/health" -Method Get
    Write-Result "GET" "/health" $health
    $healthJson = $health.Content | ConvertFrom-Json
    Write-Host "    Status: $($healthJson.status)"
    Write-Host "    Timestamp: $($healthJson.timestamp)"

    # 2. Login
    Write-Header "Authentication"
    $loginBody = @{
        username = "user"
        password = "password"
    } | ConvertTo-Json
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Result "POST" "/api/auth/login" $loginResponse
    $token = ($loginResponse.Content | ConvertFrom-Json).token
    $headers = @{ Authorization = "Bearer $token" }

    # 3. Product Management
    Write-Header "Product Management"
    
    # List Products
    $productsResp = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method Get
    Write-Result "GET" "/api/products" $productsResp
    $products = $productsResp.Content | ConvertFrom-Json
    Write-Host "    Found $($products.Count) products"

    if ($products.Count -gt 0) {
        $firstId = $products[0].id
        $prodDetail = Invoke-WebRequest -Uri "$baseUrl/api/products/$firstId" -Method Get
        Write-Result "GET" "/api/products/$firstId" $prodDetail
        $p = $prodDetail.Content | ConvertFrom-Json
        Write-Host "    Details: $($p.name) - $($p.price)"
    }

    # Create new product
    $newProdBody = @{
        name     = "Web Dext Pro"
        price    = 499.50
        stock    = 25
        category = "Services"
    } | ConvertTo-Json
    $createResp = Invoke-WebRequest -Uri "$baseUrl/api/products" -Method Post -Body $newProdBody -ContentType "application/json" -Headers $headers
    Write-Result "POST" "/api/products" $createResp
    $newProd = $createResp.Content | ConvertFrom-Json
    Write-Host "    Created Product ID: $($newProd.id)"

    # 4. Shopping Cart
    Write-Header "Shopping Cart Operations"
    
    # Clear cart first
    $clearResp = Invoke-WebRequest -Uri "$baseUrl/api/cart" -Method Delete -Headers $headers
    Write-Result "DELETE" "/api/cart" $clearResp

    # Add items to cart
    $cartItem = @{
        productId = $newProd.id
        quantity  = 3
    } | ConvertTo-Json
    $addResp = Invoke-WebRequest -Uri "$baseUrl/api/cart/items" -Method Post -Body $cartItem -ContentType "application/json" -Headers $headers
    Write-Result "POST" "/api/cart/items" $addResp

    # Get cart
    $cartResp = Invoke-WebRequest -Uri "$baseUrl/api/cart" -Method Get -Headers $headers
    Write-Result "GET" "/api/cart" $cartResp
    $cart = $cartResp.Content | ConvertFrom-Json
    Write-Host "    Cart Total: $($cart.totalAmount)"
    Write-Host "    Items in cart: $($cart.items.Count)"
    foreach ($item in $cart.items) {
        Write-Host "      - $($item.productName) x$($item.quantity) ($($item.total))"
    }

    # 5. Checkout
    Write-Header "Order & Checkout"
    $checkoutResp = Invoke-WebRequest -Uri "$baseUrl/api/orders/checkout" -Method Post -Headers $headers
    Write-Result "POST" "/api/orders/checkout" $checkoutResp
    $orderInfo = $checkoutResp.Content | ConvertFrom-Json
    Write-Host "    Order #$($orderInfo.orderId) created. Status: $($orderInfo.status)"

    # 6. Order History
    $ordersResp = Invoke-WebRequest -Uri "$baseUrl/api/orders" -Method Get -Headers $headers
    Write-Result "GET" "/api/orders" $ordersResp
    $orders = $ordersResp.Content | ConvertFrom-Json
    Write-Host "    Total orders found: $($orders.Count)"
    foreach ($o in $orders) {
        Write-Host "    Order ID: $($o.id) | Date: $($o.createdAt) | Total: $($o.totalAmount)"
    }

    Write-Header "Test Completed Successfully"
}
catch {
    Write-Host "`n[ERROR] $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Server Response: $($_.Exception.Response.Content)" -ForegroundColor Yellow
    }
}
