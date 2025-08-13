#!/usr/bin/env pwsh

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " KeyCloak REST API Template Uninstaller" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Uninstalling KeyCloak REST API template..." -ForegroundColor Yellow
$result = dotnet new uninstall KeyClokRestApi

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "? ERROR: Failed to uninstall template!" -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host ""
Write-Host "? SUCCESS: Template uninstalled successfully!" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to continue..."