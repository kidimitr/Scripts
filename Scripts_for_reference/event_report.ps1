$server = Read-Host 'Input server'
$logname = Read-Host 'Input log name'
$Log_ID = Read-Host 'Input log ID to query'
$To = Read-Host 'Input Email of recipient'
#$From = Read-Host 'Input Email of sender'

Invoke-Command -ComputerName $server -ScriptBlock {
  $logons = Get-WinEvent -FilterHashtable @{LogName = $using:Logname; id=$using:Log_ID}
  $logs = @()
  foreach ($logon in $logons){

    switch ($using:logname){
    
      'Security'{$myobject = [PSCustomObject] @{
      
            Username = $logon.properties[5].Value
            Time = $logon.timecreated
    
      }
      
   }
    
      'System' {$myobject = [PSCustomObject] @{
      
            ID = $logon.id
            Time = $logon.timecreated
    
      }
      
   }

      'microsoft-windows-printservice/operational'{
      
        $myobject = [PScustomobject] @{
          UID = $logon.Properties[2].Value
          Computer = $logon.Properties[3].Value
          Printername = $logon.Properties[4].Value
          server = $logon.MachineName
          Date = $logon.timecreated
      
        }
      }       
    }
    
     $logs += $myobject
    
      }
  $testpath = Test-Path C:\Temp
  if ($testpath -eq $false){ 
  
      New-Item -Path c:\temp -ItemType Directory
      $logs | select Username,Time | Export-Csv -Path 'c:\temp\log_report.csv' -Append -NoTypeInformation -Delimiter ';'
  
    } 
    else {$logs | Export-Csv -Path 'c:\temp\log_report.csv' -Append -NoTypeInformation -Delimiter ';'
  
  
    }

    Compress-Archive -Path 'c:\temp\log_report.csv'  -DestinationPath 'c:\temp\log_report.zip'
    $zip = 'c:\temp\log_report.zip'

    Send-MailMessage -To $using:To -from 'event_query@dhl.com'  -SmtpServer "gateway.dhl.com" -Subject "Event Log Report" -Body "Attached is the event log report for $Using:server" -Attachments $zip -Priority High
  
    Remove-Item -Path 'c:\temp\log_report.csv'
    Remove-Item -Path $zip


}

