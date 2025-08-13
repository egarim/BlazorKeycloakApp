#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak REST API Template Packager v2.0.0" -ForegroundColor Cyan  
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Set output directory
$OUTPUT_DIR = "./template-packages"

# Create output directory if it doesn't exist
if (!(Test-Path $OUTPUT_DIR)) {
    Write-Host "Creating output directory: $OUTPUT_DIR" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OUTPUT_DIR -Force | Out-Null
}

# Clean previous packages
Write-Host "Cleaning previous packages..." -ForegroundColor Yellow
$existingPackage = "$OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg"
if (Test-Path $existingPackage) {
    Remove-Item $existingPackage -Force
    Write-Host "Previous package deleted." -ForegroundColor Green
}

Write-Host ""
Write-Host "Packaging template from BlazorApi directory..." -ForegroundColor Yellow
Write-Host ""

# Package the template
$result = dotnet pack BlazorApi -o $OUTPUT_DIR

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to pack template!" -ForegroundColor Red
    Write-Host "Please check the template configuration and try again." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host ""
Write-Host "? SUCCESS: Template packaged successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Package location: $OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg" -ForegroundColor Cyan
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Installation Instructions" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To install this template locally:" -ForegroundColor Yellow
Write-Host "  dotnet new install `"$OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg`"" -ForegroundColor White
Write-Host ""
Write-Host "To uninstall:" -ForegroundColor Yellow
Write-Host "  dotnet new uninstall KeyClokRestApi" -ForegroundColor White
Write-Host ""
Write-Host "To use the template:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"My.Api`"" -ForegroundColor White
Write-Host ""
Write-Host "Available parameters:" -ForegroundColor Yellow
Write-Host "  --name              Project name (e.g., `"My.Api`")" -ForegroundColor Gray
Write-Host "  --Framework         Target framework (net9.0, net8.0)" -ForegroundColor Gray
Write-Host "  --KeycloakRealm     KeyCloak realm name" -ForegroundColor Gray
Write-Host "  --KeycloakUrl       KeyCloak server URL" -ForegroundColor Gray
Write-Host "  --ApiAudience       API audience for JWT validation" -ForegroundColor Gray
Write-Host "  --AllowedOrigins    Comma-separated CORS origins" -ForegroundColor Gray
Write-Host "  --EnableSwaggerInProduction   Enable Swagger in production" -ForegroundColor Gray
Write-Host "  --RequireHttpsMetadata        Require HTTPS metadata" -ForegroundColor Gray
Write-Host ""
Write-Host "Example with parameters:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"MyCompany.MyApi`" --KeycloakRealm `"my-realm`" --ApiAudience `"my-api`"" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."