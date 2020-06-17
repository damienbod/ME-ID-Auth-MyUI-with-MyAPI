$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"

# Write-Host (az version)

$appIdApi = &".\CreateApiAzureAppRegistration.ps1" $tenantId | select -Last 1
Write-Host "Created Api App registraion: $appIdApi"

##################################
###  Create a ServicePrincipal for the API
##################################

az ad sp create --id $appIdApi
Write-Host "Created Service Principal"