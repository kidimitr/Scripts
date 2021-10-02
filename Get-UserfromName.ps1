function Get-UserfromName {
    param (
    
    [Parameter(Mandatory=$true)][string]$First,
    [Parameter(Mandatory=$true)][string]$Last,
    [Parameter(Mandatory=$true)]
    [Validateset('prg-dc','phx-dc','kul-dc')]
    [string]$server
    
    )
    

Get-ADUser -Server $server -Filter {Givenname -eq $First -and Surname -eq $Last} | Select-Object SamAccountName,UserPrincipalname

}