#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak Templates Uninstaller" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Uninstalling KeyCloak REST API template..." -ForegroundColor Yellow
$result = dotnet new uninstall KeyClokRestApi

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to uninstall API template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: API Template uninstalled successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "Uninstalling KeyCloak Blazor Server template..." -ForegroundColor Yellow
$result = dotnet new uninstall KeyClokBlazorServer

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to uninstall Blazor Server template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "? SUCCESS: Blazor Server Template uninstalled successfully!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to continue..."