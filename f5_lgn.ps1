# Prompt the user for F5 login details
$IPAddress = Read-Host "Enter the IP address of the F5 device"
$Username = Read-Host "Enter your username"
$Password = Read-Host "Enter your password (input will be masked)" -AsSecureString

# Convert the secure string to plain text for use in the SSH session
$PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
)

# Define the SSH command sequence
$Commands = @(
    "bash",   # Enter bash mode
    "ls -l"    # Run the command to list files
)

# Install the SSH module if not already available
if (-not (Get-Module -ListAvailable -Name "Posh-SSH")) {
    Write-Host "Installing Posh-SSH module..."
    Install-Module -Name Posh-SSH -Force -Scope CurrentUser
}

# Import the SSH module
Import-Module Posh-SSH

# Establish the SSH session
try {
    $SSHSession = New-SSHSession -ComputerName $IPAddress -Credential (New-Object PSCredential ($Username, $Password)) -AcceptKey

    foreach ($Command in $Commands) {
        Write-Host "Running command: $Command"
        $Result = Invoke-SSHCommand -SSHSession $SSHSession -Command $Command
        Write-Host $Result.Output
    }

    # Close the SSH session
    Remove-SSHSession -SSHSession $SSHSession
} catch {
    Write-Host "An error occurred: $_"
}
