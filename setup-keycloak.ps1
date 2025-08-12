# Keycloak Setup Script for Blazor Server + C# REST API
# This script creates a realm and configures clients for your authentication setup

param(
    [string]$KeycloakUrl = "http://localhost:8080/",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "JoseManuel16",
    [string]$RealmName = "blazor-app",
    [string]$BlazorClientId = "blazor-server",
    [string]$ApiClientId = "blazor-api",
    [string]$BlazorBaseUrl = "https://localhost:7001",
    [string]$ApiBaseUrl = "https://localhost:7002"
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

# Prompt for required parameters if not provided
if (-not $KeycloakUrl) {
    $KeycloakUrl = Read-Host "Enter Keycloak URL (e.g., https://keycloak.example.com)"
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

Write-Host "🔧 Starting Keycloak setup..." -ForegroundColor Cyan
Write-Host "Keycloak URL: $KeycloakUrl" -ForegroundColor Gray
Write-Host "Realm: $RealmName" -ForegroundColor Gray

# Get admin token
Write-Host "🔑 Getting admin access token..." -ForegroundColor Yellow
$adminToken = Get-AdminToken -KeycloakUrl $KeycloakUrl -Username $AdminUsername -Password $AdminPassword
Write-Host "✅ Admin token obtained" -ForegroundColor Green

# Create realm
Write-Host "🏢 Creating realm '$RealmName'..." -ForegroundColor Yellow
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
    Write-Host "✅ Realm '$RealmName' created" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "⚠️  Realm '$RealmName' already exists, continuing..." -ForegroundColor Yellow
    }
    else {
        throw
    }
}

# Create Blazor Server client (Confidential)
Write-Host "🖥️  Creating Blazor Server client..." -ForegroundColor Yellow
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
        "$BlazorBaseUrl/authentication/login-callback"
    )
    webOrigins = @("$BlazorBaseUrl")
    attributes = @{
        "pkce.code.challenge.method" = "S256"
        "post.logout.redirect.uris" = "$BlazorBaseUrl/signout-callback-oidc,$BlazorBaseUrl/authentication/logout-callback,$BlazorBaseUrl/"
        "backchannel.logout.session.required" = "true"
        "backchannel.logout.revoke.offline.tokens" = "true"
    }
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" -Method Post -Body $blazorClient -Token $adminToken
    Write-Host "✅ Blazor Server client created" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "⚠️  Blazor Server client already exists, continuing..." -ForegroundColor Yellow
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

# Create API client (Resource Server)
Write-Host "🔌 Creating API client..." -ForegroundColor Yellow
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
    Write-Host "✅ API client created" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "⚠️  API client already exists, continuing..." -ForegroundColor Yellow
    }
    else {
        throw
    }
}

# Create some basic roles
Write-Host "👥 Creating realm roles..." -ForegroundColor Yellow
$roles = @("admin", "user", "manager")

foreach ($roleName in $roles) {
    $role = @{
        name = $roleName
        description = "Role: $roleName"
    }
    
    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" -Method Post -Body $role -Token $adminToken
        Write-Host "  ✅ Role '$roleName' created" -ForegroundColor Green
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "  ⚠️  Role '$roleName' already exists" -ForegroundColor Yellow
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
    realmRoles = @("user")
}

try {
    Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users" -Method Post -Body $testUser -Token $adminToken
    Write-Host "✅ Test user 'testuser' created (password: Test123!)" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*409*") {
        Write-Host "⚠️  Test user already exists" -ForegroundColor Yellow
    }
    else {
        Write-Warning "Failed to create test user: $($_.Exception.Message)"
    }
}

# Output configuration summary
Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "CONFIGURATION SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Keycloak Configuration:" -ForegroundColor White
Write-Host "  Realm Name: $RealmName" -ForegroundColor Gray
Write-Host "  Authority: $KeycloakUrl/realms/$RealmName" -ForegroundColor Gray
Write-Host ""
Write-Host "Blazor Server Client:" -ForegroundColor White
Write-Host "  Client ID: $BlazorClientId" -ForegroundColor Gray
Write-Host "  Client Secret: $($clientSecret.value)" -ForegroundColor Yellow
Write-Host "  Type: Confidential (server-side)" -ForegroundColor Gray
Write-Host ""
Write-Host "API Client:" -ForegroundColor White
Write-Host "  Client ID: $ApiClientId" -ForegroundColor Gray
Write-Host "  Type: Bearer-only (resource server)" -ForegroundColor Gray
Write-Host ""
Write-Host "Test User:" -ForegroundColor White
Write-Host "  Username: testuser" -ForegroundColor Gray
Write-Host "  Password: Test123!" -ForegroundColor Yellow
Write-Host "  Email: test@example.com" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "1. Configure your Blazor Server app with these settings" -ForegroundColor Gray
Write-Host "2. Configure your C# REST API to validate tokens from this realm" -ForegroundColor Gray
Write-Host "3. Test the login flow with the test user" -ForegroundColor Gray
Write-Host ""
Write-Host "Keycloak Admin Console: $KeycloakUrl/admin/" -ForegroundColor Cyan
Write-Host ""