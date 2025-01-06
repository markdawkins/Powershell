# Install the POSH-SSH module if not already installed
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force -Scope CurrentUser
}

# Prompt user for IP address, username, and password
$IPAddress = Read-Host "Enter the IP address of the device"
$Username = Read-Host "Enter your username"
$Password = Read-Host "Enter your password" -AsSecureString

# Convert the Secure String to PSCredential
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)

# Connect to the SSH session
try {
    $SSHSession = New-SSHSession -ComputerName $IPAddress -Credential $Credential -AcceptKey
    Write-Host "Connected to $IPAddress"
} catch {
    Write-Host "Failed to connect to $IPAddress"
    exit
}

# Enter the SSH session for interactive mode
try {
    $InteractiveSession = Enter-SSHSession -SessionId $SSHSession.SessionId
    Write-Host "Switched to interactive mode"
} catch {
    Write-Host "Failed to enter interactive SSH session"
    Remove-SSHSession -SessionId $SSHSession.SessionId
    exit
}

# Switch to bash shell and run commands interactively
try {
    $null = $InteractiveSession.Write("bash`n")  # Switch to bash shell and press Enter
    Start-Sleep -Seconds 1                       # Wait for the shell to switch
    $null = $InteractiveSession.Write("ls -l`n") # Run the 'ls -l' command and press Enter
    Start-Sleep -Seconds 1                       # Wait for the command output
    $Output = $InteractiveSession.Read()         # Read the output of the commands
    Write-Host "Command Output:"
    Write-Host $Output
} catch {
    Write-Host "Failed to execute commands interactively"
}

# Print SCRIPT COMPLETE
Write-Host "SCRIPT COMPLETE"

# Exit the interactive session and disconnect the SSH session
Exit-SSHSession -SSHSession $InteractiveSession
Remove-SSHSession -SessionId $SSHSession.SessionId
Write-Host "Disconnected from $IPAddress"
