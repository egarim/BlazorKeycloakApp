@echo off
echo ================================================
echo  KeyCloak Templates Installer
echo ================================================
echo.

if not exist "template-packages\KeyClokRestApi.2.0.0.nupkg" (
    echo ERROR: API Template package not found!
    echo Please run pack.bat first to create the template packages.
    pause
    exit /b 1
)

if not exist "template-packages\KeyClokBlazorServer.2.0.0.nupkg" (
    echo ERROR: Blazor Server Template package not found!
    echo Please run pack.bat first to create the template packages.
    pause
    exit /b 1
)

echo Installing KeyCloak REST API template...
dotnet new install "template-packages\KeyClokRestApi.2.0.0.nupkg"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to install API template!
    pause
    exit /b 1
)

echo ? SUCCESS: API Template installed successfully!
echo.

echo Installing KeyCloak Blazor Server template...
dotnet new install "template-packages\KeyClokBlazorServer.2.0.0.nupkg"

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to install Blazor Server template!
    pause
    exit /b 1
)

echo ? SUCCESS: Blazor Server Template installed successfully!
echo.
echo ================================================
echo  INSTALLATION COMPLETE
echo ================================================
echo.
echo Usage Examples:
echo.
echo REST API Template:
echo   dotnet new keycloak-api --name "My.Api"
echo.
echo Blazor Server Template:
echo   dotnet new keycloak-blazor-server --name "My.BlazorApp"
echo.
echo With custom parameters:
echo   dotnet new keycloak-api --name "MyCompany.MyApi" --KeycloakRealm "my-realm" --ApiAudience "my-api"
echo   dotnet new keycloak-blazor-server --name "MyCompany.MyApp" --ClientId "my-client" --KeycloakRealm "my-realm"
echo.

pause