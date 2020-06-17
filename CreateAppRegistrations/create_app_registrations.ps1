$tenantId = "7ff95b15-dc21-4ba6-bc92-824856578fc1"

# Write-Host (az version)

$appIdApi = &".\api_create_azure_app_registration.ps1" $tenantId | select -Last 1
Write-Host "Created Api App registraion: $appIdApi"

$appIdServerRenderedUI = &".\server_rendered_create_azure_app_registration.ps1" $tenantId $appIdApi | select -Last 1
Write-Host "Created Server Rendered App registraion: $appIdServerRenderedUI"
