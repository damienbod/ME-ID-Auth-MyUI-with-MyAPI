$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"
$identifier = New-Guid


Write-Host "Update App Registration oauth2Permissions items"

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
}'

$appId = "f3333952-e0fb-44d9-a8c9-58b17eead48b"
# 1. read oauth2Permissions
$apiApp = az ad app show --id $appId | Out-String | ConvertFrom-Json
$oauth2Permissions = $apiApp.oauth2Permissions
# 2. set to enabled to false
$oauth2Permissions[0].isEnabled = 'false'
# $oauth2Permissions[0] | add-member -Name "lang" -value '' -MemberType NoteProperty
# $oauth2Permissions[0] | add-member -Name "origin" -value 'Application' -MemberType NoteProperty

# 3. add the new oauth2Permissions values
$oauth2Permissions += (ConvertFrom-Json -InputObject ($userAccessScope | ConvertTo-Json | ConvertFrom-Json))
$oauth2Permissions[1].id = $identifier
$oauth2Permissions = ConvertTo-Json -InputObject @($oauth2Permissions)

$hh = ($oauth2Permissions | Out-String | ConvertFrom-Json)

Write-Host "--------------------------------"
Write-Host "$appId"
Write-Host "--------------------------------"
Write-Host "$oauth2Permissions" 
Write-Host "--------------------------------"

# 4. az ad app update --id $appId --set oauth2Permissions=@api_scopes.json
az ad app update --id $appId --set oauth2Permissions='[]'


# az ad app update --id $appId --set oauth2Permissions=`@api_scopes.json

