# Install the POSH-SSH module if not already installed
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Install-Module -Name Posh-SSH -Force -Scope CurrentUser
}

# Define variables
$Username = "your-username"
$Password = "your-password"
$IPAddress = "1.1.1.1"

# Create a Secure String for the password
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

# Connect to the SSH session
try {
    $SSHSession = New-SSHSession -ComputerName $IPAddress -Credential $Credential -AcceptKey
    Write-Host "Connected to $IPAddress"
} catch {
    Write-Host "Failed to connect to $IPAddress"
    exit
}

# Run the 'show running-config' command
try {
    $CommandOutput = Invoke-SSHCommand -SessionId $SSHSession.SessionId -Command "show running-config"
    Write-Host "Command Output:"
    Write-Host $CommandOutput.Output
} catch {
    Write-Host "Failed to execute the command"
}

# Pause for 60 seconds
Write-Host "Pausing for 60 seconds..."
Start-Sleep -Seconds 60

# Disconnect the SSH session
Remove-SSHSession -SessionId $SSHSession.SessionId
Write-Host "Disconnected from $IPAddress"
