$servers = Get-Clipboard

foreach ($server in $servers){

   Write-Host $server -ForegroundColor Red
  Invoke-Command -ComputerName $server -ScriptBlock {
  
    
    Get-NetRoute -PolicyStore persistentstore
    Get-NetIPAddress -InterfaceAlias Barn | select InterfaceAlias,InterfaceIndex,IPAddress,PrefixLength
  
  
  
  
  }




}