@echo off
echo ================================================
echo  KeyCloak REST API Template Installer
echo ================================================
echo.

if not exist "template-packages\KeyClokRestApi.2.0.0.nupkg" (
    echo ERROR: Template package not found!
    echo Please run pack.bat first to create the template package.
    pause
    exit /b 1
)

echo Installing KeyCloak REST API template...
dotnet new install "template-packages\KeyClokRestApi.2.0.0.nupkg"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to install template!
    pause
    exit /b 1
)

echo.
echo ? SUCCESS: Template installed successfully!
echo.
echo Usage:
echo   dotnet new keycloak-api --name "My.Api"
echo.
echo With custom parameters:
echo   dotnet new keycloak-api --name "MyCompany.MyApi" --KeycloakRealm "my-realm" --ApiAudience "my-api"
echo.

pause