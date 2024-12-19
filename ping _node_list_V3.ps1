# Define the file containing the list of IP addresses and hostnames
$ipFile = "C:\path\to\ping_list_with_hostnames.txt"

# Check if the file exists
if (Test-Path $ipFile) {
    # Read all lines from the file
    $entries = Get-Content -Path $ipFile

    foreach ($entry in $entries) {
        # Split the entry into IP address and hostname (assumes "IP,Hostname" format)
        $entryParts = $entry.Split(",")
        if ($entryParts.Length -eq 2) {
            $ip = $entryParts[0].Trim()
            $hostname = $entryParts[1].Trim()
            
            Write-Host "Pinging IP: $ip (Hostname: $hostname)..."
            
            # Ping the IP address
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
            
            if ($pingResult) {
                Write-Host "$hostname ($ip) is reachable." -ForegroundColor Green
            } else {
                Write-Host "$hostname ($ip) is not reachable." -ForegroundColor Red
            }
            
            # Pause for 10 seconds
            Start-Sleep -Seconds 10
        } else {
            Write-Host "Invalid entry format: $entry" -ForegroundColor Yellow
        }
    }
    
    # Pause for 30 seconds at the end of the script
    Write-Host "Task complete. Pausing for 30 seconds before exit..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
} else {
    Write-Host "The file $ipFile does not exist. Please check the file path." -ForegroundColor Yellow
}
