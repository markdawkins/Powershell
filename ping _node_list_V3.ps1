# Script to ping a list of IP addresses and display results alongside their hostnames

# Define the file containing the list of IP addresses and hostnames
$ipFile = "C:\path\to\ping_list_with_hostnames.txt"

# Check if the file exists
if (Test-Path $ipFile) {
    # Read all lines from the file
    $entries = Get-Content -Path $ipFile

    # Loop through each entry in the file
    foreach ($entry in $entries) {
        # Split the entry into IP address and hostname (assumes "IP,Hostname" format)
        $entryParts = $entry.Split(",")
        
        # Ensure the entry has exactly two parts: IP and hostname
        if ($entryParts.Length -eq 2) {
            $ip = $entryParts[0].Trim()       # Extract and trim the IP address
            $hostname = $entryParts[1].Trim() # Extract and trim the hostname
            
            Write-Host "Pinging IP: $ip (Hostname: $hostname)..."
            
            # Ping the IP address
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
            
            # Display result of the ping
            if ($pingResult) {
                Write-Host "$hostname ($ip) is reachable." -ForegroundColor Green
            } else {
                Write-Host "$hostname ($ip) is not reachable." -ForegroundColor Red
            }
            
            # Pause for 10 seconds after processing each entry
            Start-Sleep -Seconds 10
        } else {
            # Handle invalid entry format
            Write-Host "Invalid entry format: $entry. Each line must be 'IP,Hostname'." -ForegroundColor Yellow
        }
    }
    
    # Pause for 30 seconds at the end of the script
    Write-Host "Task complete. Pausing for 30 seconds before exit..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
} else {
    # Display error if the file does not exist
    Write-Host "The file $ipFile does not exist. Please check the file path." -ForegroundColor Yellow
}
