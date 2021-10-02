function get-kerberossize {
  param([Parameter(Mandatory=$true)][string]$username,[string]$domain)

  $groups = Get-ADUser -Identity $username -Server $domain -Properties * | select -ExpandProperty memberof | ForEach-Object {($_ -split "CN=|,")[1]}
  $user = Get-ADUser -Identity $username -Server $domain
 

  $DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
  $server = "$($DHLglobalC.HostName):3268"
  $usergroups = @()
  $usergroups += foreach ($group in $groups)
  {
    Get-ADGroup -Server $server -Filter {samaccountname -eq $group} -Properties * | select distinguishedname,groupcategory,groupscope,name,@{N='Domain';E={$_.canonicalname.split("/")[0]}}
  
  }

  $universaloutside = @()
  if($domain -eq 'prg-dc'){
    
    $universaloutside = [int]@($usergroups | Where-Object  {$_.distinguishedname -notlike '*prg-dc*' -and $_.groupscope -eq "Universal"}).count
    $universalinside  = [int]@($usergroups | Where-Object  {$_.distinguishedname -like '*prg-dc*' -and $_.groupscope -eq "Universal"}).count
  
  }elseif($domain -eq 'kul-dc'){
  
    $universaloutside = [int]@($usergroups | where {$_.distinguishedname -notlike '*kul-dc*' -and $_.groupscope -eq "Universal"}).count
    $universalinside = [int]@($usergroups | where {$_.distinguishedname -like '*kul-dc*' -and $_.groupscope -eq "Universal"}).count
  
  }elseif($domain -eq 'phx-dc'){
  
    $universaloutside = [int]@($usergroups | where {$_.distinguishedname -notlike '*phx-dc*' -and $_.groupscope -eq "Universal"}).count
    $universalinside = [int]@($usergroups | where {$_.distinguishedname -like '*phx-dc*' -and $_.groupscope -eq "Universal"}).count
  
  }
  #$globaltest = $usergroups | where {$_.groupscope -eq "Global"}
  
  
  $domainlocal = [int]@($usergroups | where {$_.groupscope -eq "DomainLocal"}).count
  $global = [int]@($usergroups | where {$_.groupscope -eq "Global"}).count
  
  $tokensize = 1200 + (40 * ($domainlocal + $universaloutside)) + (8 * ($global + $universalinside))

  Write-Host "
    Domain local groups: $domainlocal
    Global groups: $global
    Universal groups outside the domain: $universaloutside
    Universal groups inside the domain: $universalinside
    Kerberos token size: $tokensize"
  

  }
  


