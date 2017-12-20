#Allow the script execution
Set-ExecutionPolicy Unrestricted

$Domain = Read-Host -Prompt "Please input your domain name"
$Username = Read-Host -Prompt "Please input your username"

$User = Get-Credential -Credential $Username

Write-Host "Welcome"$User.UserName

function menu
{
    Write-Host "1 - Save the security environment"
    Write-Host "2 - Display the security environment"
    Write-Host "2 - Restoration of the security environment"
    Write-Host "3 - Modify the security environment"
    Write-Host "4 - Change authentification"
    Write-Host "5 - Help"
    Write-Host "6 - Quit"
}
cls
menu

$Main_menu_choice = Read-Host -Prompt "What do you want to do?"