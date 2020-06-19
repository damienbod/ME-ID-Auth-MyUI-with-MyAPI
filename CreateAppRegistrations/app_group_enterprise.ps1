Param( [string]$tenantId = "", [string]$apiAppId = "" )
$groupName = "miapigroup"

function testParams {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}

	if (!$apiAppId) 
	{ 
		Write-Host "apiAppId is null"
		exit 1
	}
}

testParams

Write-Host "Creating group and updating App Registration: $apiAppId"

##################################
### Create group
##################################

Write-Host " - Create new group"
$group = az ad group create `
	--display-name $groupName `
	--mail-nickname $groupName `

#Write-Host "$group" 
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

# NOT possible, you need to do this per Portal UI ...

#az ad group list --display-name $groupName
#az role assignment create --assignee $groupObjectId --resourceId $apiAppId --role "00000000-0000-0000-0000-000000000000"

return $groupName
