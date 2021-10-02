$fullcommand = "Invoke-Expression -Command ""wmic OS Get DataExecutionPrevention_SupportPolicy"""
$s = New-PSSession (Get-Content C:\Temp\servers.txt)
[scriptblock]$scriptblock = [scriptblock]::Create($fullcommand)
Invoke-Command -Session $s -ScriptBlock $scriptblock


