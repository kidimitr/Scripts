$DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
$users = Get-ADGroupMember -Identity GCXCZCHO-ACCENTUREDSC-OFFICEPRO | Select-Object -Property Samaccountname | ForEach-Object {Get-ADUser -Identity $_.samaccountname -Server "$($DHLglobalC.HostName):3268"} | Select-Object -Property @{n="members";e={$_.name}},Enabled

foreach ($user in $users){

    if ($User.enabled -eq $false)
    {Write-Host "$($user.members) is being removed" -ForegroundColor Red
    Remove-ADGroupMember -Identity GCXCZCHO-ACCENTUREDSC-OFFICEPRO -Members $user.members -Confirm:$false  
    
    
    }
    else{Write-Host "$($user.members) is enabled" -ForegroundColor Green}
    
    
    
    
    
    }