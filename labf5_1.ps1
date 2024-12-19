# Ensure SSH is available on your system
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Error "SSH command is not available. Please ensure SSH is installed on your system."
    exit
}

# Define the server, username, and password
$server = "labf5.com"
$username = "admin"
$password = "go"

# Using SSH for login
try {
    Write-Host "Attempting to connect to $server..." -ForegroundColor Cyan

    # Use SSH to login (assumes passwordless login or key exchange is not set up)
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    $credentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

    ssh $credentials.UserName@$server
} catch {
    Write-Error "Failed to connect to $server. Error: $_"
}
