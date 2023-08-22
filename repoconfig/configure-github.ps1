param(
    [Parameter(Mandatory = $true)]
    [String]
        $tenantId,
    [Parameter(Mandatory = $true)]
    [String]
        $appName,
    [Parameter(Mandatory = $true)]
    [String]
        $sqlAdminGroup,
    [Parameter(Mandatory = $true)]
    [String]
        $keyVaultName,
    [Parameter(Mandatory = $true)]
    [String]
        $githubOrgName,
    [Parameter(Mandatory = $true)]
    [String]
        $githubRepoName,
    [Parameter(Mandatory = $true)]
    [String]
        $githubPat
)

# log in to Azure
Connect-AzAccount -Tenant $tenantId


# Create an Azure Active Directory application and service principal
New-AzADApplication -DisplayName $appName
$clientId = (Get-AzADApplication -DisplayName $appName).AppId
New-AzADServicePrincipal -ApplicationId $clientId


# create role assignments
$objectId = (Get-AzADServicePrincipal -DisplayName $appName).Id
New-AzRoleAssignment -ObjectId $objectId -RoleDefinitionName Contributor

$clientId = (Get-AzADApplication -DisplayName $appName).Id

#Add federated credentials
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Production" -Subject "repo:$($githubOrgName)/$($githubRepoName):environment:Production"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Canary" -Subject "repo:$($githubOrgName)/$($githubRepoName):environment:Canary"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Test" -Subject "repo:$($githubOrgName)/$($githubRepoName):environment:Test"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Dev" -Subject "repo:$($githubOrgName)/$($githubRepoName):environment:Dev"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-PR" -Subject "repo:$($githubOrgName)/$($githubRepoName):pull_request"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Main" -Subject "repo:$($githubOrgName)/$($githubRepoName):ref:refs/heads/main"
New-AzADAppFederatedCredential -ApplicationObjectId $clientId -Audience api://AzureADTokenExchange -Issuer 'https://token.actions.githubusercontent.com' -Name "$($githubRepoName)-Branch" -Subject "repo:$($githubOrgName)/$($githubRepoName):ref:refs/heads/branch"


#create Group for SQL Admins
$sqlAdminsGroup = New-AzADGroup -DisplayName $sqlAdminGroup -MailNickname $sqlAdminGroup -SecurityEnabled -IsAssignableToRole
$members = @()
# Add Signed in user
$members += (Get-AzADUser -Mail (Get-AzContext).Account.Id).Id
# Add Service Principal
$members += (Get-AzADServicePrincipal -DisplayName $appName).Id
# Add members To Group
Add-AzADGroupMember -TargetGroupObjectId $sqlAdminsGroup.Id -MemberObjectId $members
# Add the Service Principal as Group Owner so that it can add managed identities to the group
Add-AzureADGroupOwner -ObjectId $sqlAdminsGroup.Id -RefObjectId $member

# Convert ObjectId to SID https://github.com/okieselbach/Intune/blob/master/Convert-AzureAdObjectIdToSid.ps1

$bytes = [Guid]::Parse($sqlAdminsGroup.Id).ToByteArray()
$array = New-Object 'UInt32[]' 4
[Buffer]::BlockCopy($bytes, 0, $array, 0, 16)
$sid = "S-1-12-1-$array".Replace(' ', '-')

# write SID to Key Vault
$secretvalueSid = ConvertTo-SecureString $sqlAdminsGroup.Id -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'aadSid' -SecretValue $secretvalueSid

$secretvalueaadObjectID = ConvertTo-SecureString $sqlAdminsGroup.Id -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'aadObjectID' -SecretValue $secretvalueaadObjectID

$secretvaluesqlAdminGroup  = ConvertTo-SecureString $sqlAdminGroup -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'aadUsername' -SecretValue $secretvaluesqlAdminGroup






#install PSSodium if missing
If(!(Get-Module -ListAvailable -Name PSSodium)){
    install-module PSSodium
}


#create GitHub Secrets
$clientAppId = (Get-AzADApplication -DisplayName $appName).AppId
$subscriptionId = (Get-AzContext).Subscription.Id
$tenantId = (Get-AzContext).Subscription.TenantId

$headers = @{Authorization = "token " + $githubPat}

Invoke-RestMethod –Method get –Uri "https://api.github.com/repos/$($githubOrgName)/$($githubRepoName)/actions/secrets" –Headers $headers

$publicKey = (Invoke-RestMethod –Method get –Uri "https://api.github.com/repos/$($githubOrgName)/$($githubRepoName)/actions/secrets/public-key" –Headers $headers)

#AZURE_TENANT_ID
$encryptedSecret = ConvertTo-SodiumEncryptedString –Text $tenantId –PublicKey $($publicKey.key)
$Body = @"
{
    "encrypted_value": "$encryptedSecret",
    "key_id": "$($publicKey.key_id)"
}
"@

Invoke-RestMethod –Method Put –Uri "https://api.github.com/repos/$($githubOrgName)/$($githubRepoName)/actions/secrets/AZURE_TENANT_ID" –Headers $headers –body $Body

#AZURE_CLIENT_ID
$encryptedSecret = ConvertTo-SodiumEncryptedString –Text $clientAppId –PublicKey $($publicKey.key)
$Body = @"
{
    "encrypted_value": "$encryptedSecret",
    "key_id": "$($publicKey.key_id)"
}
"@

Invoke-RestMethod –Method Put –Uri "https://api.github.com/repos/$($githubOrgName)/$($githubRepoName)/actions/secrets/AZURE_CLIENT_ID" –Headers $headers –body $Body

#AZURE_SUBSCRIPTION_ID
$encryptedSecret = ConvertTo-SodiumEncryptedString –Text $subscriptionId  –PublicKey $($publicKey.key)
$Body = @"
{
    "encrypted_value": "$encryptedSecret",
    "key_id": "$($publicKey.key_id)"
}
"@

Invoke-RestMethod –Method Put –Uri "https://api.github.com/repos/$($githubOrgName)/$($githubRepoName)/actions/secrets/AZURE_SUBSCRIPTION_ID" –Headers $headers –body $Body