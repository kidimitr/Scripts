  function get-groupownernew {
    param([Parameter(Mandatory=$true)]$path)
    $DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
    [string]$pattern = "prg-dc\\|}"  
    $modifygroups = Get-Acl -Path $path
    $modifygroups += (Get-Acl $path).Access | Where-Object {$_.filesystemrights -like '*modify*'} | Select-Object -ExpandProperty identityreference | ForEach-Object {($_ -split $pattern)[1]} | ForEach-Object {$_ -replace '^.{1}','G'}
      
    try{
       $modifygroups | ForEach-Object {Get-ADGroup -Server "$($DHLglobalC.HostName):3268" $_ -Properties * -ErrorAction SilentlyContinue | Select-Object -Property  info,description,samaccountname | Format-Table -Wrap}
        }
    catch{
      
    }
    
    
   
     
  }