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


##################################
### Assign users to Group
##################################

# az ad group member add -g "66329d69-9a75-4c46-8b4d-9982246e0041" --member-id "8458e96d-403b-49ea-ba56-76bfd32c97c0"


$tokenResponse = az account get-access-token --resource https://graph.microsoft.com
$token = ($tokenResponse | ConvertFrom-Json).accessToken
$uri = 'https://graph.microsoft.com/v1.0/applications/' + $apiAppId
$headers = @{
    "Authorization" = "Bearer $token"
}

Invoke-RestMethod -ContentType application/json -Uri $uri -Method Patch -Headers $headers -Body '{"signInAudience" : "AzureADandPersonalMicrosoftAccount"}'



#az role assignment create --assignee $groupObjectId --resource-group $apiAppId


#$app_role_name = "none"
#$appRole = $sp.AppRoles | Where-Object { $_.DisplayName -eq $app_role_name }

#New-AzureADUserAppRoleAssignment -ObjectId "66329d69-9a75-4c46-8b4d-9982246e0041" -PrincipalId "66329d69-9a75-4c46-8b4d-9982246e0041" -ResourceId "8458e96d-403b-49ea-ba56-76bfd32c97c0" -Id $appRole.Id

# Assign the user to the app role
#az role assignment create --assignee "66329d69-9a75-4c46-8b4d-9982246e0041" --resource-group "8458e96d-403b-49ea-ba56-76bfd32c97c0"


