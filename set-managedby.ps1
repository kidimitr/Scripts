function Set-Managedby {
param ( [parameter(Mandatory=$true)][string]$GroupOwner,
        [parameter(Mandatory=$true)][string]$GroupName,
        [parameter(Mandatory=$true)][string]$GroupDomain)

[String]$LocalGC = "{0}:3268" -f (Get-ADDomainController -Discover -Service 6 | Select-Object -ExpandProperty Hostname)
Try { $Manager_User = Get-ADUser -Properties * -Server $LocalGC -filter { SamAccountName -eq $GroupOwner } -ErrorAction Stop }
Catch { $_.Exception.Message }
If($Manager_User){
    $Owner = Get-ADUser -Identity $Manager_User -Properties SID
}
else {
    Try { $Manager_Group = Get-ADGroup -Properties * -Server $LocalGC -filter { SamAccountName -eq $GroupOwner } -ErrorAction Stop }
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