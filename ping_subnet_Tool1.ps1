# Prompt the user to input the base subnet (e.g., 192.168.1.)
$subnet = Read-Host "Enter the base subnet (e.g., 192.168.1.)"

# Check if the input ends with a dot, if not, add it
if (-not $subnet.EndsWith(".")) {
    $subnet += "."
}

# Prompt the user to input the CIDR subnet size (e.g., 24)
$cidr = Read-Host "Enter the CIDR subnet size (e.g., 24)"

# Calculate the number of hosts based on the CIDR notation
if ($cidr -eq 24) {
    $startIP = 1
    $endIP = 254
} elseif ($cidr -eq 16) {
    $startIP = 1
    $endIP = 65534
} elseif ($cidr -eq 8) {
    $startIP = 1
    $endIP = 16777214
} else {
    Write-Host "Unsupported CIDR notation. Only /24, /16, and /8 are currently supported."
    exit
}

# Loop through the IP range based on the subnet size
For ($i = $startIP; $i -le $endIP; $i++) {
    $ip = $subnet + $i

    # Ping the IP address and check if it is reachable
    $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet

    # Output result based on ping success or failure
    if ($pingResult) {
        Write-Host "$ip is reachable" -ForegroundColor Green
    } else {
        Write-Host "$ip is not reachable" -ForegroundColor Red
    }
}

# Pause for 90 seconds before closing
Write-Host "Pausing for 90 seconds to allow you to review the results..."
Start-Sleep -Seconds 90
