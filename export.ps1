$Date = Get-Date -UFormat "%Y_%m_%d"

$OutFile = "C:\Backup_$Date.csv"
Del $OutFile



$InputDN = Read-Host -Prompt "Write the DistinguishedName of the Organisation Unit"

Import-Module ActiveDirectory
set-location ad:

(Get-Acl $InputDN).access | ft identityreference, accesscontroltype, isinherited -autosize



$Childs = Get-ChildItem $InputDN -recurse


foreach($Child in $Childs){


    Write-Host $Child.distinguishedName
    
    $Header = "DistinguishedName, " + $Child.distinguishedName
    
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
