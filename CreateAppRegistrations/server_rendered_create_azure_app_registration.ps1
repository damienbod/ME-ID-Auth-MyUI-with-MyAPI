Param( [string]$tenantId = "", [string]$inputAppIdApi = "", [string]$secretForWebApp = "" )

$replyUrlsSrUI = "https://localhost:44344/signin-oidc"
$logoutUrl = "https://localhost:44344/signout-callback-oidc"
$displayNameSrUI = "mi-server-rendered-portal"
$bodySrUI = '{
	"signInAudience" : "AzureADandPersonalMicrosoftAccount", 
	"groupMembershipClaims": "None"
}' | ConvertTo-Json | ConvertFrom-Json

$requiredResourceAccessesSrUI = '[{
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

##################################
### testParams
##################################

function testParams {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}

	if (!$inputAppIdApi) 
	{ 
		Write-Host "inputAppIdApi is null"
		exit 1
	}
	
	if (!$secretForWebApp) 
	{ 
		Write-Host "secretForWebApp is null"
		exit 1
	}
}

testParams

Write-Host "Begin ServerRendered Azure App Registration"

$appDataFromInputAppIdApi = az ad app show --id $inputAppIdApi | Out-String | ConvertFrom-Json
$appDataFromInputAppIdApiOauth2Permissions = $appDataFromInputAppIdApi.oauth2Permissions[0]

$requiredResourceAccessesSrUIData = ConvertFrom-Json $requiredResourceAccessesSrUI
# add the API values to the requiredResourceAccessesSrUIData
$requiredResourceAccessesSrUIData[1].resourceAppId = $inputAppIdApi
$requiredResourceAccessesSrUIData[1].resourceAccess[0].id = $appDataFromInputAppIdApiOauth2Permissions.id
$requiredResourceAccessesSrUINew =  $requiredResourceAccessesSrUIData | ConvertTo-Json -Depth 5
# Write-Host "$requiredResourceAccessesNew" 
 
$requiredResourceAccessesSrUINew | Out-File -FilePath .\server_rendered_required_resources.json
Write-Host " - Updated required-resource-accesses for new App Registration"

##################################
### Create Azure App Registration
##################################

$myServerRenderedAppRegistration = az ad app create `
	--display-name $displayNameSrUI `
	--available-to-other-tenants true `
	--oauth2-allow-implicit-flow  false `
	--reply-urls $replyUrlsSrUI `
	--password $secretForWebApp `
	--required-resource-accesses `@server_rendered_required_resources.json

$myServerRenderedAppRegistrationData = ($myServerRenderedAppRegistration | ConvertFrom-Json)
$myServerRenderedAppRegistrationDataAppId = $myServerRenderedAppRegistrationData.appId
Write-Host " - Created ServerRendered $displayNameSrUI with appId: $myServerRenderedAppRegistrationDataAppId"

##################################
###  add logoutUrl
##################################

az ad app update --id $myServerRenderedAppRegistrationDataAppId --set logoutUrl=$logoutUrl
Write-Host " - Updated logoutUrl"

##################################
### Add optional claims to App Registration 
##################################

az ad app update --id $myServerRenderedAppRegistrationDataAppId --optional-claims `@server_rendered_optional_claims.json
Write-Host " - Optional claims added to App Registration: $myServerRenderedAppRegistrationDataAppId"

##################################
###  Remove scopes (oauth2Permissions)
##################################

# 1. read oauth2Permissions
$oauth2PermissionsSrUI = $myServerRenderedAppRegistrationData.oauth2Permissions

# 2. set to enabled to false from the defualt scope, because we want to remove this
$oauth2PermissionsSrUI[0].isEnabled = 'false'
$oauth2PermissionsSrUI = ConvertTo-Json -InputObject @($oauth2PermissionsSrUI) 
# Write-Host "$oauth2PermissionsSrUI" 
# disable oauth2Permission in Azure App Registration
$oauth2PermissionsSrUI | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $myServerRenderedAppRegistrationDataAppId --set oauth2Permissions=`@oauth2Permissionsold.json

# 3. delete the default oauth2Permission
az ad app update --id $myServerRenderedAppRegistrationDataAppId --set oauth2Permissions='[]'
Write-Host " - Updated scopes (oauth2Permissions) for App Registration: $myServerRenderedAppRegistrationDataAppId"

##################################
###  Create a ServicePrincipal for the ServerRendered App Registration
##################################

az ad sp create --id $myServerRenderedAppRegistrationDataAppId
Write-Host " - Created Service Principal for ServerRendered App registration"


return $myServerRenderedAppRegistrationDataAppId