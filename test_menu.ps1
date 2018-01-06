
#Variable globale
$Local:domainName = $null
$Local:userName = $null

#vérifier si l'utilisateur existe dans l'AD (voir plus j'ai pas encore checké)
Invoke-Command -FilePath Test-UserCredentials.ps1 -ComputerName $env:COMPUTERNAME


function menu #Main menu
{
cls #clean the screen
#$domainName = "Random1"
#$userName = "user"
Write-Host "Domain :"$domainName
Write-Host "User :"$userName

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
