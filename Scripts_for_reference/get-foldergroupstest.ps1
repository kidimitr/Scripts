
  $access = Get-Acl -Path \\prg-dc.dhl.com\za_dsc\ZAMRD\Automotive\Auto_Kewill | Select-Object -ExpandProperty Access | Select-Object -Property FileSystemRights,IdentityReference
  $acl = $access | Where-Object {$_ -like '*modify*' -or $_ -like '*readandexecute*'}
  $groups = $acl | ForEach-Object {($_.identityreference -split "prg-dc\\")[1]}
  $rights = $acl.filesystemrights | ForEach-Object {($_ -split ",")[0]}
  $arrays = @{Identity=$groups.trim();Rights=$rights.trim()}
  $domainlocals = @{Identity=$null;Rights=$null}
  $dfc_dfr = @()
  foreach ($array in $arrays){

    $domainlocals +=  try {$array | ForEach-Object  {Get-ADGroup -Server prg-dc -Identity $_.identity -Properties * | Select-Object -Property SamAccountName,Member,Info,Description,@{n='rights';e={$array.Rights}}}}
    catch {}

    }
    
    foreach ($domainlocal in $domainlocals){
    $dfcobjects = [PSCustomObject] @{
  
        Group = $domainlocal.samaccountname
        Info = $domainlocal.info
        Description = $domainlocal.description
        Rights = $domainlocal.rights
  
      }

      $dfc_dfr += $dfcobjects


  }
  
  $dfc_dfr
  
  