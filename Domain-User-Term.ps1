# Input of username.
$Term = Read-Host "Please enter username which will be modified"
# See if there is an active user.
$Term = get-aduser -filter {SamAccountName -like $Term} | Where-Object Enabled -EQ $true
# If/Else for AD lookup failure.
if ($null -ne $Term){
Write-Host $term.name 'has been found. If this is not the correct user, exit the script (CTRL-C)'
# Pull each of the groups the user is a member of.
$principal = Get-ADPrincipalGroupMembership $term | Where-Object {$_.name -ne "Domain Users"}
$creds = Get-Credential -message "Please enter ADMIN credentials authorized to do this work"
foreach ($group in $principal) {
    Remove-ADGroupMember -Identity $group -Members $Term -Credential $creds -Confirm:$false
    Write-Host $group.Name "has been removed from" $term.Name
}
# Change the user to disabled and set the description.
Set-ADUser $Term -Enabled $false -Verbose -Description "Termination Script" -Manager $null
# Accidental deletion can prevent moving as well - removing...
Set-ADObject $Term -ProtectedFromAccidentalDeletion:$false
# Put them in the OU.
########Move-ADObject -Identity $Term.DistinguishedName -TargetPath "OU=$OU,DC=$fill,DC=com" -Verbose
} Else {
    Write-Host "No active user found"
}