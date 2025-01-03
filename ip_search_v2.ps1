# Prompt the user for the IP address to search for
$ipAddress = Read-Host "Enter the IP address to search for"

# Prompt the user for the specific path under 'C:\Users' where the CSV file is located
$relativePath = Read-Host "Enter the path under 'C:\\Users' to the CSV file (e.g., 'JohnDoe\\Documents\\file.csv')"

# Construct the full path to the CSV file
$csvFile = Join-Path "C:\Users" $relativePath

# Check if the specified file exists
if (Test-Path $csvFile) {
    try {
        # Import the contents of the CSV file into a variable
        $csvData = Import-Csv -Path $csvFile

        # Filter the rows in the CSV where the IP address matches the user input
        $matchingRows = $csvData | Where-Object { $_.IPAddress -eq $ipAddress }

        # Check if any matching rows were found
        if ($matchingRows) {
            # Output the matching rows in a formatted table for better readability
            Write-Host "Matching row(s) found:" -ForegroundColor Green
            $matchingRows | Format-Table -AutoSize
        } else {
            # Inform the user if no matches were found
            Write-Host "No rows found with IP address $ipAddress" -ForegroundColor Yellow
        }
    } catch {
        # Catch any errors that occur during the processing of the CSV file
        Write-Host "An error occurred while processing the CSV file: $_" -ForegroundColor Red
    }
} else {
    # Inform the user if the specified file does not exist
    Write-Host "The file '$csvFile' does not exist. Please check the file path and try again." -ForegroundColor Red
}

# End of script
