function Get-ServicePath {
    param ([Parameter(Mandatory=$true)]$computer,
    [Parameter(Mandatory=$true)]$servicename
    )
    try{ Get-WmiObject -ComputerName $computer -Class win32_service -Filter "Name like '$servicename'" -ErrorAction SilentlyContinue | Select-Object -Property Name,Pathname,State  

}catch{}

    try{Get-CimInstance -ComputerName $computer -Class win32_service -Filter "Name like '$servicename'" -ErrorAction SilentlyContinue | Select-Object -Property Name,Pathname,State

}catch{}
    

}