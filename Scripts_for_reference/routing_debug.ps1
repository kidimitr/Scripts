#function Get-RoutingTableAlt
#{param([Parameter(Mandatory=$true)]
#    [string]$server,
#    [Parameter(Mandatory=$true)]
#    [ValidateSet('prg-dc','phx-dc','kul-dc')]
#    [string]$domain
#  )
$server = Read-Host "Server"
$domain = Read-Host "Domain"    
$result = @()
 
   
  
  try
  {
    $result +=    Invoke-Command -ComputerName $server -ScriptBlock { while ($True){
  
      $Routing_p =  try{$route1 = Get-NetRoute -InterfaceAlias Barn -PolicyStore Persistentstore -RouteMetric 3 -ErrorAction SilentlyContinue | Select-Object -Property @{N="Routing_on_$Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric}}
                        $route2 = Get-NetRoute -InterfaceAlias Barn -PolicyStore Activestore -RouteMetric 3 -ErrorAction Stop| Select-Object -Property @{N="Routing_on_$Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric + " ACTIVESTORE!"}}
        if(!$route1 -eq $true){$route2}else{$route1}
      
      }catch{
      
              "Error was $_"
              $line = $_.InvocationInfo.ScriptLineNumber
              "Error was in Line $line"
      }
      $Routing2_p = $Routing_p | select -ExpandProperty routing_on_$using:server
      $Gateway = Get-NetIPConfiguration -InterfaceAlias Barn | select -ExpandProperty IPv4DefaultGateway
      $BARN = Get-NetIPAddress -InterfaceAlias Barn | Select-Object -Property @{N='IP_Address';E={$_.IPAddress + "\" +  $_.prefixlength}}
      #$Gateway_string = $Gateway.ToString()
      $BARN2 = Get-NetIPAddress -InterfaceAlias Barn | Select-Object -ExpandProperty IPAddress
      $BARNHOSTNAME = "{0}-b.{1}.dhl.com" -f $using:server,$using:domain
      $PTR = try{$REVERSEDNS =  [System.Net.Dns]::GetHostByName($BARNHOSTNAME).addresslist.ipaddresstostring
          if($REVERSEDNS -eq $BARN2){"PTR matches: $REVERSEDNS"}else{"PTR does not match: $REVERSEDNS"}
          }catch
           {
              "Error was $_"
              $line = $_.InvocationInfo.ScriptLineNumber
              "Error was in Line $line"
           }
      $A_Record = try{$BARNDNSRECORD = [System.Net.Dns]::GetHostByAddress($REVERSEDNS).hostname
        if ($BARNDNSRECORD -eq $BARNHOSTNAME){"DNS Record matches $BARNHOSTNAME"
            }else{"DNS Record does not match"}
        }catch{
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
         } 
       $gateway2 = if(!$Gateway -eq $true){'No Gateway'}else{"Gateway detected!"}
      $objectresult =  [pscustomobject] @{ 
        Barn_IP = if($BARN -eq 'False'){"BARN interface not found"}else{$Barn.IP_Address}
        Gateway = $gateway2
        Barn_Hostname = $BARNHOSTNAME
        PTR = $PTR
        A_Record = $A_Record
        Routing = $Routing2_p | ft -Wrap | Out-String
       
      
      } 
      
      return $gateway
      return $objectresult
      
  
   } } -ErrorAction Stop -HideComputerName
      
      
  
  }
  catch 
  {
   Write-Host "Could not connect to server $Server" -BackgroundColor Red
      
  }
  $result | Select-Object -Property * -ExcludeProperty RunSpaceID | fl  
  

  #}
  


