# Fix Audience Issue - Add Audience Mapper to Blazor Server Client
param(
    [string]$KeycloakUrl = "http://localhost:8080",
    [string]$AdminUsername = "admin", 
    [string]$AdminPassword = "admin",
    [string]$RealmName = "blazor-app",
    [string]$ClientId = "blazor-server",
    [string]$TargetAudience = "blazor-api"
)

Write-Host "🔧 Manual Steps to Fix Audience Issue" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The issue is that your JWT token is missing the 'aud' (audience) claim." -ForegroundColor Yellow
Write-Host "Your API expects 'aud': ['blazor-api'] but your token doesn't have this." -ForegroundColor Yellow
Write-Host ""
Write-Host "Here's how to fix it manually in Keycloak:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Keycloak Admin Console:" -ForegroundColor White
Write-Host "   $KeycloakUrl/admin" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Navigate to your client:" -ForegroundColor White
Write-Host "   - Select realm: $RealmName" -ForegroundColor Gray
Write-Host "   - Go to: Clients > $ClientId" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Add Audience Mapper:" -ForegroundColor White
Write-Host "   - Click on 'Client scopes' tab" -ForegroundColor Gray
Write-Host "   - Click on '$ClientId-dedicated' scope" -ForegroundColor Gray
Write-Host "   - Click 'Add mapper' > 'By configuration'" -ForegroundColor Gray
Write-Host "   - Select 'Audience'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Configure the Audience Mapper:" -ForegroundColor White
Write-Host "   - Name: audience-mapper" -ForegroundColor Gray
Write-Host "   - Included Client Audience: $TargetAudience" -ForegroundColor Gray
Write-Host "   - Add to ID token: OFF" -ForegroundColor Gray
Write-Host "   - Add to access token: ON" -ForegroundColor Gray
Write-Host "   - Click 'Save'" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Test the fix:" -ForegroundColor White
Write-Host "   - Logout from your Blazor app" -ForegroundColor Gray
Write-Host "   - Login again to get a new token" -ForegroundColor Gray
Write-Host "   - Copy the new token and decode it" -ForegroundColor Gray
Write-Host "   - Verify it now includes: 'aud': ['$TargetAudience']" -ForegroundColor Gray
Write-Host "   - Test protected endpoints in Swagger" -ForegroundColor Gray
Write-Host ""
Write-Host "Alternative: Quick Test with Modified API Config" -ForegroundColor Cyan
Write-Host "If you want to test immediately without changing Keycloak:" -ForegroundColor Yellow
Write-Host "You can temporarily modify your API to accept the 'azp' claim as audience." -ForegroundColor Yellow
Write-Host ""
