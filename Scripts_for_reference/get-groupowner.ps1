function get-groupowner {
  param($pathof)
  
  
  $pattern = '^.{8}','G'
  (Get-Acl $pathof).Access | Where-Object {$_.filesystemrights -like '*modify*'} | Select-Object -Property identityreference | fw -Column 1 | Out-String | clip.exe
  $groupacl = (Get-Clipboard).Trim() | ForEach-Object {$_ -replace $pattern} | Out-String
  $DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
  $vysledek = @()
foreach ($groupac in $groupacl) {
  
  echo $groupac
  $vysledek += Get-ADGroup -Server "$($DHLglobalC.HostName):3268" $groupac.Trim() -Properties * | Select-Object -Property info,SamAccountName,description
 
  [pscustomobject] @{
    info = $vysledek.info
    name = $vysledek.samaccountname
    description = $vysledek.description
  }
  
  }

  

}