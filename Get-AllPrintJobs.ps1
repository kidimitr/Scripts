function Get-AllPrintJobs {
<#
      .SYNOPSIS
      Get-AllPrintJobs outputs print jobs on a remote computers.

      .DESCRIPTION
      Get-AllPrintJob allows one to view all print jobs or remove all print jobs
      as well as for specified printers on a remote server.

      .PARAMETER Server
      Input remote server from which the event logs should be extract

      .PARAMETER All_Printers
      Specify all printers are to be queried (Accepted inputed 'RemoveAll','GetJobsAll' )

      .PARAMETER One_Printer
      Specify one printer to query (Accepted input 'GetJobsPrinter','RemoveJobsPrinter')
            
      .PARAMETER Printername
      Specifies print queue to query

      
      .EXAMPLE
       Get-AllPrintJobs -server czstlwspc000057 -printername DEKRE1LS02 -One_Printer RemoveJobsPrinter
  #>



  param(
    [Parameter(Mandatory=$true,Position=0)]
    $server,
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='All Printers')]
    [ValidateSet('RemoveAll','GetJobsAll')]
    $All_Printers,
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='One Printer')]
    $printername,
    [Parameter(Mandatory=$true,Position=2,ParameterSetName='One Printer')]
    [ValidateSet('GetJobsPrinter','RemoveJobsPrinter')]
    $One_Printer
  
  
  
  ) Switch ($All_Printers){

    GetJobsAll     {try {$printers = Get-Printer -ComputerName $server -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
               }catch {Write-Host 'Could not connect to server' -ForegroundColor Red}
                try {foreach ($printer in $printers){Get-PrintJob -ComputerName $server -PrinterName $printer}}
                catch{}
                    
              }

    RemoveAll      {try {$printers = Get-Printer -ComputerName $server -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
                }catch{Write-Host 'Could not connect to server' -ForegroundColor Red}
                try{
                 $ids = @()
                 $ids += foreach ($printer in $printers){Get-PrintJob -ComputerName $server -PrinterName $printer | Select-Object -Property ID,Printername}
                  foreach ($id in $ids)
               {                           
                Remove-PrintJob -ComputerName $server -ID $ID.id -PrinterName $id.printername
               }      
                }catch{}
              
                }


   


}

  Switch ($One_Printer){
    GetJobsPrinter {try{Get-PrintJob -ComputerName $server -PrinterName $printername}catch{Write-Host 'Could not connect' -ForegroundColor Red }} 


    RemoveJobsPrinter {try{$IDS = Get-PrintJob -ComputerName $server -PrinterName $printername | Select-Object -Property ID,Printername}catch{Write-Host 'Could not connect' -ForegroundColor Red }
                      try{foreach($id in $ids){Remove-PrintJob -ComputerName $server -PrinterName $id.printername -ID $id.id  }}catch{Write-Host 'Could not remove jobs' -ForegroundColor Red}
  
  }




  }

}