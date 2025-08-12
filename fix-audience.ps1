# Fix Audience Issue - Add Audience Mapper to Blazor Server Client
# This script adds the required audience mapper to include "blazor-api" in JWT tokens

param(
    [string]$KeycloakUrl = "http://localhost:8080",
    [string]$AdminUsername = "admin", 
    [string]$AdminPassword = "admin",
    [string]$RealmName = "blazor-app",
    [string]$ClientId = "blazor-server",
    [string]$TargetAudience = "blazor-api"
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
        Write-Host "Getting admin token..." -ForegroundColor Yellow
        $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        Write-Host "✅ Admin token obtained" -ForegroundColor Green
        return $response.access_token
    }
    catch {
        Write-Host "❌ Failed to get admin token: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual steps to fix the audience issue:" -ForegroundColor Cyan
        Write-Host "1. Open Keycloak Admin Console: $KeycloakUrl/admin" -ForegroundColor Gray
        Write-Host "2. Go to Realm: $RealmName" -ForegroundColor Gray
        Write-Host "3. Go to Clients > $ClientId > Client scopes" -ForegroundColor Gray
        Write-Host "4. Click 'Add client scope'" -ForegroundColor Gray
        Write-Host "5. Select the 'Optional' tab and add any available scope" -ForegroundColor Gray
        Write-Host "6. OR create a new Protocol Mapper:" -ForegroundColor Gray
        Write-Host "   - Name: audience-mapper" -ForegroundColor Gray
        Write-Host "   - Mapper Type: Audience" -ForegroundColor Gray
        Write-Host "   - Included Client Audience: $TargetAudience" -ForegroundColor Gray
        Write-Host ""
        return $null
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
            $bodyJson = $Body | ConvertTo-Json -Depth 10
            return Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers -Body $bodyJson
        } else {
            return Invoke-RestMethod -Uri $Uri -Method $Method -Headers $headers
        }
    }
    catch {
        Write-Host "API call failed: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

Write-Host "🔧 Fixing Audience Issue for JWT Tokens" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Get admin token
$adminToken = Get-AdminToken -KeycloakUrl $KeycloakUrl -Username $AdminUsername -Password $AdminPassword

if ($adminToken) {
    try {
        # Get the client
        Write-Host "Getting client information..." -ForegroundColor Yellow
        $clients = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$ClientId" -Token $adminToken
        
        if ($clients.Count -eq 0) {
            Write-Host "❌ Client '$ClientId' not found" -ForegroundColor Red
            exit 1
        }
        
        $client = $clients[0]
        $clientUuid = $client.id
        Write-Host "✅ Found client: $ClientId (ID: $clientUuid)" -ForegroundColor Green
        
        # Create audience mapper
        Write-Host "Creating audience mapper..." -ForegroundColor Yellow
        
        $audienceMapper = @{
            name = "audience-mapper"
            protocol = "openid-connect"
            protocolMapper = "oidc-audience-mapper"
            consentRequired = $false
            config = @{
                "included.client.audience" = $TargetAudience
                "id.token.claim" = "false"
                "access.token.claim" = "true"
            }
        }
        
        $response = Invoke-KeycloakApi -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$clientUuid/protocol-mappers/models" -Method POST -Body $audienceMapper -Token $adminToken
        
        Write-Host "✅ Audience mapper created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎯 Configuration Summary:" -ForegroundColor Cyan
        Write-Host "  Client: $ClientId" -ForegroundColor Gray
        Write-Host "  Target Audience: $TargetAudience" -ForegroundColor Gray
        Write-Host "  Mapper: audience-mapper" -ForegroundColor Gray
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Cyan
        Write-Host "1. Logout and login again in your Blazor app to get a new token" -ForegroundColor Gray
        Write-Host "2. Copy the new token and decode it - it should now include 'aud': ['$TargetAudience']" -ForegroundColor Gray
        Write-Host "3. Test the protected endpoints in Swagger UI" -ForegroundColor Gray
        Write-Host ""
        
    }
    catch {
        Write-Host "❌ Error creating audience mapper: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please follow the manual steps above." -ForegroundColor Yellow
    }
}
