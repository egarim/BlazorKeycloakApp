#!/usr/bin/env pwsh

# Combined Template Packing Script
# Packs and installs both RestAPI and BlazorServer templates

param(
    [string]$OutputDir = "template-packages",
    [switch]$ApiOnly,
    [switch]$BlazorOnly,
    [switch]$SkipInstall,
    [switch]$Force,
    [switch]$Verbose
)

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Combined Template Packing Script" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Template definitions
$Templates = @(
    @{
        Name = "RestApiWithKeyClock"
        ShortName = "restapiwithkeycloak"
        Directory = "BlazorApi"
        Description = "REST API with Keycloak JWT Authentication"
        Skip = $BlazorOnly
    },
    @{
        Name = "BlazorServerWithKeyClock"
        ShortName = "blazorserverwithkeycloak"
        Directory = "BlazorServer"
        Description = "Blazor Server with Keycloak OIDC Authentication"
        Skip = $ApiOnly
    }
)

# Function to write verbose output
function Write-VerboseOutput($Message) {
    if ($Verbose) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkGray
    }
}

# Function to handle errors
function Write-ErrorMessage($Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

# Function to pack and install a template
function Pack-Template($Template) {
    Write-Host ""
    Write-Host "Processing: $($Template.Description)" -ForegroundColor Green
    Write-Host "Directory: $($Template.Directory)" -ForegroundColor Yellow
    Write-Host "Package: $($Template.Name)" -ForegroundColor Yellow
    Write-Host ""

    # Check if template directory exists
    if (-not (Test-Path $Template.Directory)) {
        Write-ErrorMessage "Template directory '$($Template.Directory)' not found!"
        return $false
    }

    # Check if template configuration exists
    $TemplateConfigPath = Join-Path $Template.Directory ".template.config" "template.json"
    if (-not (Test-Path $TemplateConfigPath)) {
        Write-ErrorMessage "Template configuration not found! Expected: $TemplateConfigPath"
        return $false
    }

    Write-VerboseOutput "Template configuration found: $TemplateConfigPath"

    # Remove existing installation
    try {
        Write-Host "Uninstalling existing template..." -ForegroundColor Yellow
        dotnet new uninstall $Template.Name 2>&1 | Out-Null
        dotnet new uninstall $Template.ShortName 2>&1 | Out-Null
    } catch {
        Write-VerboseOutput "Uninstall failed (expected if not previously installed): $_"
    }

    # Clean build artifacts
    $BinPath = Join-Path $Template.Directory "bin"
    $ObjPath = Join-Path $Template.Directory "obj"

    if (Test-Path $BinPath) {
        Write-VerboseOutput "Removing bin directory..."
        Remove-Item $BinPath -Recurse -Force
    }

    if (Test-Path $ObjPath) {
        Write-VerboseOutput "Removing obj directory..."
        Remove-Item $ObjPath -Recurse -Force
    }

    # Remove old packages
    Get-ChildItem -Path $OutputDir -Filter "$($Template.Name)*.nupkg" -ErrorAction SilentlyContinue | Remove-Item -Force

    # Pack the template
    Write-Host "Packing template..." -ForegroundColor Green
    $PackCommand = "dotnet pack `"$($Template.Directory)`" -o `"$OutputDir`" --configuration Release"
    Write-VerboseOutput "Command: $PackCommand"

    $packResult = Invoke-Expression $PackCommand
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMessage "Failed to pack template: $($Template.Name)"
        return $false
    }

    # Find the generated package
    $PackageFiles = Get-ChildItem -Path $OutputDir -Filter "$($Template.Name)*.nupkg"
    if ($PackageFiles.Count -eq 0) {
        Write-ErrorMessage "No .nupkg file found for template: $($Template.Name)"
        return $false
    }

    $PackageFile = $PackageFiles[0].FullName
    Write-Host "? Template packed successfully: $($PackageFiles[0].Name)" -ForegroundColor Green

    # Install the template (unless skipped)
    if (-not $SkipInstall) {
        Write-Host "Installing template..." -ForegroundColor Green
        $InstallCommand = "dotnet new install `"$PackageFile`""
        Write-VerboseOutput "Command: $InstallCommand"
        
        $installResult = Invoke-Expression $InstallCommand
        if ($LASTEXITCODE -ne 0) {
            Write-ErrorMessage "Failed to install template: $($Template.Name)"
            return $false
        }
        
        Write-Host "? Template installed successfully" -ForegroundColor Green
    }

    return $true
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    Write-Host "Creating output directory: $OutputDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Process templates
$SuccessCount = 0
$TotalCount = 0

foreach ($Template in $Templates) {
    if ($Template.Skip) {
        Write-VerboseOutput "Skipping template: $($Template.Name)"
        continue
    }
    
    $TotalCount++
    $success = Pack-Template $Template
    if ($success) {
        $SuccessCount++
    }
}

# Summary
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

if ($SuccessCount -eq $TotalCount) {
    Write-Host "? All templates processed successfully! ($SuccessCount/$TotalCount)" -ForegroundColor Green
} else {
    Write-Host "??  Some templates failed to process ($SuccessCount/$TotalCount successful)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Available Templates:" -ForegroundColor Yellow

foreach ($Template in $Templates) {
    if (-not $Template.Skip) {
        Write-Host "  dotnet new $($Template.ShortName) --name MyProject" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Management Commands:" -ForegroundColor Yellow
Write-Host "  dotnet new list" -ForegroundColor White -NoNewline; Write-Host " (list all templates)" -ForegroundColor DarkGray
Write-Host "  dotnet new uninstall <template-name>" -ForegroundColor White -NoNewline; Write-Host " (uninstall template)" -ForegroundColor DarkGray

if ($SkipInstall) {
    Write-Host ""
    Write-Host "Note: Templates were packed but not installed (--SkipInstall was specified)" -ForegroundColor Yellow
    Write-Host "To install manually, use: dotnet new install <package-file>" -ForegroundColor White
}

Write-Host ""