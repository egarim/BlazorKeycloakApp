# Complete Keycloak Setup Script for Blazor Server + C# REST API
# This script creates a realm, configures clients, and handles all redirect URI configurations

param(
    [string]$KeycloakUrl = "http://localhost:8080",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "JoseManuel16",
    [string]$RealmName = "blazor-app",
    [string]$BlazorClientId = "blazor-server",
    [string]$ApiClientId = "blazor-api",
    [string]$BlazorBaseUrl = "https://localhost:7001",
    [string]$ApiBaseUrl = "https://localhost:7049",
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
        Write-Host "Troubleshooting tips:" -ForegroundColor Yellow
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

# Function to create realm
function New-Realm {
    param($RealmName, $KeycloakUrl, $Token)
    
    $realm = @{
        realm = $RealmName
        enabled = $true
        displayName = "Blazor Application Realm"
        registrationAllowed = $false
        loginWithEmailAllowed = $true
        duplicateEmailsAllowed = $false
        resetPasswordAllowed = $true
        editUsernameAllowed = $false
        bruteForceProtected = $true
        accessTokenLifespan = 300
        accessTokenLifespanForImplicitFlow = 900
        ssoSessionIdleTimeout = 1800
        ssoSessionMaxLifespan = 36000
        offlineSessionIdleTimeout = 2592000
        accessCodeLifespan = 60
        accessCodeLifespanUserAction = 300
        accessCodeLifespanLogin = 1800
        actionTokenGeneratedByAdminLifespan = 43200
        actionTokenGeneratedByUserLifespan = 300
    }
    
    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms" -Method Post -Body $realm -Token $Token
        Write-Host "Realm '$RealmName' created successfully" -ForegroundColor Green
        return $true
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "Realm '$RealmName' already exists" -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Error "Failed to create realm: $($_.Exception.Message)"
            return $false
        }
    }
}

# Function to create Blazor Server client
function New-BlazorClient {
    param($RealmName, $ClientId, $BaseUrl, $KeycloakUrl, $Token)
    
    $redirectUris = @(
        "$BaseUrl/",
        "$BaseUrl/signin-oidc",
        "$BaseUrl/authentication/login-callback",
        "https://localhost:7001/",
        "https://localhost:7001/signin-oidc",
        "https://localhost:7001/authentication/login-callback"
    )
    
    $postLogoutRedirectUris = @(
        "$BaseUrl/",
        "$BaseUrl/authentication/logout-callback",
        "$BaseUrl/signout-callback-oidc",
        "https://localhost:7001/",
        "https://localhost:7001/authentication/logout-callback",
        "https://localhost:7001/signout-callback-oidc"
    )
    
    $client = @{
        clientId = $ClientId
        name = "Blazor Server Application"
        description = "OpenID Connect client for Blazor Server"
        enabled = $true
        clientAuthenticatorType = "client-secret"
        secret = "your-blazor-client-secret-here"
        redirectUris = $redirectUris
        webOrigins = @("$BaseUrl", "https://localhost:7001")
        protocol = "openid-connect"
        publicClient = $false
        frontchannelLogout = $true
        attributes = @{
            "pkce.code.challenge.method" = "S256"
            "post.logout.redirect.uris" = ($postLogoutRedirectUris -join "##")
        }
        standardFlowEnabled = $true
        implicitFlowEnabled = $false
        directAccessGrantsEnabled = $false
        serviceAccountsEnabled = $false
        fullScopeAllowed = $true
    }
    
    try {
        $response = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" -Method Post -Body $client -Token $Token
        Write-Host "Blazor client '$ClientId' created successfully" -ForegroundColor Green
        
        # Get the client UUID for further configuration
        $clients = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$ClientId" -Token $Token
        $clientUuid = $clients[0].id
        
        # Add audience mapper
        Add-AudienceMapper -RealmName $RealmName -ClientUuid $clientUuid -KeycloakUrl $KeycloakUrl -Token $Token
        
        return $clientUuid
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "Blazor client '$ClientId' already exists" -ForegroundColor Yellow
            $clients = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$ClientId" -Token $Token
            return $clients[0].id
        }
        else {
            Write-Error "Failed to create Blazor client: $($_.Exception.Message)"
            return $null
        }
    }
}

# Function to create API client
function New-ApiClient {
    param($RealmName, $ClientId, $BaseUrl, $KeycloakUrl, $Token)
    
    $client = @{
        clientId = $ClientId
        name = "Blazor API"
        description = "JWT Bearer client for Blazor API"
        enabled = $true
        clientAuthenticatorType = "client-secret"
        secret = "your-api-client-secret-here"
        protocol = "openid-connect"
        publicClient = $false
        bearerOnly = $true
        standardFlowEnabled = $false
        implicitFlowEnabled = $false
        directAccessGrantsEnabled = $false
        serviceAccountsEnabled = $false
        fullScopeAllowed = $true
        attributes = @{
            "access.token.lifespan" = "300"
        }
    }
    
    try {
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" -Method Post -Body $client -Token $Token
        Write-Host "API client '$ClientId' created successfully" -ForegroundColor Green
        return $true
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "API client '$ClientId' already exists" -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Error "Failed to create API client: $($_.Exception.Message)"
            return $false
        }
    }
}

# Function to add audience mapper
function Add-AudienceMapper {
    param($RealmName, $ClientUuid, $KeycloakUrl, $Token)
    
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
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$ClientUuid/protocol-mappers/models" -Method Post -Body $audienceMapper -Token $Token
        Write-Host "Audience mapper added successfully" -ForegroundColor Green
        return $true
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "Audience mapper already exists" -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Warning "Failed to create audience mapper: $($_.Exception.Message)"
            return $false
        }
    }
}

# Function to create roles
function New-Roles {
    param($RealmName, $KeycloakUrl, $Token)
    
    $roles = @("admin", "user")
    
    foreach ($roleName in $roles) {
        $role = @{
            name = $roleName
            description = "Role for $roleName users"
        }
        
        try {
            Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" -Method Post -Body $role -Token $Token
            Write-Host "Role '$roleName' created successfully" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*409*") {
                Write-Host "Role '$roleName' already exists" -ForegroundColor Yellow
            }
            else {
                Write-Warning "Failed to create role '$roleName': $($_.Exception.Message)"
            }
        }
    }
}

# Function to create test user
function New-TestUser {
    param($RealmName, $KeycloakUrl, $Token)
    
    $user = @{
        username = "testuser"
        email = "testuser@example.com"
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
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users" -Method Post -Body $user -Token $Token
        Write-Host "Test user 'testuser' created successfully" -ForegroundColor Green
        
        # Get user ID and assign roles
        $users = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=testuser" -Token $Token
        $userId = $users[0].id
        
        # Assign roles
        $adminRole = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/admin" -Token $Token
        $userRole = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/user" -Token $Token
        
        $rolesToAssign = @($adminRole, $userRole)
        
        Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" -Method Post -Body $rolesToAssign -Token $Token
        Write-Host "Roles assigned to test user" -ForegroundColor Green
        
        return $true
    }
    catch {
        if ($_.Exception.Message -like "*409*") {
            Write-Host "Test user 'testuser' already exists" -ForegroundColor Yellow
            return $true
        }
        else {
            Write-Warning "Failed to create test user: $($_.Exception.Message)"
            return $false
        }
    }
}

# Main script execution
Write-Host "Complete Keycloak Setup Script" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

if ($ShowInstructions) {
    Write-Host "Manual Setup Instructions:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Access Keycloak Admin Console: $KeycloakUrl/admin" -ForegroundColor Gray
    Write-Host "2. Login with admin credentials" -ForegroundColor Gray
    Write-Host "3. Create realm: $RealmName" -ForegroundColor Gray
    Write-Host "4. Create client: $BlazorClientId (OpenID Connect)" -ForegroundColor Gray
    Write-Host "5. Create client: $ApiClientId (Bearer-only)" -ForegroundColor Gray
    Write-Host "6. Configure redirect URIs and audience mapper" -ForegroundColor Gray
    Write-Host "7. Create roles: admin, user" -ForegroundColor Gray
    Write-Host "8. Create test user: testuser / Test123!" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

Write-Host "Connecting to Keycloak at: $KeycloakUrl" -ForegroundColor Yellow
Write-Host "Realm: $RealmName" -ForegroundColor Gray
Write-Host "Blazor Client: $BlazorClientId" -ForegroundColor Gray
Write-Host "API Client: $ApiClientId" -ForegroundColor Gray
Write-Host ""

# Get admin token
Write-Host "Getting admin access token..." -ForegroundColor Yellow
$adminToken = Get-AdminToken -KeycloakUrl $KeycloakUrl -Username $AdminUsername -Password $AdminPassword

if (-not $UpdateOnly) {
    # Create realm
    Write-Host "Creating realm..." -ForegroundColor Yellow
    $realmCreated = New-Realm -RealmName $RealmName -KeycloakUrl $KeycloakUrl -Token $adminToken
    
    if (-not $realmCreated) {
        Write-Error "Failed to create realm. Exiting."
        exit 1
    }
    
    # Create roles
    Write-Host "Creating roles..." -ForegroundColor Yellow
    New-Roles -RealmName $RealmName -KeycloakUrl $KeycloakUrl -Token $adminToken
}

# Create/update clients
Write-Host "Creating Blazor Server client..." -ForegroundColor Yellow
$blazorClientUuid = New-BlazorClient -RealmName $RealmName -ClientId $BlazorClientId -BaseUrl $BlazorBaseUrl -KeycloakUrl $KeycloakUrl -Token $adminToken

Write-Host "Creating API client..." -ForegroundColor Yellow
$apiClientCreated = New-ApiClient -RealmName $RealmName -ClientId $ApiClientId -BaseUrl $ApiBaseUrl -KeycloakUrl $KeycloakUrl -Token $adminToken

if (-not $UpdateOnly) {
    # Create test user
    Write-Host "Creating test user..." -ForegroundColor Yellow
    New-TestUser -RealmName $RealmName -KeycloakUrl $KeycloakUrl -Token $adminToken
}

Write-Host ""
Write-Host "Setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Keycloak URL: $KeycloakUrl" -ForegroundColor Gray
Write-Host "Realm: $RealmName" -ForegroundColor Gray
Write-Host "Blazor Client ID: $BlazorClientId" -ForegroundColor Gray
Write-Host "API Client ID: $ApiClientId" -ForegroundColor Gray
Write-Host "Test User: testuser / Test123!" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update appsettings.json with the above configuration" -ForegroundColor Gray
Write-Host "2. Run the Blazor Server app: dotnet run" -ForegroundColor Gray
Write-Host "3. Run the API: dotnet run" -ForegroundColor Gray
Write-Host "4. Test authentication at: $BlazorBaseUrl" -ForegroundColor Gray
Write-Host ""
Write-Host "Important: Audience mapper configured for JWT tokens" -ForegroundColor Green
Write-Host "This fixes the 'aud' claim issue for API authentication" -ForegroundColor Green
