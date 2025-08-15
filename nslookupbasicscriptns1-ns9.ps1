# DNS Resolution Check Script for ns1 and ns9

# Import required module for Excel handling
try {
    Import-Module ImportExcel -ErrorAction Stop
} catch {
    Write-Host "ImportExcel module is required. Install it with: Install-Module -Name ImportExcel -Force" -ForegroundColor Red
    exit
}

# Configuration
$InputFile = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025.xlsx"
$OutputNS1 = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025-ns1results01.csv"
$OutputNS9 = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025-ns9results01.csv"
$DNS_Servers = @{
    "ns1" = "10.212.6.64"
    "ns9" = "10.211.134.47"
}

# Check if input file exists
if (-Not (Test-Path $InputFile)) {
    Write-Host "Input file not found: $InputFile" -ForegroundColor Red
    exit
}

# Function to perform DNS resolution
function Test-DNSResolution {
    param (
        [string]$ServerName,
        [string]$ServerIP,
        [string]$OutputFile,
        [array]$Hostnames
    )
    
    Write-Host "`nTesting against $ServerName ($ServerIP)..." -ForegroundColor Yellow
    
    # Clear or create output file
    "Hostname,IPAddresses" | Out-File -FilePath $OutputFile -Force
    
    $total = $Hostnames.Count
    $count = 0
    
    foreach ($Hostname in $Hostnames) {
        $count++
        $progress = [math]::Round(($count / $total) * 100, 2)
        Write-Progress -Activity "Resolving hostnames against $ServerName" -Status "$progress% Complete" -PercentComplete $progress -CurrentOperation $Hostname
        
        Write-Host "Resolving [$count/$total]: $Hostname" -ForegroundColor Cyan
        
        try {
            $Result = Resolve-DnsName -Server $ServerIP -Name $Hostname -ErrorAction Stop
            $IPAddresses = $Result | Where-Object { $_.QueryType -eq "A" } | Select-Object -ExpandProperty IPAddress -ErrorAction SilentlyContinue
            
            if ($IPAddresses) {
                $Output = """$Hostname"",""$($IPAddresses -join ', ')"""
                Write-Host "  Success: $($IPAddresses -join ', ')" -ForegroundColor Green
            } else {
                $Output = """$Hostname"",""No A records found"""
                Write-Host "  Warning: No A records found" -ForegroundColor Yellow
            }
        } catch {
            $Output = """$Hostname"",""Resolution Failed: $($_.Exception.Message)"""
            Write-Host "  Error: Resolution Failed - $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Append to output file
        $Output | Out-File -FilePath $OutputFile -Append
    }
    
    Write-Host "`n$ServerName resolution completed. Results saved to $OutputFile" -ForegroundColor Green
}

# Main script execution
try {
    # Read hostnames from Excel file (assuming they're in column A)
    $Hostnames = Import-Excel -Path $InputFile | Select-Object -ExpandProperty A -ErrorAction Stop | Where-Object { $_ -ne $null }
    
    if (-not $Hostnames -or $Hostnames.Count -eq 0) {
        throw "No hostnames found in the Excel file"
    }
    
    Write-Host "Loaded $($Hostnames.Count) hostnames from input file" -ForegroundColor Green
    
    # Test against both DNS servers
    Test-DNSResolution -ServerName "ns1" -ServerIP $DNS_Servers["ns1"] -OutputFile $OutputNS1 -Hostnames $Hostnames
    Test-DNSResolution -ServerName "ns9" -ServerIP $DNS_Servers["ns9"] -OutputFile $OutputNS9 -Hostnames $Hostnames
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nScript completed successfully" -ForegroundColor Green
