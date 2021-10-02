function Get-ADusergroups {
    param ([Parameter(Mandatory=$true)][string]$user,
    [Parameter(Mandatory=$true)]
    [Validateset('prg-dc','phx-dc','kul-dc')]
    [string]$domain
    )
    #$DHLglobalC = Get-ADDomainController -Server 'dhl.com' | Where-Object {$_.IsGlobalCatalog -match 'True'}
    #$GlobalCatalog = "$($DHLglobalC.HostName):3268"
    Get-ADUser -Server $domain -Identity $user -Properties * | Select-Object -ExpandProperty memberof | ForEach-Object {($_ -split "CN=|,")[1]}

}