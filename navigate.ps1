Function Navigate
{
    $objDomain = New-Object System.DirectoryServices.DirectoryEntry


    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher

    $objSearcher.SearchRoot = $objDomain

    $objSearcher.Filter = ("(objectCategory=organizationalUnit)")


    $colProplist = "name"

    foreach ($i in $colPropList)
        {
            $objSearcher.PropertiesToLoad.Add($i)
        }

    write-host "Here are the differents Organizational Units of the Domain : $Global:DOMAIN"

    $colResults = $objSearcher.FindAll()
    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            write-host "$cpt -> $name"
            $cpt = $cpt + 1
        }
    write-host "------------------------------------"
    write-host "------------------------------------"
    write-host "Please write the number of the Organizational Unit you want"
    $nb_ou = Read-Host ">>> "
    $cpt = 0
    foreach ($objResult in $colResults)
        {
            $objComputer = $objResult.Properties;

            $name = $objComputer.name
            if($cpt -eq $nb_ou)
            {
                $input = $name
                $LDAPway = $objResult.Path
            }
            $cpt = $cpt + 1
        }

    $stop = 0
    while($stop -eq 0)
    {
        write-host "Here are the childs of the Organizational Unit you selected : $input"
        $nb_char = $LDAPway.Length

        $OUdef = $LDAPway.Substring(7,$nb_char-7)
        $ADPath = "AD:\$OUdef"
        $OU_childs = Get-ChildItem -Path $ADPath

        $cpt = 0
        foreach($ou_child in $OU_childs)
        {
            $name = $ou_child.name
            write-host "$cpt -> $name"
            write-host $ou_child
            $cpt = $cpt + 1
        }
        write-host "-1 -> QUIT"
        $nb_ou = Read-Host "Select your number "
        if($nb_ou -eq -1){$stop = 1}
        $cpt = 0
        foreach ($ou_child in $OU_childs)
            {
                $ou_chil = $ou_child.Properties;

                if($cpt -eq $nb_ou)
                {
                    $input = $ou_child.name
                    $LDAPway = "LDAP://$ou_child"
                    write-host $LDAPway
                }
                $cpt = $cpt + 1
            }
    }
    $inpustop = Read-Host "..."

    return $ADPath
}

$way = Navigate

#Faire un traitement pour supprimer les deux premiers char (0 et ' ')