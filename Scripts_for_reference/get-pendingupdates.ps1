function Get-PendingUpdates {
    param($server)
    
    $Query = [System.Activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$server))
    $search = $Query.createupdatesearcher()
    $results = $search.search("IsInstalled=0")
    $output = $results.updates | Where-Object {$_.ishidden -like '*true*'} | Select-Object -ExpandProperty Title
    $color = $Host.UI.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = 'Green'
    Write-Output $output 
    $Host.UI.RawUI.ForegroundColor = $color
    

}