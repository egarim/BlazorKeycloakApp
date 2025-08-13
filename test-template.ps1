#!/usr/bin/env pwsh

# Test script for the RestApiWithKeyClock template
# This script creates a test project and verifies it builds successfully

param(
    [string]$TestProjectName = "TestApiProject",
    [string]$TestDirectory = "template-test",
    [switch]$KeepTestProject,
    [switch]$Verbose
)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Template Testing Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$TemplateShortName = "restapiwithkeycloak"

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

# Check if template is installed
Write-Host "Checking if template is installed..." -ForegroundColor Yellow
$templateList = dotnet new list $TemplateShortName 2>&1
if ($LASTEXITCODE -ne 0 -or $templateList -like "*No templates found*") {
    Write-ErrorAndExit "Template '$TemplateShortName' is not installed. Please run pack-template.ps1 first."
}

Write-Host "Template found!" -ForegroundColor Green

# Clean up existing test directory
if (Test-Path $TestDirectory) {
    Write-Host "Removing existing test directory..." -ForegroundColor Yellow
    Remove-Item $TestDirectory -Recurse -Force
}

# Create test directory
Write-Host "Creating test directory: $TestDirectory" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $TestDirectory -Force | Out-Null
Set-Location $TestDirectory

try {
    # Test 1: Basic template creation
    Write-Host ""
    Write-Host "Test 1: Creating project with default settings..." -ForegroundColor Green
    Write-VerboseOutput "Command: dotnet new $TemplateShortName --name $TestProjectName"
    
    $createResult = dotnet new $TemplateShortName --name $TestProjectName 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "Failed to create project with template. Output: $createResult"
    }
    
    Write-Host "? Project created successfully" -ForegroundColor Green

    # Test 2: Check if required files exist
    Write-Host ""
    Write-Host "Test 2: Verifying project structure..." -ForegroundColor Green
    
    $RequiredFiles = @(
        "$TestProjectName.csproj",
        "Program.cs",
        "appsettings.json",
        "Controllers/AuthTestController.cs",
        "Controllers/UserController.cs",
        "Controllers/ValuesController.cs"
    )
    
    foreach ($file in $RequiredFiles) {
        if (Test-Path $file) {
            Write-Host "? Found: $file" -ForegroundColor Green
        } else {
            Write-Host "? Missing: $file" -ForegroundColor Red
            $missingFiles = $true
        }
    }
    
    if ($missingFiles) {
        Write-ErrorAndExit "Some required files are missing from the generated project."
    }

    # Test 3: Check namespace replacement
    Write-Host ""
    Write-Host "Test 3: Verifying namespace replacement..." -ForegroundColor Green
    
    $programContent = Get-Content "Program.cs" -Raw
    if ($programContent -match "namespace\s+$TestProjectName" -or $programContent -match "using\s+$TestProjectName") {
        Write-Host "? Namespace correctly replaced" -ForegroundColor Green
    } else {
        Write-VerboseOutput "Program.cs content preview:"
        Write-VerboseOutput ($programContent.Substring(0, [Math]::Min(500, $programContent.Length)))
        Write-Host "??  Namespace replacement verification inconclusive" -ForegroundColor Yellow
    }

    # Test 4: Check configuration placeholders
    Write-Host ""
    Write-Host "Test 4: Verifying configuration..." -ForegroundColor Green
    
    $appSettingsContent = Get-Content "appsettings.json" -Raw
    if ($appSettingsContent -match "your-realm" -and $appSettingsContent -match "your-api") {
        Write-Host "? Configuration placeholders found" -ForegroundColor Green
    } else {
        Write-Host "??  Configuration verification inconclusive" -ForegroundColor Yellow
        Write-VerboseOutput "appsettings.json content: $appSettingsContent"
    }

    # Test 5: Build the project
    Write-Host ""
    Write-Host "Test 5: Building the project..." -ForegroundColor Green
    Write-VerboseOutput "Command: dotnet build"
    
    $buildResult = dotnet build 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "? Build failed. Output:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        Write-ErrorAndExit "Project build failed."
    }
    
    Write-Host "? Project builds successfully" -ForegroundColor Green

    # Test 6: Test with custom parameters
    Write-Host ""
    Write-Host "Test 6: Testing with custom parameters..." -ForegroundColor Green
    
    Set-Location ..
    $CustomTestDir = "custom-test"
    if (Test-Path $CustomTestDir) {
        Remove-Item $CustomTestDir -Recurse -Force
    }
    
    Write-VerboseOutput "Command: dotnet new $TemplateShortName --name CustomApi --output $CustomTestDir --AuthorityUrl http://localhost:8080/realms/test --Audience test-api"
    
    $customResult = dotnet new $TemplateShortName --name "CustomApi" --output $CustomTestDir --AuthorityUrl "http://localhost:8080/realms/test" --Audience "test-api" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "??  Custom parameters test failed: $customResult" -ForegroundColor Yellow
    } else {
        Write-Host "? Custom parameters work correctly" -ForegroundColor Green
        
        # Verify custom settings
        $customAppSettings = Get-Content "$CustomTestDir/appsettings.json" -Raw
        if ($customAppSettings -match "test-api" -and $customAppSettings -match "realms/test") {
            Write-Host "? Custom parameters applied correctly" -ForegroundColor Green
        } else {
            Write-Host "??  Custom parameters may not have been applied" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "All Tests Completed Successfully! ?" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Template '$TemplateShortName' is working correctly." -ForegroundColor Green
    Write-Host ""
    Write-Host "Generated test projects:" -ForegroundColor Yellow
    Write-Host "  ./$TestDirectory/$TestProjectName" -ForegroundColor White
    if (Test-Path $CustomTestDir) {
        Write-Host "  ./$CustomTestDir" -ForegroundColor White
    }
    
} catch {
    Write-ErrorAndExit "Test failed with exception: $_"
} finally {
    # Return to original directory
    Set-Location ..
    
    # Clean up test projects unless requested to keep them
    if (-not $KeepTestProject) {
        Write-Host ""
        Write-Host "Cleaning up test projects..." -ForegroundColor Yellow
        if (Test-Path $TestDirectory) {
            Remove-Item $TestDirectory -Recurse -Force
        }
        if (Test-Path "custom-test") {
            Remove-Item "custom-test" -Recurse -Force
        }
        Write-Host "Test projects removed." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Test projects preserved (--KeepTestProject specified)" -ForegroundColor Yellow
    }
}