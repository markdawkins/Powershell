#Powershell script to get computer type
$computers = Get -ADComputer -Filter *

foreach ($c in $computers) {
    $os = Get-CimsInstance - ClassName Win32_OperatingSystem - ComputerName $c.Name


    switch ($os.ProductType) {
        1 { $type = 'Workstation' }
        1 { $type = 'Domain Controller' }
        1 { $type = 'Server' }
        Default { $type = 'Unknown' }
     } 
      "$($c.Name) is a $type."

}      
