@echo off
echo ================================================
echo  KeyCloak Templates Packager v2.0.0
echo ================================================
echo.
echo This script will package both templates:
echo 1. KeyCloak REST API Template (KeyClokRestApi)
echo 2. KeyCloak Blazor Server Template (KeyClokBlazorServer)
echo.

REM Set output directory
set OUTPUT_DIR=.\template-packages

REM Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM Clean previous packages
echo Cleaning previous packages...
if exist "%OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg" (
    del "%OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg"
    echo Previous KeyClokRestApi package deleted.
)
if exist "%OUTPUT_DIR%\KeyClokBlazorServer.2.0.0.nupkg" (
    del "%OUTPUT_DIR%\KeyClokBlazorServer.2.0.0.nupkg"
    echo Previous KeyClokBlazorServer package deleted.
)

echo.
echo ================================================
echo  Packaging KeyCloak REST API Template
echo ================================================

REM Package the API template
dotnet pack BlazorApi -o "%OUTPUT_DIR%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to pack API template!
    echo Please check the template configuration and try again.
    pause
    exit /b 1
)

echo ? SUCCESS: API Template packaged successfully!

echo.
echo ================================================
echo  Packaging KeyCloak Blazor Server Template  
echo ================================================

REM Package the Blazor Server template
dotnet pack BlazorServer -o "%OUTPUT_DIR%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to pack Blazor Server template!
    echo Please check the template configuration and try again.
    pause
    exit /b 1
)

echo ? SUCCESS: Blazor Server Template packaged successfully!

echo.
echo ================================================
echo  PACKAGING COMPLETE
echo ================================================
echo.
echo Package locations:
echo   %OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg
echo   %OUTPUT_DIR%\KeyClokBlazorServer.2.0.0.nupkg
echo.
echo ================================================
echo  Installation Instructions
echo ================================================
echo.
echo To install templates locally:
echo   dotnet new install "%OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg"
echo   dotnet new install "%OUTPUT_DIR%\KeyClokBlazorServer.2.0.0.nupkg"
echo.
echo To uninstall:
echo   dotnet new uninstall KeyClokRestApi
echo   dotnet new uninstall KeyClokBlazorServer
echo.
echo ================================================
echo  Template Usage
echo ================================================
echo.
echo REST API Template:
echo   dotnet new keycloak-api --name "My.Api"
echo   dotnet new keycloak-api --name "MyCompany.MyApi" --KeycloakRealm "my-realm"
echo.
echo Blazor Server Template:
echo   dotnet new keycloak-blazor-server --name "My.BlazorApp"
echo   dotnet new keycloak-blazor-server --name "MyCompany.MyApp" --ClientId "my-client"
echo.
echo ================================================

pause