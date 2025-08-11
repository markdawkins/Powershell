# File: run-nslookup.ps1

$inputFile = "checklist.csv"
if (-not (Test-Path $inputFile)) {
    Write-Error "❌ Input file '$inputFile' not found."
    exit 1
}

Write-Host "✅ Reading hostnames from $inputFile..."
$hosts = Import-Csv -Path $inputFile

# Confirm header name
if (-not ($hosts | Get-Member -Name Hostname -MemberType NoteProperty)) {
    Write-Error "❌ CSV must have a column named 'Hostname'. Found headers: $($hosts[0] | Get-Member -MemberType NoteProperty | ForEach-Object Name -join ', ')"
    exit 1
}

# DNS servers to query
$dnsServers = @(
    @{Name = "ns1"; IP = "10.212.6.64"},
    @{Name = "ns3"; IP = "10.211.6.47"}
)

$outputDir = ".\NSLookup_Results"
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

foreach ($dns in $dnsServers) {
    $outputFile = Join-Path $outputDir "$($dns.Name)_results.csv"
    $results = @()

    Write-Host "🔍 Querying DNS server $($dns.IP) ($($dns.Name))..."

    foreach ($entry in $hosts) {
        $hostname = $entry.Hostname
        if (-not $hostname) {
            Write-Warning "⚠️ Skipping empty hostname entry."
            continue
        }
        $hostname = $hostname.Trim()
        Write-Host "   → Looking up $hostname..."

        try {
            $lookupRaw = nslookup $hostname $dns.IP 2>&1
        } catch {
            $lookupRaw = @($_.Exception.Message)
        }

        # Extract last IPv4 result
        $ipMatch = $lookupRaw | Select-String -Pattern 'Address:\s+(\d{1,3}(?:\.\d{1,3}){3})' -AllMatches
        if ($ipMatch -and $ipMatch.Matches.Count -gt 0) {
            $resolvedIP = $ipMatch.Matches[-1].Groups[1].Value
            $lookupResult = ($lookupRaw | Where-Object {
                ($_ -notmatch '^\*\*\* Unknown') -and
                ($_ -notmatch '^Server:') -and
                ($_ -notmatch '^Address:')
            }) -join "`n"
        } else {
            $resolvedIP = "Not Found"
            $lookupResult = "Lookup failed"
        }

        $results += [PSCustomObject]@{
            Hostname      = $hostname
            DNS_Server    = "$($dns.Name) ($($dns.IP))"
            IP_Address    = $resolvedIP
            Lookup_Result = $lookupResult
        }
    }

    $results | Export-Csv -Path $outputFile -NoTypeInformation -Force
    Write-Host "✅ Results saved to $outputFile"
}

Write-Host "🎯 NSLookup completed. Files stored in: $outputDir"
