# Import hostnames from checklist.csv
# Assuming the CSV has a column named "Hostname"
$hosts = Import-Csv -Path "checklist.csv"

# DNS servers to query
$dnsServers = @(
    @{Name = "ns1"; IP = "10.212.6.64"},
    @{Name = "ns3"; IP = "10.211.6.47"}
)

# Output files
$outputDir = ".\NSLookup_Results"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

foreach ($dns in $dnsServers) {
    $outputFile = Join-Path $outputDir "$($dns.Name)_results.txt"
    if (Test-Path $outputFile) { Remove-Item $outputFile } # Clear old results
    
    foreach ($host in $hosts) {
        $hostname = $host.Hostname
        $result = nslookup $hostname $dns.IP
        Add-Content -Path $outputFile -Value "===== Lookup for $hostname on $($dns.Name) ($($dns.IP)) ====="
        Add-Content -Path $outputFile -Value $result
        Add-Content -Path $outputFile -Value ""
    }
}

Write-Host "NSLookup completed. Results stored in: $outputDir"
