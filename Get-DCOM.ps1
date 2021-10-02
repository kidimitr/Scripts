function Get-DCOM {
  Param ($server,$maxevents)
  $events = Get-WinEvent -ComputerName $server -FilterHashtable @{logname='system';id='10016'} -MaxEvents $maxevents
  foreach ($event in $events){
    $appid = $event.properties[4].Value


    [PSCustomObject] @{
    
      Date = $event.timecreated
      AppID = $event.properties[4].Value
      CLSID = $event.properties[3].Value
      User = $event.Properties[5].Value + '\' + $event.Properties[6].Value
      Name = (Get-ItemProperty -Path HKLM:\SOFTWARE\Classes\Appid\$appid).'(default)'
      
  
  
 
  
    }
  


  }

}