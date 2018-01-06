$input = Read-Host -prompt "write to Ou name affected"

$allowance = Read-Host -Prompt "Deny / Allow "


$Ou = New-ADOrganizationalUnit -name $input -PassThru
$Acl = get-acl $Ou

## Note that bf967a86-0de6-11d0-a285-00aa003049e2 is the schemaIDGuid for the computer class.
# bf967aba-0de6-11d0-a285-00aa003049e2 is the schemaIDGuid for the user class.
#The following object specific ACE is to grant $Ou permission to create computer objects under $Ou.
 $computer_class_guid = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
 $user_class_guid = new-object Guid  00299570-246d-11d0-a768-00aa006e0529

 $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $Ou,"CreateChild","Allow",$computer_class_guid

 $acl.AddAccessRule(($ace1)
Set-acl -Path -AclObject $acl $Ou