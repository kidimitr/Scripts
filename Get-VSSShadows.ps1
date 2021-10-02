function Get-VSSOLD {
    param ([Parameter(Mandatory=$true)][string]$Server



            )
    
            $results = Invoke-Command -ComputerName $Server -ScriptBlock {
                $myobject = @()
                $pattern = '[0-9]{1}\/[0-9]{2}\/[0-9]{4}'
                $volumepattern = '\((.+)\)'
                $shadows = @(vssadmin list shadows | Select-String -Pattern $pattern -Context 0,2 | 
                Select-Object @{Label='Date'; Expression={$_.line.trim("'").substring(46)| Select-String -Pattern $pattern -AllMatches | ForEach-Object {$_.matches} | ForEach-Object {$_.value}}}, 
                   @{Label="ID"; Expression={$_.Context.PostContext[0].Trim().SubString(15)}},
                   @{Label="Volume"; Expression={$_.Context.PostContext[1].Trim().SubString(17) | Select-String -Pattern $volumepattern -AllMatches | ForEach-Object {$_.matches} | ForEach-Object {$_.value} | ForEach-Object {($_ -split "\(|\)")[1]}}})
                
                $shadowstorage = @(vssadmin list shadowstorage | Select-String -Pattern 'For volume:' -Context 0,4 | 
                   Select-Object @{Name='For_Volume';Expression={$_.line.trim(",").substring(16) | ForEach-Object {($_ -split "=|\)")[0]}}},
                   @{Name='On_Volume';Expression={$_.context.postcontext[0].substring(32) | ForEach-Object {($_ -split "=|\)")[0]}}},
                   @{Name='Used';Expression={$_.context.postcontext[1].substring(35)}},
                   @{Name='Allocated';Expression={$_.context.postcontext[2].substring(40)}},
                   @{Name='Max';Expression={$_.context.postcontext[3].substring(38)}})
                
                $myobject += [PSCustomObject]@{
                    Shadows = foreach ($shadow in $shadows){Write-Host "Store on" $shadow.date "on drive" $shadow.volume "with ID" $shadow.ID}
                    Shadowstorage =  foreach ($shadowstorag in $shadowstorage){Write-Host -ForegroundColor Blue "==========================================" "`nVolume"$shadowstorag.For_Volume "Stored on" $shadowstorag.On_Volume "`nUsed" $shadowstorag.Used "`nAllocated" $shadowstorag.allocated "`nMax" $shadowstorag.max "`n=========================================="}
                    
                
                
                }
                
                
                
                
                
                
                
                
                
                   Return $myobject
                } -HideComputerName
                
                
                $results | Select-Object -Property date,id,volume -ExcludeProperty runspaceid
}