$a = @()

$a += Invoke-Command -ComputerName 'czchows6304' -ScriptBlock {   

  $b = [pscustomobject] @{
     
        Routing = @{}
        IP = ''
        
  
  
  
  }

  $c =  Get-NetRoute -InterfaceAlias Barn -PolicyStore Persistentstore | Select-Object -Property @{N="Routing on $Using:Server";E={"DestinationPrefix " + $_.DestinationPrefix + " NextHop " + $_.NextHop + " RouteMetric " + $_.RouteMetric}} | ft -Wrap | Out-String
  $d =  Get-NetIPAddress -InterfaceAlias Barn | Select-Object -Property @{N='IP Address';E={$_.IPAddress + "\" +  $_.prefixlength}}

 
  $b.routing = $c
  $b.ip = $d
  return $b

}

$a | select -Property * -ExcludeProperty PSComputerName,RunSpaceId | fl






Write-Host "==================" -ForegroundColor Red