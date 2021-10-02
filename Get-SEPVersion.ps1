function Get-SEPVersion {
    param ([Parameter(Mandatory=$true)][string]$server
        
    )
    
    Get-CimInstance -ComputerName $server -ClassName win32_product | Where-Object {$_.name -like '*Symantec Endpoint Protection*'} | Select-Object -Property Name,Version

}