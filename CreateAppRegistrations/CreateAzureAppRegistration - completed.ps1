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
	
$appId = ($myApiAppRegistration | ConvertFrom-Json).appId
Write-Host "created appId: $appId"

az ad app update --id $appId --set accessTokenAcceptedVersion=2


az ad app update --id $appId --optional-claims `@api_optional_claims.json
az ad app update --id $appId --set oauth2Permissions=`@api_scopes.json

# az ad app update --id $appId --set groupMembershipClaims="None"
# az ad app update --id $appId --set signInAudience="AzureADandPersonalMicrosoftAccount"

az ad app show --id $appId
