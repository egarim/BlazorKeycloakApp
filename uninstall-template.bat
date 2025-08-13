@echo off
echo ================================================
echo  KeyCloak Templates Uninstaller
echo ================================================
echo.

echo Uninstalling KeyCloak REST API template...
dotnet new uninstall KeyClokRestApi

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to uninstall API template!
    pause
    exit /b 1
)

echo ? SUCCESS: API Template uninstalled successfully!
echo.

echo Uninstalling KeyCloak Blazor Server template...
dotnet new uninstall KeyClokBlazorServer

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to uninstall Blazor Server template!
    pause
    exit /b 1
)

echo ? SUCCESS: Blazor Server Template uninstalled successfully!
echo.

pause