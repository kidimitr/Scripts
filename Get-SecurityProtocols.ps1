function Get-SecurityProtocols
{param([Parameter(Mandatory=$true)][string]$server)

  Invoke-Command -ComputerName $server -ScriptBlock {

    $path = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
    $protocols = Get-ChildItem -Recurse $path
    $realpaths =$protocols.name.replace("HKEY_LOCAL_MACHINE","HKLM:")
    $properties = @()

    foreach ($realpath in $realpaths){


      $properties += Get-ItemProperty -Path $realpath | select Enabled,Disabledbydefault,pspath

  

    }

    foreach ($property in $properties){

      [pscustomobject] @{
  
        Enabled = $property.Enabled
        DisabledbyDefault = $property.Disabledbydefault
        Path = $property.pspath.Replace("Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE","HKLM:")
        RunSpaceID = $property.runspaceID
  
      }
  
    }

  } -HideComputerName | ft
  
  }