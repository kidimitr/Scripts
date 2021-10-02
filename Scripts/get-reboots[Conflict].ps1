Add-Type -AssemblyName PresentationFramework
function Get-Reboots
{ param($computername)
  $Results = @()
  $Reboots = Get-WinEvent -ComputerName $computername -FilterHashtable @{logname='system';id='1074'}

  foreach ($Reboot in $Reboots ){

    $Results += [PSCustomObject]@{
      Process = $Reboot.Properties[0].value.Substring($reboots[0].Properties[0].value.LastIndexOf('\')+1).split('(')[0]
      User = $Reboot.Properties[6].value
      Host = $Reboot.Properties[1].value
      ShutdownType = $Reboot.Properties[4].value
      Reason = $Reboot.Properties[2].Value
     
    }
  }
  
  
  $Results
  
}


# where is the XAML file?
$inputXML = @" 
<Window x:Class="GUI.MainWindow"
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
xmlns:local="clr-namespace:GUI"
mc:Ignorable="d"
Title="Reboots" Height="600" Width="450
">
<Grid>
<Button Content="Query" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="357,10,0,0" Name="btnQuery"/>
<Label Content="Computer Name:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="10,10,0,0" Height="37" Width="135"/>
<TextBox HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="204" Margin="119,10,0,0" Name="txtComputer"/>
<TextBox HorizontalAlignment="Left" Height="459" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="424" Margin="10,60,0,0" Name="txtResults" IsReadOnly="True" RenderTransformOrigin="0.5,0.5">
    <TextBox.RenderTransform>
        <TransformGroup>
            <ScaleTransform/>
            <SkewTransform AngleY="-0.137"/>
            <RotateTransform/>
            <TranslateTransform Y="-0.445"/>
        </TransformGroup>
    </TextBox.RenderTransform>
</TextBox>
</Grid>
</Window>
"@


#create window

$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
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
      if ($result = Get-Reboots -computername $var_txtComputer.Text) {
          foreach ($item in $result) {
              $var_txtResults.Text = $var_txtResults.Text + "Process: $($item.process)`n"
              $var_txtResults.Text = $var_txtResults.Text + "User: $($item.user)`n"
              $var_txtResults.Text = $var_txtResults.Text + "Host: $($item.host)`n"
              $var_txtResults.Text = $var_txtResults.Text + "Reason: $($item.reason)`n"
              $var_txtResults.Text = $var_txtResults.Text + "ShutdownType: $($item.Shutdowntype)`n`n"
          }
      }       
  })

$var_txtComputer.Text = ''


$Null = $window.ShowDialog()



