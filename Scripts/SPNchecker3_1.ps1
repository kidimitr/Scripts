Import-Module 'D:\Wintel\Kiril\Scripts\SPN_Check\PoshRSJob'
#Import-Module 'D:\Automation\SPNcheck\MySQLquery\Run-MySQLQuery.ps1'
$AllServers = 'mykulws1263.kul-dc.dhl.com' 
$scriptblock = {
    Import-Module 'ActiveDirectory', 'DnsClient'
    $fqdn = $_
    $setspnqueryERROR = @()
    $admanagerERROR = @()
    $ArecordqueryERROR = @()
    $CNAMErecordERROR = @()
    $computername = ($fqdn -split "\.")[0]
    $queries = @(
        "C:\windows\system32\setspn.exe -Q HTTP/$computername",
        "C:\windows\system32\setspn.exe -Q HTTP/$fqdn" 
    )
    
    foreach ($query in $queries) {

        try {
            $cmd = iex $query -ErrorAction Stop
        }
        catch {
            $setspnqueryERROR += "Error when tried to run $query"
        }
        #check for existing SPN record
        if ($cmd -match 'Existing SPN found') {
            try {
                $HostnameIP = Resolve-DnsName $fqdn -ErrorAction Stop | select IP4Address
            }
            catch {
                [string]$hostnameIPerror = "Error when tried to resolve-dnsname $fqdn"
            }
            
            #check, if found SPN record is for SRV account or hostname  
            if ($cmd -match "CN=$computername") { break }
            else {
                #resolving manager identity from found SRV accounts + their description
                $account = @()
                $CNstring = $cmd | Select-String -SimpleMatch 'CN='
                foreach ($acc in $CNstring) {
                    $account += ((($acc | Select-String -SimpleMatch 'CN=') -split ',', 2)[0] -split 'CN=')[1]
                }
                $description = @()
                $email = @()
                $DHLglobalC = Get-ADDomainController -Server 'dhl.com' | where {$_.IsGlobalCatalog -match 'True'}
                foreach ($srvacc in $account) {
                    try {
                        $ADmanager = Get-ADUser -Identity $srvacc -Properties manager, description -ErrorAction Stop
                    }
                    catch {
                        $admanagerERROR += "Error, when tried to get-aduser $srvacc"
                    }
                    $descstring = ($ADmanager.description | Out-String).Trim()
                    $description += "$srvacc : $descstring`n---------------`n"
                    if ($ADmanager.manager -like $null) {
                        
                    }
                    else {
                        $userprincipalname = Get-ADUser -Identity $ADmanager.manager -Server "$($DHLglobalC.HostName):3268"
                        $emailstring = ($userprincipalname.UserPrincipalName | Out-String).Trim()
                        $email += "$srvacc : $emailstring`n---------------`n"                                    
                    }
                }
                #DNS query to check CNAME or A records
                $dnsrecord = @()
                $ArecordqueryERROR = @()
                $dnsaliasfilter = $cmd | Select-String -SimpleMatch 'http/' | Where-Object { $_ -notmatch '\d' }
                foreach ($alias in $dnsaliasfilter) {
                    $aliasfilter = ($alias -split '/')[1]
                            
                    try {
                        $resolve = Resolve-DnsName -Name $aliasfilter -type a -ErrorAction stop | Where-Object { $_ -like "*_A" -and $_.name -like "*$aliasfilter*" }
                    }
                    catch {
                        $ArecordqueryERROR += "Error when tried to resolve-dnsname $aliasfilter"
                    }
                    
                    if ($resolve.type -like $null) {
                             
                    }
                    else {
                        if ($dnsrecord.name -contains $resolve.name) {
                                
                        }
                        else {
                            $dnsrecord += $resolve | select name, type, IP4Address
                        }
                    }
                }

                foreach ($alias in $dnsaliasfilter) {
                    $aliasfilter = ($alias -split '/')[1]
                    try {
                        $resolve = Resolve-DnsName -name $aliasfilter -type cname
                    }
                    catch {
                        $CNAMErecordERROR += "Error when tried to resolve-dns $aliasfilter"
                    }
                    if ($resolve.type -like $null) {
                         
                    }
                    else {
                        if ($dnsrecord.name -notcontains $resolve.name) {
                            $dnsrecord += $resolve | select name, type
                        }
                        else {
                            
                        }
                    }
                } 

                [pscustomobject]@{
                    server           = $fqdn
                    query            = $query
                    account          = $account -join ';'
                    manager          = ($email | Out-String).trim()
                    description      = ($description | Out-String).trim()
                    DNSname          = ($dnsrecord.name | Out-String).Trim()
                    DNStype          = ($dnsrecord.type | Out-String).Trim()
                    IPAddress        = ($dnsrecord.IP4Address | Out-String).Trim()
                    HostnameIP       = $HostnameIP.IP4Address | Out-String
                    SetSPNerror      = ($setspnqueryERROR | Out-String).Trim()
                    HostresolveError = $hostnameIPerror
                    ADmanagerError   = ($admanagerERROR | Out-String).Trim()
                    ArecordError     = ($ArecordqueryERROR | Out-String).Trim()
                    CNAMErecordError = ($CNAMErecordERROR | Out-String).Trim()

                }
                $duplicitycheck = $cmd | Select-String -SimpleMatch "http/$computername"
                if ($duplicitycheck -match "http/$computername" -and "http/$fqdn") { break }
            }
        }
        else {
            
        }
    }
}

$jobparam = @{
    Name            = { $_ }
    Throttle        = 1
    ScriptBlock     = $scriptblock
    ModulesToImport = 'ActiveDirectory', 'DnsClient'
}
    
$jobs = $AllServers | Start-RSJob @jobparam -ErrorAction Stop
$jobs | Wait-RSJob -Timeout 18000 -ShowProgress
$results = $jobs | Receive-RSJob
$date = (Get-Date).ToString("MM_dd")
$automationpath = 'D:\Wintel\Kiril\Scripts\SPN_Check\'
$results | Export-Csv -Path "$automationpath\Results_$date.csv" -Delimiter ';' -NoTypeInformation