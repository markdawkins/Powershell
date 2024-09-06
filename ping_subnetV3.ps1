# Prompt the user to input the subnet (e.g., 192.168.1.)
$subnet = Read-Host "Enter the subnet (e.g., 192.168.1.)"

# Check if the input ends with a dot, if not, add it
if (-not $subnet.EndsWith(".")) {
    $subnet += "."
}

# Loop through 1 to 254 (all hosts in the subnet range except the network and broadcast address)
For ($i=1; $i -le 254; $i++) {
    $ip = $subnet + $i

    # Ping the IP address and check if it is reachable
    $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet

    # Output result based on ping success or failure
    if ($pingResult) {
        Write-Host "$ip is reachable" -ForegroundColor Green
    }
    else {
        Write-Host "$ip is not reachable" -ForegroundColor Red
    }
}

# Pause for 90 seconds before closing
Write-Host "Pausing for 90 seconds to allow you to review the results..."
Start-Sleep -Seconds 90
