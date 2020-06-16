$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
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


Write-Host "created identifierUrl: $identifierUrl"
# Write-Host (az version)
Write-Host "Azure Create API App Registration"

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

Write-Host "created API $displayName with appId: $appId"

az ad app update --id $appId --optional-claims `@api_optional_claims.json

###  Add scopes
# 1. read oauth2Permissions
$apiApp = az ad app show --id $appId | Out-String | ConvertFrom-Json
$oauth2Permissions = $apiApp.oauth2Permissions

# 2. set to enabled to false
$oauth2Permissions[0].isEnabled = 'false'
$oauth2Permissions = ConvertTo-Json -InputObject @($oauth2Permissions) 

#Write-Host "- oauth2Permissions -----------"
#Write-Host "$oauth2Permissions" 

# 3. disable
$oauth2Permissions | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsold.json

# 4. delete
az ad app update --id $appId --set oauth2Permissions='[]'

# 5. add new scope add the new oauth2Permissions values
$oauth2PermissionsNew += (ConvertFrom-Json -InputObject $userAccessScope)
$oauth2PermissionsNew[0].id = $identifier 
$oauth2PermissionsNew = ConvertTo-Json -InputObject @($oauth2PermissionsNew) 

#Write-Host "- oauth2PermissionsNew --------"
#Write-Host "$oauth2PermissionsNew" 

$oauth2PermissionsNew | Out-File -FilePath .\oauth2Permissionsnew.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsnew.json

# create a ServicePrincipal for the API
az ad sp create --id $appId

### Finished adding scopes
# az ad app show --id $appId

return $appId