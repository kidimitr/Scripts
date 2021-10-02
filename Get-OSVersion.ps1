function Get-OSVersion
{param([Parameter(mandatory=$true)][string]$server)

  $CIMOS = Get-CimInstance -ComputerName $server -ClassName win32_operatingsystem  -ErrorAction SilentlyContinue | Select-Object -Property  @{N='Name';E={$_.Name.split("|")[0]}},OSArchitecture,InstallDate,NumberOfProcesses
  if(!$CIMOS -eq $false){$CIMOS}else{ $WMIOS = Get-WmiObject -ComputerName $server -Class win32_operatingsystem | Select-Object -Property  @{N='Name';E={$_.Name.split("|")[0]}},OSArchitecture,InstallDate,NumberOfProcesses 
$INSTALLTIME = $WMIOS.InstallDate
$TIMEINstalled = [System.Management.ManagementDateTimeConverter]::ToDateTime($INSTALLTIME)
[PSCustomObject]@{
  Name = $WMIOS.Name
  InstallDate = $TIMEINstalled
  OSArchitecture = $WMIOS.OSArchitecture

  }
 }
}
