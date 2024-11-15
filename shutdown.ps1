# PowerShell Script: Lockdown Shutdown with Message
# This script shuts down the computer after 900 seconds and displays a message after a delay.

# Command to initiate shutdown
lockdown {
    shutdown -s -t 900
    Start-Sleep -Seconds 20
    Write-Host "System going down"
}
