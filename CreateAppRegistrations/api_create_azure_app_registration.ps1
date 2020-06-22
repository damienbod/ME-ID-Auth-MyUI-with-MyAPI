Param( [string]$tenantId = "" )
$displayNameApi = "mi-api"
$bodyApi = '{
	"signInAudience" : "AzureADandPersonalMicrosoftAccount", 
	"groupMembershipClaims": "None"
}' | ConvertTo-Json | ConvertFrom-Json
$userAccessScopeApi = '{
		"lang": null,
		"origin": "Application",		
		"adminConsentDescription": "Allow access to the API",
		"adminConsentDisplayName": "mi-api-access",
		"id": "--- replaced in scripts ---",
		"isEnabled": true,
		"type": "User",
		"userConsentDescription": "Allow access to mi-api access_as_user",
		"userConsentDisplayName": "Allow access to mi-api",
		"value": "access_as_user"
}' | ConvertTo-Json | ConvertFrom-Json

##################################
### testParams
##################################

function testParams {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}
}

testParams

Write-Host "Begin API Azure App Registration"

##################################
### Create Azure App Registration
##################################

$identifierApi = New-Guid
$identifierUrlApi = "api://" + $identifierApi
$myApiAppRegistration = az ad app create `
	--display-name $displayNameApi `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--identifier-uris $identifierUrlApi `
	--required-resource-accesses `@api_required_resources.json 

$myApiAppRegistrationResult = ($myApiAppRegistration | ConvertFrom-Json)
$myApiAppRegistrationResultAppId = $myApiAppRegistrationResult.appId
Write-Host " - Created API $displayNameApi with myApiAppRegistrationResultAppId: $myApiAppRegistrationResultAppId"

##################################
### Add optional claims to App Registration 
##################################

az ad app update --id $myApiAppRegistrationResultAppId --optional-claims `@api_optional_claims.json
Write-Host " - Optional claims added to App Registration: $myApiAppRegistrationResultAppId"

##################################
###  Add scopes (oauth2Permissions)
##################################

# 1. read oauth2Permissions
$oauth2PermissionsApi = $myApiAppRegistrationResult.oauth2Permissions

# 2. set to enabled to false from the defualt scope, because we want to remove this
$oauth2PermissionsApi[0].isEnabled = 'false'
$oauth2PermissionsApi = ConvertTo-Json -InputObject @($oauth2PermissionsApi) 
# Write-Host "$oauth2PermissionsApi" 
# disable oauth2Permission in Azure App Registration
$oauth2PermissionsApi | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=`@oauth2Permissionsold.json

# 3. delete the default oauth2Permission
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions='[]'

# 4. add the new scope required add the new oauth2Permissions values
$oauth2PermissionsApiNew += (ConvertFrom-Json -InputObject $userAccessScopeApi)
$oauth2PermissionsApiNew[0].id = $identifierApi
$oauth2PermissionsApiNew = ConvertTo-Json -InputObject @($oauth2PermissionsApiNew) 
# Write-Host "$oauth2PermissionsApiNew" 
$oauth2PermissionsApiNew | Out-File -FilePath .\oauth2Permissionsnew.json
az ad app update --id $myApiAppRegistrationResultAppId --set oauth2Permissions=`@oauth2Permissionsnew.json
Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $myApiAppRegistrationResultAppId"

##################################
###  Create a ServicePrincipal for the API App Registration
##################################

az ad sp create --id $myApiAppRegistrationResultAppId | Out-String | ConvertFrom-Json
Write-Host " - Created Service Principal for API App registration"

return $myApiAppRegistrationResultAppId