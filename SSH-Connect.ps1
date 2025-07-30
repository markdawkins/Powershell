<#
.SYNOPSIS
    Connects to a remote host via SSH after prompting for IP address.
.DESCRIPTION
    This script prompts the user to enter an IP address or hostname,
    then attempts to establish an SSH connection to that host.
.NOTES
    File Name      : SSH-Connect.ps1
    Prerequisite   : PowerShell 5.1 or later with OpenSSH client installed
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

# Prompt for IP address
$ipAddress = Read-Host "Enter the IP address or hostname of the SSH server"

# Validate input (basic validation)
if (-not $ipAddress) {
    Write-Host "No IP address entered. Exiting." -ForegroundColor Red
    exit 1
}

# Prompt for username (optional)
$username = Read-Host "Enter your username (leave blank if not required)"

# Build the SSH command
$sshCommand = "ssh"
if ($username) {
    $sshCommand += " $username@$ipAddress"
} else {
    $sshCommand += " $ipAddress"
}

Write-Host "`nConnecting to $ipAddress via SSH..." -ForegroundColor Green
Write-Host "Command: $sshCommand`n" -ForegroundColor DarkGray

# Execute the SSH command
try {
    Invoke-Expression $sshCommand
}
catch {
    Write-Host "Failed to establish SSH connection: $_" -ForegroundColor Red
    exit 1
}
