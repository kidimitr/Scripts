function Get-WSUS
{param(
    [Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [ValidateSet('Last_Update','WSUS_Server')]
    [string]$command
  
  ) 
  
  $Results = @()
  switch($command){
  
        'Last_Update' {$Results += Invoke-Command -ComputerName $server -ScriptBlock {
        
            $Detect = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Detect'
            $Download = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Download'
            $Install = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Install'
            $property = [pscustomobject]@{
      
              Detect = $Detect.lastsuccesstime   
              Download = $Download.lastsuccesstime
              Install = $Install.lastsuccesstime
      
            } 
            
            Return $property
          
          } -HideComputerName
        
        
     
    }
        
        'WSUS_Server' {$Results += Invoke-Command -ComputerName $server -ScriptBlock {$WSUS = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
             $property =  [pscustomobject]@{
            
                WSUS_Server = $Wsus.wuserver
            
            
            }  
      
          Return $property
    
        } -HideComputerName
    } 
  }

  $Results | Select-Object -Property * -ExcludeProperty RunspaceID

}






