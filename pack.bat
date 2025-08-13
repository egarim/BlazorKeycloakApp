@echo off
echo ================================================
echo  KeyCloak REST API Template Packager v2.0.0
echo ================================================
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
    echo Previous package deleted.
)

echo.
echo Packaging template from BlazorApi directory...
echo.

REM Package the template
dotnet pack BlazorApi -o "%OUTPUT_DIR%"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to pack template!
    echo Please check the template configuration and try again.
    pause
    exit /b 1
)

echo.
echo ? SUCCESS: Template packaged successfully!
echo.
echo Package location: %OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg
echo.
echo ================================================
echo  Installation Instructions
echo ================================================
echo.
echo To install this template locally:
echo   dotnet new install "%OUTPUT_DIR%\KeyClokRestApi.2.0.0.nupkg"
echo.
echo To uninstall:
echo   dotnet new uninstall KeyClokRestApi
echo.
echo To use the template:
echo   dotnet new keycloak-api --name "My.Api"
echo.
echo Available parameters:
echo   --name              Project name (e.g., "My.Api")
echo   --Framework         Target framework (net9.0, net8.0)
echo   --KeycloakRealm     KeyCloak realm name
echo   --KeycloakUrl       KeyCloak server URL
echo   --ApiAudience       API audience for JWT validation
echo   --AllowedOrigins    Comma-separated CORS origins
echo   --EnableSwaggerInProduction   Enable Swagger in production
echo   --RequireHttpsMetadata        Require HTTPS metadata
echo.
echo Example with parameters:
echo   dotnet new keycloak-api --name "MyCompany.MyApi" --KeycloakRealm "my-realm" --ApiAudience "my-api"
echo.
echo ================================================

pause