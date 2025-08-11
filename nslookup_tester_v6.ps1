# =========================================
# Script Name: run-nslookup.ps1
# Purpose:     Perform DNS lookups on hostnames from checklist.csv 
#              using two different DNS servers, save results to CSV.
# =========================================

# -------------------------------
# Configuration
# -------------------------------

# Path to input CSV file
$inputFile = "checklist.csv"

# Check if input file exists
if (-not (Test-Path $inputFile)) {
    Write-Error "❌ Input file '$inputFile' not found."
    exit 1
}

Write-Host "✅ Reading hostnames from $inputFile..."
$hosts = Import-Csv -Path $inputFile

# Validate that the CSV has a column named 'Hostname'
if (-not ($hosts | Get-Member -Name Hostname -MemberType NoteProperty)) {
    Write-Error "❌ CSV must have a column named 'Hostname'. Found headers: $($hosts[0] | Get-Member -MemberType NoteProperty | ForEach-Object Name -join ', ')"
    exit 1
}

# DNS servers to use for lookups
$dnsServers = @(
    @{Name = "ns1"; IP = "10.212.6.64"},
    @{Name = "ns3"; IP = "10.211.6.47"}
)

# Output directory for CSV files
$outputDir = ".\NSLookup_Results"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# -------------------------------
# Processing Loop
# -------------------------------
foreach ($dns in $dnsServers) {
    # Create output file name for each DNS server
    $outputFile = Join-Path $outputDir "$($dns.Name)_results.csv"
    $results = @()

    Write-Host "🔍 Querying DNS server $($dns.IP) ($($dns.Name))..."

    foreach ($entry in $hosts) {
        # Avoid using $host (reserved variable in PowerShell)
        $hostname = $entry.Hostname
        if (-not $hostname) {
            Write-Warning "⚠️ Skipping empty hostname entry."
            continue
        }
        $hostname = $hostname.Trim()
        Write-Host "   → Looking up $hostname..."

        try {
            # Perform nslookup against the current DNS server
            $lookupRaw = nslookup $hostname $dns.IP 2>&1
        } catch {
            # If nslookup fails, store the exception message
            $lookupRaw = @($_.Exception.Message)
        }

        # Extract the last IPv4 address from nslookup output
        $ipMatch = $lookupRaw | Select-String -Pattern 'Address:\s+(\d{1,3}(?:\.\d{1,3}){3})' -AllMatches
        if ($ipMatch -and $ipMatch.Matches.Count -gt 0) {
            $resolvedIP = $ipMatch.Matches[-1].Groups[1].Value

            # Filter out DNS server reverse lookup noise
            $lookupResult = ($lookupRaw | Where-Object {
                ($_ -notmatch '^\*\*\* Unknown') -and
                ($_ -notmatch '^Server:') -and
                ($_ -notmatch '^Address:')
            }) -join "`n"
        } else {
            $resolvedIP = "Not Found"
            $lookupResult = "Lookup failed"
        }

        # Store the result in a structured object
        $results += [PSCustomObject]@{
            Hostname      = $hostname
            DNS_Server    = "$($dns.Name) ($($dns.IP))"
            IP_Address    = $resolvedIP
            Lookup_Result = $lookupResult
        }
    }

    # Export the results to a CSV file
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Force
    Write-Host "✅ Results saved to $outputFile"
}

# -------------------------------
# Final Banner and Pause
# -------------------------------
Write-Host ""
Write-Host "===================================="
Write-Host "   🎯 All checks completed"
Write-Host "===================================="
Write-Host ""

# Pause for 30 seconds before closing
Start-Sleep -Seconds 30
