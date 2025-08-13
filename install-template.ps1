#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak REST API Template Installer" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$packagePath = "template-packages/KeyClokRestApi.2.0.0.nupkg"

if (!(Test-Path $packagePath)) {
    Write-Host "ERROR: Template package not found!" -ForegroundColor Red
    Write-Host "Please run pack.ps1 first to create the template package." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "Installing KeyCloak REST API template..." -ForegroundColor Yellow
$result = dotnet new install $packagePath

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to install template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host ""
Write-Host "? SUCCESS: Template installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Usage:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"My.Api`"" -ForegroundColor White
Write-Host ""
Write-Host "With custom parameters:" -ForegroundColor Yellow
Write-Host "  dotnet new keycloak-api --name `"MyCompany.MyApi`" --KeycloakRealm `"my-realm`" --ApiAudience `"my-api`"" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue..."