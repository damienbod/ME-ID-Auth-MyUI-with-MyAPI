$tenantId = $args[0]
$appIdApi = $args[1]
$secretForPortal = $args[2]
$replyUrls = "https://localhost:44344/signin-oidc"
$logoutUrl = "https://localhost:44344/signout-callback-oidc"
$displayName = "mi-server-rendered-portal"
$requiredResourceAccesses = '[{
	"resourceAppId": "00000003-0000-0000-c000-000000000000",
	"resourceAccess": [
		{
			"id": "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0",
			"type": "Scope"
		},
		{
			"id": "7427e0e9-2fba-42fe-b0c0-848c9e6a8182",
			"type": "Scope"
		},
		{
			"id": "37f7f235-527c-4136-accd-4a02d197296e",
			"type": "Scope"
		},
		{
			"id": "14dad69e-099b-42c9-810b-d002981feec1",
			"type": "Scope"
		},
		{
			"id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
			"type": "Scope"
		}
	]
},
{
	"resourceAppId": "-- replace --",
	"resourceAccess": [
		{
			"id": "-- replace --",
			"type": "Scope"
		}
	]
}]' | ConvertTo-Json | ConvertFrom-Json

Write-Host "Begin ServerRendered Azure App Registration"

$apiApp = az ad app show --id $appIdApi | Out-String | ConvertFrom-Json
$oauth2Permissions = $apiApp.oauth2Permissions[0]

$data = ConvertFrom-Json $requiredResourceAccesses
# add the API values to the data
$data[1].resourceAppId = $appIdApi
$data[1].resourceAccess[0].id = $oauth2Permissions.id
$requiredResourceAccessesNew =  $data | ConvertTo-Json -Depth 5
# Write-Host "$requiredResourceAccessesNew" 
 
$requiredResourceAccessesNew | Out-File -FilePath .\server_rendered_required_resources.json
Write-Host " - Updated required-resource-accesses for new App Registration"

##################################
### Create Azure App Registration
##################################

$myServerRenderedAppRegistration = az ad app create `
	--display-name $displayName `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--reply-urls $replyUrls `
	--password $secretForPortal `
	--required-resource-accesses `@server_rendered_required_resources.json

$data = ($myServerRenderedAppRegistration | ConvertFrom-Json)
$appId = $data.appId
Write-Host " - Created ServerRendered $displayName with appId: $appId"

##################################
### Add optional claims to App Registration 
##################################

az ad app update --id $appId --optional-claims `@server_rendered_optional_claims.json
Write-Host " - Optional claims added to App Registration: $appId"

##################################
###  Remove scopes (oauth2Permissions)
##################################

# 1. read oauth2Permissions
$srApp = az ad app show --id $appId | Out-String | ConvertFrom-Json
$oauth2Permissions = $srApp.oauth2Permissions

# 2. set to enabled to false from the defualt scope, because we want to remove this
$oauth2Permissions[0].isEnabled = 'false'
$oauth2Permissions = ConvertTo-Json -InputObject @($oauth2Permissions) 
# Write-Host "$oauth2Permissions" 
# disable oauth2Permission in Azure App Registration
$oauth2Permissions | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsold.json

# 3. delete the default oauth2Permission
az ad app update --id $appId --set oauth2Permissions='[]'
Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $appId"

##################################
###  add logoutUrl
##################################

az ad app update --id $appId --set logoutUrl=$logoutUrl
Write-Host " - Updated logoutUrl"

##################################
###  Create a ServicePrincipal for the ServerRendered App Registration
##################################

az ad sp create --id $appId
Write-Host " - Created Service Principal for ServerRendered App registration"

##################################
### Set signInAudience to AzureADandPersonalMicrosoftAccount
##################################

# https://docs.microsoft.com/en-us/graph/api/application-update
$tokenResponse = az account get-access-token --resource https://graph.microsoft.com
$token = ($tokenResponse | ConvertFrom-Json).accessToken
# Write-Host "$token"
$uri = 'https://graph.microsoft.com/v1.0/applications/' + $appId.id
Write-Host " - $uri"
$headers = @{
    "Authorization" = "Bearer $token"
}
Invoke-RestMethod -ContentType application/json -Uri $uri -Method Patch -Headers $headers -Body '{"signInAudience" : "AzureADandPersonalMicrosoftAccount"}'
Write-Host " - Updated signInAudience to AzureADandPersonalMicrosoftAccount"


return $appId