$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
$apiAppId = "33836dc5-762b-4eb2-beb1-758d9371d78d"
$apiId = "024cd9e5-fda3-43ab-a5d0-2a28f098bacf"
$groupName = "miapigroup"
$identifier = New-Guid


Write-Host "Updating App Registration: $apiAppId"

##################################
### Create group
##################################

Write-Host "Create new group"
$group = az ad group create `
	--display-name $groupName `
	--mail-nickname $groupName `

Write-Host "$group" 
$groupObjectId = ($group | ConvertFrom-Json).objectId
Write-Host " - Created new group objectId: $groupObjectId"
	
##################################
### Only allowed defined users, groups use the app
##################################

az ad sp update --id $apiAppId --set appRoleAssignmentRequired=true
Write-Host " - Set user assigned true to APP registration"
#az ad sp show --id $apiAppId

##################################
### Assign group to App Registration
##################################

#az ad group list --display-name $groupName

#az role assignment create --assignee $groupObjectId --resourceId $apiAppId --role "00000000-0000-0000-0000-000000000000"


