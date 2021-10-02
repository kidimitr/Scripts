function Get-Adapters-Info{
param( $computer )
$session = New-PSSession -ComputerName $computer
Invoke-Command -Session $session -ScriptBlock {Get-NetLbfoTeam | Format-Table}
Invoke-Command -Session $session -ScriptBlock {Get-NetAdapter}
}