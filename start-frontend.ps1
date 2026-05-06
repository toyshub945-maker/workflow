# Run this in PowerShell window 2 (after backend is running)
Set-Location "$PSScriptRoot\frontend"

# Install npm packages if needed
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing frontend dependencies (first time, ~1 min)..." -ForegroundColor Cyan
    npm install
}

# Dynamically detect local IP for network access
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.InterfaceAlias -notlike "Loopback*" } | Select-Object -First 1).IPAddress
if (-not $localIP) { 
    $localIP = "192.168.1.4" # Fallback to last known good IP
}

# Set environment variable for current process
$env:NEXT_PUBLIC_BACKEND_URL = "http://${localIP}:8000"

# Also write to .env.local for Next.js to be absolutely sure
# Use utf8 without BOM for compatibility
$content = "NEXT_PUBLIC_BACKEND_URL=http://${localIP}:8000"
$content | Out-File -FilePath "$PSScriptRoot\frontend\.env.local" -Encoding utf8

Write-Host ""
Write-Host "Starting frontend on http://${localIP}:3002" -ForegroundColor Green
Write-Host "Local network access: http://${localIP}:3002" -ForegroundColor Cyan
Write-Host "Connecting to backend at: $env:NEXT_PUBLIC_BACKEND_URL" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""

# Run Next.js and bind to 0.0.0.0 so it's accessible on the network
npm run dev -- -H 0.0.0.0


