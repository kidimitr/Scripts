function Get-Functions
{

Get-ChildItem -Path 'D:\Google Drive\Powershell_scripts' | Where-Object {$_.Name -like '*ps1*'} | Select-Object -ExpandProperty Name | ForEach-Object {($_ -split ".ps1")[0]}  
Get-ChildItem -Path 'C:\Users\kidimitr\Documents\WindowsPowerShell\Scripts' | Where-Object {$_.Name -like '*ps1*'} | Select-Object -ExpandProperty Name | ForEach-Object {($_ -split ".ps1")[0]}
}
