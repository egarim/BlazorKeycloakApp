# PowerShell script to update Keycloak client configuration for logout redirect URIs
# This script will help you configure the correct redirect URIs in your Keycloak client

Write-Host "=== Keycloak Client Configuration Update ===" -ForegroundColor Green
Write-Host ""
Write-Host "To fix the logout redirect URI issue, you need to update your Keycloak client configuration."
Write-Host ""

Write-Host "1. Open your Keycloak Admin Console:" -ForegroundColor Yellow
Write-Host "   http://localhost:8080/admin" -ForegroundColor Cyan
Write-Host ""

Write-Host "2. Login with your admin credentials" -ForegroundColor Yellow
Write-Host ""

Write-Host "3. Navigate to: Realms > blazor-app > Clients > blazor-server" -ForegroundColor Yellow
Write-Host ""

Write-Host "4. Go to the 'Settings' tab and update the following fields:" -ForegroundColor Yellow
Write-Host ""

Write-Host "   Valid redirect URIs (add these if not present):" -ForegroundColor Cyan
Write-Host "   - https://localhost:7001/signin-oidc" -ForegroundColor White
Write-Host "   - https://localhost:7001/signout-callback-oidc" -ForegroundColor White
Write-Host "   - https://localhost:7001/" -ForegroundColor White
Write-Host ""

Write-Host "   Valid post logout redirect URIs (add these):" -ForegroundColor Cyan
Write-Host "   - https://localhost:7001/" -ForegroundColor White
Write-Host "   - https://localhost:7001/signout-callback-oidc" -ForegroundColor White
Write-Host ""

Write-Host "   Web origins (if not present):" -ForegroundColor Cyan
Write-Host "   - https://localhost:7001" -ForegroundColor White
Write-Host ""

Write-Host "5. Click 'Save' to save the changes" -ForegroundColor Yellow
Write-Host ""

Write-Host "6. After saving, restart your Blazor application:" -ForegroundColor Yellow
Write-Host "   - Stop the running application (Ctrl+C)" -ForegroundColor White
Write-Host "   - Run: dotnet run --urls=`"https://localhost:7001`"" -ForegroundColor White
Write-Host ""

Write-Host "Alternative: Quick JSON Configuration" -ForegroundColor Green
Write-Host "If you prefer to update via JSON export/import:" -ForegroundColor Yellow
Write-Host ""

$jsonConfig = @"
{
  "redirectUris": [
    "https://localhost:7001/signin-oidc",
    "https://localhost:7001/signout-callback-oidc",
    "https://localhost:7001/"
  ],
  "postLogoutRedirectUris": [
    "https://localhost:7001/",
    "https://localhost:7001/signout-callback-oidc"
  ],
  "webOrigins": [
    "https://localhost:7001"
  ]
}
"@

Write-Host "JSON snippet to add to your client configuration:" -ForegroundColor Cyan
Write-Host $jsonConfig -ForegroundColor White
Write-Host ""

Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
