function Get-NetFrameworkVersion {
    param ([Parameter(Mandatory=$true)]
    [string]$server        
    )
    
try {Invoke-Command -ComputerName $server -ErrorAction SilentlyContinue -ScriptBlock {
    $NETv4Later = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\'
    $NETv4Early = Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP'
    
    if (!$NETv4Later.Release -eq $false){
    switch ($NETv4Later.Release) {
        528040 {Write-Host "Version 4.8 or later installed" -ForegroundColor Cyan}
        528049 {Write-Host "Version 4.8 or later installed" -ForegroundColor Cyan}
        461808 {Write-Host "Version 4.7.2 installed" -ForegroundColor Cyan}
        461814 {Write-Host "Version 4.7.2 installed" -ForegroundColor Cyan}
        461308 {Write-Host "Version 4.7.1 installed" -ForegroundColor Cyan}
        461310 {Write-Host "Version 4.7.1 installed" -ForegroundColor Cyan}
        460798 {Write-Host "Version 4.7 installed" -ForegroundColor Cyan}
        460805 {Write-Host "Version 4.7 installed" -ForegroundColor Cyan}
        394802 {Write-Host "Version 4.6.2 installed" -ForegroundColor Cyan}
        394806 {Write-Host "Version 4.6.2 installed" -ForegroundColor Cyan}
        394254 {Write-Host "Version 4.6.1 installed" -ForegroundColor Cyan}
        394271 {Write-Host "Version 4.6.1 installed" -ForegroundColor Cyan}
        393295 {Write-Host "Version 4.6 installed" -ForegroundColor Cyan}
        393297 {Write-Host "Version 4.6 installed" -ForegroundColor Cyan}
        379893 {Write-Host "Version 4.5.2 installed" -ForegroundColor Cyan}
        378675 {Write-Host "Version 4.5.1 installed" -ForegroundColor Cyan}
        378758 {Write-Host "Version 4.5.1 installed" -ForegroundColor Cyan}
        378389 {Write-Host "Version 4.5 installed" -ForegroundColor Cyan}
    }
    
    }else {
        $NETv4Later.Version
    }
    
    $V2Check = $NETv4Early | Where-Object {$_.name -like '*2.0*'}
    if (!$V2Check -eq $false){
        $V2_Version = (Get-ItemProperty -Path $V2Check.Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")).Version
        Write-Host "Version $V2_Version installed" -ForegroundColor Green
    }else {Write-Host "Version 2.0 not installed" -ForegroundColor Red}
    $V3Check = $NETv4Early | Where-Object {$_.name -like '*3.0*'}
    if (!$V3Check -eq $false){
         $V3_Version = (Get-ItemProperty -Path $V3Check.Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")).Version
        Write-Host "Version $V3_Version installed" -ForegroundColor Magenta
    }else {Write-Host "Version 3.0 not installed" -ForegroundColor Red}
    $V3_5Check = $NETv4Early | Where-Object {$_.name -like '*3.5*'}
    if (!$V3_5Check -eq $false){
        $V3_5Version = (Get-ItemProperty -Path $V3_5Check.Name.Replace("HKEY_LOCAL_MACHINE","HKLM:")).Version
        Write-Host "Version $V3_5Version installed" -ForegroundColor Yellow
    }else {Write-Host "Version 3.5 not installed" -ForegroundColor Red}
    
    

}
}catch{Write-Host "Could not connect to server!!" -ForegroundColor Red}
}