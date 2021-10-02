function Get-VeritasVolumeDisks{
  param(
    [Parameter(Mandatory=$true,Position=0)]
    [string]$server,
    [Parameter(Mandatory=$true,Position=1)]
    [string]$drive
  
  
  
  )


  $VolumeName =  Invoke-Command -ComputerName $server -ScriptBlock {
      
    $name =  Get-Volume -DriveLetter $using:drive | select -ExpandProperty Filesystemlabel
    $myobject = [pscustomobject]@{
    
      Label = $name
    
    
    }
     return $myobject
     } -HideComputerName
     
    $pattern = $VolumeName | select -Property * -ExcludeProperty RunspaceID | Select-Object -ExpandProperty Label
     
     $VeritasDisk = Invoke-Command -ComputerName $server -ScriptBlock {
  
       $vxprint = vxprint
       $myobject = [pscustomobject]@{
       
         Vxprint = $vxprint
       
       }
       
       Return $vxprint
     
     
     
     }
      $VeritasDisk | Select-String -Pattern $pattern
      
   }
