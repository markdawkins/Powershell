# PowerShell Script: Test connectivity to URLs from CSV file with delay and logging
# Force PowerShell to use TLS 1.2 and TLS 1.3 for HTTPS connections
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Path to the CSV file (must contain a column named "URL")
$urlFile = ".\url_list.csv"
# Path to the results file
$resultsFile = ".\url_test_results.txt"

# Clear the results file if it exists
if (Test-Path $resultsFile) {
    Clear-Content $resultsFile
}

# Read URLs from CSV
if (Test-Path $urlFile) {
    $urls = Import-Csv $urlFile
} else {
    Write-Output "ERROR: File $urlFile not found."
    exit
}

foreach ($entry in $urls) {
    $url = $entry.URL

    try {
        # Attempt to request the webpage
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10

        if ($response.StatusCode -eq 200) {
            $result = "$url : Validated Success"
        } else {
            $result = "$url : Unable to Connect (Status Code: $($response.StatusCode))"
        }
    }
    catch {
        $result = "$url : Unable to Connect"
    }

    # Output to screen and append to file
    Write-Output $result
    Add-Content -Path $resultsFile -Value $result

    # Wait 15 seconds before testing the next URL
    Start-Sleep -Seconds 15
}

# Final banner message
Write-Output "======================================="
Write-Output "         All testing completed         "
Write-Output "======================================="

# Add timestamp to results file
$timestamp = "Test completed at: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Add-Content -Path $resultsFile -Value "======================================="
Add-Content -Path $resultsFile -Value $timestamp
Add-Content -Path $resultsFile -Value "======================================="

# Wait 30 seconds before ending script
Start-Sleep -Seconds 30
