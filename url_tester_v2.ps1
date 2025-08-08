# PowerShell Script: Test connectivity to specified URLs with delay

# List of URLs to test
$urls = @(
    "https://hp.com",
    "https://www.cnn.com",
    "https://www.comerica.com"
)

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
