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

# Run the commands in sequence
try {
    # Combine the commands to execute 'bash' and then 'ls -l'
    $Command = "bash"
    $CommandOutput = Invoke-SSHCommand -SessionId $SSHSession.SessionId -Command $Command
    Write-Host "Command Output:"
    Write-Host $CommandOutput.Output
} catch {
    Write-Host "Failed to execute commands"
}

# Print SCRIPT COMPLETE
Write-Host "SCRIPT COMPLETE"

# Disconnect the SSH session
Remove-SSHSession -SessionId $SSHSession.SessionId
Write-Host "Disconnected from $IPAddress"
