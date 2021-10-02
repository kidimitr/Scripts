function Get-PublicIP
{
  <#
    .SYNOPSIS
    This function displays the Public IP of this network

    .DESCRIPTION
    Public IP

    .EXAMPLE
    Get-PublicIP
    Provides Public IP

    .NOTES
    

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-PublicIP

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


  Invoke-WebRequest -Uri ipinfo.io/ip | Select-Object -ExpandProperty Content | Format-List
  

}
