function New-ShareandADgroups {

    <#
    .SYNOPSIS
     Creates share and AD groups
    .DESCRIPTION
     Creates local folder, share, DFS link (if needed), AD groups (DFC,DFR,GFC,GFR)
     sets mangagedby and adds users to read and modify groups.

    .PARAMETER Server
     Input server name

    .PARAMETER LocalPAth
     Input local path of folder

    .PARAMETER Folder
     Input name of folder

     .PARAMETER Sharename
     Input name of share

     .PARAMETER DFS
     Input Yes/NO if DFS is required

     .PARAMETER DFSPath
     Input DFS path if needed

     .PARAMETER ADgroup
     Input AD group without prefix DFC/DFR/GFC/GFR

     .PARAMETER Description
     Input description of AD group
    
     .PARAMETER Info
     Input owner of AD group

     .PARAMETER OUPATH
     Input OU path where AD group should be created
    
    .PARAMETER  Managedby
     Input username of person who can managed AD group

    .PARAMETER Domain
     Input domain of user

    .PARAMETER ICACLPath
     Input full local path of share for ICACL assisgnment

    .PARAMETER AddusersM
     Input YES/NO if users need adding to GFC group
    
    .PARAMETER usersM
     Input users separated by commas to add to modify group

    .PARAMETER AddusersRX
     Input YES/NO if users need adding to GFR group

    .PARAMETER usersRX
     Input users separated by commas to add to read group

    .EXAMPLE
     
    New-ShareandADgroups -server PLDSCWSSC0300 -local_path E:\DATA_WAW -folder HR_VOLKSWAGEN -sharename HR_VOLKSWAGEN
    -DFS Yes -DFSPath \\PRG-DC.DHL.COM\PL_DSC\WAW\HR_VOLKSWAGEN -adgroup PLWAW-DSC-HR_VOLKSWAGEN -description \\PRG-DC.DHL.COM\PL_DSC\WAW\HR_VOLKSWAGEN 
    -OUPATH 'OU=PL_DSC,OU=Groups,OU=FilePrint,OU=Applications,DC=prg-dc,DC=dhl,DC=com' -info 'Owner: marta.kuprianowicz@dhl.com' -managedby mkuprian -domain prg-dc 
    -ICACLPATH \\PLDSCWSSC0300\E$\DATA_WAW\HR_VOLKSWAGEN -addusersM Yes 
    -usersM agadamsk,achojnac,algrabsk,annagrad,dladosz,dkonarze,honwiech,jmilosz,budnic,kprzybyl,marstarb,mgrabins,mkuprian,mrusinow,dkroliko,annapawl 
    -addusersRW Yes -usersRW amrugas,apuchals 
     
    
    #>

    [CmdletBinding()]
    param (
    [Parameter(Mandatory=$true,Position=1)][string]$server,
    [Parameter(Mandatory=$true,Position=2)][string]$local_path,
    [Parameter(Mandatory=$true,Position=3)][string]$folder,
    [Parameter(Mandatory=$true,Position=4)][string]$sharename,
    [Parameter(Mandatory=$true,Position=5)]
    [Validateset('Yes','No')]
    [string]$DFS,
    [Parameter(Mandatory=$false,Position=6)][string]$DFSPath,
    [Parameter(Mandatory=$true,Position=7)][string]$adgroup,
    [Parameter(Mandatory=$true,Position=8)][string]$description,
    [Parameter(Mandatory=$true,Position=9)][string]$info,
    [Parameter(Mandatory=$true,Position=10)][string]$OUPATH,
    [Parameter(Mandatory=$true,Position=11)][string]$managedby,
    [Parameter(Mandatory=$true,Position=12)][string]$domain,
    [Parameter(Mandatory=$true,Position=13)][string]$ICACLPATH,
    [Parameter(Mandatory=$true,Position=14)]
    [Validateset('Yes','No')][string]$addusersM,
    [Parameter(Mandatory=$false,Position=15)][array]$usersM,
    [Parameter(Mandatory=$true,Position=16)]
    [Validateset('Yes','No')][string]$addusersRX,
    [Parameter(Mandatory=$false,Position=17)][array]$usersRX

    )
  
    $fullpath = $local_path + '\' + $folder
    Write-Host $fullpath
$gfc = "GFC$adgroup"
$gfr = "GFR$adgroup"
$dfc = "DFC$adgroup"
$dfr = "DFR$adgroup"

Write-Host $dfc
Write-Host $dfr
Write-Host $gfc
Write-Host $gfr 

#Test if DFC group exists
Write-Host 'Checking if AD group exists' -ForegroundColor White
try {$DFCTest = Get-ADGroup -Server $domain -Identity $dfc -ErrorAction Stop}catch{}



if($DFCTest)
#IF groups do exist then GFC/GFR are nested in DFC/DFR, managedby is set and users are added to GFC/GFR groups after checking.

{ 
  Write-Host "Group $dfc already exists `nChecking if GFC is nested in DFC" -ForegroundColor Magenta
   #Test if GFC is nested in DFC. 
  $test_memberof = Get-ADGroup -Server $domain -Identity $dfc -Properties * | Select-Object -ExpandProperty members | ForEach-Object {($_ -split "CN=|,")[1]} | Where-Object {$_ -like $gfc}

  if (!$test_memberof){
  # IF GFC not in DFC    
  Write-Host 'Adding GFC/GFR into DFC/DFR' -ForegroundColor Gray
  Add-ADGroupMember -Server $domain -Identity $dfc -Members $gfc -Verbose
  Add-ADGroupMember -Server $domain -Identity $dfr -Members $gfr -Verbose

}else{Write-Host 'GFC already member of DFC group' -ForegroundColor Magenta}

  
#------------Waiting-----------------------
  $time = 30 # seconds, use you actual time in here
foreach($i in (1..$time)) {
    $percentage = $i / $time
    $remaining = New-TimeSpan -Seconds ($time - $i)
    $message = "{0:p0} complete, remaining time {1} before proceeding with next action" -f $percentage, $remaining
    Write-Progress -Activity $message -PercentComplete ($percentage * 100)
    Start-Sleep 1
}

#------------Proceeding-----------------------

  # Checking if managedby is populated
 $test_managedby = Get-ADGroup -Server $domain -Identity $gfc -Properties * | Select-Object -ExpandProperty managedby | ForEach-Object {($_ -split "CN=|,")[1]} | Where-Object {$_ -like $managedby}

 if(!$test_managedby){
  #Setting managedby.
  Write-Host "Setting managedby" -ForegroundColor Green  
  Set-Managedby -GroupOwner $managedby -GroupName $dfc -GroupDomain $domain -Verbose
  Set-Managedby -GroupOwner $managedby -GroupName $dfr -GroupDomain $domain -Verbose
  Set-Managedby -GroupOwner $managedby -GroupName $gfr -GroupDomain $domain -Verbose
  Set-Managedby -GroupOwner $managedby -GroupName $gfc -GroupDomain $domain -Verbose
}else{Write-Host "Managedby already set" -ForegroundColor Yellow}

 #Adding Groups
  switch ($addusersM){
    
    Yes {
        Write-Host 'Adding users to GFC'
        $usersM = ($usersM).Split(",") | ForEach-Object {$_.trim()}
        Add-ADGroupMember -Server $domain -Identity $gfc -Members $usersM -Verbose
        }
 
    No {  }
 
 
 }
 
 switch ($addusersRX){
     
     Yes {
         Write-Host 'Adding users to GFR'
         $usersRX = ($usersRX).Split(",") | ForEach-Object {$_.trim()}
         Add-ADGroupMember -Server $domain -Identity $gfr -Members $usersRX -Verbose
         }
  
     No {  }
  
  
  }



}else{
#IF groups do not exist, they are created and GFC/GFR are nested in DFC/DFR, managedby is set and users are added to GFC/GFR groups.
 
Write-Host 'Group does not exist. Creating groups' -ForegroundColor Magenta
New-ADGroup -Server $domain -Path $OUPATH -GroupCategory Security -GroupScope DomainLocal -Name $dfc -SamAccountName $dfc -DisplayName $dfc -Description $description -OtherAttributes @{info=$info} -Verbose
New-ADGroup -Server $domain -Path $OUPATH -GroupCategory Security -GroupScope DomainLocal -Name $dfr -SamAccountName $dfr -DisplayName $dfr -Description $description -OtherAttributes @{info=$info} -Verbose
New-ADGroup -Server $domain -Path $OUPATH -GroupCategory Security -GroupScope Global -Name $gfc -SamAccountName $gfc -DisplayName $gfc -Description $description -OtherAttributes @{info=$info} -Verbose
New-ADGroup -Server $domain -Path $OUPATH -GroupCategory Security -GroupScope Global -Name $gfr -SamAccountName $gfr -DisplayName $gfr -Description $description -OtherAttributes @{info=$info} -Verbose

$time = 30 # seconds, use you actual time in here
foreach($i in (1..$time)) {
    $percentage = $i / $time
    $remaining = New-TimeSpan -Seconds ($time - $i)
    $message = "{0:p0} complete, remaining time {1} before proceeding with next action" -f $percentage, $remaining
    Write-Progress -Activity $message -PercentComplete ($percentage * 100)
    Start-Sleep 1
}

Write-Host "Nesting GFC/GFR in DFC/DFR" -ForegroundColor Blue
Add-ADGroupMember -Server $domain -Identity $dfc -Members $gfc -Verbose
Add-ADGroupMember -Server $domain -Identity $dfr -Members $gfr -Verbose

#------------Waiting-----------------------
$time = 15 # seconds, use you actual time in here
foreach($i in (1..$time)) {
    $percentage = $i / $time
    $remaining = New-TimeSpan -Seconds ($time - $i)
    $message = "{0:p0} complete, remaining time {1} before proceeding with next action" -f $percentage, $remaining
    Write-Progress -Activity $message -PercentComplete ($percentage * 100)
    Start-Sleep 1
}

#------------Proceeding-----------------------
Write-Host "Setting managedby" -ForegroundColor Green
Set-Managedby -GroupOwner $managedby -GroupName $dfc -GroupDomain $domain -UserDomain $domain -Verbose
Set-Managedby -GroupOwner $managedby -GroupName $dfr -GroupDomain $domain -UserDomain $domain -Verbose
Set-Managedby -GroupOwner $managedby -GroupName $gfr -GroupDomain $domain -UserDomain $domain -Verbose
Set-Managedby -GroupOwner $managedby -GroupName $gfc -GroupDomain $domain -UserDomain $domain -Verbose

switch ($addusersM){
    
    Yes {
        Write-Host 'Adding users to GFC'
        $usersM = ($usersM).Split(",") | ForEach-Object {$_.trim()}
        Add-ADGroupMember -Server $domain -Identity $gfc -Members $usersM -Verbose
        }

    No {  }
 
 
 }
 
 switch ($addusersRX){
     
     Yes {
        Write-Host 'Adding users to GFR'
         $usersRX = ($usersRX).Split(",") | ForEach-Object {$_.trim()}
         Add-ADGroupMember -Server $domain -Identity $gfr -Members $usersRX -Verbose
         }
  
     No {  }
  
  
  }

}

Write-Host "Checking if folder/share needs to be created" -ForegroundColor Yellow


    
    #Checking if folder exists.
    $test_path = Test-Path -Path $ICACLPATH
    #If folder doesn't exist it is created.
    if(!$test_path){Invoke-Command -ComputerName $server -ScriptBlock {
        Write-Host "Creating folder" -ForegroundColor Cyan
     $foldercreation = New-Item -Path $using:local_path -Name $using:folder -ItemType Directory -ErrorAction SilentlyContinue -WarningAction SilentlyContinue}
    }else{Write-host 'Folder already exists' -ForegroundColor Magenta}
    #Checking if share exists
    try {$test_share = Get-SmbShare -CimSession $server -Name $sharename -ErrorAction SilentlyContinue}catch{'Share already exists'}
    #If share doesn't exist it is created
    if(!$test_share){
    Write-host "Creating share" -ForegroundColor Cyan
    $share = Invoke-Command -ComputerName $server -ScriptBlock {
    $share = New-SmbShare -Name $using:sharename -Path $using:fullpath -FullAccess Everyone
    Return $share

    }}else{Write-host 'Share already exists' -ForegroundColor Magenta}
    




# If share is created then DFS is created if needed

if($share){
#$Sharepath = '\\' + $server + '\' + $sharename
$Sharepath = '\\{0}.{1}.dhl.com\{2}' -f $server,$domain,$sharename
#------------Waiting-----------------------
$time = 10 # seconds, use you actual time in here
foreach($i in (1..$time)) {
    $percentage = $i / $time
    $remaining = New-TimeSpan -Seconds ($time - $i)
    $message = "{0:p0} complete, remaining time {1} before proceeding with next action" -f $percentage, $remaining
    Write-Progress -Activity $message -PercentComplete ($percentage * 100)
    Start-Sleep 1
}
#------------Proceeding-----------------------
Write-Host "Checking if DFS link exists" -ForegroundColor Green
$DFS_Test = Get-DfsnFolderTarget -Path $DFSPath

if(!$DFS_Test){
switch ($DFS) {
    Yes {try{ 
        Write-Host "Creating DFS link" -ForegroundColor Gray
        New-DfsnFolderTarget -Path $DFSPath -TargetPath $Sharepath -State Online -ErrorAction Stop} catch{Write-Host "Share created but DFS Already Exists"} }
    No  {  }
}}else{Write-Host "DFS already exists" -ForegroundColor Blue}}else{

        #$Sharepath = '\\' + $server + '\' + $sharename
    # $Sharepath = '\\{0}.{1}.dhl.com\{2}' -f $server,$domain,$sharename
    Write-Host "Share not created as the folder/share already exist `nDFS created (if needed) however" -ForegroundColor Red

}

     
    
    


#ICACLS variables are filled

$icacldfc = "icacls `"{0}`" /grant `"{3}\{1}:(OI)(CI)M`" /t /c > `"$env:windir\icacls_{2}.txt`"" -f $ICACLPATH,$dfc,$dfc,$Domain
$icacldfr = "icacls `"{0}`" /grant `"{3}\{1}:(OI)(CI)RX`" /t /c > `"$env:windir\icacls_{2}.txt`"" -f $ICACLPATH,$dfr,$dfr,$Domain

#Checking if AD groups were created and users/groups properly nested and  ifDFS link was created 
#=======================================
Write-Host "Checking if everything was created and members properly nested `n ========================================" -ForegroundColor Blue
Get-ADGroup -Server $domain -Identity $dfr -Properties * | Select-Object -Property samaccountname,info,description,@{N='managedby';E={$_.managedby | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='members';E={$_.members | ForEach-Object {($_ -split "CN=|,")[1]}}}
Get-ADGroup -Server $domain -Identity $dfc -Properties * | Select-Object -Property samaccountname,info,description,@{N='managedby';E={$_.managedby | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='members';E={$_.members | ForEach-Object {($_ -split "CN=|,")[1]}}}
Get-ADGroup -Server $domain -Identity $gfc -Properties * | Select-Object -Property samaccountname,info,description,@{N='managedby';E={$_.managedby | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='memberof';E={$_.memberof | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='members';E={$_.members | ForEach-Object {($_ -split "CN=|,")[1]}}}
Get-ADGroup -Server $domain -Identity $gfr -Properties * | Select-Object -Property samaccountname,info,description,@{N='managedby';E={$_.managedby | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='memberof';E={$_.memberof | ForEach-Object {($_ -split "CN=|,")[1]}}},@{N='members';E={$_.members | ForEach-Object {($_ -split "CN=|,")[1]}}}

#Checking if DFS was properly created


switch ($DFS) {
    Yes {
        Write-Host "Checking DFS link" -ForegroundColor Magenta
        Get-DfsnFolderTarget -Path $DFSPath }
    No  {  }
}

#Checking ACLs
$ACLStatus = Get-Acl -Path $Sharepath 
$Test_ACL = $ACLStatus.Access.Identityreference.Value.Split('\\') | Where-Object {$_ -eq $dfc}


if(!$Test_ACL){
# Adding DFR/DFC into shares ACL
Write-Host "Adding DFR/DFC into share's ACL" -ForegroundColor Magenta
Write-Host "First Attempt to assign ACLS" -ForegroundColor Green

$permissions1 = Invoke-Command -ComputerName $server -ScriptBlock {

$DFCAssigning =  Invoke-Expression -Command $using:icacldfc -Verbose
    Invoke-Expression -Command $using:icacldfr -Verbose
Return $DFCAssigning
}



if($permissions1){
    #------------Waiting-----------------------
    $time = 30 # seconds, use you actual time in here
foreach($i in (1..$time)) {
    $percentage = $i / $time
    $remaining = New-TimeSpan -Seconds ($time - $i)
    $message = "{0:p0} complete, remaining time {1} before proceeding with next action" -f $percentage, $remaining
    Write-Progress -Activity $message -PercentComplete ($percentage * 100)
    Start-Sleep 1
}
#------------Proceeding-----------------------
    #Re-trying to add groups to share's ACL
    Write-Host "Re-trying to add DFR/DFC into share's ACL" -ForegroundColor Red
    Invoke-Command -ComputerName $server -ScriptBlock {
    Invoke-Expression -Command $Using:icacldfc -Verbose
    Invoke-Expression -Command $Using:icacldfr -Verbose
    }


}}else{Write-Host "DFC already member of share's ACL" -ForegroundColor Gray}          

Get-Acl -Path $Sharepath | Format-List


}


function Set-Managedby {
    param ( [parameter(Mandatory=$true)][string]$GroupOwner,
            [parameter(Mandatory=$true)][string]$GroupName,
            [parameter(Mandatory=$true)][string]$GroupDomain,
            [parameter(Mandatory=$true)][string]$UserDomain
            
            )
    
    [String]$LocalGC = "{0}:3268" -f (Get-ADDomainController -Discover -Service 6 | Select-Object -ExpandProperty Hostname)
    Try { $Manager_User = Get-ADUser -Properties * -Server $UserDomain -filter { SamAccountName -eq $GroupOwner } -ErrorAction Stop }
    Catch { $_.Exception.Message }
    If($Manager_User){
        $Owner = Get-ADUser -Identity $Manager_User -Properties SID
    }
    else {
        Try { $Manager_Group = Get-ADGroup -Properties * -Server $GroupDomain -filter { SamAccountName -eq $GroupOwner } -ErrorAction Stop }
        Catch { $_.Exception.Message }
        if($Manager_Group){
            $Owner = Get-ADGroup -Identity $Manager_Group -Properties SID
        }
    }
    
    [string]$ADGroup = Get-ADGroup -Identity $GroupName -Server $GroupDomain | Select-Object -ExpandProperty DistinguishedName
    if($Owner){
        $guid =[guid]'bf9679c0-0de6-11d0-a285-00aa003049e2'
        $sid = $Owner.SID
        $ADDrive = New-PSDrive -Name AD2 -PSProvider ActiveDirectory -Root "//RootDSE/" -Server $GroupDomain
        $ADPath = "{0}:\{1}"-f $ADDrive.Name,$ADGroup
        Try { $ACL = Get-Acl $ADPath -ErrorAction Stop }
        Catch { $_.Exception.Message }
        If($ACL){
            $ctrl =[System.Security.AccessControl.AccessControlType]::Allow
            $rights =[System.DirectoryServices.ActiveDirectoryRights]::WriteProperty -bor[System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
            $intype =[System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    
            $LDAP_Path = "LDAP://{0}" -f $ADGroup
            $group =[adsi]$LDAP_Path
            $UserDistinguishedName = $Owner.DistinguishedName
            $group.put("ManagedBy",$UserDistinguishedName)
            $group.setinfo()
    
            $rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($sid,$rights,$ctrl,$guid)
            $acl.AddAccessRule($rule)
            
            Try { Set-Acl -acl $acl -path $ADPath -ErrorAction Stop }
            Catch { $_.Exception.Message }
        }
    }
    else {
        "Group owner: {0} not found in AD" -f $GroupOwner
    }
    if($ADDrive){
      Remove-PSDrive -Name $ADDrive.Name
    }
    
    }
