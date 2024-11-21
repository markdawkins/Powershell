# Schedule the shutdown in 90 seconds
shutdown /s /t 90

# Wait for 75 seconds before showing the message
Start-Sleep -Seconds 75

# Display a message box with "Shutdown Complete"
[System.Windows.Forms.MessageBox]::Show("Shutdown Complete", "Shutdown Notification", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
