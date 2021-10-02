function Get-LocalAdministrators {  
    param ($strcomputer)  

    $admins = Get-WmiObject win32_groupuser -computer $strcomputer   
    $admins = $admins |? {$_.groupcomponent -like '*"Administrators"'}  

    $admins | ForEach-Object {  
    
    
    
    
    $_.partcomponent -match ".+Domain\=(.+)\,Name\=(.+)$" > $nul 
    $matches[1].trim('"') + "\" + $matches[2].trim('"')  
    }  
}