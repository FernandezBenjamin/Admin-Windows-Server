Function Add_ACL
{
    write-host "These are the differents Organizational Units on this domain"
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
            write-host "$cpt : $name"
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

    write-host "OU choisis : $input - $LDAPway"


    $nb_char = $LDAPway.Length

    $OUdef = $LDAPway.Substring(7,$nb_char-7)
    $ADPath = "AD:\$OUdef"

    write-host $ADPath



    Try{
        $ou = Get-ADOrganizationalUnit -LDAPFilter $LDAPway -Credential $GLOBAL:CRED
    }
    Catch{
        Write-Host "Error: OU was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        $inpustop = Read-Host "..."
        Break
    }

    Try{
        $objACL = (Get-Acl -Path $ADPath).Access | ? ActiveDirectoryRights 
        }
    Catch{
        Write-Host "Error: ACL was not found in OU: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        $inpustop = Read-Host " ..."
        Break
    }

    $objDomaine=[ADSI]$LDAPway
    $objRecherche = new-object system.DirectoryServices.DirectorySearcher($objDomaine)
    $objRecherche.Filter="(&(objectCategory=user)(objectClass=user))"
    $objResult = $objRecherche.FindAll()
    $nb_group = 0
    foreach($objRes in $objResult)
    {
        $nb_group = $nb_group + 1
    }
    $choice = 0
    write-host "Write the name of the groups of the Organizational Unit you want to apply the new rights on"
    write-host "(Type END to stop)"
    $nb_group = 0
    while($choice -ne "END")
    {
        foreach($objRes in $objResult)
        {
            write-host "GROUP - $name"
        }
        $choice = Read-Host ">>> "
        if($choice -ne "END")
        {
            $groups = $groups + $choice
            $nb_group = $nb_group + 1
        }
    }

    write-host "Do you want to Allow or Deny the next selection ?"
    $rightType = Read-Host "1- Allow | 2- Deny  >>> "

$right = 1
while($right -gt 0 -and $right -lt 11)
{
    $cptr = 0
    $cptwr = 0
    $cptrwr = 0
    $cptex = 0
    $cptrex = 0
    $cptdel = 0
    $cptmodif = 0
    $cptcrea = 0
    $cptcreadir = 0
    $cptfullc = 0
    $cptchoose = 0

    if($rightType -eq 1)
    {
        $rightype = "Allow"
    }
    elseif($rightType -eq 2)
    {
        $rightype = "Deny"
    }

    write-host "Here are different rights you can choose to apply on these groups" 
    if($cptr -eq 0){write-host "1- Read"}
    if($cptwr -eq 0){write-host "2- Write"}
    if($cptrwr -eq 0){write-host "3- Read and write"}
    if($cptex -eq 0){write-host "4- ExecuteFile"}
    if($cptrex -eq 0){write-host "5- Read and execute"}
    if($cptdel -eq 0){write-host "6- Delete"}
    if($cptmodif -eq 0){write-host "7- Modify"}
    if($cptcrea -eq 0){write-host "8- CreateFiles"}
    if($cptcreadir -eq 0){write-host "9- CreateDirectories"}
    if($cptfullc -eq 0){write-host "10- Full control"}
    write-host "11- Stop"
    $right=Read-Host ">>> "
  
    if($right -ne 11 -and $cptchoose -gt 0)
    {
        $colRights = $colRights + ","
    }

    if($right -eq 1 -and $cptr -eq 0)
    {
        $colRights = $colRights + "Read"
        $cptr = $cptr + 1 
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 2 -and $cptwr -eq 0)
    {        
        $colRights = $colRights + "Write" 
        $cptwr = $cptwr + 1
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 3 -and $cptrwr -eq 0)
    {        
        $colRights = $colRights + "ReadAndWrite" 
        $cptrwr = $cptrwr + 1
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 4 -and $cptex -eq 0)
    {        
        $colRights = $colRights + "ExecuteFile" 
        $cptex = $cptex + 1
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 5 -and $cptrex -eq 0)
    {        
        $colRights = $colRights + "ReadAndExecute"
        $cptrex = $cptrex + 1
        $cptchoose = $cptchoose + 1 
    }
    elseif($right -eq 6 -and $cptdel -eq 0)
    {        
        $colRights = $colRights + "Delete"
        $cptdel = $cptdel + 1 
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 7 -and $cptmodif -eq 0)
    {
        $colRights = $colRights + "Modify"
        $cptmodif = $cptmodif + 1 
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 8 -and $cptcrea -eq 0)
    {
        $colRights = $colRights + "CreateFiles"
        $cptcrea = $cptcrea + 1 
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 9 -and $cptcreadir -eq 0)
    {
        $colRights = $colRights + "CreateDirectories" 
        $cptcreadir = $cptcreadir + 1
        $cptchoose = $cptchoose + 1
    }
    elseif($right -eq 10 -and $cptfullc -eq 0)
    {
        $colRights = "Fullcontrol" 
        $cptfullc = $cptfullc + 1
        $right = 11
    }
}
    
    write-host $colRights
    $acl.SetAccessRuleProtection($True, $False)
    
    write-host "Les groupes selectionnés sont :"
    foreach($grp in $groups)
    {
        #!! PROBLEME AVEC LA CREATION DE L'ACE !!
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($grp,$colRights, "ContainerInherit, ObjectInherit", "None", $rightype)
        write-host $grp.name
        if($rule -ne $null)
        {
            $acl.AddAccessRule($rule)
        }
             
    }

    $concat = "$Global:DOMAIN\$Global:USER"
    #$ace = New-Object Security.AccessControl.ActiveDirectoryAccessRule($concat,$colsRights)
    #$acl.AddAccessRule($ace)
    Try
    {
        Set-ACL -ACLObject $acl -Path $ADPath
    }
    Catch
    {
        Write-Host "Error: Set-ACL didn't work: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        $inpustop = Read-Host "..."
        Break
    }
    $inpustop = Read-Host "..."
}