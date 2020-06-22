##################################
### Set signInAudience to AzureADandPersonalMicrosoftAccount
##################################

# https://docs.microsoft.com/en-us/graph/api/application-update
$idAppForGraphApi = $myApiAppRegistrationResult.objectId
#Write-Host " - id = apiApp.objectId: $idAppForGraphApi"
$tokenResponseApi = az account get-access-token --resource https://graph.microsoft.com
$tokenApi = ($tokenResponseApi | ConvertFrom-Json).accessToken
#Write-Host "$token"
$uriApi = 'https://graph.microsoft.com/v1.0/applications/' + $idAppForGraphApi
Write-Host " - $uriApi"
$headersApi = @{
    "Authorization" = "Bearer $tokenApi"
}

Invoke-RestMethod  `
	-ContentType application/json `
	-Uri $uriApi `
	-Method Patch `
	-Headers $headersApi `
	-Body $bodyApi

Write-Host " - Updated signInAudience to AzureADandPersonalMicrosoftAccount"
Write-Host " - Updated groupMembershipClaims to None"



##################################
### Set signInAudience to AzureADandPersonalMicrosoftAccount
##################################

# https://docs.microsoft.com/en-us/graph/api/application-update
$myServerRenderedAppRegistrationDataObjectId = $myServerRenderedAppRegistrationData.objectId
Write-Host " - id = srApp.objectId: $myServerRenderedAppRegistrationDataObjectId"
$tokenResponseSrUI = az account get-access-token --resource https://graph.microsoft.com
$tokenSrUI = ($tokenResponseSrUI | ConvertFrom-Json).accessToken
#Write-Host "$tokenSrUI"
$uriSrUI = 'https://graph.microsoft.com/v1.0/applications/' + $myServerRenderedAppRegistrationDataObjectId
Write-Host " - $uriSrUI"
$headersSrUI = @{
    "Authorization" = "Bearer $tokenSrUI"
}

Invoke-RestMethod `
	-ContentType application/json `
	-Uri $uriSrUI `
	-Method Patch `
	-Headers $headersSrUI `
	-Body $bodySrUI
	
Write-Host " - Updated signInAudience to AzureADandPersonalMicrosoftAccount"
Write-Host " - Updated groupMembershipClaims to None"