 #Allow the script execution
Set-ExecutionPolicy Unrestricted

 #Import Active Directory Module
 Import-Module Activedirectory


#Variable Global
$Global:DOMAIN = $null
$Global:USER = $null



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
    $Cred = Get-Credential -Message "Enter Your Credentials (Domain\Username)"
    if ($Cred -eq $Null){
        Write-Host "Please enter your username in the form of Domain\UserName and try again" -BackgroundColor Black -ForegroundColor Yellow
        Rerun
        Break
    }

    #Parse provided user credentials
    $DomainNetBIOS = $Cred.username.Split("{\}")[0]
    $UserName = $Cred.username.Split("{\}")[1]
    $Password = $Cred.GetNetworkCredential().password

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

#MAIN Menu
Function menuMain{

    $choice = 1
    do{
        cls #clean the screen
        if( $choice -lt 1 -or $choice -gt 7){
           mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 1 and 7. Enter '6' for help"
        }
        Write-Host "`nDomain : $Global:DOMAIN"
        Write-Host "User : $Global:USER`n"
        Write-Host "============================================="
        Write-Host "                  MENU"
        Write-Host "=============================================`n"
        Write-Host "`t1 - Save the right environment"
        Write-Host "`t2 - Display the right environment"
        Write-Host "`t3 - Restoration of the right environment"
        Write-Host "`t4 - Modify the right environment"
        Write-Host "`t5 - Change security environment"
        Write-Host "`t6 - Help"
        Write-Host "`t7 - Quit`n"
        Write-Host "============================================="

        $choice = Read-Host -Prompt "What do you want to do?"

    }while($choice -lt 1 -or $choice -gt 7)
    return $choice;
}

Function menuBackup{
  $choice = 0
  do{
    cls #clean the screen
    if( $choice -lt 0 -or $choice -gt 3){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    Write-Host "`nDomain : $Global:DOMAIN"
    Write-Host "User : $Global:USER`n"
    Write-Host "============================================="
    Write-Host "         SAVE THE RIGHT ENVIRONMENT"
    Write-Host "=============================================`n"
    Write-Host "Would you do a backup of your right environment ?"
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Yes"
    Write-Host "`t2 - No"
    Write-Host "`t3 - Help"
    Write-Host "============================================="
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 3)
  return $choice;
}

Function menuDisplayRight{
  $choice = 1
  do{
    cls #clean the screen
    if( $choice -lt 0 -or $choice -gt 2){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    Write-Host "`nDomain : $Global:DOMAIN"
    Write-Host "User : $Global:USER`n"
    Write-Host "============================================="
    Write-Host "              DISPLAY THE RIGHT"
    Write-Host "=============================================`n"
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Enter the distinguished name"
    Write-Host "`t2 - Help"
    Write-Host "============================================="
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 3)
  return $choice;
}

Function menuRestoration{
  $choice = 1
  do{
    cls #clean the screen
    if( $choice -lt 0 -or $choice -gt 3){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    Write-Host "`nDomain : $Global:DOMAIN"
    Write-Host "User : $Global:USER`n"
    Write-Host "============================================="
    Write-Host "   RESTORATATION OF THE RIGHT ENVIRONMENT"
    Write-Host "=============================================`n"
    Write-Host "`t0 - Return"
    Write-Host "`t1 - Restoration complete"
    Write-Host "`t2 - Restoration from a point"
    Write-Host "`t3 - Help"
    Write-Host "============================================="
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 3)
  return $choice;
}

Function menuModifyRight{
  $choice = 1
  do{
    cls #clean the screen
    if( $choice -lt 0 -or $choice -gt 6){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    Write-Host "`nDomain : $Global:DOMAIN"
    Write-Host "User : $Global:USER`n"
    Write-Host "============================================="
    Write-Host "                  MO"
    Write-Host "=============================================`n"
    Write-Host "`t0 - Return"
    Write-Host "============================================="
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 0 -or $choice -gt 6)
  return $choice;
}

Function help{
  $choice = 1
  do{
    cls #clean the screen
    if( $choice -lt 1 -or $choice -gt 6){
       mess_error -error_mess "You enter a wrong value ($choice)" -help_mess "Please enter a value between 0 and 3. Enter '3' for help"
    }
    Write-Host "`nDomain : $Global:DOMAIN"
    Write-Host "User : $Global:USER`n"
    Write-Host "============================================="
    Write-Host "                  MENU"
    Write-Host "=============================================`n"
    Write-Host "============================================="
    $choice = Read-Host -Prompt "What do you want to do?"
  }while($choice -lt 1 -or $choice -gt 6)
  return $choice;
}



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


       if ($ACL.AccessControlType -eq "Allow"){
            $OutInfo = "$OutInfo, Allow"

        } else {
            $OutInfo = "$OutInfo, Deny"
        }


        if ($ACL.IsInherited -eq "True"){
            $OutInfo = "$OutInfo, True"

        } else {
            $OutInfo = "$OutInfo, False"
        }
        


	    Add-Content -Value $OutInfo -Path $OutFile
	}

    
}



}

Function Get-ADSIOU
{
    # Renvoie toutes les OU du domaine courrant
    $objDomain = [ADSI]''
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher($objDomain)
    $objSearcher.Filter = '(objectCategory=organizationalUnit)'

    $OU = $objSearcher.FindAll() | Select-object -ExpandProperty Path
    
    $OU
}

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
        write-host $i.Path
        if([boolean]( $i.Path.memberof  -match ($Groupes -join '|')) )
        {
            echo "Ce groupe fais partie des Administrateurs"
        }
        
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

function add_acl{


echo "Welcome in this function tester"
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

$input = Read-Host -prompt "write to Ou name affected"

#$input = Read-Host -prompt "write to Ou name affected"
#master

$right = 13
while($right -gt 6 -and $right -lt 0)
{
    echo "What kind of right do you want to set"
    echo "1- Modify"
    echo "2- Read and write"
    echo "3- Read and execute"
    echo "4- Write"
    echo "5- Full control"
    $right=Read-Host ">>> "

    if($right -eq 1)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Modify" 
    }
    elseif($right -eq 2)
    {        
        $colRights = [System.Security.AccessControl.FileSystemRights]"Write, Read" 
    }
    elseif($right -eq 3)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"ReadAndExecute" 
    }
    elseif($right -eq 4)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Write" 
    }
    elseif($right -eq 5)
    {
        $colRights = [System.Security.AccessControl.FileSystemRights]"Fullcontrol" 
    }
}

$inheritance = 13
while($inheritance -gt 4 -and $inheritance -lt 0)
{
    echo "Set the inheritance"
    echo "1- ACE inherited by child container"
    echo "2- ACE inherited by child objects like files"
    echo "3- No inheritance"
    $inheritance=Read-Host ">>> "

    if($inheritance -eq 1)
    {
        $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
    }
    elseif($inheritance -eq 2)
    { 
        $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit 
    }
    elseif($inheritance -eq 3)
    {
        $InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::None 
    }
}

$propagation = 13
while($propagation -gt 4 -and $propagation -lt 0)
{
    echo "Set the propagation"
    echo "1- ACE propagated to child objects that already exist"
    echo "2- ACE not propagated to child objects that already exist"
    echo "3- No inheritance"
    $propagation=Read-Host ">>> "

    if($propagation -eq 1)
    {
        $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly 
    }
    elseif($propagation -eq 2)
    { 
        $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit
    }
    elseif($propagation -eq 3)
    {
        $PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None  
    }
}

$type = 13
while($type -gt 3 -and $type -lt 0)
{
    echo "Set the ACE type"
    echo "1- Allow"
    echo "2- Deny"
    $type=Read-Host ">>> "

    if($type -eq 1)
    {
        $objType =[System.Security.AccessControl.AccessControlType]::Allow 
    }
    elseif($type -eq 2)
    { 
       $objType =[System.Security.AccessControl.AccessControlType]::Deny
    }
}

$concat = "$Global:DOMAIN\$Global:user"


$objUser = New-Object System.Security.Principal.NTAccount("Winserv0\Administrateur") 



}







TestUserCredentials

$again = 1

do{
  switch (menuMain){
  #1 - Save the right environment
    1{
      switch(menuBackup){
      #1 - Yes
        1{
          backup
        }
      #2 - No
        2{

        }
      #3 - Help
        3{

        }
      #0 - Return
        default{}
      }
    }
  #2 - Display the right environment
    2{
      switch(menuDisplayRight){
      #1 - Enter the distinguished name
        1{

        }
      #2 - Help
        2{

        }
      #0 - Return
        default{}
      }
    }
  #3 - Restoration of the right environment
    3{
      switch(menuRestoration){
      #1 - Restoration complete
        1{

        }
      #2 - Restoration from a point
        2{

        }
      #3 - Help
        3{

        }
      #0 - Return
        default{}
      }
    }
  #4 - Modify the right environment
    4{

    }
  #5 - Change security environment
    5{
        TestUserCredentials
    }
  #6 - Help
    6{

    }
  #7 - Quit
    7{
      $again = 0;
    }
    default{

    }
  }
}while($again -eq 1)


Write-Host " Good Bye !"
