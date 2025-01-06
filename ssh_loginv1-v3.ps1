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

# Switch to bash shell
try {
    Invoke-SSHCommand -SessionId $SSHSession.SessionId -Command "bash"
    Write-Host "Switched to bash shell"
} catch {
    Write-Host "Failed to switch to bash shell"
    Remove-SSHSession -SessionId $SSHSession.SessionId
    exit
}

# Run the 'ls -l' command
try {
    $CommandOutput = Invoke-SSHCommand -SessionId $SSHSession.SessionId -Command "ls -l"
    Write-Host "Command Output:"
    Write-Host $CommandOutput.Output
} catch {
    Write-Host "Failed to execute the 'ls -l' command"
}

# Print SCRIPT COMPLETE
Write-Host "SCRIPT COMPLETE"

# Disconnect the SSH session
Remove-SSHSession -SessionId $SSHSession.SessionId
Write-Host "Disconnected from $IPAddress"
