function Get-Uptime {
    param ([Parameter(Mandatory = $false, Position = 0)][string]$Hostname,
        [Parameter(Mandatory = $false, Position = 1)][switch]$Local
        
    )
    

    if ($Local) {

        $Time = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $Date = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        Write-Host @"
==============================
Computer was last rebooted on:  
$Date

or

$($time.Days) Days $($time.Hours) Hours $($time.Minutes) Minutes ago
==============================  


"@  


    }
    else {


        $Time = (Get-Date) - (Get-CimInstance -ComputerName $Hostname -ClassName Win32_OperatingSystem).LastBootUpTime
        $Date = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        Write-Host @"
==============================
Computer was last rebooted on:  
$Date

or

$($time.Days) Days $($time.Hours) Hours $($time.Minutes) Minutes ago
==============================  

"@


   }



}