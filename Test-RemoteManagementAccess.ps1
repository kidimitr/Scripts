function Test-RemoteManagementAccess
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "Provide the remote computer hostname.")]
        [Alias('Hostname', 'cn')]
        [string[]]$ComputerName
    )

    process
    {
        foreach ($Computer in $ComputerName)
        {
            try 
            {
                $ICM = Invoke-Command -ComputerName $Computer -Scriptblock { $env:COMPUTERNAME } -ErrorAction Stop
                $ICM = $true          
            }
            catch
            {
                if ($_.Exception.Message -ilike "*Access is denied*") { $ICM = "Access denied" }
                elseif ($_.Exception.Message -ilike "*RPC server is unavailable*") { $ICM = "RPC server is unavailable" }
                elseif ($_.Exception.Message -ilike "*WinRM*") { $ICM = "Disabled" }
                else { $ICM = $_.Exception.Message }
            }

            try
            {
                $WSMan = Get-CimInstance -Class win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop
                $WSMan = $true
            }
            catch
            {
                if ($_.Exception.Message -ilike "*Access is denied*") { $WSMan = "Access denied" }
                elseif ($_.Exception.Message -ilike "*RPC server is unavailable*") { $WSMan = "RPC server is unavailable" }
                elseif ($_.Exception.Message -ilike "*WinRM*") { $WSMan = "Disabled" }
                else { $WSMan = $_.Exception.Message }    
            }

            try 
            {
                $RDP = (Test-Port -computer $Computer -TCP -port 3389 -TCPtimeout 10000).Open
            }
            catch
            {
                $RDP = $_.Exception.Message
            }
            $Properties = [ordered]@{
                Hostname   = $Computer
                PSRemoting = $ICM
                WSMan      = $WSMan
                RDPPort    = $RDP
            }
            $Object = New-Object PSObject -Property $Properties
            Write-Output $Object
        }
    }
}
