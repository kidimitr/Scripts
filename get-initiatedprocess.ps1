function Get-InitiatedProcess {
  param([Parameter(Mandatory = $true)][string]$computer)

  $events = Get-WinEvent -ComputerName $computer -FilterHashtable @{logname='security';id='4688'}
  foreach ($event in $events){
    [pscustomobject] @{
    
      Name = $event.properties[1].value
      Time = $event.timecreated
      Process = $event.properties[5].value 
  
  
  
  
  
    }
  }
}