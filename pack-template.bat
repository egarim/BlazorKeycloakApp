@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo   REST API with Keycloak Template 
echo ========================================
echo.

set TEMPLATE_DIR=BlazorApi
set TEMPLATE_NAME=RestApiWithKeyClock
set OUTPUT_DIR=template-packages
set TEMPLATE_SHORT_NAME=restapiwithkeycloak

echo Creating template package from %TEMPLATE_DIR%...
echo.

:: Check if template directory exists
if not exist "%TEMPLATE_DIR%" (
    echo ERROR: Template directory '%TEMPLATE_DIR%' not found!
    echo Make sure you're running this script from the solution root directory.
    echo Current directory: %CD%
    pause
    exit /b 1
)

:: Check if template.json exists
if not exist "%TEMPLATE_DIR%\.template.config\template.json" (
    echo ERROR: Template configuration not found!
    echo Expected: %TEMPLATE_DIR%\.template.config\template.json
    pause
    exit /b 1
)

:: Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" (
    echo Creating output directory: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

:: Remove any existing template installation
echo Checking for existing template installation...
dotnet new uninstall %TEMPLATE_NAME% 2>nul
if !errorlevel! equ 0 (
    echo Previous template installation removed.
) else (
    echo No previous installation found.
)

:: Also try to uninstall by short name
dotnet new uninstall %TEMPLATE_SHORT_NAME% 2>nul

:: Clean the template directory
echo.
echo Cleaning template directory...
if exist "%TEMPLATE_DIR%\bin" (
    echo Removing bin directory...
    rmdir /s /q "%TEMPLATE_DIR%\bin"
)
if exist "%TEMPLATE_DIR%\obj" (
    echo Removing obj directory...
    rmdir /s /q "%TEMPLATE_DIR%\obj"
)

:: Remove any existing packages
echo Cleaning old packages...
del /q "%OUTPUT_DIR%\%TEMPLATE_NAME%*.nupkg" 2>nul

:: Pack the template
echo.
echo Packing template...
echo Command: dotnet pack "%TEMPLATE_DIR%" -o "%OUTPUT_DIR%" --configuration Release
dotnet pack "%TEMPLATE_DIR%" -o "%OUTPUT_DIR%" --configuration Release

if !errorlevel! neq 0 (
    echo.
    echo ERROR: Failed to pack template!
    echo Check the output above for detailed error information.
    pause
    exit /b 1
)

:: Find the generated .nupkg file
echo.
echo Looking for generated package...
set PACKAGE_FILE=
for %%f in ("%OUTPUT_DIR%\%TEMPLATE_NAME%*.nupkg") do (
    set PACKAGE_FILE=%%f
    echo Found package: %%f
)

if not defined PACKAGE_FILE (
    echo ERROR: No .nupkg file found in %OUTPUT_DIR%
    echo Expected pattern: %TEMPLATE_NAME%*.nupkg
    dir "%OUTPUT_DIR%"
    pause
    exit /b 1
)

echo.
echo Template packed successfully: !PACKAGE_FILE!

:: Install the template
echo.
echo Installing template...
echo Command: dotnet new install "!PACKAGE_FILE!"
dotnet new install "!PACKAGE_FILE!"

if !errorlevel! neq 0 (
    echo.
    echo ERROR: Failed to install template!
    echo Check the output above for detailed error information.
    pause
    exit /b 1
)

:: Verify installation
echo.
echo Verifying template installation...
dotnet new list %TEMPLATE_SHORT_NAME%

echo.
echo ========================================
echo Template Installation Complete!
echo ========================================
echo.
echo Template Name: %TEMPLATE_NAME%
echo Short Name: %TEMPLATE_SHORT_NAME%
echo Package: !PACKAGE_FILE!
echo.
echo Usage Examples:
echo   dotnet new %TEMPLATE_SHORT_NAME% --name MyApi
echo   dotnet new %TEMPLATE_SHORT_NAME% --name MyApi --output ./MyApiProject
echo   dotnet new %TEMPLATE_SHORT_NAME% --name MyApi --AuthorityUrl "http://localhost:8080/realms/my-realm"
echo   dotnet new %TEMPLATE_SHORT_NAME% --help
echo.
echo To list all available templates:
echo   dotnet new list
echo.
echo To uninstall this template:
echo   dotnet new uninstall %TEMPLATE_NAME%
echo.
echo Quick Test:
echo   mkdir test-api
echo   cd test-api
echo   dotnet new %TEMPLATE_SHORT_NAME% --name TestApi
echo   dotnet run
echo.

pause