# Define the file containing the list of IP addresses
$ipFile = "C:\path\to\ping_list.txt"

# Check if the file exists
if (Test-Path $ipFile) {
    # Read all lines from the file
    $ipAddresses = Get-Content -Path $ipFile

    foreach ($ip in $ipAddresses) {
        # Trim any whitespace
        $ip = $ip.Trim()

        # Check if the IP is not empty
        if ($ip -ne "") {
            Write-Host "Pinging $ip..."
            
            # Ping the IP address
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
            
            if ($pingResult) {
                Write-Host "$ip is reachable." -ForegroundColor Green
            } else {
                Write-Host "$ip is not reachable." -ForegroundColor Red
            }
            
            # Pause for 10 seconds
            Start-Sleep -Seconds 10
        }
    }
    
    # Pause for 30 seconds at the end of the script
    Write-Host "Task complete. Pausing for 30 seconds before exit..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
} else {
    Write-Host "The file $ipFile does not exist. Please check the file path." -ForegroundColor Yellow
}
