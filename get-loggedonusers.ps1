function Get-loggedonusers{
  param([Parameter(Mandatory=$true)]$computername)
  
  $WMI = Get-WmiObject -Class Win32_Process -ComputerName $ComputerName -ErrorAction Stop
  $USERS = @()
  foreach ($WM in $WMI){ $USERS += $WM.getowner().user}
  
  $USERS | Select-Object -Unique
    
}
