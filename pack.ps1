#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak Templates Packager v2.0.0" -ForegroundColor Cyan  
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will package both templates:" -ForegroundColor Yellow
Write-Host "1. KeyCloak REST API Template (KeyClokRestApi)" -ForegroundColor White
Write-Host "2. KeyCloak Blazor Server Template (KeyClokBlazorServer)" -ForegroundColor White
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
$apiPackage = "$OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg"
$blazorPackage = "$OUTPUT_DIR/KeyClokBlazorServer.2.0.0.nupkg"

if (Test-Path $apiPackage) {
    Remove-Item $apiPackage -Force
    Write-Host "Previous KeyClokRestApi package deleted." -ForegroundColor Green
}
if (Test-Path $blazorPackage) {
    Remove-Item $blazorPackage -Force
    Write-Host "Previous KeyClokBlazorServer package deleted." -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Packaging KeyCloak REST API Template" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Package the API template
$result = dotnet pack BlazorApi -o $OUTPUT_DIR

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to pack API template!" -ForegroundColor Red
    Write-Host "Please check the template configuration and try again." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: API Template packaged successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Packaging KeyCloak Blazor Server Template" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Package the Blazor Server template
$result = dotnet pack BlazorServer -o $OUTPUT_DIR

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to pack Blazor Server template!" -ForegroundColor Red
    Write-Host "Please check the template configuration and try again." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: Blazor Server Template packaged successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " PACKAGING COMPLETE" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package locations:" -ForegroundColor Yellow
Write-Host "  $OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg" -ForegroundColor White
Write-Host "  $OUTPUT_DIR/KeyClokBlazorServer.2.0.0.nupkg" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Installation Instructions" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To install templates locally:" -ForegroundColor Yellow
Write-Host "  dotnet new install `"$OUTPUT_DIR/KeyClokRestApi.2.0.0.nupkg`"" -ForegroundColor White
Write-Host "  dotnet new install `"$OUTPUT_DIR/KeyClokBlazorServer.2.0.0.nupkg`"" -ForegroundColor White
Write-Host ""
Write-Host "To uninstall:" -ForegroundColor Yellow
Write-Host "  dotnet new uninstall KeyClokRestApi" -ForegroundColor White
Write-Host "  dotnet new uninstall KeyClokBlazorServer" -ForegroundColor White
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " Template Usage" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "REST API Template:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"My.Api`"" -ForegroundColor White
Write-Host "  dotnet new keycloak-api --name `"MyCompany.MyApi`" --KeycloakRealm `"my-realm`"" -ForegroundColor Gray
Write-Host ""
Write-Host "Blazor Server Template:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-blazor-server --name `"My.BlazorApp`"" -ForegroundColor White
Write-Host "  dotnet new keycloak-blazor-server --name `"MyCompany.MyApp`" --ClientId `"my-client`"" -ForegroundColor Gray
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan

Read-Host "Press Enter to continue..."