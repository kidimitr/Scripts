$servers = Get-Clipboard

foreach ($server in $servers){


  Invoke-Command -ComputerName $server -ScriptBlock {
    #Get-NetRoute -InterfaceAlias Barn | Where-Object {$_.NextHop -notcontains '0.0.0.0'} | Remove-NetRoute -Confirm:$false
    #New-NetRoute -DestinationPrefix 7.244.65.0/24 -InterfaceAlias Barn -NextHop 7.244.76.1 -RouteMetric 3 -AddressFamily IPv4
    #New-NetRoute -DestinationPrefix 7.245.81.0/24 -InterfaceAlias Barn -NextHop 7.244.76.1 -RouteMetric 3 -AddressFamily IPv4 
    #New-NetRoute -DestinationPrefix 10.35.8.0/24 -InterfaceAlias Barn -NextHop 7.244.76.1 -RouteMetric 3 -AddressFamily IPv4
    #Get-NetRoute -InterfaceAlias Barn | Where-Object {$_.NextHop -notcontains '0.0.0.0'}  
    
    #Get-NetIPConfiguration -InterfaceAlias Barn | Select-Object -Property Ipv4address,PsComputername
    Get-NetRoute -InterfaceAlias Barn | Where-Object {$_.NextHop -notcontains '0.0.0.0'}
  
  }
  


}

