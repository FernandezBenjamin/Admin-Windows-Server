#Allow the script execution
Set-ExecutionPolicy Unrestricted

#Set-Location AD

#Fonction de recuperation de toutes les OU du domaine
Function Get-ADSIOU
{
    # Renvoie toutes les OU du domaine courrant
    $objDomain = [ADSI]''
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher($objDomain)
    $objSearcher.Filter = '(objectCategory=organizationalUnit)'

    $OU = $objSearcher.FindAll() | Select-object -ExpandProperty Path

    $OU
}


#Fonction de recuperation de tous les comptes du domaine
Function Get-ADUsers
{
    echo "**** Utilisateurs du domaine*****"

    $ldapQuery = "(&(objectCategory=user))"
    $de = new-object system.directoryservices.directoryentry
    $ads = new-object system.directoryservices.directorysearcher -argumentlist $de,$ldapQuery
    $complist = $ads.findall()
    foreach ($i in $complist) 
    {
        write-host $i.Path
        echo "Is member of :"
        ([ADSI]$i.Path).memberof
        echo "-------------------"
        
    }
}

Function Get-ADGroups
{
    echo "**** Groupes du domaine*****"

    $Groupes = 'Administrateur','Admin','Administrateurs','Admins'
    $ldapQuery = "(&(objectCategory=group))"
    $de = new-object system.directoryservices.directoryentry
    $ads = new-object system.directoryservices.directorysearcher -argumentlist $de,$ldapQuery
    $complist = $ads.findall()
    foreach ($i in $complist) 
    {
        write-host $i.
        
    }
}

Function Get-ADComputers
{
    echo "**** Ordinateurs du domaine*****"
    $ldapQuery = "(&(objectCategory=computer))"
    $de = new-object system.directoryservices.directoryentry
    $ads = new-object system.directoryservices.directorysearcher -argumentlist $de,$ldapQuery
    $complist = $ads.findall()
    foreach ($i in $complist) 
    {
        write-host $i.Path
        
    }
}


Function TestFunct
{
$strCategory = "computer"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry


$objSearcher = New-Object System.DirectoryServices.DirectorySearcher

$objSearcher.SearchRoot = $objDomain

$objSearcher.Filter = ("(objectCategory=$strCategory)")


$colProplist = "name"

foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}


$colResults = $objSearcher.FindAll()


foreach ($objResult in $colResults)

    {$objComputer = $objResult.Properties; $objComputer.name}
}


echo "Welcome in this function test"
$saisie = 2
while($saisie -lt 6 -and $saisie -gt 0)
{
    echo "******MENU******"
    echo "1- Get-ADUsers"
    echo "2- Get-ADComputers"
    echo "3- Get-ADGroups"
    echo "4- Get-ADSIOU"
    echo "5- Leave the script"
    $saisie=Read-Host ">>> "

    if($saisie -eq 1)
    {
        #Commande pour recuperer le DN du compte utilisé actuellement
        #([ADSI]"LDAP://$(whoami /fqdn)").memberof
        Get-ADUsers
    }
    elseif($saisie -eq 2)
    {
        Get-ADComputers
    }
    elseif($saisie -eq 3)
    {
        Get-ADGroups
    }
    elseif($saisie -eq 4)
    {
        Get-ADSIOU
    }
    elseif($saisie -eq 5)
    {
        $saisie = 0
    }
}

#Get-ADUser -Identity 'CN=Petitjean Arnaud,CN=Users,DC=powershell-scripting,DC=com' -Properties Description

# Connexion à l'objet en spécifiant son DN - Distinguished Name
$user = [ADSI]'LDAP://CN=Gege GF. Firth,CN=Users,DC=esgi,DC=priv'

echo "$user"

# Modification de la propriété Description avec la méthode Put
#$user.Put('Description','Cet utilisateur est exceptionnel !')

# Application des changements avec la méthode SetInfo
#$user.SetInfo()

#Recuperation du SID d'un compte
#param ($account = $(throw "esgi.priv\Administrateur")) 

#if ($account -is [security.principal.ntaccount]) { 
#    $ntaccount = $account 

#} else {
#    $ntaccount = new-object security.principal.ntaccount $account 
#}

#$ntaccount.translate( [security.principal.securityidentifier] )