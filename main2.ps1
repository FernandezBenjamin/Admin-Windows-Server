 #Allow the script execution
Set-ExecutionPolicy Unrestricted

 #Import Active Directory Module
 Import-Module Activedirectory


#Variable Global
$Global:DOMAIN = $null
$Global:USER = $null
$GLOBAL:CRED = $null
#============================# FUNCTIONS CREDENTIAL #============================#

#Clear User Info Function
Function ClearUserInfo{

    $Cred = $Null
    $DomainNetBIOS = $Null
    $UserName  = $Null
    $Password = $Null
}

#Rerun The Script Function
Function Rerun{

    $Title = "Test Another Credentials?"
    $Message = "Do you want to Test Another Credentials?"
    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Test Another Credentials."
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "End Script."
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

    Switch ($Result){
        0 {TestUserCredentials}
        1 {"End Script."}
    }
}

#Test User Credentials Function
Function TestUserCredentials
{
    ClearUserInfo
    #Get user credentials
    $cred = Get-Credential -Message "Enter Your Credentials (Domain\Username)"
    $GLOBAL:CRED = $cred
    if ($cred -eq $Null){
        Write-Host "Please enter your username in the form of Domain\UserName and try again" -BackgroundColor Black -ForegroundColor Yellow
        Rerun
        Break
    }

    #Parse provided user credentials
    $DomainNetBIOS = $cred.username.Split("{\}")[0]
    $UserName = $cred.username.Split("{\}")[1]
    $Password = $cred.GetNetworkCredential().password

    Write-Host "`n"
    Write-Host "Checking Credentials for $DomainNetBIOS\$UserName" -BackgroundColor Black -ForegroundColor White
    Write-Host "***************************************"

    If ($DomainNetBIOS -eq $Null -or $UserName -eq $Null) {
        Write-Host "Please enter your username in the form of Domain\UserName and try again" -BackgroundColor Black -ForegroundColor Yellow
        Rerun
        Break
    }
    #    Checks if the domain in question is reachable, and get the domain FQDN.
    Try{
        $DomainFQDN = (Get-ADDomain $DomainNetBIOS).DNSRoot
    }
    Catch{
        Write-Host "Error: Domain was not found: " $_.Exception.Message -BackgroundColor Black -ForegroundColor Red
        Write-Host "Please make sure the domain NetBios name is correct, and is reachable from this computer" -BackgroundColor Black -ForegroundColor Red
        Rerun
        Break
    }

    #Checks user credentials against the domain
    $DomainObj = "LDAP://" + $DomainFQDN
    $DomainBind = New-Object System.DirectoryServices.DirectoryEntry($DomainObj,$UserName,$Password)
    $DomainName = $DomainBind.distinguishedName

    If ($DomainName -eq $Null)
        {
            Write-Host "Domain $DomainFQDN was found: True" -BackgroundColor Black -ForegroundColor Green

            $UserExist = Get-ADUser -Server $DomainFQDN -Properties LockedOut -Filter {sAMAccountName -eq $UserName}
            If ($UserExist -eq $Null)
                        {
                            Write-Host "Error: Username $Username does not exist in $DomainFQDN Domain." -BackgroundColor Black -ForegroundColor Red
                            Rerun
                            Break
                        }
            Else
                        {
                            Write-Host "User exists in the domain: True" -BackgroundColor Black -ForegroundColor Green


                            If ($UserExist.Enabled -eq "True")
                                    {
                                        Write-Host "User Enabled: "$UserExist.Enabled -BackgroundColor Black -ForegroundColor Green
                                    }

                            Else
                                    {
                                        Write-Host "User Enabled: "$UserExist.Enabled -BackgroundColor Black -ForegroundColor RED
                                        Write-Host "Enable the user account in Active Directory, Then check again" -BackgroundColor Black -ForegroundColor RED
                                        Rerun
                                        Break
                                    }

                            If ($UserExist.LockedOut -eq "True")
                                    {
                                        Write-Host "User Locked: " $UserExist.LockedOut -BackgroundColor Black -ForegroundColor Red
                                        Write-Host "Unlock the User Account in Active Directory, Then check again..." -BackgroundColor Black -ForegroundColor RED
                                        Rerun
                                        Break
                                    }
                            Else
                                    {
                                        Write-Host "User Locked: " $UserExist.LockedOut -BackgroundColor Black -ForegroundColor Green
                                    }
                        }

            Write-Host "Authentication failed for $DomainNetBIOS\$UserName with the provided password." -BackgroundColor Black -ForegroundColor Red
            Write-Host "Please confirm the password, and try again..." -BackgroundColor Black -ForegroundColor Red
            Rerun
            Break
        }

    Else
        {
        Write-Host "SUCCESS: The account $Username successfully authenticated against the domain: $DomainFQDN" -BackgroundColor Black -ForegroundColor Green
        $Global:DOMAIN = $DomainFQDN
        $Global:USER = $Username
        }
}

function mess_error($error_mess,$help_mess){
    Write-Host "`n## ERROR ##"$error_mess -ForegroundColor Red
    Write-Host "## HELP ## $help_mess`n" -ForegroundColor Yellow
}

#============================# ALL FUNCTION MENU #============================#

Function header($title){
  Write-Host "`nDomain : $Global:DOMAIN"
  Write-Host "User : $Global:USER`n"
  Write-Host "======================================================================"
  Write-Host "`t$title"
  Write-Host "======================================================================"
}

Function footer{
  Write-Host "======================================================================"
}


# Main menu
Function menuMain{
    $min = 1
    $max = 7
    $choice = $min
    do{
        cls #clean the screen
        if( $choice -lt $min -or $choice -gt $max){
           mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between $min and $max. Enter '$max' for help"
        }
        header("MENU PRINCIPAL")
        Write-Host "`t1 - Save the right environment"
        Write-Host "`t2 - Display the right environment"
        Write-Host "`t3 - Restoration of the right environment"
        Write-Host "`t4 - Edit an organization unity"
        Write-Host "`t5 - Change security environment"
        Write-Host "`t6 - Help"
        Write-Host "`t7 - Quit`n"
        footer

        Add_ACL

        $choice = Read-Host -Prompt "What do you want to do?"

    }while($choice -lt $min -or $choice -gt $max)
    return $choice;
}

# Backup Menu
Function menuBackup{

  $min = 0
  $max = 3
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    header("MENU : SAVE THE RIGHT ENVIRONMENT")
    Write-Host "Would you do a backup of your right environment ?"
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Yes"
    Write-Host "`t2 - No"
    Write-Host "`t3 - Help"
    footer
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 3)
  return $choice;
}

# Display right menu
Function menuDisplayRight{

  $min = 0
  $max = 2
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    header("MENU : DISPLAY THE RIGHT")
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Enter the distinguished name"
    Write-Host "`t2 - Help"
    footer
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

# Restoration menu
Function menuRestoration{

  $min = 0
  $max = 3
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    header("MENU : RESTORATATION OF THE RIGHT ENVIRONMENT")
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Restoration complete"
    Write-Host "`t2 - Restoration from a point"
    Write-Host "`t3 - Help"
    footer
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 3)
  return $choice;
}

# Edit an organization unityt manu
Function menuEdit{

  $min = 0
  $max = 3
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between $min and $max. Enter '$max' for help"
    }
    header("MENU : EDIT AN ORGANIZATION UNITY")
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Modify an ACL"
    Write-Host "`t2 - Add an ACL"
    Write-Host "`t3 - Help"
    footer
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

#============================# ALL FUNCTIONS HELP #============================#

Function helpMainMenu{

  $min = 0
  $max = 0
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter '$max' for quit "
    }
    header("HELP : MENU PRINCIPAL")
    Write-Host "1 - Save the right environment`n"
    Write-Host "`tMake a backup of all right of all Organizations Unities`n"
    Write-Host "2 - Display the right environment`n"
    Write-Host "`tDisplay all right of one Organizations Unities`n"
    Write-Host "3 - Restoration of the right environment`n"
    Write-Host "`tWith a backup, You can make a restoration"
    Write-Host "`tof total or partial`n"
    Write-Host "4 - Edit an organization unity`n"
    Write-Host "`tAdd or Modify an ACE in ACL`n"
    Write-Host "5 - Change security environment`n"
    Write-Host "`tChange the environment with which you connected"
    Write-Host "`tChange your domain name or your username `n"
    Write-Host "7 - Quit`n"
    Write-Host "`tQuit the program `n"
    footer
    $choice = Read-Host -Prompt "Enter 0 to quit "
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

Function helpBackupMenu{

  $min = 0
  $max = 0
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter '$max' for quit "
    }
    header("HELP : BACKUP")
    Write-Host "0 - Return`n"
    Write-Host "`tReturn at the main menu`n"
    Write-Host "1 - Yes`n"
    Write-Host "`tMake a backup of all right of all Organizations Unities`n"
    Write-Host "2 - No`n"
    Write-Host "`tCancel the backup`n"
    footer
    $choice = Read-Host -Prompt "Enter 0 to quit "
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

Function helpDisplayRightMenu{
  $min = 0
  $max = 0
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter '$max' for quit "
    }
    header("HELP : DISPLAY RIGHT MENU")
    Write-Host "0 - Return`n"
    Write-Host "`tReturn at the main menu`n"
    Write-Host "1 - Enter the distinguished name`n"
    Write-Host "`tEnter the distinguished name of your object"
    Write-Host "`tfor display its right`n"
    footer
    $choice = Read-Host -Prompt "Enter 0 to quit "
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

Function helpRestorationMenu{
  $min = 0
  $max = 0
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter '$max' for quit "
    }
    header("HELP : RESTORATION")
    Write-Host "0 - Return`n"
    Write-Host "`tReturn at the main menu`n"
    Write-Host "1 - Restoration complete`n"
    Write-Host "`tMake a restoration complete with an backup file`n"
    Write-Host "2 - Restoration from a point`n"
    Write-Host "`tMake a restoration partial, start at on of organization"
    Write-Host "`tunities, with an backup file`n"
    footer
    $choice = Read-Host -Prompt "Enter 0 to quit "
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}

Function helpEditMenu{
  $min = 0
  $max = 0
  $choice = $min
  do{
    cls #clean the screen
    if( $choice -lt $min -or $choice -gt $max){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter '$max' for quit "
    }
    header("HELP : EDIT MENU")
    Write-Host "0 - Return`n"
    Write-Host "`tReturn at the main menu`n"
    Write-Host "1 - Modify an ACL"
    Write-Host "`tYou can modify an ACL on an organization unities"
    Write-Host "`tChange the right or who it applies to`n"
    Write-Host "2 - Add an ACL"
    Write-Host "Create an ACL on an organization unities`n"
    footer
    $choice = Read-Host -Prompt "Enter 0 to quit "
  }while($choice -lt $min -or $choice -gt $max)
  return $choice;
}


#============================# FUNCTION BACKUP #============================#

Function backup{
  $Date = Get-Date -UFormat "%Y_%m_%d_%H_%M"
  $OutFile = "C:\Backup\Backup_$Date.csv"

  if (Test-Path $OutFile){
    Del $OutFile
  }

  if (!(Test-Path -Path "C:\Backup")){
    New-Item -ItemType Directory -Path C:\Backup
  }

  $InputDN = Read-Host -Prompt "Write the DistinguishedName of the Organisation Unit"

  Import-Module ActiveDirectory
  set-location ad:
  (Get-Acl $InputDN).access | ft identityreference, accesscontroltype, isinherited -autosize

  $Childs = Get-ChildItem $InputDN -recurse

  foreach($Child in $Childs){
    Write-Host $Child.distinguishedName
    $Header = $Child.distinguishedName
    Add-Content -Value $Header -Path $OutFile

    $Header = "IdentityReference,AccessControlType,IsInherited"
    Add-Content -Value $Header -Path $OutFile

    (Get-Acl $Child.DistinguishedName).access | ft identityreference, accesscontroltype, isinherited -autosize

    $ACLs = Get-Acl $Child.DistinguishedName | ForEach-Object {$_.access}

    Foreach ($ACL in $ACLs){
      $OutInfo = $ACL.identityreference
      if($ACL.AccessControlType -eq "Allow"){
          $OutInfo = "$OutInfo, Allow"
      }else {
        $OutInfo = "$OutInfo, Deny"
      }
      if ($ACL.IsInherited -eq "True"){
        $OutInfo = "$OutInfo, True"
      }else{
        $OutInfo = "$OutInfo, False"
      }
      Add-Content -Value $OutInfo -Path $OutFile
    }
  }
}

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




#============================# MAIN #============================#

TestUserCredentials

$again = 1
$againSubMenu = 1


do{
  switch (menuMain){
  #1 - Save the right environment
    1{
      do{
        switch(menuBackup){
        #1 - Yes
          1{
             backup
          }
        #2 - No
          2{
            $againSubMenu = 0
          }
        #3 - Help
          3{
            helpBackupMenu
          }
        #0 - Return
          default{
            $againSubMenu = 0
          }
        }
      }while($againSubMenu -eq 1)

    }
  #2 - Display the right environment
    2{
    do{
      switch(menuDisplayRight){
      #1 - Enter the distinguished name
        1{

        }
      #2 - Help
        2{
          helpDisplayRightMenu
        }
      #0 - Return
        default{
          $againSubMenu = 0
        }
      }
    }while($againSubMenu -eq 1)

    }
  #3 - Restoration of the right environment
    3{
      do{
        switch(menuRestoration){
        #1 - Restoration complete
          1{

          }
        #2 - Restoration from a point
          2{

          }
        #3 - Help
          3{
            helpRestorationMenu
          }
        #0 - Return
          default{
            $againSubMenu = 0
          }
        }
      }while($againSubMenu -eq 1)
    }
  #4 - Modify the right environment
    4{
      do{
        switch(menuEdit){
        #1 - Modify an ACL
          1{

          }
        #2 - Add an ACL
          2{
                add_acl
          }
        #3 - Help
          3{

          }
        #0 - Return
          default{
            $againSubMenu
          }
        }
      }while($againSubMenu -eq 1)

    }
  #5 - Change security environment
    5{
      TestUserCredentials
    }
  #6 - Help
    6{
      helpMainMenu
    }
  #7 - Quit
    7{
      $again = 0;
    }
    default{

    }
  }
}while($again -eq 1)


Write-Host " Good Bye $Global:USER!"
