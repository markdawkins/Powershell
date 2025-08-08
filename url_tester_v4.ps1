# PowerShell Script: Test connectivity to URLs from file with delay

# Path to the URL list file
$urlFile = ".\url_list.txt"

# Read URLs from file
if (Test-Path $urlFile) {
    $urls = Get-Content $urlFile
} else {
    Write-Output "ERROR: File $urlFile not found."
    exit
}

foreach ($url in $urls) {
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

    # Wait 15 seconds before the next URL
    Start-Sleep -Seconds 15
}

# Final banner message
Write-Output "======================================="
Write-Output "         All testing completed         "
Write-Output "======================================="
