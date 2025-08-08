# PowerShell Script: Test connectivity to URLs from CSV file with delay
# Force PowerShell to use TLS 1.2 and TLS 1.3 for HTTPS connections
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Path to the CSV file (must contain a column named "URL")
$urlFile = ".\url_list.csv"

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
            Write-Output "$url : Validated Success"
        } else {
            Write-Output "$url : Unable to Connect (Status Code: $($response.StatusCode))"
        }
    }
    catch {
        Write-Output "$url : Unable to Connect"
    }

    # Wait 15 seconds before testing the next URL
    Start-Sleep -Seconds 15
}

# Final banner message
Write-Output "======================================="
Write-Output "         All testing completed         "
Write-Output "======================================="

# Wait 30 seconds before ending script
Start-Sleep -Seconds 30
