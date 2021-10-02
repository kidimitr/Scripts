function Get-JEA{

  Param(
 
        [parameter(position=1)]
        $server

  )


  Invoke-Command -computername $server -ScriptBlock {

  
    try {Get-PSSessionConfiguration -Name 'DHLFilePrint' -ErrorAction Stop}
    catch {Write-Host 'JEA NOT PRESENT' -ForegroundColor Red}
  }

 }