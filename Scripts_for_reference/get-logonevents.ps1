function Get-LogonEvents {
  param(
    [parameter(Mandatory=$true)]
    [string]$computername,
    [parameter(argument1='Grid',argument2='CSV')][string]$output
    
  
  )
  
    Switch()

  Invoke-Command -ComputerName $computername -ScriptBlock {
    $ids = 4624,4625
    $events = Get-WinEvent -FilterHashtable @{logname='security';id=$ids}
    $ids2 = 4647,4634
    $events2 = Get-WinEvent -FilterHashtable @{logname='security';id=$ids2}
    $ids3 = 4778,4779
    $events3 = Get-WinEvent -FilterHashtable @{logname='security';id=$ids3}
    foreach ($event in $events){
      [pscustomobject] @{    
        Name = $event.Properties[5].Value
        Time = $event.TimeCreated
        ID = $event.id  
      }
    }  
  
    foreach ($event2 in $events2){
      [pscustomobject] @{    
        Name = $event2.properties[1].value
        Time = $event2.Timecreated
        ID = $event2.id    
      }
    }
    #Shows events for disconnected/reconnected RDP session
    foreach ($event3 in $events3){
      [pscustomobject] @{    
        Name = $event3.properties[0].value
        Time = $event3.Timecreated
        ID = $event3.id
    
      }
    }  
  }   | Out-GridView

}
#| Export-Csv -Path c:\temp\logons.csv -NoTypeInformation -Delimiter ';'