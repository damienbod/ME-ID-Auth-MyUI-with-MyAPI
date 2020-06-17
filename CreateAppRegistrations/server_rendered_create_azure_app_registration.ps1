$tenantId = $args[0]
$displayName = "mi-api"
$userAccessScope = '{
		"lang": null,
		"origin": "Application",		
		"adminConsentDescription": "Allow access to the API",
		"adminConsentDisplayName": "my-api-access",
		"id": "--- replaced in scripts ---",
		"isEnabled": true,
		"type": "User",
		"userConsentDescription": "Allow access to my-api access_as_user",
		"userConsentDisplayName": "Allow access to my-api",
		"value": "access_as_user"
}' | ConvertTo-Json | ConvertFrom-Json

Write-Host "Begin ServerRendered Azure App Registration"

##################################
### Create Azure App Registration
##################################

$identifier = New-Guid
$identifierUrl = "api://" + $identifier 
$myApiAppRegistration = az ad app create `
	--display-name $displayName `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--identifier-uris $identifierUrl `
	--required-resource-accesses `@api_required_resources.json 

$data = ($myApiAppRegistration | ConvertFrom-Json)
$appId = $data.appId
Write-Host " - Created ServerRendered $displayName with appId: $appId"

##################################
### Add optional claims to App Registration 
##################################

az ad app update --id $appId --optional-claims `@api_optional_claims.json
Write-Host " - Optional claims added to App Registration: $appId"

##################################
###  Add scopes (oauth2Permissions)
##################################

# 1. read oauth2Permissions
$apiApp = az ad app show --id $appId | Out-String | ConvertFrom-Json
$oauth2Permissions = $apiApp.oauth2Permissions

# 2. set to enabled to false from the defualt scope, because we want to remove this
$oauth2Permissions[0].isEnabled = 'false'
$oauth2Permissions = ConvertTo-Json -InputObject @($oauth2Permissions) 
# Write-Host "$oauth2Permissions" 
# disable oauth2Permission in Azure App Registration
$oauth2Permissions | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsold.json

# 3. delete the default oauth2Permission
az ad app update --id $appId --set oauth2Permissions='[]'

# 4. add the new scope required add the new oauth2Permissions values
$oauth2PermissionsNew += (ConvertFrom-Json -InputObject $userAccessScope)
$oauth2PermissionsNew[0].id = $identifier 
$oauth2PermissionsNew = ConvertTo-Json -InputObject @($oauth2PermissionsNew) 
# Write-Host "$oauth2PermissionsNew" 
$oauth2PermissionsNew | Out-File -FilePath .\oauth2Permissionsnew.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsnew.json
Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $appId"

##################################
###  Create a ServicePrincipal for the ServerRendered App Registration
##################################

az ad sp create --id $appId
Write-Host " - Created Service Principal for ServerRendered App registration"

return $appId