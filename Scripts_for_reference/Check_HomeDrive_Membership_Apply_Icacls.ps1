Invoke-Command -ComputerName gbemawsa034 -ScriptBlock {


  $folders = Get-ChildItem F:\Users\Quota1\

  foreach ($folder in $folders){
    $name = $folder.name
   $userfolder = $folder.getaccesscontrol('Access') | select accesstostring | Where-Object {$_ -notlike "*$name*"}
    
    if(!$userfolder -eq $false ) {     
    
    $icacl = "icacls `"{0}`" /grant `"{1}:(OI)(CI)M`" /t /c > `"c:\temp\Logs\icacls_{2}.txt`"" -f $folder.fullname,$name,$name
    
    Invoke-Expression -Command $icacl
    
    }
    

  
  
  
  }


  }




#foreach ($folder in $folders){$folder.getaccesscontrol('Access') | select Accesstostring | Where-Object {$_ -notlike $folder.Name} | select -Property @{N='User';E={$folder.name}}}