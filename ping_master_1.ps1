# Prompt the user for the CSV file name
Write-Host "Please enter the name of the CSV file (located in C:\Users):"
$fileName = Read-Host

# Construct the full path to the file
$csvPath = "C:\Users\$fileName"

# Check if the file exists
if (-Not (Test-Path -Path $csvPath)) {
    Write-Host "Error: The file '$csvPath' does not exist."
    exit 1
}

# Import the CSV file
try {
    $hosts = Import-Csv -Path $csvPath
} catch {
    Write-Host "Error: Unable to read the CSV file. Ensure it is formatted correctly."
    exit 1
}

# Iterate through each entry in the CSV file
foreach ($host in $hosts) {
    # Extract the IP/Hostname
    $target = $host.IP

    if (-not $target) {
        Write-Host "Skipping entry with missing IP/Hostname."
        continue
    }

    # Perform a ping
    Write-Host "Pinging $target ..."
    try {
        $pingResult = Test-Connection -ComputerName $target -Count 2 -ErrorAction Stop
        Write-Host "$target is reachable."
    } catch {
        Write-Host "$target is not reachable."
    }
}

# Indicate script completion
Write-Host "Script Complete"
