function Check-IfMemberofGroup {
    param ([Parameter(Mandatory=$true,Position=1)][string]$user,
    [Parameter(Mandatory=$true,Position=2)]
    [Validateset('prg-dc','phx-dc','kul-dc')]
    [string]$domain,
    [Parameter(Mandatory=$true,Position=3)][string]$group
    )
    #$DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
    #$GlobalCatalog = "$($DHLglobalC.HostName):3268"
    Get-ADUser -Server $domain -Identity $user -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {($_ -split "CN=|,")[1]} | Where-Object {$_ -like $group }

}