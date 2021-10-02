Import-Module C:\Temp\Modules\set-managedby.ps1
$adgroup = Read-Host "input ad group"
$description = Read-Host "enter desription"
$OUPATH = Read-Host "Enter OU Path"
$info = Read-Host "enter info"
$gfc = "GFC$adgroup"
$gfr = "GFR$adgroup"
$dfc = "DFC$adgroup"
$dfr = "DFR$adgroup"
$managedby = Read-Host 'Enter managedby'
$domain = Read-Host 'Enter domain'
$ICACLPATH = Read-Host 'Enter UNC path of share'

$dfc
$dfr
$gfc
$gfr

New-ADGroup -Path $OUPATH -GroupCategory Security -GroupScope DomainLocal -Name $dfc -SamAccountName $dfc -DisplayName $dfc -Description $description -OtherAttributes @{info=$info}
New-ADGroup -Path $OUPATH -GroupCategory Security -GroupScope DomainLocal -Name $dfr -SamAccountName $dfr -DisplayName $dfr -Description $description -OtherAttributes @{info=$info}
New-ADGroup -Path $OUPATH -GroupCategory Security -GroupScope Global -Name $gfc -SamAccountName $gfc -DisplayName $gfc -Description $description -OtherAttributes @{info=$info}
New-ADGroup -Path $OUPATH -GroupCategory Security -GroupScope Global -Name $gfr -SamAccountName $gfr -DisplayName $gfr -Description $description -OtherAttributes @{info=$info}

Start-Sleep -Seconds 20
Add-ADGroupMember -Identity $dfc -Members $gfc
Add-ADGroupMember -Identity $dfr -Members $gfr

Set-Managedby -GroupOwner $managedby -GroupName $dfc -GroupDomain $domain
Set-Managedby -GroupOwner $managedby -GroupName $dfr -GroupDomain $domain
Set-Managedby -GroupOwner $managedby -GroupName $gfr -GroupDomain $domain
Set-Managedby -GroupOwner $managedby -GroupName $gfc -GroupDomain $domain

$icacldfc = "icacls `"{0}`" /grant `"{3}\{1}:(OI)(CI)M`" /t /c > `"c:\temp\Logs\icacls_{2}.txt`"" -f $ICACLPATH,$dfc,$dfc,$Domain
$icacldfr = "icacls `"{0}`" /grant `"{3}\{1}:(OI)(CI)RX`" /t /c > `"c:\temp\Logs\icacls_{2}.txt`"" -f $ICACLPATH,$dfr,$dfr,$Domain

#$gfccreation = "New-ADGroup -Path `"{0}`" -GroupCategory Security -GroupScope Global -Name `"{1}`" -SamAccountName `"{1}`" -DisplayName `"{1}`" -Description `"{2}`" -OtherAttributes @{info=`"{3}`"}" -f $OUPATH,$gfc,$description,$info

Start-Sleep -Seconds 20

Invoke-Expression -Command $icacldfc
Invoke-Expression -Command $icacldfr
