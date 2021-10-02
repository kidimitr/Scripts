 function Get-UpdateStatus {
     param ([Parameter(Mandatory=$true)][string]$server
     )
     
 
 
 
 $Updates = Invoke-Command -ComputerName $server -HideComputerName -ScriptBlock {$UpdateSession = New-Object -ComObject Microsoft.Update.Session
    $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
    try
    {
        $SearchResult = $UpdateSearcher.Search("IsAssigned=1 and IsHidden=0 and IsInstalled=0 and Type='Software'")
    }
    catch
    {
        switch ($_.Exception.HResult)
        {
            0x80072F78 { throw "Error 0x80072F78 - ERROR_HTTP_INVALID_SERVER_RESPONSE - The server response could not be parsed. Execution stopped" }
            0x8024402C { throw "Error 0x8024402C - WU_E_PT_WINHTTP_NAME_NOT_RESOLVED - Winhttp SendRequest/ReceiveResponse failed with 0x2ee7 error. Either the proxy server or target server name can not be resolved. Corresponding to ERROR_WINHTTP_NAME_NOT_RESOLVED. Stop/Restart service or reboot the machine if you see this error frequently." }
            0x80072EFD { throw "Error 0x80072EFD - ERROR_INTERNET_CANNOT_CONNECT - The attempt to connect to the server failed." }
            0x8024401B { throw "Error 0x8024401B - WU_E_PT_HTTP_STATUS_PROXY_AUTH_REQ - Http status 407 - proxy authentication required." }
            0x8024002B { throw "Error 0x8024002B - WU_E_LEGACYSERVER - The Sus server we are talking to is a Legacy Sus Server (Sus Server 1.0)." }
            0x80244017 { throw "Error 0x80244017 - WU_E_PT_HTTP_STATUS_DENIED Same as HTTP status 401 - the requested resource requires user authentication." }
            default { throw "$_ - Refer to https://support.microsoft.com/en-us/kb/938205." }
        }
    }
    if ($SearchResult.Updates.Count -gt 0)
    {
        $Updates = @()
        foreach ($Update in $SearchResult.Updates) 
        { 
            $Updates += [pscustomobject]@{ 
                Title        = $Update.Title
                KB           = $($Update.KBArticleIDs)
                MsrcSeverity = $Update.MsrcSeverity
                IsDownloaded = $Update.IsDownloaded
                Categories   = ($Update.Categories | Select-Object -ExpandProperty Name)
                Server       = $Using:server
            }
        }
        
        Return $Updates
    }else{foreach ($Update in $SearchResult){
        $Updates = @()
        $Updates += [pscustomobject] @{
            Pending = ($Update.warnings | Select-Object -ExpandProperty Message)
            Server = $Using:server

      }

   } Return $Updates
 }
}   

#$Updates | Select-Object -Property * -ExcludeProperty RunSpaceID
$Updates
 }