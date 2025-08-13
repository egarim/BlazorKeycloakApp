# Keycloak .NET Templates - Quick Start Guide

This guide will help you quickly get started with the two Keycloak authentication templates:

## ?? Available Templates

### 1. REST API with Keycloak (RestApiWithKeyClock)
- **Template Name**: `restapiwithkeycloak`
- **Description**: REST API with JWT Bearer authentication
- **Use Case**: Backend API services, microservices

### 2. Blazor Server with Keycloak (BlazorServerWithKeyClock)
- **Template Name**: `blazorserverwithkeycloak`
- **Description**: Blazor Server app with OpenID Connect authentication
- **Use Case**: Web applications, admin dashboards, internal tools

## ?? Quick Installation

### Option 1: Install Both Templates
```powershell
# Pack and install both templates at once
.\pack-all-templates.ps1
```

### Option 2: Install Individual Templates
```batch
# REST API Template (Windows)
pack-template.bat

# Blazor Server Template (Windows)
pack-blazorserver-template.bat
```

```powershell
# REST API Template (Cross-platform)
.\pack-template.ps1

# Blazor Server Template (Cross-platform)
.\pack-blazorserver-template.ps1
```

## ?? Creating New Projects

### REST API Project
```bash
# Basic REST API
dotnet new restapiwithkeycloak --name MyApi

# With custom Keycloak settings
dotnet new restapiwithkeycloak --name MyApi \
  --AuthorityUrl "http://localhost:8080/realms/my-realm" \
  --Audience "my-api"
```

### Blazor Server Project
```bash
# Basic Blazor Server app
dotnet new blazorserverwithkeycloak --name MyBlazorApp

# With custom Keycloak settings
dotnet new blazorserverwithkeycloak --name MyBlazorApp \
  --AuthorityUrl "http://localhost:8080/realms/my-realm" \
  --ClientId "my-blazor-client"
```

## ?? Configuration Steps

### 1. Keycloak Setup (Required for both templates)

1. **Start Keycloak**:
   ```bash
   # Using Docker
   docker run -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:latest start-dev
   ```

2. **Create Realm and Clients**:
   - Use the automated setup script: `.\setup-keycloak-complete.ps1`
   - Or manually configure in Keycloak Admin Console

### 2. REST API Configuration

1. **Update `appsettings.json`**:
   ```json
   {
     "Keycloak": {
       "Authority": "http://localhost:8080/realms/your-realm",
       "Audience": "your-api",
       "RequireHttpsMetadata": false
     }
   }
   ```

2. **Run and Test**:
   ```bash
   dotnet run
   # Navigate to: https://localhost:5001/swagger
   ```

### 3. Blazor Server Configuration

1. **Update `appsettings.json`**:
   ```json
   {
     "Keycloak": {
       "Authority": "http://localhost:8080/realms/your-realm",
       "ClientId": "your-blazor-client",
       "ClientSecret": "GET_FROM_KEYCLOAK_ADMIN",
       "RequireHttpsMetadata": false
     }
   }
   ```

2. **Get Client Secret**:
   - Open Keycloak Admin Console: http://localhost:8080/admin
   - Navigate to: Realms > your-realm > Clients > your-blazor-client > Credentials
   - Copy the Client Secret

3. **Run and Test**:
   ```bash
   dotnet run
   # Navigate to: https://localhost:5001
   ```

## ?? Testing Your Setup

### Test Templates Work Correctly
```powershell
# Test REST API template
.\test-template.ps1

# Test Blazor Server template
.\test-blazorserver-template.ps1
```

### Test Authentication
1. **Login**: Use test credentials `testuser / Test123!`
2. **API Testing**: Use the `/api-test` page in Blazor apps
3. **Swagger**: Test API endpoints with JWT tokens

## ?? Common Parameters

| Parameter | REST API Template | Blazor Server Template | Description |
|-----------|------------------|----------------------|-------------|
| `--name` | ? Required | ? Required | Project name and namespace |
| `--output` | ? Optional | ? Optional | Output directory |
| `--Framework` | ? Optional | ? Optional | Target framework (net8.0/net9.0) |
| `--AuthorityUrl` | ? Optional | ? Optional | Keycloak authority URL |
| `--Audience` | ? Optional | ? | JWT audience for API validation |
| `--ClientId` | ? | ? Optional | OIDC client ID |
| `--ClientSecret` | ? | ? Optional | Client secret placeholder |
| `--CorsOrigin` | ? Optional | ? | CORS allowed origin |
| `--ApiBaseUrl` | ? | ? Optional | Backend API URL |

## ?? Template Management

```bash
# List all templates
dotnet new list

# View template help
dotnet new restapiwithkeycloak --help
dotnet new blazorserverwithkeycloak --help

# Uninstall templates
dotnet new uninstall RestApiWithKeyClock
dotnet new uninstall BlazorServerWithKeyClock

# Reinstall (after making changes)
.\pack-all-templates.ps1
```

## ?? What You Get

### REST API Template Includes:
- ? JWT Bearer authentication with Keycloak
- ? Swagger UI with authentication support
- ? Sample controllers (AuthTest, User, Values)
- ? Role-based authorization policies
- ? CORS configuration
- ? Comprehensive error handling

### Blazor Server Template Includes:
- ? OpenID Connect authentication with Keycloak
- ? Protected and public pages
- ? User profile with claims display
- ? API integration with JWT token handling
- ? Authentication diagnostic tools
- ? Role-based navigation and authorization
- ? Session management with cookies

## ?? Troubleshooting

### Template Installation Issues
```bash
# Clear template cache
dotnet new --debug:ephemeral-hive

# Reinstall templates
.\pack-all-templates.ps1 -Force
```

### Authentication Issues
1. **Check Keycloak is running**: http://localhost:8080
2. **Verify realm and client configuration**
3. **Use diagnostic tools in Blazor apps**: `/api-test` page
4. **Check client secret** (for Blazor Server apps)

### Build Issues
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

## ?? Example Complete Workflow

```bash
# 1. Install templates
.\pack-all-templates.ps1

# 2. Create API project
mkdir MyProject && cd MyProject
dotnet new restapiwithkeycloak --name MyApi

# 3. Create Blazor app
dotnet new blazorserverwithkeycloak --name MyBlazorApp

# 4. Setup Keycloak (from main solution directory)
cd ..
.\setup-keycloak-complete.ps1

# 5. Update configurations with your realm settings
# Edit MyProject/MyApi/appsettings.json
# Edit MyProject/MyBlazorApp/appsettings.json

# 6. Run projects
cd MyProject
# Terminal 1: dotnet run --project MyApi
# Terminal 2: dotnet run --project MyBlazorApp
```

## ?? Next Steps

1. **Customize Authentication**: Add custom claims, policies, or roles
2. **Integrate Services**: Connect to databases, external APIs
3. **Deploy**: Configure for production environments
4. **Extend Templates**: Modify source projects and repack templates

For detailed documentation, see the main [README.md](README.md) file.