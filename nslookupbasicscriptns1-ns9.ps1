
#Generate resolution on ns1

# Input and Output File Paths

$InputFile = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025.xlsx"  # File containing hostnames (one per line)

$OutputFile = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025-ns1results01.csv"  # File to save the results

 

# Check if the input file exists

if (-Not (Test-Path $InputFile)) {

    Write-Host "Input file not found: $InputFile" -ForegroundColor Red

    exit

}

 

# Clear the output file if it exists

if (Test-Path $OutputFile) {

    Clear-Content $OutputFile

}

 

# Read hostnames from the input file

$Hostnames = Get-Content $InputFile

 

# Perform nslookup for each hostname

foreach ($Hostname in $Hostnames) {

    Write-Host "Resolving: $Hostname" -ForegroundColor Cyan

    try {

        $Result = Resolve-DnsName -Server 10.212.6.64 -Name $Hostname -ErrorAction Stop

        $IPAddresses = $Result | Where-Object { $_.QueryType -eq "A" } | Select-Object -ExpandProperty IPAddress

        $Output = "$Hostname : $($IPAddresses -join ', ')"

    } catch {

        $Output = "$Hostname : Resolution Failed"

    }

    # Append the result to the output file

    $Output | Out-File -FilePath $OutputFile -Append

}

 

Write-Host "NSLookup completed. Results saved to $OutputFile" -ForegroundColor Green

 

 

#Generate resolution on ns9

# Input and Output File Paths

$InputFile = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025.xlsx"  # File containing hostnames (one per line)

$OutputFile = "C:\Users\MGD002\OneDrive - Comerica\Desktop\Sunday_CHG_DOCS\DNSCheckList082025-ns9results01.csv"  # File to save the results

 

# Check if the input file exists

if (-Not (Test-Path $InputFile)) {

    Write-Host "Input file not found: $InputFile" -ForegroundColor Red

    exit

}

 

# Clear the output file if it exists

if (Test-Path $OutputFile) {

    Clear-Content $OutputFile

}

 

# Read hostnames from the input file

$Hostnames = Get-Content $InputFile

 

# Perform nslookup for each hostname

foreach ($Hostname in $Hostnames) {

    Write-Host "Resolving: $Hostname" -ForegroundColor Cyan

    try {

        $Result = Resolve-DnsName -Server 10.211.134.47 -Name $Hostname -ErrorAction Stop

        $IPAddresses = $Result | Where-Object { $_.QueryType -eq "A" } | Select-Object -ExpandProperty IPAddress

        $Output = "$Hostname : $($IPAddresses -join ', ')"

    } catch {

        $Output = "$Hostname : Resolution Failed"

    }

    # Append the result to the output file

    $Output | Out-File -FilePath $OutputFile -Append

}

 

Write-Host "NSLookup completed. Results saved to $OutputFile" -ForegroundColor Green
