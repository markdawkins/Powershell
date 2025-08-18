<#
.SYNOPSIS
    Captures network traffic on Ethernet4 interface for 5 minutes using specified source and destination IP filters.
.DESCRIPTION
    This script prompts the user for source and destination IP addresses, then runs Tshark for 5 minutes
    to capture traffic matching these filters on the Ethernet4 interface.
.NOTES
    File Name      : TsharkCapture.ps1
    Prerequisites  : Wireshark must be installed at default location
    Version        : 3.0
#>

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires Administrator privileges. Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# Define Tshark path
$tsharkPath = "C:\Program Files\Wireshark\tshark.exe"

# Verify Tshark exists at specified location
if (-not (Test-Path $tsharkPath)) {
    Write-Host "Tshark not found at $tsharkPath" -ForegroundColor Red
    Write-Host "Please install Wireshark to the default location or modify the script path." -ForegroundColor Yellow
    Write-Host "Download from: https://www.wireshark.org/download.html" -ForegroundColor Cyan
    exit 1
}

# List available interfaces
Write-Host "`nListing available interfaces..." -ForegroundColor Cyan
& "$tsharkPath" -D | Out-Host

# Prompt user for IP addresses
Write-Host "`nEnter IP addresses (leave blank for any)" -ForegroundColor Cyan
$srcIp = Read-Host "Source IP address"
$dstIp = Read-Host "Destination IP address"

# Validate IP addresses if provided
if ($srcIp -and -not ($srcIp -as [System.Net.IPAddress])) {
    Write-Host "Invalid source IP address format" -ForegroundColor Red
    exit 1
}

if ($dstIp -and -not ($dstIp -as [System.Net.IPAddress])) {
    Write-Host "Invalid destination IP address format" -ForegroundColor Red
    exit 1
}

# Build capture filter (BPF syntax)
$captureFilter = @()
if ($srcIp) { $captureFilter += "src host $srcIp" }
if ($dstIp) { $captureFilter += "dst host $dstIp" }

$finalFilter = $captureFilter -join " and "
if (-not $finalFilter) { $finalFilter = "ip" }

Write-Host "`nUsing filter: $finalFilter" -ForegroundColor Green

# Generate output filename with timestamp
$outputDir = "$env:USERPROFILE\Desktop\TsharkCaptures"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFile = "$outputDir\TsharkCapture_$timestamp.pcapng"

# Display capture information
Write-Host "`nCapture Settings:" -ForegroundColor Cyan
Write-Host "Interface: Ethernet4" -ForegroundColor Cyan
Write-Host "Duration: 5 minutes" -ForegroundColor Cyan
Write-Host "Output File: $outputFile" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop capture early" -ForegroundColor Yellow

# Run Tshark capture
try {
    $captureArgs = @(
        "-i", "Ethernet4",
        "-f", $finalFilter,
        "-a", "duration:300",
        "-w", "`"$outputFile`""
    )

    Write-Host "`nStarting capture..." -ForegroundColor Green
    & "$tsharkPath" $captureArgs

    if ($LASTEXITCODE -ne 0) {
        throw "Tshark exited with error code $LASTEXITCODE"
    }

    # Verify capture file was created
    if (-not (Test-Path $outputFile)) {
        throw "Capture file was not created"
    }

    $fileSize = (Get-Item $outputFile).Length / 1MB
    Write-Host "`nCapture completed successfully!" -ForegroundColor Green
    Write-Host "File saved to: $outputFile" -ForegroundColor Green
    Write-Host "File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
}
catch {
    Write-Host "`nError during capture:" -ForegroundColor Red
    Write-Host $_ -ForegroundColor Red
    
    # Clean up partial capture file if it exists
    if (Test-Path $outputFile) {
        Remove-Item $outputFile -Force
        Write-Host "Removed incomplete capture file" -ForegroundColor Yellow
    }
    
    exit 1
}
