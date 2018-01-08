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
            write-host "$cpt - $name"

            $cpt = $cpt + 1
        }
    write-host "------------------------------------"
    write-host "------------------------------------"
    write-host "Please write the name of the Organizational Unit you want"
    $input = Read-Host ">>> "

    Try{
        $ou = Get-ADOrganizationalUnit -Identity ("OU=$input,"+$domain.DistinguishedName)
    }
    Catch{
        Write-Host "Error: OU was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Break
    }

    Try{
        write-host "Recuperation des donnees de l'OU $input"
        $objACL = Get-ACL -Path ($ou.DistinguishedName)
        }
    Catch{
        Write-Host "Error: ACL was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Break
    }

$right = 1
while($right -gt 0 -and $right -lt 11)
{
    write-host "1- Read"
    write-host "2- Write"
    write-host "3- Read and write"
    write-host "4- ExecuteFile"
    write-host "5- Read and execute"
    write-host "6- Delete"
    write-host "7- Modify"
    write-host "8- CreateFiles"
    write-host "9- CreateDirectories"
    write-host "10- Full control"
    write-host "11- Stop"
    $right=Read-Host ">>> "
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
    if($right -eq 1 -and $cptr -eq 0)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Read"
        $cptr = $cptr + 1 
    }
    elseif($right -eq 2 -and $cptwr -eq 0)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"Write" 
        $cptwr = $cptwr + 1
    }
    elseif($right -eq 3 -and $cptrwr -eq 0)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"ReadAndWrite" 
        $cptrwr = $cptrwr + 1
    }
    elseif($right -eq 4 -and $cptex -eq 0)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"ExecuteFile" 
        $cptex = $cptex + 1
    }
    elseif($right -eq 5 -and $cptrex -eq 0)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute"
        $cptrex = $cptrex + 1 
    }
    elseif($right -eq 6 -and $cptdel -eq 0)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"Delete"
        $cptdel = $cptdel + 1 
    }
    elseif($right -eq 7 -and $cptmodif -eq 0)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Modify"
        $cptmodif = $cptmodif + 1 
    }
    elseif($right -eq 8 -and $cptcrea -eq 0)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"CreateFiles"
        $cptcrea = $cptcrea + 1 
    }
    elseif($right -eq 9 -and $cptcreadir -eq 0)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"CreateDirectories" 
        $cptcreadir = $cptcreadir + 1
    }
    elseif($right -eq 10 -and $cptfullc -eq 0)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Fullcontrol" 
        $cptfullc = $cptfullc + 1
        $right = 11
    }
}

    $path = $input
    $acl = Get-Acl -Path $path
    $concat = "$Global:DOMAIN\$Global:USER"
    $ace = New-Object Security.AccessControl.ActiveDirectoryAccessRule($concat,$colsRights)
    $acl.AddAccessRule($ace)
    Try
    {
        Set-ACL -ACLObject $acl -Path ("AD:\"+($ou.DistinguishedName))
    }
    Catch
    {
        Write-Host "Error: Set-ACL didn't work: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Break
    }
    $input = Read-Host "..."
}