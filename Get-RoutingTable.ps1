function Get-RoutingTable{
  <#
      .SYNOPSIS
      Get-RoutingTable queries a server's BARN config

      .DESCRIPTION
      Get-RoutingTable assess whether a BARN is setup correctly for Backups

      .PARAMETER Server
      Input remote server from which the event logs should be extract

      .PARAMETER Domain
      Specifies the domain of the queried server (Values allowed: PHX-DC,PRG-DC,KUL-DC)

      .PARAMETER EventID_System
     
      .EXAMPLE
       Get-RoutingTable -server czchows6304 -domain prg-dc
  #>  
  
  
  param([Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [ValidateSet('prg-dc','phx-dc','kul-dc')]
    [string]$domain
  )
    $result = @()
 
  
  try
  {
    $result +=    Invoke-Command -ComputerName $server -ScriptBlock {
  
  $route1 =  try{Get-NetRoute -InterfaceAlias Barn -PolicyStore Persistentstore -RouteMetric 3  -ErrorAction SilentlyContinue| Select-Object -Property @{N="Routing_on_$Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric + " PERSISTENTSTORE"}}}catch{}
  $route2 =  try{ Get-NetRoute -InterfaceAlias Barn -PolicyStore Activestore -RouteMetric 3 -ErrorAction SilentlyContinue | Select-Object -Property @{N="Routing_on_$Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric + " ACTIVESTORE!"}}}catch{}
  $Routing_p =  if(!$route1 -eq $true){$route2}else{$route1}
      
      
      $Routing2_p = $Routing_p | Select-Object -ExpandProperty routing_on_$using:server
      $Gateway_GW = Get-NetIPConfiguration -InterfaceAlias Barn
      $BARN = Get-NetIPAddress -InterfaceAlias Barn | Select-Object -Property @{N='IP_Address';E={$_.IPAddress + "\" +  $_.prefixlength}}
      $BARN2 = Get-NetIPAddress -InterfaceAlias Barn | Select-Object -ExpandProperty IPAddress
      $ROUTING_NextHop = Get-NetRoute -InterfaceAlias Barn -PolicyStore Persistentstore | Select-Object -ExpandProperty Nexthop
      $Trace = switch ($using:domain){
      
        Prg-dc {Test-NetConnection prgnbu2014-b.prg-dc.dhl.com -TraceRoute -Hops 1 -WarningAction SilentlyContinue }
        Kul-dc {Test-NetConnection nbumstr-b.apis.dhl.com  -TraceRoute -Hops 1 -WarningAction SilentlyContinue}
        Phx-dc {Test-NetConnection qasnbu2014-b.phx-dc.dhl.com -TraceRoute -Hops 1 -WarningAction SilentlyContinue}
      
      }

      if(!$ROUTING_NextHop -eq $false){
      $ROUTING_NextHop1 = $ROUTING_NextHop[0].split('.')[0] + '.'
      $ROUTING_NextHop2 = $ROUTING_NextHop[0].split('.')[1] + '.'
      $ROUTING_NextHop3 = $ROUTING_NextHop[0].split('.')[2] + '.'
      $ROUTINGHOP = $ROUTING_NextHop1 + $ROUTING_NextHop2 + $ROUTING_NextHop3
      $TraceIP1 = $Trace.TraceRoute.split('.')[0] + '.'
      $TraceIP2 = $Trace.TraceRoute.split('.')[1] + '.'
      $TraceIP3 = $Trace.TraceRoute.split('.')[2] + '.'
      $TRACEIP = $TraceIP1 + $TraceIP2 + $TraceIP3
      $trace0 = $TRACEIP -match $ROUTINGHOP}else{$trace0 = $false}
      $Trace_Result = if(!$trace0 -eq $false){'Trace SUCCESSFUL'}else{'Trace UNSUCCESSFUL'}
      $BARNHOSTNAME = "{0}-b.{1}.dhl.com" -f $using:server,$using:domain
      $PTR = try{$REVERSEDNS =  [System.Net.Dns]::GetHostByName($BARNHOSTNAME).addresslist.ipaddresstostring
        $DUALPTR1 = $REVERSEDNS[0]
        $DUALPTR2 = $REVERSEDNS[1]
        if($REVERSEDNS.Count -gt 1){"PTR matches: $DUALPTR1 & $DUALPTR2"}else{if($REVERSEDNS -eq $BARN2){"PTR matches: $REVERSEDNS"}else{"PTR does not match: $REVERSEDNS"}}
        
          }catch
           {
              "Error was $_"
              $line = $_.InvocationInfo.ScriptLineNumber
              "Error was in Line $line"
           }


      $A_Record = if($REVERSEDNS.Count -gt 1){try{$BARNDNSRECORD = [System.Net.Dns]::GetHostByAddress($DUALPTR1).hostname
        if ($BARNDNSRECORD -eq $BARNHOSTNAME){"DNS Record matches $BARNHOSTNAME"
            }else{"DNS Record does not match $BARNDNSRECORD $REVERSEDNS"}
        }catch{
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
         }}else{try{$BARNDNSRECORD = [System.Net.Dns]::GetHostByAddress($REVERSEDNS).hostname
            if ($BARNDNSRECORD -eq $BARNHOSTNAME){"DNS Record matches $BARNHOSTNAME"
                }else{"DNS Record does not match $BARNDNSRECORD $REVERSEDNS"}
            }catch{
            "Error was $_"
            $line = $_.InvocationInfo.ScriptLineNumber
            "Error was in Line $line"
             }}
       $gateway2 = if(!$Gateway_GW.IPv4DefaultGateway.nexthop -eq $true){'No Gateway'}else{"Gateway detected! " + $Gateway_GW.IPv4DefaultGateway.nexthop}
       $PersistentRoutes = $Routing2_p | Format-Table -Wrap | Out-String
      $objectresult =  [pscustomobject] @{ 
        Barn_IP = if(!$BARN -eq $true){"BARN interface not found"}else{$Barn.IP_Address}
        Gateway = $gateway2
        Barn_Hostname = $BARNHOSTNAME
        PTR = $PTR
        A_Record = $A_Record
        Persistent_Routes = if(!$PersistentRoutes -eq $true){'No Persistent Routes found'}else{$PersistentRoutes}
        Trace = $Trace_Result
    
      } 
       
      return $objectresult
  
    } -ErrorAction SilentlyContinue -HideComputerName
    
  }
  catch 
  {
   Write-Host "Could not connect to server $Server" -BackgroundColor Red
  }
  $result | Select-Object -Property * -ExcludeProperty RunSpaceID | Format-List  
  }
  


