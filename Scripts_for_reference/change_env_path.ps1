$servers = New-PSSession (Get-Content C:\Temp\server1.txt)
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$oldpath;C:\windows\system32;C:\windows;C:\windows\System32\Wbem;C:\windows\System32\WindowsPowerShell\v1.0\;C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps;C:\Program Files\GlobalBuild;C:\Program Files\HP\HP BTO Software\lib;C:\Program Files\HP\HP BTO Software\bin;C:\Program Files\HP\HP BTO Software\bin\win64;C:\Program Files\HP\HP BTO Software\bin\win64\OpC;C:\Program Files\CA\AccessControl\bin;C:\Users\operator_kidimitr\AppData\Local\Microsoft\WindowsApps"

foreach ($server in $servers){

Invoke-Command -Session $server -ScriptBlock { Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $Using:newPath} 

}