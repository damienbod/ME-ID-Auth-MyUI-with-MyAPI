Param( [string]$tenantId = "", [string]$secretForWebApp = "" )

function testParams {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}

	if (!$secretForWebApp) 
	{ 
		Write-Host "secretForWebApp is null"
		$secretForWebApp = New-Guid
	}
}

function testSubscription {
    $account = az account show | ConvertFrom-Json
	$accountTenantId = $account.tenantId
    if ($accountTenantId -ne $tenantId) 
	{ 
		Write-Host "$accountTenantId not possible, change account"
		exit 1
	}
	$accountName = $account.name
    Write-Host "$accountName can update"
}

testParams
testSubscription

Write-Host "tenantId $tenantId"
Write-Host "secretForWebApp $secretForWebApp"
Write-Host "-----------"
Write-Host (az version)
Write-Host "-----------"

# Create API App Registration
$appIdApi = &".\api_create_azure_app_registration.ps1" $tenantId | select -Last 1
Write-Host "Created Api App registraion: $appIdApi"

# Create Server Rendered App Registration
$appIdServerRenderedUI = &".\server_rendered_create_azure_app_registration.ps1" $tenantId $appIdApi $secretForWebApp | select -Last 1
Write-Host "Created Server Rendered App registraion: $appIdServerRenderedUI"
