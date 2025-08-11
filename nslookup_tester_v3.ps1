# File: run-nslookup.ps1
# Description: Read hostnames from checklist.csv and run nslookup against two DNS servers.
# Expects checklist.csv to contain a column named "Hostname"

$inputFile = "checklist.csv"
if (-not (Test-Path $inputFile)) {
    Write-Error "Input file '$inputFile' not found. Place checklist.csv in the script folder or update the path."
    exit 1
}

$hosts = Import-Csv -Path $inputFile

# DNS servers to query
$dnsServers = @(
    @{Name = "ns1"; IP = "10.212.6.64"},
    @{Name = "ns3"; IP = "10.211.6.47"}
)

# Output directory
$outputDir = ".\NSLookup_Results"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

foreach ($dns in $dnsServers) {
    $outputFile = Join-Path $outputDir "$($dns.Name)_results.csv"

    $results = @()

    foreach ($entry in $hosts) {
        # Avoid using $host variable name (reserved in PowerShell)
        $hostname = $entry.Hostname
        if (-not $hostname) { continue }
        $hostname = $hostname.Trim()

        try {
            # Capture raw nslookup output
            $lookupRaw = nslookup $hostname $dns.IP 2>&1
        } catch {
            $lookupRaw = @($_.Exception.Message)
        }

        # Extract the last IPv4 Address (skip the DNS server's own address)
        $ipMatch = $lookupRaw | Select-String -Pattern 'Address:\s+(\d{1,3}(?:\.\d{1,3}){3})' -AllMatches
        if ($ipMatch -and $ipMatch.Matches.Count -gt 0) {
            $resolvedIP = $ipMatch.Matches[-1].Groups[1].Value

            # Remove DNS server reverse lookup lines for cleaner output
            $lookupResult = ($lookupRaw | Where-Object {
                ($_ -notmatch '^\*\*\* Unknown') -and
                ($_ -notmatch '^Server:') -and
                ($_ -notmatch '^Address:')
            }) -join "`n"

        } else {
            $resolvedIP = "Not Found"
            $lookupResult = "Lookup failed"
        }

        # Store result
        $results += [PSCustomObject]@{
            Hostname      = $hostname
            DNS_Server    = "$($dns.Name) ($($dns.IP))"
            IP_Address    = $resolvedIP
            Lookup_Result = $lookupResult
        }
    }

    # Export results to CSV (overwrite any existing file)
    $results | Export-Csv -Path $outputFile -NoTypeInformation -Force
}

Write-Host "NSLookup completed. CSV results stored in: $outputDir"
