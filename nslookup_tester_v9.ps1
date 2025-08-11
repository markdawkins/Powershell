<#
.SYNOPSIS
  Run nslookup for hostnames from checklist.csv against two DNS servers and save all results to one CSV.

.NOTES
  - Place this script in the same folder as checklist.csv or update $inputFile to the full path.
  - Run with: powershell -ExecutionPolicy Bypass -File .\run-nslookup.ps1
#>

# ---------- Configuration ----------
$inputFile = "checklist.csv"                     # path to input CSV (must include a Hostname column)
$dnsServers = @(
    @{Name = "ns1"; IP = "10.212.6.64"},
    @{Name = "ns3"; IP = "10.211.6.47"}
)
$outputDir  = ".\NSLookup_Results"
$outputFile = Join-Path $outputDir "Merged_NSLookup_Results.csv"
$pauseSeconds = 30

# ---------- Basic checks ----------
if (-not (Test-Path $inputFile)) {
    Write-Host "❌ Input file '$inputFile' not found in $(Get-Location)."
    Write-Host "Make sure checklist.csv is in the same folder as this script or update the $inputFile path."
    Write-Host ""
    Write-Host "Pausing so you can read this message..."
    Start-Sleep -Seconds $pauseSeconds
    exit 1
}

# Read header line to validate columns (case-insensitive)
$firstLine = (Get-Content -Path $inputFile -TotalCount 1) -replace "`r",""
$columns = $firstLine -split ',' | ForEach-Object { $_.Trim() }
$columnsLower = $columns | ForEach-Object { $_.ToLower() }

if (-not ($columnsLower -contains "hostname")) {
    Write-Host "❌ CSV must have a column named 'Hostname' (case-insensitive)."
    Write-Host "Found header columns: $($columns -join ', ')"
    Write-Host ""
    Write-Host "Pausing so you can read this message..."
    Start-Sleep -Seconds $pauseSeconds
    exit 1
}

# Import CSV (this returns 0 rows if there are no host lines)
Write-Host "✅ Reading hostnames from $inputFile..."
$hosts = Import-Csv -Path $inputFile

# Ensure output directory exists
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

# ---------- Main processing ----------
$results = @()

try {
    if ($hosts.Count -eq 0) {
        Write-Warning "⚠️ Input CSV contains header but no hostname rows. No lookups will be performed."
    }

    foreach ($dns in $dnsServers) {
        Write-Host "🔍 Querying DNS server $($dns.IP) ($($dns.Name))..."
        if ($hosts.Count -eq 0) {
            Write-Host "   → (Skipping lookups because there are no host rows)"
            continue
        }

        foreach ($entry in $hosts) {
            # Use a variable name other than $Host (reserved)
            $hostname = $null

            # Support either exact 'Hostname' header or case-insensitive access
            if ($entry.PSObject.Properties.Match("Hostname")) {
                $hostname = $entry.Hostname
            } else {
                # attempt case-insensitive property lookup
                $prop = $entry.PSObject.Properties | Where-Object { $_.Name.ToLower() -eq "hostname" }
                if ($prop) { $hostname = $prop.Value }
            }

            if (-not $hostname) {
                Write-Warning "⚠️ Skipping an entry with empty hostname."
                continue
            }

            $hostname = $hostname.Trim()
            Write-Host "   → Looking up $hostname..."

            try {
                # Run nslookup and capture output lines
                $lookupRaw = nslookup $hostname $dns.IP 2>&1
            } catch {
                # If nslookup itself throws, capture the message as an array
                $lookupRaw = @($_.Exception.Message)
            }

            # Attempt to find IPv4 addresses in the output (take the last match)
            $ipMatch = $lookupRaw | Select-String -Pattern 'Address:\s+(\d{1,3}(?:\.\d{1,3}){3})' -AllMatches
            if ($ipMatch -and $ipMatch.Matches.Count -gt 0) {
                $resolvedIP = $ipMatch.Matches[-1].Groups[1].Value

                # Remove server reverse-lookup noise from the result text
                $lookupResult = ($lookupRaw | Where-Object {
                    ($_ -notmatch '^\*\*\* Unknown') -and
                    ($_ -notmatch '^Server:') -and
                    ($_ -notmatch '^Address:')
                }) -join "`n"
            } else {
                $resolvedIP = "Not Found"
                $lookupResult = ($lookupRaw -join " ")    # keep some context (single-line)
            }

            $results += [PSCustomObject]@{
                Hostname      = $hostname
                DNS_Server    = "$($dns.Name) ($($dns.IP))"
                IP_Address    = $resolvedIP
                Lookup_Result = $lookupResult
            }
        }
    }

    # ---------- Export results ----------
    if ($results.Count -gt 0) {
        $results | Export-Csv -Path $outputFile -NoTypeInformation -Force
        Write-Host "✅ All results saved to: $outputFile"
    } else {
        # Create CSV file with just headers if no rows were collected
        "Hostname,DNS_Server,IP_Address,Lookup_Result" | Out-File -FilePath $outputFile -Encoding UTF8
        Write-Warning "⚠️ No lookup results collected. Empty CSV created with headers at: $outputFile"
    }
}
catch {
    Write-Error "❗ An unexpected error occurred: $_"
}
finally {
    # Final banner and guaranteed pause so you can see the output / error messages
    Write-Host ""
    Write-Host "===================================="
    Write-Host "   🎯 All checks completed"
    Write-Host "===================================="
    Write-Host ""
    Write-Host "Pausing for $pauseSeconds seconds before exit..."
    Start-Sleep -Seconds $pauseSeconds
}
