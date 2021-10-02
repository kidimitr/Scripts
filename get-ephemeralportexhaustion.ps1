function Get-EphemeralPortExhaustion
{ param ([string]$server)
  
  Invoke-Command -ComputerName $server -ScriptBlock {
  
  
    try {Get-WinEvent -FilterHashtable @{logname='system';id='4231'} -ErrorAction Stop}
    catch {Write-Host 'No Events Found' -BackgroundColor Red}
  
  
  
  }  
 
}




