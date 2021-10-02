function Get-UsernameFromEmail {
    param ([Parameter(Mandatory=$true)]
    $Email,
    [Parameter(Mandatory=$true)][string]
    [Validateset('prg-dc','phx-dc','kul-dc')]
    $domain
    )
    
    Get-ADUser -Server $domain -Filter {mail -eq $Email} | Select-Object -ExpandProperty SamAccountName


}