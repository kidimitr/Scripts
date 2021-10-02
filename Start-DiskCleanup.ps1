function Start-DiskCleanup {
    [CmdletBinding()]
    param ([Parameter(Mandatory=$true)]
    [string]$server
        
    )
    
    begin {
        Write-Host 'Starting Disk Cleanup' -ForegroundColor Blue
    }
    
    process {
        $date = (Get-Date).AddMonths(-6)
        $User_Profiles = @()
      $User_Profiles +=  Invoke-Command -ComputerName $server -ScriptBlock {
        $date = (Get-Date).AddMonths(-6)
        $MyObject = @()
      
          $UserProfiles = Get-ChildItem -Path C:\Users | Where-Object {$_.Name -like '*operator_*' -or $_.Name -like '*admin-*' -or $_.Name -like '*extadm_*' -and $_.LastAccessTime -le $date}
          $RegistryUsers = @()
          
          $RegistryUsers += foreach($UserProfile in $UserProfiles){
              
              $UserCheck = $UserProfile.Name
              Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' | Get-ItemProperty | Select-Object -Property ProfileImagePath,Pspath | Where-Object {$_.ProfileImagePath -like "*$Usercheck*"}}
  
        
          $MyObject += [PSCustomObject] @{
              User = $UserProfiles | select -ExpandProperty Name
              Time = $UserProfiles | select -ExpandProperty LastWriteTime
              Registry_ProfilePath = $RegistryUsers.profileimagepath
              Registry_Path = $RegistryUsers.pspath.replace('Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE','HKLM:')
          }
            
           Return $MyObject
       

    } -HideComputerName
        
  

}
   
    
    end {
        $User_Profiles | Select-Object -Property * -ExcludeProperty RunSpaceID
        Invoke-Command -ComputerName $server -ScriptBlock {
            $date = (Get-Date).AddMonths(-6)
            $profiles = Get-ChildItem -Path C:\Users | Where-Object {$_.Name -like '*operator_*' -or $_.Name -like '*admin-*' -or $_.Name -like '*extadm_*' -and $_.LastAccessTime -le $date}
            $registry_profile = @()
            $registry_profile += foreach($profile in $profiles){
            $usercheck = $profile.name
            Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' | 
            Get-ItemProperty | Select-Object -Property ProfileImagePath,Pspath | Where-Object {$_.ProfileImagePath -like "*$Usercheck*"} |
            Remove-Item -Recurse -Force -Confirm:$false
        }
            $profiles | Remove-Item -Recurse -Force -Confirm:$false
            
            Remove-Item -Path C:\Windows\Temp\* -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item -Path C:\Windows\SoftwareDistribution\Download\* -Recurse -Force -Confirm:$false
            Remove-Item -Path C:\ProgramData\Microsoft\Windows\WER\ReportQueue\* -Recurse -Force -Confirm:$true -ErrorAction SilentlyContinue
            Remove-Item -Path C:\ProgramData\Microsoft\Windows\WER\ReportArchive\* -Recurse -Force -Confirm:$true -ErrorAction SilentlyContinue
            $date1 = (Get-Date).AddDays(-7)
            Get-ChildItem C:\Temp | Where-Object {$_.LastWriteTime -lt $date1} | Remove-Item -Recurse -Force -Confirm:$false
            Get-ChildItem 'C:\Program Files\CA\AccessControl\bin' | Where-Object {$_.Name -like '*.dmp*'} | Remove-Item



        }
    }


}

