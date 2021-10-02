function Get-GROUPACL {
    <#
     .SYNOPSIS 
     Checks which groups have write permissions to groups and users
     
     .DESCRIPTION
     Checks which groups have write permissions to groups and users
     by checking ACL of OU
     
     .PARAMETER ADgroup
      Input ADgroup to check write ACL
     
     .Parameter ADUser
      Input ADUser to check write ACL
     
     .Parameter Domain
     Enter Domain if KUL-DC or PHX-DC default is PRG-DC

       
     .EXAMPLE
     Get-GROUPACL -ADUser SanthoshRavi -domain kul-dc
     #>
    
    
    
    
        param ([Parameter(Mandatory=$false,ParameterSetName='ADGroup')][String]$ADGroup,
        [Parameter(Mandatory=$false,ParameterSetName='ADUser')][string]$ADUser,
        [Parameter(Mandatory=$true)]
        [Validateset('kul-dc','phx-dc','prg-dc')]
        [String]$domain,
        [Parameter(Mandatory=$false)]
        [Switch]$ACLS,
        [Parameter(Mandatory=$false)]
        [Switch]$Owner

        )

        if($ACLS){
        
        
        if($ADUser){
        
        if ($domain -eq 'kul-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            $OU = Get-ADUser -Server $domain -Identity $ADUser | Select-Object -ExpandProperty Distinguishedname
            (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
        
        }else{if($domain -eq 'phx-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            $OU = Get-ADUser -Server $domain -Identity $ADUser | Select-Object -ExpandProperty Distinguishedname
            (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
        
        }else{if($domain -eq 'prg-dc'){
                New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
                Set-Location -Path "$($domain):"
                [string]$OU = Get-ADUser -Identity $ADUser | Select-Object -ExpandProperty Distinguishedname
                (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
                 
            }
        }
    
     }
    
    }else {
    
        if ($domain -eq 'kul-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            $OU = Get-ADGroup -Server $domain -Identity $ADGroup| Select-Object -ExpandProperty Distinguishedname
            (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
        
        }else{if($domain -eq 'phx-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            $OU = Get-ADGroup -Server $domain -Identity $ADGroup | Select-Object -ExpandProperty Distinguishedname
            (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
        
        }else{if($domain -eq 'prg-dc'){
                New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
                Set-Location -Path "$($domain):"
                [string]$OU = Get-ADGroup -Identity $ADGroup | Select-Object -ExpandProperty Distinguishedname
                (Get-Acl -Path $OU).access | Where-Object {$_.ActiveDirectoryRights -like '*write*'} | Select-Object -Property IdentityReference,ActiveDirectoryRights | Format-Table -Force
                 
        }
      }
    }
    
  }

}

if($Owner){

    if($ADUser){
        
        if ($domain -eq 'kul-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADUser -Server $domain -Identity $ADUser | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
        
        }else{if($domain -eq 'phx-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADUser -Server $domain -Identity $ADUser | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
        
        }else{if($domain -eq 'prg-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADUser -Server $domain -Identity $ADUser | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
                 
            }
        }
    
     }
    
    }else {
    
        if ($domain -eq 'kul-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADGroup -Server $domain -Identity $ADGroup | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
        
        }else{if($domain -eq 'phx-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADGroup -Server $domain -Identity $ADGroup | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
        
        }else{if($domain -eq 'prg-dc'){
            New-PSDrive -Name $domain -PSProvider ActiveDirectory -Root '//rootdse/' -Server $domain
            Set-Location -Path "$($domain):"
            [string]$OU = Get-ADGroup -Server $domain -Identity $ADGroup | Select-Object -ExpandProperty distinguishedname
            Get-Acl -Path $OU  | Select-Object -ExpandProperty owner
                 
        }
      }
    }
    
  }
}
     Set-Location C:\windows\System32
}
    