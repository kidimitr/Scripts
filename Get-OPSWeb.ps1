function Get-OPSWeb {
    param ([Parameter(Mandatory = $true)]
    [string]$server
    )
    Invoke-WebRequest http://opsweb.prg-dc.dhl.com/support/textapi/systemInfo?name=$server| Select-Object -ExpandProperty Content
}

