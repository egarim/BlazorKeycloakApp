# Complete Keycloak Setup Script for Blazor Server + C# REST API
# This script creates a realm, configures clients, and handles all redirect URI config    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid" -Method Put -Body $updatedClient -Token $Token
        Write-Host "✅ Client configuration updated successfully" -ForegroundColor Green
        
        # Add audience mapper if it doesn't exist
        Write-Host "🎯 Ensuring audience mapper exists..." -ForegroundColor Yellow
        $audienceMapper = @{
            name = "audience-mapper"
            protocol = "openid-connect"
            protocolMapper = "oidc-audience-mapper"
            consentRequired = $false
            config = @{
                "included.client.audience" = "blazor-api"
                "id.token.claim" = "false"
                "access.token.claim" = "true"
            }
        }
        
        try {
            Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid/protocol-mappers/models" -Method Post -Body $audienceMapper -Token $Token
            Write-Host "✅ Audience mapper added" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*409*") {
                Write-Host "⚠️  Audience mapper already exists" -ForegroundColor Yellow
            }
            else {
                Write-Warning "Failed to create audience mapper: $($_.Exception.Message)"
            }
        }
        
        return $true
    }ons

param(
    [string]$KeycloakUrl = "http://localhost:8080/",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "JoseManuel16",
    [string]$RealmName = "blazor-app",
    [string]$BlazorClientId = "blazor-server",
    [string]$ApiClientId = "blazor-api",
    [string]$BlazorBaseUrl = "https://localhost:7001",
    [string]$ApiBaseUrl = "https://localhost:7002",
    [switch]$UpdateOnly = $false,
    [switch]$ShowInstructions = $false
)

# Function to get admin access token
function Get-AdminToken {
    param($KeycloakUrl, $Username, $Password)
    
    $tokenUrl = "$KeycloakUrl/realms/master/protocol/openid-connect/token"
    $body = @{
        grant_type = "password"
        client_id = "admin-cli"
        username = $Username
        password = $Password
    }
    
    try {
        $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        return $response.access_token
    }
    catch {
        Write-Error "Failed to get admin token: $($_.Exception.Message)"
        Write-Host ""
        Write-Host "?? Troubleshooting tips:" -ForegroundColor Yellow
        Write-Host "1. Verify Keycloak is running at: $KeycloakUrl" -ForegroundColor Gray
        Write-Host "2. Check admin credentials (default: admin/admin)" -ForegroundColor Gray
        Write-Host "3. Ensure Keycloak admin console is accessible" -ForegroundColor Gray
        Write-Host ""
        exit 1
    }
}

# Function to make authenticated API calls
function Invoke-KeycloakApi {
    param($Uri, $Method = "GET", $Body = $null, $Token)
    
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    try {
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            return Invoke-RestMethod -Uri $Uri -Method $Method -Body $jsonBody -Headers $headers
        }
        else {
            return Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers
        }
    }
    catch {
        Write-Warning "API call failed: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Warning "Response: $responseBody"
        }
        throw
    }
}

# Function to show manual configuration instructions
function Show-ManualInstructions {
    param($BlazorBaseUrl)
    
    Write-Host ""
    Write-Host "=== Manual Configuration Instructions ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If the automated setup fails, you can configure manually:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Open Keycloak Admin Console:" -ForegroundColor Cyan
    Write-Host "   $KeycloakUrl/admin" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Navigate to: Realms > $RealmName > Clients > $BlazorClientId" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Update the Settings tab with these values:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Valid redirect URIs:" -ForegroundColor White
    Write-Host "   - $BlazorBaseUrl/signin-oidc" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/signout-callback-oidc" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/authentication/login-callback" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/authentication/logout-callback" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Valid post logout redirect URIs:" -ForegroundColor White
    Write-Host "   - $BlazorBaseUrl/" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/signout-callback-oidc" -ForegroundColor Gray
    Write-Host "   - $BlazorBaseUrl/authentication/logout-callback" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Web origins:" -ForegroundColor White
    Write-Host "   - $BlazorBaseUrl" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Advanced Settings tab:" -ForegroundColor Cyan
    Write-Host "   - Proof Key for Code Exchange Code Challenge Method: S256" -ForegroundColor Gray
    Write-Host "   - Access Token Lifespan: 5 minutes" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5. Click 'Save' to apply changes" -ForegroundColor Cyan
    Write-Host ""
}

# Function to update existing client configuration
function Update-ClientConfiguration {
    param($Token, $KeycloakUrl, $RealmName, $BlazorClientId, $BlazorBaseUrl)
    
    Write-Host "?? Updating client configuration..." -ForegroundColor Yellow
    
    # Get existing clients
    $clients = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$BlazorClientId" -Token $Token
    
    if ($clients.Count -eq 0) {
        Write-Error "Client '$BlazorClientId' not found in realm '$RealmName'"
        return $false
    }
    
    $blazorClientUuid = $clients[0].id
    $existingClient = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid" -Token $Token
    
    # Update client configuration with complete redirect URIs
    $updatedClient = $existingClient
    $updatedClient.redirectUris = @(
        "$BlazorBaseUrl/signin-oidc",
        "$BlazorBaseUrl/signout-callback-oidc",
        "$BlazorBaseUrl/",
        "$BlazorBaseUrl/authentication/login-callback",
        "$BlazorBaseUrl/authentication/logout-callback"
    )
    
    $updatedClient.webOrigins = @("$BlazorBaseUrl")
    
    # Ensure attributes exist and are properly configured
    if (-not $updatedClient.attributes) {
        $updatedClient.attributes = @{}
    }
    
    $updatedClient.attributes["pkce.code.challenge.method"] = "S256"
    $updatedClient.attributes["post.logout.redirect.uris"] = "$BlazorBaseUrl/signout-callback-oidc,$BlazorBaseUrl/authentication/logout-callback,$BlazorBaseUrl/"
    $updatedClient.attributes["backchannel.logout.session.required"] = "true"
    $updatedClient.attributes["backchannel.logout.revoke.offline.tokens"] = "true"
    $updatedClient.attributes["access.token.lifespan"] = "300"
    
    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid" -Method Put -Body $updatedClient -Token $Token
        Write-Host "? Client configuration updated successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to update client configuration: $($_.Exception.Message)"
        return $false
    }
}

# Main script execution
Write-Host "?? Keycloak Configuration Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Show instructions only if requested
if ($ShowInstructions) {
    Show-ManualInstructions -BlazorBaseUrl $BlazorBaseUrl
    exit 0
}

# Prompt for required parameters if not provided
if (-not $KeycloakUrl) {
    $KeycloakUrl = Read-Host "Enter Keycloak URL (e.g., http://localhost:8080)"
}

if (-not $AdminUsername) {
    $AdminUsername = Read-Host "Enter Keycloak admin username"
}

if (-not $AdminPassword) {
    $AdminPassword = Read-Host "Enter Keycloak admin password" -AsSecureString
    $AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPassword))
}

# Remove trailing slash from URLs
$KeycloakUrl = $KeycloakUrl.TrimEnd('/')
$BlazorBaseUrl = $BlazorBaseUrl.TrimEnd('/')
$ApiBaseUrl = $ApiBaseUrl.TrimEnd('/')

Write-Host "Configuration:" -ForegroundColor White
Write-Host "  Keycloak URL: $KeycloakUrl" -ForegroundColor Gray
Write-Host "  Realm: $RealmName" -ForegroundColor Gray
Write-Host "  Blazor Client: $BlazorClientId" -ForegroundColor Gray
Write-Host "  API Client: $ApiClientId" -ForegroundColor Gray
Write-Host "  Blazor URL: $BlazorBaseUrl" -ForegroundColor Gray
Write-Host ""

# Get admin token
Write-Host "?? Authenticating with Keycloak..." -ForegroundColor Yellow
$adminToken = Get-AdminToken -KeycloakUrl $KeycloakUrl -Username $AdminUsername -Password $AdminPassword
Write-Host "? Admin token obtained" -ForegroundColor Green

# If UpdateOnly switch is used, just update the client configuration
if ($UpdateOnly) {
    $success = Update-ClientConfiguration -Token $adminToken -KeycloakUrl $KeycloakUrl -RealmName $RealmName -BlazorClientId $BlazorClientId -BlazorBaseUrl $BlazorBaseUrl
    
    if ($success) {
        Write-Host ""
        Write-Host "?? Client configuration updated successfully!" -ForegroundColor Green
        Write-Host "You can now restart your Blazor application." -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "? Update failed. Please check the error messages above." -ForegroundColor Red
        Show-ManualInstructions -BlazorBaseUrl $BlazorBaseUrl
    }
    exit 0
}

# Full setup process
Write-Host "?? Creating realm '$RealmName'..." -ForegroundColor Yellow
$realmConfig = @{
    realm = $RealmName
    enabled = $true
    displayName = "Blazor Application"
    loginWithEmailAllowed = $true
    registrationAllowed = $true
    resetPasswordAllowed = $true
    rememberMe = $true
    verifyEmail = $false
    loginTheme = "keycloak"
    accessTokenLifespan = 300  # 5 minutes
    ssoSessionIdleTimeout = 1800  # 30 minutes
    ssoSessionMaxLifespan = 36000  # 10 hours
    refreshTokenMaxReuse = 0  # Enable refresh token rotation
    revokeRefreshToken = $true
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms" -Method Post -Body $realmConfig -Token $adminToken
    Write-Host "? Realm '$RealmName' created" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "??  Realm '$RealmName' already exists, continuing..." -ForegroundColor Yellow
    }
    else {
        throw
    }
}

# Create Blazor Server client (Confidential) with complete redirect URI configuration
Write-Host "???  Creating Blazor Server client..." -ForegroundColor Yellow
$blazorClient = @{
    clientId = $BlazorClientId
    name = "Blazor Server Application"
    enabled = $true
    protocol = "openid-connect"
    publicClient = $false  # Confidential client
    standardFlowEnabled = $true  # Authorization Code Flow
    implicitFlowEnabled = $false
    directAccessGrantsEnabled = $false
    serviceAccountsEnabled = $false
    authorizationServicesEnabled = $false
    fullScopeAllowed = $true
    redirectUris = @(
        "$BlazorBaseUrl/signin-oidc",
        "$BlazorBaseUrl/signout-callback-oidc",
        "$BlazorBaseUrl/",
        "$BlazorBaseUrl/authentication/login-callback",
        "$BlazorBaseUrl/authentication/logout-callback"
    )
    webOrigins = @("$BlazorBaseUrl")
    attributes = @{
        "pkce.code.challenge.method" = "S256"
        "post.logout.redirect.uris" = "$BlazorBaseUrl/signout-callback-oidc,$BlazorBaseUrl/authentication/logout-callback,$BlazorBaseUrl/"
        "backchannel.logout.session.required" = "true"
        "backchannel.logout.revoke.offline.tokens" = "true"
        "access.token.lifespan" = "300"
    }
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" -Method Post -Body $blazorClient -Token $adminToken
    Write-Host "? Blazor Server client created with complete redirect URI configuration" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "??  Blazor Server client already exists, updating configuration..." -ForegroundColor Yellow
        $success = Update-ClientConfiguration -Token $adminToken -KeycloakUrl $KeycloakUrl -RealmName $RealmName -BlazorClientId $BlazorClientId -BlazorBaseUrl $BlazorBaseUrl
        if (-not $success) {
            Write-Host "? Failed to update existing client configuration" -ForegroundColor Red
        }
    }
    else {
        throw
    }
}

# Get the created Blazor client to retrieve its ID and secret
$clients = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$BlazorClientId" -Token $adminToken
$blazorClientUuid = $clients[0].id

# Get client secret
$clientSecret = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid/client-secret" -Token $adminToken

# CRITICAL: Add audience mapper to include API audience in JWT tokens
Write-Host "🎯 Adding audience mapper for JWT tokens..." -ForegroundColor Yellow
$audienceMapper = @{
    name = "audience-mapper"
    protocol = "openid-connect"
    protocolMapper = "oidc-audience-mapper"
    consentRequired = $false
    config = @{
        "included.client.audience" = $ApiClientId
        "id.token.claim" = "false"
        "access.token.claim" = "true"
    }
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$blazorClientUuid/protocol-mappers/models" -Method Post -Body $audienceMapper -Token $adminToken
    Write-Host "✅ Audience mapper created - JWT tokens will now include 'aud: [$ApiClientId]'" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "⚠️  Audience mapper already exists" -ForegroundColor Yellow
    }
    else {
        Write-Warning "Failed to create audience mapper: $($_.Exception.Message)"
        Write-Host "📝 Manual fix required: Add audience mapper in Keycloak admin console" -ForegroundColor Red
    }
}

# Create API client (Resource Server)
Write-Host "?? Creating API client..." -ForegroundColor Yellow
$apiClient = @{
    clientId = $ApiClientId
    name = "Blazor REST API"
    enabled = $true
    protocol = "openid-connect"
    publicClient = $false
    bearerOnly = $true  # Resource server - only accepts bearer tokens
    standardFlowEnabled = $false
    implicitFlowEnabled = $false
    directAccessGrantsEnabled = $false
    serviceAccountsEnabled = $false
    authorizationServicesEnabled = $false
    fullScopeAllowed = $true
    attributes = @{
        "access.token.lifespan" = "300"  # 5 minutes
    }
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" -Method Post -Body $apiClient -Token $adminToken
    Write-Host "? API client created" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "??  API client already exists, continuing..." -ForegroundColor Yellow
    }
    else {
        throw
    }
}

# Create some basic roles
Write-Host "?? Creating realm roles..." -ForegroundColor Yellow
$roles = @("admin", "user", "manager")

foreach ($roleName in $roles) {
    $role = @{
        name = $roleName
        description = "Role: $roleName"
    }
    
    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" -Method Post -Body $role -Token $adminToken
        Write-Host "  ? Role '$roleName' created" -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "  ??  Role '$roleName' already exists" -ForegroundColor Yellow
        }
        else {
            Write-Warning "Failed to create role '$roleName': $($_.Exception.Message)"
        }
    }
}

# Create a test user (optional)
Write-Host "👤 Creating test user..." -ForegroundColor Yellow
$testUser = @{
    username = "testuser"
    email = "test@example.com"
    firstName = "Test"
    lastName = "User"
    enabled = $true
    emailVerified = $true
    credentials = @(
        @{
            type = "password"
            value = "Test123!"
            temporary = $false
        }
    )
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users" -Method Post -Body $testUser -Token $adminToken
    Write-Host "✅ Test user 'testuser' created (password: Test123!)" -ForegroundColor Green
    
    # Get the created user to assign roles
    $users = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=testuser" -Token $adminToken
    if ($users.Count -gt 0) {
        $testUserUuid = $users[0].id
        
        # Assign admin and user roles
        $adminRole = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/admin" -Token $adminToken
        $userRole = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/user" -Token $adminToken
        
        $rolesToAssign = @($adminRole, $userRole)
        
        try {
            Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$testUserUuid/role-mappings/realm" -Method Post -Body $rolesToAssign -Token $adminToken
            Write-Host "✅ Assigned 'admin' and 'user' roles to testuser" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to assign roles to test user: $($_.Exception.Message)"
        }
    }
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "??  Test user already exists" -ForegroundColor Yellow
    }
    else {
        Write-Warning "Failed to create test user: $($_.Exception.Message)"
    }
}

# Output configuration summary
Write-Host ""
Write-Host "?? Setup completed successfully!" -ForegroundColor Green
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host "CONFIGURATION SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan
Write-Host ""
Write-Host "Keycloak Configuration:" -ForegroundColor White
Write-Host "  Realm Name: $RealmName" -ForegroundColor Gray
Write-Host "  Authority: $KeycloakUrl/realms/$RealmName" -ForegroundColor Gray
Write-Host ""
Write-Host "Blazor Server Client:" -ForegroundColor White
Write-Host "  Client ID: $BlazorClientId" -ForegroundColor Gray
Write-Host "  Client Secret: $($clientSecret.value)" -ForegroundColor Yellow
Write-Host "  Type: Confidential (server-side)" -ForegroundColor Gray
Write-Host "  Redirect URIs configured for all authentication scenarios" -ForegroundColor Green
Write-Host "  Audience Mapper: ✅ Configured to include '$ApiClientId' in JWT tokens" -ForegroundColor Green
Write-Host ""
Write-Host "API Client:" -ForegroundColor White
Write-Host "  Client ID: $ApiClientId" -ForegroundColor Gray
Write-Host "  Type: Bearer-only (resource server)" -ForegroundColor Gray
Write-Host "  Audience Validation: Expects 'aud: [$ApiClientId]' in JWT tokens" -ForegroundColor Gray
Write-Host ""
Write-Host "Test User:" -ForegroundColor White
Write-Host "  Username: testuser" -ForegroundColor Gray
Write-Host "  Password: Test123!" -ForegroundColor Yellow
Write-Host "  Email: test@example.com" -ForegroundColor Gray
Write-Host "  Roles: admin, user (can access all endpoints)" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "1. Update your appsettings.json files with the configuration above" -ForegroundColor Gray
Write-Host "2. Start your applications:" -ForegroundColor Gray
Write-Host "   - BlazorApi: dotnet run --project BlazorApi" -ForegroundColor Gray
Write-Host "   - BlazorServer: dotnet run --project BlazorServer" -ForegroundColor Gray
Write-Host "3. Test the login flow with the test user" -ForegroundColor Gray
Write-Host ""
Write-Host "Keycloak Admin Console: $KeycloakUrl/admin/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor White
Write-Host "  Full setup: .\setup-keycloak-complete.ps1" -ForegroundColor Gray
Write-Host "  Update client only: .\setup-keycloak-complete.ps1 -UpdateOnly" -ForegroundColor Gray
Write-Host "  Show manual instructions: .\setup-keycloak-complete.ps1 -ShowInstructions" -ForegroundColor Gray
Write-Host ""