# Destination image resource group name
$imageResourceGroup = 'DevOps-RG'

# Azure region
$location = 'usgovvirginia'

# Name of the image to be created
$imageTemplateName = 'GAOWin10GoldImage'

# Distribution properties of the managed image upon completion
$runOutputName = 'myDistResults'


# Your Azure Subscription ID
$subscriptionID = (Get-AzContext).Subscription.Id
Write-Output $subscriptionID

[int]$timeInt = $(Get-Date -UFormat '%s')
$imageRoleDefName = "Azure Image Builder Contributor"
$identityName = "win10Gold$timeInt"

New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location

$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

$myRoleImageCreationPath = "myRoleImageCreation.json"


$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force


New-AzRoleDefinition -InputFile $myRoleImageCreationPath

$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams


