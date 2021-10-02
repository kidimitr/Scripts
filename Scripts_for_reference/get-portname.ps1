function get-portname($server){

  $printername = Get-CimInstance -ComputerName $server -ClassName win32_printer | Where-Object {$_.Shared -eq $true} | select -Property PortName
  $ports = $printername.portname
  $IP = @()
  
 $myobjects = foreach($port in $ports){
   
    $IP += Invoke-Command -ComputerName $server -ScriptBlock {(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Print\Monitors\Standard TCP/IP Port\Ports\$Using:port" Hostname).hostname} -ErrorAction SilentlyContinue | Out-String
    $Printer = @()
    $Printer = Get-CimInstance -ComputerName $server -ClassName win32_printer | Where-Object {$_.Shared -eq $true} | select -Property PortName,Name,DriverName | Out-String
   
  
  

              [pscustomobject] @{
                #Name = ($printer.name | Out-String).Trim()
                #Portname = ($printer.portname | Out-String).Trim()
                #IP = ($IP | Out-String).Trim()
                #Driver = ($printer.drivername | Out-String).Trim()
                Name = $printer.name
                Portname = $printer.portname
                IP = $IP
                Driver = $printer.drivername
                         
              } | Export-Csv -NoTypeInformation c:\temp\testport.csv -Append -Delimiter ';'
   
      write-host $myobjects
      }
       
    }
