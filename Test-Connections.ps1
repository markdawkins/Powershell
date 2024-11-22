# Script to test connection to weather.gov on port 80
Write-Host "Testing connection to weather.gov on port 80..."
$weatherTest = Test-NetConnection -ComputerName weather.gov -Port 80

# Display the result of the first test
if ($weatherTest.TcpTestSucceeded) {
    Write-Host "Connection to weather.gov on port 80 was successful." -ForegroundColor Green
} else {
    Write-Host "Connection to weather.gov on port 80 failed." -ForegroundColor Red
}

# Wait for 40 seconds
Write-Host "Waiting for 40 seconds before the next test..."
Start-Sleep -Seconds 40

# Prompt for the second target
$secondTarget = Read-Host "Enter the target (e.g., example.com) for the second connection test"

# Test the second connection on port 80
Write-Host "Testing connection to $secondTarget on port 80..."
$secondTest = Test-NetConnection -ComputerName $secondTarget -Port 80

# Display the result of the second test
if ($secondTest.TcpTestSucceeded) {
    Write-Host "Connection to $secondTarget on port 80 was successful." -ForegroundColor Green
} else {
    Write-Host "Connection to $secondTarget on port 80 failed." -ForegroundColor Red
}

Write-Host "Script completed."
