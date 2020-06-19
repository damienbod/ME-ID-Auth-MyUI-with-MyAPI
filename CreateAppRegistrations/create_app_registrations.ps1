Param( [string]$tenantId = "", [string]$secretForWebApp = "" )

function testParams() {

	if (!$tenantId) 
	{ 
		Write-Host "tenantId is null"
		exit 1
	}

	if (!$secretForWebApp) 
	{ 
		Write-Host "secretForWebApp is not defined, creating one"
		$secretForWebApp = New-Guid
	}
	return $secretForWebApp
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
    Write-Host "tenant: $accountName can update"
}

$secretForWebApp = testParams
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

# Create Group and Update Azure AD Enterprise APP for the API App Registration 
$groupName = &".\app_group_enterprise.ps1" $tenantId $appIdApi  | select -Last 1
Write-Host "Created Group and updated Azure AD Enterprise APP for the API App Registration, groupName: $groupName"

Write-Host "Add the $groupName group to the App Registration and add users"
