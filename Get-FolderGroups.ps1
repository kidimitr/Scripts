function Get-FolderGroups
{param([Parameter(Mandatory=$true,Position=0)]
[string]$path,
[Parameter(Mandatory=$true,Position=1)]
[Validateset('phx-dc','prg-dc','kul-dc')]
[string]$domain


)
 
 
$acl = Get-Acl -Path $path
$ace = $acl.Access | Select-Object -Property FileSystemRights,IdentityReference
$rights = $ace | Where-Object {$_ -like '*modify*' -or $_ -like '*readandexecute*'}
$groups = $rights | ForEach-Object {($_.identityreference -split "{0}\\" -f $domain)[1]}
#$DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
#$GlobalCatalog = "$($DHLglobalC.HostName):3268"
$domainlocals = @()
foreach ($group in $groups){

  $domainlocals +=  try {Get-ADGroup -Server $domain  -Identity $group -Properties * | Select-Object -Property SamAccountName,Member,Info,Description}
  catch {}

  }
  $grouplist = $domainlocals.member | ForEach-Object {($_ -split "CN=|,")[1]}
  $globals = @()
foreach ($grouplis in $grouplist){

  $globals += try {Get-ADGroup -Server $domain -Identity $grouplis -Properties * | Select-Object -Property SamAccountName,Info,Description}
              catch {}



}
$dfc_dfr = @()
foreach ($domainlocal in $domainlocals){
      $dfcobjects = [PSCustomObject] @{
  
        Group = $domainlocal.samaccountname
        Info = $domainlocal.info
        Description = $domainlocal.description
        
  
      }


      $dfc_dfr += $dfcobjects


}
$gfc_gfr = @()
foreach ($global in $globals){
  $gfc = [pscustomobject] @{
    
    Group = $global.samaccountname
    Info = $global.info
    Description = $global.description
  
  }
  
  $gfc_gfr += $gfc

}

$gfc_gfr + $dfc_dfr | Format-Table -Wrap
  

}



