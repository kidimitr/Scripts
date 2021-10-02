function Get-Uptime {
param( $computername )
$session = New-PSSession -ComputerName $computername
Invoke-Command -Session $session -ScriptBlock {uptime}
}