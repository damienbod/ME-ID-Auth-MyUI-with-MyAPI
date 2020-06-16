$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
$identifier = New-Guid
$identifierUrl = "api://" + $identifier 

Write-Host "created identifierUrl: $identifierUrl"
Write-Host (az version)
Write-Host "Azure Create App Registration"

$myApiAppRegistration = az ad app create `
	--display-name "mi-api" `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--identifier-uris $identifierUrl `
	--required-resource-accesses `@api_required_resources.json 

$data = ($myApiAppRegistration | ConvertFrom-Json)
$appId = $data.appId

Write-Host "created appId: $appId"

az ad app update --id $appId --optional-claims `@api_optional_claims.json

# TODO 
# 1. read oauth2Permissions
# 2. set to enabled to false
# 3. add the new oauth2Permissions values
# 4. az ad app update --id $appId --set oauth2Permissions=@api_scopes.json

# Write-Host "disable scopes"
# disable default exposed scope
# $data.oauth2Permissions[0].isEnabled = false
# $DEFAULT_SCOPE = $(az ad app show --id $appId | jq '.oauth2Permissions[0].isEnabled = false' | jq -r '.oauth2Permissions')

# az ad app update --id $appId --set oauth2Permissions=$data.oauth2Permissions

# set needed scopes from file 'oath2-permissions'
# az ad app update --id $appId --set oauth2Permissions=@api_scopes.json

# create a ServicePrincipal for the API
az ad sp create --id $appId

# az ad app update --id $appId --set oauth2Permissions=`@api_scopes.json

# az ad app update --id $appId --set groupMembershipClaims="None"
# az ad app update --id $appId --set signInAudience="AzureADandPersonalMicrosoftAccount"

az ad app show --id $appId
