<#
.SYNOPSIS
    Connects to a remote host via SSH with username and password authentication.
.DESCRIPTION
    This script prompts the user to enter an IP address/hostname, username, and password,
    then establishes an SSH connection using these credentials.
.NOTES
    File Name      : SSH-Connect.ps1
    Prerequisite   : PowerShell 5.1 or later with OpenSSH client installed
    Note           : For security reasons, consider using SSH keys instead of passwords
#>

# Check if SSH is available
function Test-SSHAvailable {
    try {
        $null = Get-Command ssh -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to get secure string as plain text (not recommended for production)
function Get-PlainTextFromSecureString {
    param(
        [System.Security.SecureString]$SecureString
    )
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

# Main script
Clear-Host
Write-Host "SSH Connection Script" -ForegroundColor Cyan
Write-Host "---------------------`n"

# Verify SSH client is installed
if (-not (Test-SSHAvailable)) {
    Write-Host "SSH client is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install OpenSSH Client:" -ForegroundColor Yellow
    Write-Host "1. For Windows 10/11: Install via 'Optional Features' or PowerShell (Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0)" -ForegroundColor Yellow
    Write-Host "2. For other systems: Install OpenSSH from your package manager" -ForegroundColor Yellow
    exit 1
}

# Prompt for connection details
$ipAddress = Read-Host "Enter the IP address or hostname of the SSH server"
if (-not $ipAddress) {
    Write-Host "No IP address entered. Exiting." -ForegroundColor Red
    exit 1
}

$username = Read-Host "Enter your username"
if (-not $username) {
    Write-Host "Username cannot be empty. Exiting." -ForegroundColor Red
    exit 1
}

$securePassword = Read-Host "Enter your password" -AsSecureString
if (-not $securePassword) {
    Write-Host "Password cannot be empty. Exiting." -ForegroundColor Red
    exit 1
}

# Convert secure password to plain text (not recommended for production)
$password = Get-PlainTextFromSecureString -SecureString $securePassword

Write-Host "`nAttempting to connect to $ipAddress as $username..." -ForegroundColor Green

# Using plink (PuTTY) for password authentication (alternative method)
try {
    # Method 1: Using sshpass (needs to be installed on Linux/macOS)
    # sshpass -p "$password" ssh $username@$ipAddress
    
    # Method 2: Using Expect on Linux/macOS
    
    # Method 3: Using Plink (PuTTY) - works on Windows
    if (Get-Command plink -ErrorAction SilentlyContinue) {
        $plinkCommand = "echo y | plink -ssh $username@$ipAddress -pw $password"
        Invoke-Expression $plinkCommand
    }
    # Method 4: Native SSH with keyboard-interactive (may not work for all servers)
    else {
        # This approach may not work on all servers as it depends on keyboard-interactive authentication
        $sshCommand = @"
`$session = New-SSHSession -ComputerName $ipAddress -Credential (New-Object System.Management.Automation.PSCredential('$username', (ConvertTo-SecureString '$password' -AsPlainText -Force))) -AcceptKey
Enter-SSHSession -SessionId `$session.SessionId
"@
        Invoke-Expression $sshCommand
    }
}
catch {
    Write-Host "Failed to establish SSH connection: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Clear the password from memory
    Remove-Variable password -ErrorAction SilentlyContinue
    Remove-Variable securePassword -ErrorAction SilentlyContinue
}

Write-Host "`nConnection closed." -ForegroundColor Yellow
