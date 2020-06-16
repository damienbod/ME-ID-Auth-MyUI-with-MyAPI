$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"

Write-Host (az version)
Write-Host "Azure Create App Registration"


# $jsonObj = Get-Content "$(appregapi.json)" | Out-String | ConvertFrom-Json
# $data = ($bodyJSON | ConvertFrom-Json).value
# Write-Host "data: $bodyJSON"


$myApiAppRegistration = az ad app create `
	--display-name "mi-api" `
	--available-to-other-tenants false `
	--oauth2-allow-implicit-flow  false `
	--required-resource-accesses `@api_required_resources.json `
	--optional-claims `@api_optional_claims.json


Write-Host "API App Registion: $myApiAppRegistration"


$appId = ($myApiAppRegistration | ConvertFrom-Json).appId
Write-Host "created appId: $appId"
# az ad app show --id "98328d53-55ec-4f14-8407-0ca5ff2f2d20"
