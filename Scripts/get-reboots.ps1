Add-Type -AssemblyName PresentationFramework
function Get-Reboots{ 
  param([Parameter(Mandatory=$true,Position=0,HelpMessage='Input host to query',ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
  [Alias("Hostname","Server")]$Computername)
  $Results = @()
  $Reboots = Get-WinEvent -ComputerName $computername -FilterHashtable @{logname='system';id='1074'}

  foreach ($Reboot in $Reboots ){

    $Results += [PSCustomObject]@{
      Process = $Reboot.Properties[0].value.Substring($reboots[0].Properties[0].value.LastIndexOf('\')+1).split('(')[0]
      User = $Reboot.Properties[6].value
      Host = $Reboot.Properties[1].value
      ShutdownType = $Reboot.Properties[4].value
      Reason = $Reboot.Properties[2].Value
      Date = $Reboot.TimeCreated
     
    }

  }
  
  
  $Results
  
}


# where is the XAML file?

$xamlFile =  @"
<Window x:Class="PW_GUI.MainWindow"
       xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
       xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
       xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
       xmlns:local="clr-namespace:PW_GUI"
       mc:Ignorable="d"
       Title="Get Reboots" Height="326" Width="403">
   <Grid>
       <Label Content="ComputerName" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,10,0,0"/>
       <TextBox Name ="txtComputer" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="174" Margin="115,15,0,0"/>
       <Button Name ="btnQuery" Content="Query" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="311,15,0,0"/>
       <TextBox Name ="txtResults" HorizontalAlignment="Left" Height="225" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="373" Margin="10,60,0,0"/>

   </Grid>
</Window>

"@
#create window

$inputXML = $xamlFile -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

# Create variables based on form control names.
# Variable will be named as 'var_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}
Get-Variable var_*
$var_btnQuery.Add_Click( {
  #clear the result box
  $var_txtResults.Text = ""
      if ($result = Get-RebootsGUI -computername $var_txtComputer.Text) {
          foreach ($item in $result) {
              $var_txtResults.Text = $var_txtResults.Text + "Process: $($item.process)`n"
              $var_txtResults.Text = $var_txtResults.Text + "User: $($item.user)`n"
              $var_txtResults.Text = $var_txtResults.Text + "Host: $($item.host)`n"
              $var_txtResults.Text = $var_txtResults.Text + "Reason: $($item.reason)`n"
              $var_txtResults.Text = $var_txtResults.Text + "Time: $($item.Date)`n"
              $var_txtResults.Text = $var_txtResults.Text + "ShutdownType: $($item.Shutdowntype)`n`n"
          }
      }       
  })

$var_txtComputer.Text = $env:COMPUTERNAME


$Null = $window.ShowDialog()



