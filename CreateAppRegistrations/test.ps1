$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
$identifier = New-Guid
$appId = "3c73514c-ee32-4535-a926-2493a99e4479"

Write-Host "Update App Registration oauth2Permissions items"
Write-Host "- appId -----------------------"
Write-Host "$appId"

# 1. read oauth2Permissions
$apiApp = az ad app show --id $appId | Out-String | ConvertFrom-Json
$oauth2Permissions = $apiApp.oauth2Permissions

# 2. set to enabled to false
$oauth2Permissions[0].isEnabled = 'false'
# $oauth2Permissions[0] | add-member -Name "lang" -value '' -MemberType NoteProperty
# $oauth2Permissions[0] | add-member -Name "origin" -value 'Application' -MemberType NoteProperty
$oauth2Permissions = ConvertTo-Json -InputObject @($oauth2Permissions) 

Write-Host "- oauth2Permissions -----------"
Write-Host "$oauth2Permissions" 

# 3. disable
$oauth2Permissions | Out-File -FilePath .\oauth2Permissionsold.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsold.json

# 4. delete
az ad app update --id $appId --set oauth2Permissions='[]'

# 5. add new scope add the new oauth2Permissions values

$userAccessScope = '{
		"lang": null,
		"origin": "Application",		
		"adminConsentDescription": "Allow access to the API",
		"adminConsentDisplayName": "my-api-access",
		"id": "--- to replace ---",
		"isEnabled": true,
		"type": "User",
		"userConsentDescription": "Allow access to my-api access_as_user",
		"userConsentDisplayName": "Allow access to my-api",
		"value": "access_as_user"
}' | ConvertTo-Json | ConvertFrom-Json

$oauth2PermissionsNew += (ConvertFrom-Json -InputObject $userAccessScope)
$oauth2PermissionsNew[0].id = $identifier 
$oauth2PermissionsNew = ConvertTo-Json -InputObject @($oauth2PermissionsNew) 

Write-Host "- oauth2PermissionsNew --------"
Write-Host "$oauth2PermissionsNew" 

$oauth2PermissionsNew | Out-File -FilePath .\oauth2Permissionsnew.json
az ad app update --id $appId --set oauth2Permissions=`@oauth2Permissionsnew.json

