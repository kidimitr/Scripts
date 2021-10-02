function Get-RoutingTable
{param([Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [ValidateSet('prg-dc','phx-dc','kul-dc')]
    [string]$domain
  )
  
  try
  {
    Invoke-Command -ComputerName $server -ScriptBlock {
  
      Get-NetRoute -InterfaceAlias Barn -PolicyStore Persistentstore | Select-Object -Property @{N="Routing on $Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric}} | ft -Wrap 
      Get-NetIPAddress -InterfaceAlias Barn | Select-Object -Property @{N='IP Address';E={$_.IPAddress + "\" +  $_.prefixlength}} | ft -Wrap
      
  
    } -ErrorAction Stop
  
  }
  catch 
  {
    Write-Host "Could not connect to server $Server" -BackgroundColor Red
    
    
  }
  $Win32_networkadaptercon = Get-CimInstance -ComputerName $server -ClassName Win32_NetworkAdapterConfiguration
  #$Win32_networkadaptercon = Get-WmiObject -ComputerName $server -Class Win32_NetworkAdapterConfiguration
  $win32_networkadapter = Get-CimInstance -ComputerName $server -ClassName win32_networkadapter
  #$win32_networkadapter = Get-WmiObject -ComputerName $server -Class Win32_NetworkAdapter
  $BARN = ($Win32_networkadaptercon | Where-Object -Property Index -eq ($win32_networkadapter | Where-Object NetconnectionID -eq 'BARN').deviceid).ipaddress

  if($BARN -eq 'False'){

    Write-Host "BARN interface not found"

  }else{Write-Host "DNS Info"
        Write-Host "--------"
  }

  $BARNHOSTNAME =  "{0}-b.{1}.dhl.com" -f $server,$domain
  Write-Host "Barn host name is $BARNHOSTNAME" -ForegroundColor Yellow
  try
  {
    $REVERSEDNS =  [System.Net.Dns]::GetHostByName($BARNHOSTNAME).addresslist.ipaddresstostring
    if($REVERSEDNS -eq $BARN){Write-Host "Reverse IP matches $BARN" -ForegroundColor DarkCyan}else{Write-Host "Reverse IP $REVERSEDNS does not match $BARN" -ForegroundColor Red}
  }
  catch
  {
    "Error was $_"
    $line = $_.InvocationInfo.ScriptLineNumber
    "Error was in Line $line"
  }

  try
  {
    $BARNDNSRECORD = [System.Net.Dns]::GetHostByAddress($REVERSEDNS).hostname
    if ($BARNDNSRECORD -eq $BARNHOSTNAME){
      Write-Host "DNS Record matches $BARNHOSTNAME`n" -ForegroundColor DarkCyan
      Write-Host '=============================================='-BackgroundColor Magenta
    }else{Write-Host "DNS Record does not match" -ForegroundColor Red}
  }
  catch
  {
    "Error was $_"
    $line = $_.InvocationInfo.ScriptLineNumber
    "Error was in Line $line"
  }
  

  
  
  
  }
  
  
  


