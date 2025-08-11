# Import hostnames from checklist.csv
# Assuming the CSV has a column named "Hostname"
$hosts = Import-Csv -Path "checklist.csv"

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

    # Create empty list to store results
    $results = @()

    foreach ($host in $hosts) {
        $hostname = $host.Hostname
        $lookup = nslookup $hostname $dns.IP 2>&1

        # Extract the resolved IP if found
        $ipMatch = $lookup | Select-String -Pattern "Address:\s+(\d{1,3}(\.\d{1,3}){3})" -AllMatches
        $resolvedIP = if ($ipMatch.Matches.Count -gt 0) {
            $ipMatch.Matches[-1].Groups[1].Value
        } else {
            "Not Found"
        }

        # Add result object
        $results += [PSCustomObject]@{
            Hostname      = $hostname
            DNS_Server    = "$($dns.Name) ($($dns.IP))"
            IP_Address    = $resolvedIP
            Lookup_Result = ($lookup -join " ")  # Full raw output in one string
        }
    }

    # Export to CSV
    $results | Export-Csv -Path $outputFile -NoTypeInformation
}

Write-Host "NSLookup completed. CSV results stored in: $outputDir"
