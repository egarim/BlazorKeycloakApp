#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak Templates Installer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$apiPackagePath = "template-packages/KeyClokRestApi.2.0.0.nupkg"
$blazorPackagePath = "template-packages/KeyClokBlazorServer.2.0.0.nupkg"

if (!(Test-Path $apiPackagePath)) {
    Write-Host "ERROR: API Template package not found!" -ForegroundColor Red
    Write-Host "Please run pack.ps1 first to create the template packages." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

if (!(Test-Path $blazorPackagePath)) {
    Write-Host "ERROR: Blazor Server Template package not found!" -ForegroundColor Red
    Write-Host "Please run pack.ps1 first to create the template packages." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "Installing KeyCloak REST API template..." -ForegroundColor Yellow
$result = dotnet new install $apiPackagePath

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to install API template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: API Template installed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "Installing KeyCloak Blazor Server template..." -ForegroundColor Yellow
$result = dotnet new install $blazorPackagePath

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to install Blazor Server template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: Blazor Server Template installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host " INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Yellow
Write-Host ""
Write-Host "REST API Template:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"My.Api`"" -ForegroundColor White
Write-Host ""
Write-Host "Blazor Server Template:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-blazor-server --name `"My.BlazorApp`"" -ForegroundColor White
Write-Host ""
Write-Host "With custom parameters:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"MyCompany.MyApi`" --KeycloakRealm `"my-realm`" --ApiAudience `"my-api`"" -ForegroundColor Gray
Write-Host "  dotnet new keycloak-blazor-server --name `"MyCompany.MyApp`" --ClientId `"my-client`" --KeycloakRealm `"my-realm`"" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to continue..."