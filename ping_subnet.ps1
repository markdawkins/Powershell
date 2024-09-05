# Define the base subnet
$subnet = "192.168.1."

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
