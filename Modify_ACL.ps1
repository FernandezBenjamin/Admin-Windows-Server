Function Set-OUAcl
{

    echo "These are the differents organizationalunits on this domain"
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry


    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher

    $objSearcher.SearchRoot = $objDomain

    $objSearcher.Filter = ("(objectCategory=organizationalUnit)")


    $colProplist = "name"

    foreach ($i in $colPropList)
        {
            $objSearcher.PropertiesToLoad.Add($i)
        }


    $colResults = $objSearcher.FindAll()

    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            write-host "$cpt - " -nonewline
            $name

            $cpt = $cpt + 1
        }
    echo "------------------------------------"
    echo "------------------------------------"
    echo "Please select a number in the list of organizationalunits "
    $select = Read-Host ">>> "
    while($select -ge $cpt -and $select -lt -1)#Remplacer valeurs dans comparaison par nombre d'objet dans la liste
        {
            echo "ERROR : Wrong selection, please enter a number that is in the list "
            $select = Read-Host ">>> "
        }

    $colResults = $objSearcher.FindAll()

    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            if($cpt -eq $select)
                {
                    $SelectedOU = $name
                    $SelectedOU
                }

            $cpt = $cpt + 1
        }

#Recuperation de l'OU sélectionnée
Try{
        $ou = Get-ADOrganizationalUnit -Identity ("OU=$SelectedOU,"+$domain.DistinguishedName)
    }
    Catch{
        Write-Host "Error: OU was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Break
    }
    #Recuperation des SID de chaque groupe sur lesquels on veut agir
    echo "------------------------------------"
    echo "------------------------------------"
    echo "This is a list of all the groups of the domain"

    $objDomain = New-Object System.DirectoryServices.DirectoryEntry


    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher

    $objSearcher.SearchRoot = $objDomain

    $objSearcher.Filter = ("(objectCategory=group)")


    $colProplist = "name"

    foreach ($i in $colPropList)
        {
            $objSearcher.PropertiesToLoad.Add($i)
        }


    $colResults = $objSearcher.FindAll()

    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            write-host "$cpt - " -nonewline
            $name

            $cpt = $cpt + 1
        }
    echo "------------------------------------"
    echo "------------------------------------"
    echo "Please select a number in the list of groups "
    $select = Read-Host ">>> "
    while($select -ge $cpt -and $select -lt -1)#Remplacer valeurs dans comparaison par nombre d'objet dans la liste
        {
            echo "ERROR : Wrong selection, please enter a number that is in the list "
            $select = Read-Host ">>> "
        }

    $colResults = $objSearcher.FindAll()

    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            if($cpt -eq $select)
                {
                    $idGroups = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup "$name").SID
                }

            $cpt = $cpt + 1
        }


    #Get a copy of the current DACL on the OU
    Try{
        $objACL = Get-ACL -Path ($ou.DistinguishedName)
        }
    Catch{
        Write-Host "Error: ACL was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Break
    }


    #Lister les droits et permettre la selection de plusieurs d'entre eux
    echo "Quel droit voulez vous appliquer a l'ACL (respectez la casse) ?"
    echo "Read"
    echo "Write"
    echo "Delete"
    echo "ExecuteFile"
    echo "CreateFiles"
    echo "CreateDirectories"
    echo "Veuillez selectionner un droit a appliquer"
    $rights = Read-Host ">>> "

    echo "Quel droit voulez vous appliquer a l'ACL (respectez la casse) ?"
    while($select -ne -1)
    {
        echo "Read"
        echo "Write"
        echo "Delete"
        echo "ExecuteFile"
        echo "CreateFiles"
        echo "CreateDirectories"
        echo "Veuillez selectionner un droit a appliquer (-1 pour quitter)"
        $select = Read-Host ">>> "
        if($select -ne -1)
            {
                $rights = $rights + ",$select"
            }
        else
            {
                $rights = $rights + $select
            }
    }

    echo "Les droits que vous avez choisis sont :"
    $rights

    $colRights = [System.Security.AccessControl.FileSystemRights]"Fullcontrol" #Pouvoir mettre un $rights

    $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None 
    $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 

    #Allow dans la plupart des cas mais Deny peut desactiver des ACE
    $objType =[System.Security.AccessControl.AccessControlType]::Allow 

    #Doit comporter les identifiants de connexion du compte qui execute le script
    $objUser = New-Object System.Security.Principal.NTAccount("esgi.priv\Administrateur")

    #BONUS EVENTUEL : Ajouter des groupes dans l'ACL avec des droits spéciaux (ici Reset Password)
    #echo "Test d'affichage de stockage d'objet SID"
    #foreach($idGroup in $idGroups)
    #    {
    #        $idGroup
    #        $objACL.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    #        $idGroup,"ExtendedRight","Allow",$extendedrightsmap["Reset Password"],"Descendents",$guidmap["user"]))
    #    } 

    $objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 
 
    $objACL.AddAccessRule($objACE) 

    #Re-apply the modified DACL to the OU
    Set-ACL -ACLObject $objACL -Path ("AD:\"+($ou.DistinguishedName))

#Allow the group to reset user passwords on all descendent user objects
}