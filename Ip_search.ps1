# Prompt the user for the IP address to search for
# Read-Host is used to get input from the user
$ipAddress = Read-Host "Enter the IP address to search for"

# Prompt the user for the full path to the CSV file
$csvFile = Read-Host "Enter the full path to the CSV file"

# Check if the specified file exists
if (Test-Path $csvFile) {
    try {
        # Import the contents of the CSV file into a variable
        # Import-Csv reads the CSV file and converts each row into an object
        $csvData = Import-Csv -Path $csvFile

        # Filter the rows in the CSV where the IP address matches the user input
        # Replace 'IPAddress' with the actual column name in your CSV file if it's different
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
        # Display an error message to the user
        Write-Host "An error occurred while processing the CSV file: $_" -ForegroundColor Red
    }
} else {
    # Inform the user if the specified file does not exist
    Write-Host "The file '$csvFile' does not exist. Please check the file path and try again." -ForegroundColor Red
}

# End of script
