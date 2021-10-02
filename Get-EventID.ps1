function Get-EventID
{
  <#
      .SYNOPSIS
      Get-Event Extracts events from remote computers

      .DESCRIPTION
      Get-Event Extracts events from remote computers
      Allows for extracting reports based on log type and ID  

      .PARAMETER Server
      Input remote server from which the event logs should be extract

      .PARAMETER System
      Specifies System as the log type

      .PARAMETER EventID_System
      Inpute EventID from log type System(Values allowed:41,1074,1001)
            
      .PARAMETER Security
      Specifies System as the log type

      .PARAMETER EventID_Security
      Inpute EventID from log type Security (Values allowed:4624,4625)

      .PARAMETER Output
       Specify if output should be to CSV,Grid, or Shell      

      .EXAMPLE
       Get-Eventtest -server czchows6304 -Security Security -eventid_security 4624 -output Shell
  #>
  
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$server,
    
    [Parameter(Mandatory=$true,Position=1,Parametersetname='System')]
    [ValidateSet('System')]
    [string]$System,
    
    [Parameter(Mandatory=$true,Position=2,Parametersetname='System')]
    [ValidateSet('41','1074','1001')]
    [int[]]$eventid_system,
    
    [Parameter(Mandatory=$true,Position=1,Parametersetname='Security')]
    [ValidateSet('Security')]
    [string]$Security,
    
    [Parameter(Mandatory=$true,Position=2,Parametersetname='Security')]
    [ValidateSet('4624','4625')]
    [int]$eventid_security,
    
    [Parameter(Mandatory=$true,Position=1,Parametersetname='Printer')]
    [ValidateSet('microsoft-windows-printservice/operational')]
    [string]$Print,
    
    [Parameter(Mandatory=$true,Position=2,Parametersetname='Printer')]
    [ValidateSet('307')]
    [int]$eventid_printer,

    [Parameter(Mandatory=$true,Parametersetname='Application')]
    [Validateset('Application')]
    [string]$Application,
    
    [Parameter(Mandatory=$true,Parametersetname='Application')]
    [Validateset('11707','11747')]
    [int]$eventid_application,

    [Parameter(Mandatory=$true,Position=3)]
    [ValidateSet('CSV','Grid','Shell')]
    [string]$output
  
  )
  
  Begin {}
  
  Process { 
    if($System){
  
      Switch($output){
  
        'Grid' {if($eventid_system -eq '1074'){ $eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system } 
            $reboots = @()  
            foreach($eventout in $eventoutput){
               $reboots += [PSCustomObject] @{
                
                  Username = $eventout.properties[6].value
                  Process = $eventout.properties[0].value
                  Time = $eventout.timecreated -f "HH:mm"
                  } 
                 } $reboots | Out-GridView
                }else{$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system | Out-GridView}}
               }
         
         
        'Csv'  { if($eventid_system -eq '1074'){ $eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system } 
            $reboots = @()  
            foreach($eventout in $eventoutput){
               $reboots += [PSCustomObject] @{
                
                  Username = $eventout.properties[6].value
                  Process = $eventout.properties[0].value
                  Time = $eventout.timecreated -f "HH:mm"
                  } 
                 } $reboots | Export-Csv -Path c:\temp\system_logs.csv -NoTypeInformation -Delimiter ';'
                }else{$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system | Out-GridView}}}
        'Shell'{if($eventid_system -eq '1074'){$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system}
            $reboots = @()
            foreach($eventout in $eventoutput){
                $reboots += [pscustomobject] @{
              
                 Username = $eventout.properties[6].value
                 Process = $eventout.properties[0].value
                 Time = $eventout.timecreated -f "HH:mm"
              } 
             }   $reboots
            }else{ $eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$System;id=$eventid_system}}     
          
          }
        } 
    
      }elseif($Security){
        Switch($output){
  
          'Grid' {if($Security -eq '4624') {$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security}
                $logons = @()
                foreach($eventout in $eventoutput){
                  $myobject =  [pscustomobject]@{                
                  
                    Username = $eventout.properties[5].Value
                    Time = $eventoutput.timecreated
                                   
                  }
                          
                }
                $logons += $myobject
                $logons | Out-GridView
            }else{$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security} | Out-GridView}
                         
          }
          'Csv'  {if($Security -eq '4624') {$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security}
                $logons = @()
                $myobject = [pscustomobject]@{
            
                    Username = $eventout.properties[5].Value
                    Time = $eventoutput.timecreated
                       
              }
                 $logons += $myobject
                 $logons | Export-Csv -Path c:\temp\security_logs.csv -NoTypeInformation -Delimiter ';'
            }else{$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security} | Export-Csv -Path c:\temp\security_logs.csv -NoTypeInformation -Delimiter ';'}              
          }
          
          'Shell'{if($Security -eq '4624'){ $eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security}
                $logons = @()
                $myobject = [pscustomobject]@{
            
                    Username = $eventout.properties[5].Value
                    Time = $eventoutput.timecreated
            
              }
              $logons
            }else{$eventoutput = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Security;id=$eventid_security}}
        } 
            
      }
     }elseif($Print){ $eventoutputs = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Print;id=$eventid_printer}
          $logs = @()
       
         foreach ($eventoutput in $eventoutputs){
         
          $myobject = [PScustomobject] @{
            UID = $eventoutput.Properties[2].Value
            Computer = $eventoutput.Properties[3].Value
            Printername = $eventoutput.Properties[4].Value
            server = $eventoutput.MachineName
            Date = $eventoutput.timecreated
         
          }
          $logs += $myobject

          
        }
        switch ($output)
        {
          'Grid' { $logs| Out-GridView}
          'Csv'  { $logs| Export-Csv -Path c:\temp\printer_logs.csv -NoTypeInformation -Delimiter ';'}
          'Shell'{ $logs }
        
        }


      }elseif($Application){$eventoutputs = Get-WinEvent -ComputerName $server -FilterHashtable @{logname=$Application;id=$eventid_application}
        $logs = @()

        foreach ($eventoutput in $eventoutputs){
            $myobject = [PSCustomObject] @{
                
              Sofware = $eventoutput.Properties[0].Value
              Time = $eventoutput.timecreated


            }

              $logs += $myobject
              

        }

        switch ($output)
        {
          'Grid' { $logs| Out-GridView}
          'Csv'  { $logs| Export-Csv -Path c:\temp\printer_logs.csv -NoTypeInformation -Delimiter ';'}
          'Shell'{ $logs | fl}
        
        }


      }
    
   }
    End  {if($System -or $Security -and $output -eq 'Shell'){ $eventoutput
       }
     } 
  
  }
  