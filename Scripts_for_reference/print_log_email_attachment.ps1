$server = Read-Host "Input Server"
$filename =  "c:\temp\print_report_$server.csv"
$To = Read-Host 'Input recipient'

Invoke-Command -ComputerName $server -ScriptBlock {

  $prints = Get-WinEvent -FilterHashtable @{logname='microsoft-windows-printservice/operational';id='307'}
  $objects = @()
  foreach ($print in $prints){

    $myobjects = [pscustomobject] @{
      UID = $print.Properties[2].Value
      Computer = $print.Properties[3].Value
      Printername = $print.Properties[4].Value
      server = $print.MachineName
      Date = $print.timecreated
    }

    $objects += $myobjects
    $testpath = Test-Path C:\Temp
 

  }
   if ($testpath -eq $false){
    
    New-Item -Path 'c:\temp' -ItemType Directory  
    $objects | Export-Csv -Path $Using:filename -Append -NoTypeInformation -Delimiter ';'
  
  
  }
    else {$objects | Export-Csv -Path $using:filename -Append -NoTypeInformation -Delimiter ';'
  



    }
    Compress-Archive -Path $using:filename -DestinationPath "c:\temp\print_report_$using:server.zip"
    $zip =  "c:\temp\print_report_$using:server.zip"

  Send-MailMessage -To $using:To -from "PringLogs@dhl.com" -SmtpServer "gateway.dhl.com" -Subject "Print Logs" -Body "Attached is the printing report for server $Using:server" -Attachments $zip -Priority High

  Remove-Item $Using:filename
  Remove-Item $zip   

  }