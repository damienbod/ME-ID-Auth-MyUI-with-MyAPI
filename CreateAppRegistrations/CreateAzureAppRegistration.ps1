$tenantId: "7ff95b15-dc21-4ba6-bc92-824856578fc1"


Write-Host "Azure Create App Registration"

az webapp config appsettings set `
    --resource-group $resourceGroup `
    --name $appServiceName `
    --output none `
    --settings `
	AzureKeyVaultEndpoint="https://damienbod.vault.azure.net" 
