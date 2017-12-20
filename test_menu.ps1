#Allow the script execution
Set-ExecutionPolicy Unrestricted

Import-Module ActiveDirectory

$Domain = Read-Host -Prompt "Please input your domain name"
$Username = Read-Host -Prompt "Please input your username"

#vérifier si l'utilisateur existe dans l'AD (voir plus j'ai pas encore checké)
Invoke-Command -FilePath ..\..\powershell\Test-UserCredentials.ps1 -ComputerName $env:COMPUTERNAME

#$User = Get-Credential -Credential $Username


function menu #Main menu
{
cls #clean the screen
Write-Host "Domain :"$Domain
Write-Host "User :"$User.UserName

Write-Host "============================================="
Write-Host "                  MENU"
Write-Host "============================================="

    Write-Host "1 - Save the right environment"
    Write-Host "2 - Display the right environment"
    Write-Host "2 - Restoration of the right environment"
    Write-Host "3 - Modify the right environment"
    Write-Host "4 - Change security environment"
    Write-Host "5 - Help"
    Write-Host "6 - Quit"


}

menu

$Main_menu_choice = Read-Host -Prompt "What do you want to do?"