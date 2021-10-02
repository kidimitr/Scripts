function New-Printer {
     <#
 .SYNOPSIS
  Creates print queue
 .DESCRIPTION
  Creates a print queue on a remote server using 
  Add-PrinterPort
  Add-Printer
  Set-PrinterConfiguration
  Win32_PrinterConfiguration
 .PARAMETER Server
  Enter server name
 .PARAMETER Printername
  Name of print queue
 .PARAMETER Portname
  Name of port
 .PARAMETER IPAddress
  IP Address of print queue
 .PARAMETER Comment
  Input who requested the print queue
  creation and the INC number
 .PARAMETER Location
  Input location of print queue
 .PARAMETER DriverName
  Input the driver the print queue
  should use
 .EXAMPLE
  New-Printer -server SEGOTWS430 -PrinterName SEGOTNP065 -PortName IP_2.16.24.192 -IPAddress 2.16.24.192 -Comment 'Zandra Nordesand - INC32519327' -Location 'EA-SE-GOT' -DriverName 'HP Universal Printing PCL 6 (v6.6.5)'
 #>





    param ([Parameter(Mandatory=$true,Position=1)][string]$server,
    [Parameter(Mandatory=$true,Position=2)][string]$PrinterName,
    [Parameter(Mandatory=$true,Position=3)][string]$PortName,
    [Parameter(Mandatory=$true,Position=4)][string]$IPAddress,
    [Parameter(Mandatory=$true,Position=5)][string]$Comment,
    [Parameter(Mandatory=$true,Position=6)][string]$Location,
    [Parameter(Mandatory=$true,Position=7)][string]$DriverName

    )

  [string[]]$testprinter = @()
  [string[]]$testport = @()  
  [string[]]$testdriver = @()
   $test_connection = Test-Connection -ComputerName $server -ErrorAction SilentlyContinue
# Tests if server is reachable
if (!$test_connection -eq $false){

Write-Host 
'=================================='
$testprinter = Get-Printer -ComputerName $server | ForEach-Object {$_.Name}
$testport = Get-PrinterPort -ComputerName $server | ForEach-Object {$_.Name}
$testdriver = Get-PrinterDriver -ComputerName $server | Select-Object -Property Name | ForEach-Object {$_.Name}
# Checks if print queue already exists on server
if ($testprinter -notcontains $PrinterName){
# Checks if driver exists on server
    if($testdriver -contains $DriverName){
# Checks if portname already exists on server
        if ($testport -notcontains $PortName){
            Add-PrinterPort -ComputerName $server -PortNumber 9100 -Name $PortName -PrinterHostAddress $IPAddress
            Write-Host "$Portname created"

    }else{Write-Host 'Port Already Exists'}


    Add-Printer -ComputerName $server -Name $PrinterName -ShareName $PrinterName -PortName $PortName -Shared -Comment $Comment -Location $Location -DriverName $DriverName -Published
    Write-Host "$Printername created"
    $test_created = $true

}else{Write-Host "$drivername doesn't exist on $server" -ForegroundColor Magenta '`r`n Available drivers'

$testdriver | Format-Table
$test_created = $false


}

}else{Write-Host 'Printer already exists' -ForegroundColor Magenta}

}else {Write-Host "Connection failed" -ForegroundColor Red}

# Checks if print queue has been created
if ($test_created -eq $true){

$printersetting = Get-CimInstance -ComputerName $server -ClassName Win32_PrinterConfiguration | Where-Object {$_.Name -eq $PrinterName}
# Checks if papersize is not set to A4
if($printersetting.PaperSize -notlike 'A4'){


Set-PrintConfiguration -ComputerName $server -PrinterName $PrinterName -PaperSize A4
Write-Host 'Papersize set to A4'
}else{Write-Host 'Papersize already set to A4'}

$GetPrinter = Get-Printer -ComputerName $server -Name $PrinterName
#Checks if printprocessor is set to Winprint and if it is listed in the directory
}if(($GetPrinter).printprocessor -ne "WinPrint" -or ($GetPrinter).Published -ne $true){


    Set-Printer -ComputerName $server -Name $PrinterName -PrintProcessor WinPrint -Published $true
    Write-Host "Printprocessor set to winprint and list in directory is enabled"
}else{Write-Host "Printerprocesor is already Winprint and Published"}





}