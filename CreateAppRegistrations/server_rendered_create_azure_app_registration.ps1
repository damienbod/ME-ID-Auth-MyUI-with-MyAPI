$tenantId = $args[0]
$appIdapp = $args[1]
$displayName = "mi-server-rendered-portal"
$requiredResourceAccesses = '[
	{
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
	}
]' | ConvertTo-Json | ConvertFrom-Json

Write-Host "Begin ServerRendered Azure App Registration"

# add the API values to the data
$requiredResourceAccesses[1].resourceAppId = $identifier 
$requiredResourceAccesses[1].resourceAccess[0].id = $identifier 
$requiredResourceAccessesNew = ConvertTo-Json -InputObject @($requiredResourceAccesses) 
Write-Host "$requiredResourceAccessesNew" 
$requiredResourceAccessesNew | Out-File -FilePath .\server_rendered_required_resources.json
Write-Host " - Updated required-resource-accesses  for new App Registration"

##################################
### Create Azure App Registration
##################################

#$identifier = New-Guid
#$identifierUrl = "api://" + $identifier 

$myApiAppRegistration = az ad app create `
	--display-name $displayName `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--required-resource-accesses `@server_rendered_required_resources.json

$data = ($myApiAppRegistration | ConvertFrom-Json)
$appId = $data.appId
Write-Host " - Created ServerRendered $displayName with appId: $appId"

##################################
### Add optional claims to App Registration 
##################################

az ad app update --id $appId --optional-claims `@api_optional_claims.json
Write-Host " - Optional claims added to App Registration: $appId"

##################################
###  Create a ServicePrincipal for the ServerRendered App Registration
##################################

az ad sp create --id $appId
Write-Host " - Created Service Principal for ServerRendered App registration"

return $appId