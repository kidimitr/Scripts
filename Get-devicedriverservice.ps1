Function Get-DeviceDriverService
{
 Param(
   [string]$computer = “localhost”
 )
 Add-Type -AssemblyName System.ServiceProcess
 [System.ServiceProcess.ServiceController]::GetDevices($computer)
} #end Get-DeviceDriverService