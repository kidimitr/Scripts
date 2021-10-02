#Sample text
$text = @"
This is (a) sample
text, this is
a (sample text)
"@
#Sample pattern: Text wrapped in ()
$pattern = '$.{5}|', ''
#Replace matches with:
$newvalue = 'test'

$testnumbers = '15:14:46.5337982'
