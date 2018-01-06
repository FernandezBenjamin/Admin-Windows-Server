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
