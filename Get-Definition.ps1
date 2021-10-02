function Get-Definition {
    param ([Parameter(Mandatory=$false,Position=1)][string]$Function
        )
    

        (Get-Command $Function).Definition
}