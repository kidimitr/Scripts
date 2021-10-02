function Get-GroupOwnerofsubfolders {
  param($path)
  $pattern = '^.{8}','G'
  $DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
  (Get-ChildItem -Path $path).GetAccessControl().Access | Where-Object {$_.filesystemrights -like '*modify*'} | Select-Object -Property identityreference | Format-Wide -Column 1 | Out-String | & "$env:windir\system32\clip.exe"
  (Get-Clipboard).Trim() | ForEach-Object {$_ -replace $pattern} | clip
  
    $adgroups = (Get-Clipboard).Trim()
    foreach ($adgroup in $adgroups){
      Try {
  
        $vysledek = Get-ADGroup -Server "$($DHLglobalC.HostName):3268" -Identity $adgroup -Properties * -ErrorAction Stop | Select-Object -Property info,samaccountname,description
    
        }
      catch { 
 
        }
        
          [pscustomobject] @{
            info = $vysledek.info
            samaccountname = $vysledek.samaccountname
            description = $vysledek.description
    
          }
    }

    }