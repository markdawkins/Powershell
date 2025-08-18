<#
.SYNOPSIS
    Captures network traffic on Ethernet4 interface for 5 minutes using specified source and destination IP filters.
.DESCRIPTION
    This script prompts the user for source and destination IP addresses, then runs Tshark for 5 minutes
    to capture traffic matching these filters on the Ethernet4 interface.
.NOTES
    File Name      : TsharkCapture.ps1
    Prerequisites  : Tshark (Wireshark) must be installed and in system PATH
    Version        : 1.0
#>

# Check if Tshark is available
if (-not (Get-Command tshark.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Tshark not found. Please install Wireshark first." -ForegroundColor Red
    exit 1
}

# Prompt user for IP addresses
$srcIp = Read-Host "Enter source IP address (or leave blank for any)"
$dstIp = Read-Host "Enter destination IP address (or leave blank for any)"

# Build display filter based on input
$displayFilter = @()
if ($srcIp) { $displayFilter += "ip.src == $srcIp" }
if ($dstIp) { $displayFilter += "ip.dst == $dstIp" }

$finalFilter = $displayFilter -join " and "
if (-not $finalFilter) { $finalFilter = "ip" }

Write-Host "Using filter: $finalFilter" -ForegroundColor Cyan

# Generate output filename with timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFile = "TsharkCapture_$timestamp.pcapng"

# Run Tshark capture for 5 minutes (300 seconds)
Write-Host "Starting capture on Ethernet4 for 5 minutes..." -ForegroundColor Green
Write-Host "Output will be saved to: $outputFile" -ForegroundColor Green

tshark.exe -i "Ethernet4" -f "$finalFilter" -a duration:300 -w $outputFile

Write-Host "Capture completed. File saved to: $outputFile" -ForegroundColor Green
