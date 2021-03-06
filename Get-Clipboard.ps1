<#
Get-Clipboard
	-Summary: Returns whatever is currently saved to the clipboard.
	-Usage: Get-Clipboard
#>

Add-Type -AssemblyName System.Windows.Forms
$tb = New-Object System.Windows.Forms.TextBox
$tb.Multiline = $true
$tb.Paste()
$tb.Text
