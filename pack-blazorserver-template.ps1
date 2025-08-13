#!/usr/bin/env pwsh

# Blazor Server with Keycloak Template Packing Script
# Cross-platform PowerShell script to pack and install the template

param(
    [string]$TemplateDir = "BlazorServer",
    [string]$OutputDir = "template-packages",
    [switch]$Force,
    [switch]$SkipInstall,
    [switch]$Verbose
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Blazor Server with Keycloak Template " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TemplateName = "BlazorServerWithKeyClock"
$TemplateShortName = "blazorserverwithkeycloak"

# Function to write verbose output
function Write-VerboseOutput($Message) {
    if ($Verbose) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

# Function to handle errors
function Write-ErrorAndExit($Message, $ExitCode = 1) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit $ExitCode
}

Write-Host "Creating template package from $TemplateDir..." -ForegroundColor Green
Write-Host ""

# Check if template directory exists
if (-not (Test-Path $TemplateDir)) {
    Write-ErrorAndExit "Template directory '$TemplateDir' not found! Make sure you're running this script from the solution root directory. Current directory: $(Get-Location)"
}

# Check if template configuration exists
$TemplateConfigPath = Join-Path $TemplateDir ".template.config" "template.json"
if (-not (Test-Path $TemplateConfigPath)) {
    Write-ErrorAndExit "Template configuration not found! Expected: $TemplateConfigPath"
}

Write-VerboseOutput "Template configuration found: $TemplateConfigPath"

# Create output directory if it doesn't exist
if (-not (Test-Path $OutputDir)) {
    Write-Host "Creating output directory: $OutputDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Remove any existing template installation
Write-Host "Checking for existing template installation..." -ForegroundColor Yellow

try {
    $uninstallResult = dotnet new uninstall $TemplateName 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Previous template installation removed." -ForegroundColor Green
    } else {
        Write-Host "No previous installation found." -ForegroundColor Yellow
    }
} catch {
    Write-VerboseOutput "Uninstall attempt failed: $_"
}

# Also try to uninstall by short name
try {
    dotnet new uninstall $TemplateShortName 2>&1 | Out-Null
} catch {
    Write-VerboseOutput "Uninstall by short name failed: $_"
}

# Clean the template directory
Write-Host ""
Write-Host "Cleaning template directory..." -ForegroundColor Yellow

$BinPath = Join-Path $TemplateDir "bin"
$ObjPath = Join-Path $TemplateDir "obj"

if (Test-Path $BinPath) {
    Write-VerboseOutput "Removing bin directory..."
    Remove-Item $BinPath -Recurse -Force
}

if (Test-Path $ObjPath) {
    Write-VerboseOutput "Removing obj directory..."
    Remove-Item $ObjPath -Recurse -Force
}

# Remove any existing packages
Write-Host "Cleaning old packages..." -ForegroundColor Yellow
Get-ChildItem -Path $OutputDir -Filter "$TemplateName*.nupkg" | Remove-Item -Force

# Pack the template
Write-Host ""
Write-Host "Packing template..." -ForegroundColor Green
$PackCommand = "dotnet pack `"$TemplateDir`" -o `"$OutputDir`" --configuration Release"
Write-VerboseOutput "Command: $PackCommand"

$packResult = Invoke-Expression $PackCommand
if ($LASTEXITCODE -ne 0) {
    Write-ErrorAndExit "Failed to pack template! Check the output above for detailed error information."
}

# Find the generated .nupkg file
Write-Host ""
Write-Host "Looking for generated package..." -ForegroundColor Yellow

$PackageFiles = Get-ChildItem -Path $OutputDir -Filter "$TemplateName*.nupkg"
if ($PackageFiles.Count -eq 0) {
    Write-Host "Directory contents:" -ForegroundColor Red
    Get-ChildItem $OutputDir | Format-Table Name, Length, LastWriteTime
    Write-ErrorAndExit "No .nupkg file found in $OutputDir. Expected pattern: $TemplateName*.nupkg"
}

$PackageFile = $PackageFiles[0].FullName
Write-Host "Found package: $($PackageFiles[0].Name)" -ForegroundColor Green
Write-Host "Template packed successfully: $PackageFile" -ForegroundColor Green

# Install the template (unless skipped)
if (-not $SkipInstall) {
    Write-Host ""
    Write-Host "Installing template..." -ForegroundColor Green
    $InstallCommand = "dotnet new install `"$PackageFile`""
    Write-VerboseOutput "Command: $InstallCommand"
    
    $installResult = Invoke-Expression $InstallCommand
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "Failed to install template! Check the output above for detailed error information."
    }

    # Verify installation
    Write-Host ""
    Write-Host "Verifying template installation..." -ForegroundColor Yellow
    dotnet new list $TemplateShortName
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Template Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Template Name: " -NoNewline; Write-Host $TemplateName -ForegroundColor White
Write-Host "Short Name: " -NoNewline; Write-Host $TemplateShortName -ForegroundColor White
Write-Host "Package: " -NoNewline; Write-Host $(Split-Path $PackageFile -Leaf) -ForegroundColor White
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Yellow
Write-Host "  dotnet new $TemplateShortName --name MyBlazorApp" -ForegroundColor White
Write-Host "  dotnet new $TemplateShortName --name MyBlazorApp --output ./MyBlazorProject" -ForegroundColor White
Write-Host "  dotnet new $TemplateShortName --name MyBlazorApp --AuthorityUrl `"http://localhost:8080/realms/my-realm`"" -ForegroundColor White
Write-Host "  dotnet new $TemplateShortName --help" -ForegroundColor White
Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host "  dotnet new list" -ForegroundColor White -NoNewline; Write-Host " (list all templates)" -ForegroundColor DarkGray
Write-Host "  dotnet new uninstall $TemplateName" -ForegroundColor White -NoNewline; Write-Host " (uninstall template)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Quick Test:" -ForegroundColor Yellow
Write-Host "  mkdir test-blazor && cd test-blazor" -ForegroundColor White
Write-Host "  dotnet new $TemplateShortName --name TestBlazorApp" -ForegroundColor White
Write-Host "  dotnet run" -ForegroundColor White
Write-Host ""

if ($SkipInstall) {
    Write-Host "Note: Template was packed but not installed (--SkipInstall was specified)" -ForegroundColor Yellow
    Write-Host "To install manually: dotnet new install `"$PackageFile`"" -ForegroundColor White
    Write-Host ""
}