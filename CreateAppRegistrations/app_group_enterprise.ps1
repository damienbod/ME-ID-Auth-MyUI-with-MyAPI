$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
$apiAppId = "8458e96d-403b-49ea-ba56-76bfd32c97c0"
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
Write-Host "Created new group objectId: $groupObjectId"
	
##################################
### Only allowed defined users, groups use the app
##################################

az ad sp update --id $apiAppId --set appRoleAssignmentRequired=true


