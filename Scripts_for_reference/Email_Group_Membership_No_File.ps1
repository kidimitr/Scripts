cls


$Groups = "UDLDHL-MS-EFILE-CON","UDLDHL-MS-EFILE","UDLDHL-MS-EFILE-ADM","UDLDHL-MS-EFILE-EXT"
$ADusers = @()
foreach ($group in $groups){
    

  $users = Get-ADGroupMember -Identity $group

  foreach ($user in $users){

       $ADuser =  Get-ADUser $user -Properties SAMAccountname,EmailAddress,Enabled 
      if($ADuser.enabled){
      $ADusers += $ADuser | select SAMAccountname,EmailAddress
      
      }
      
        }
}

$attachment = $ADusers | Sort-Object -Property Samaccountname -Unique | ConvertTo-Csv -Delimiter ';' -NoTypeInformation | Out-String


$message = New-Object System.Net.Mail.MailMessage
$from = 'kiril.dimitrov@dhl.com'
$to_1 = 'kiril.dimitrov@dhl.com'
$to_2 = 'kiril.dimitrov@dhl.com'
$subject = 'MyShare eFile Users'
$emailbody = 'Report of Citrix MyShare eFile users.  To be uploaded to sftp://pclegg@czchols1607:10022/ITS/Citrix/toAspera 1st Monday of each month (by pclegg)'
$attText = $attachment
$attname = 'myShare_user_report.csv'

$message.From = $from
$message.To.Add($to_1)
$message.to.Add($to_2)
$message.Subject = $subject
$message.Body = $emailbody

$att = New-Object ([System.Net.Mail.Attachment]::CreateAttachmentFromString($attText,$attname))
$message.Attachments.Add($att)

$mailer = New-Object System.Net.Mail.SmtpClient
$mailer.Host = 'gateway.dhl.com'

$message.IsBodyHtml = $false

$mailer.Send($message)
