function Get-Drivers {
    param ([Parameter(Mandatory=$true)][String]$server

    )

    try {
        $WMI = Get-WmiObject -ComputerName $server -class Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Select-Object -Property DeviceName,DriverName,DriverVersion,Manufacturer | Sort-Object -Property DeviceName
    }
    catch {Write-Host "Could not connect via WMI" -ForegroundColor Red}
        
    try {$CIM = Get-CimInstance -ComputerName $server -ClassName Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Select-Object -Property DeviceName,Drivername,DriverVersion,Manufacturer | Sort-Object -Property DeviceName }
    catch{Write-Host "Could not connect via CIM" -ForegroundColor Red}

    if (!$WMI -eq $false){$WMI}else{$CIM}
    
}