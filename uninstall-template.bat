@echo off
echo ================================================
echo  KeyCloak REST API Template Uninstaller
echo ================================================
echo.

echo Uninstalling KeyCloak REST API template...
dotnet new uninstall KeyClokRestApi

if %ERRORLEVEL% neq 0 (
    echo.
    echo ? ERROR: Failed to uninstall template!
    pause
    exit /b 1
)

echo.
echo ? SUCCESS: Template uninstalled successfully!
echo.

pause