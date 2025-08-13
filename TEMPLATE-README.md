# KeyCloak Templates Collection

A comprehensive collection of .NET templates for creating applications with KeyCloak authentication integration.

## ?? Templates Available

### 1. KeyCloak REST API Template
- **Short Name**: `keycloak-api`
- **Package ID**: KeyClokRestApi
- **Version**: 2.0.0
- **Description**: REST API with KeyCloak JWT authentication, Swagger integration, and comprehensive testing endpoints

### 2. KeyCloak Blazor Server Template  
- **Short Name**: `keycloak-blazor-server`
- **Package ID**: KeyClokBlazorServer
- **Version**: 2.0.0
- **Description**: Blazor Server application with KeyCloak OIDC authentication, API integration, and diagnostics

## ?? Quick Start

### 1. Package Both Templates
```bash
# Windows (Command Prompt)
pack.bat

# Windows/Linux/macOS (PowerShell)
./pack.ps1
```

### 2. Install Both Templates
```bash
# Windows (Command Prompt)
install-template.bat

# Windows/Linux/macOS (PowerShell)
./install-template.ps1
```

### 3. Create New Projects
```bash
# Create REST API
dotnet new keycloak-api --name "MyCompany.Api"

# Create Blazor Server App
dotnet new keycloak-blazor-server --name "MyCompany.Web"
```

## ??? Template Features Comparison

| Feature | REST API Template | Blazor Server Template |
|---------|------------------|----------------------|
| **Authentication** | JWT Bearer | OIDC + Cookies |
| **KeyCloak Integration** | ? Token validation | ? Full OIDC flow |
| **Swagger UI** | ? With JWT auth | ? N/A |
| **API Testing** | ? Built-in endpoints | ? API test page |
| **Role Authorization** | ? Admin/User roles | ? Admin/User roles |
| **Diagnostics** | ? Token analysis | ? Full diagnostics |
| **CORS Support** | ? Configurable | ? N/A |
| **Template Parameters** | 8 parameters | 8 parameters |

## ?? Template Parameters

### REST API Template Parameters
| Parameter | Default | Description |
|-----------|---------|-------------|
| `--Framework` | `net9.0` | Target framework |
| `--KeycloakRealm` | `blazor-app` | KeyCloak realm name |
| `--KeycloakUrl` | `http://localhost:8080` | KeyCloak server URL |
| `--ApiAudience` | `my-api` | API audience for JWT validation |
| `--AllowedOrigins` | `https://localhost:7001,https://localhost:7003` | CORS origins |
| `--EnableSwaggerInProduction` | `false` | Enable Swagger in production |
| `--RequireHttpsMetadata` | `false` | Require HTTPS metadata |

### Blazor Server Template Parameters  
| Parameter | Default | Description |
|-----------|---------|-------------|
| `--Framework` | `net9.0` | Target framework |
| `--KeycloakRealm` | `blazor-app` | KeyCloak realm name |
| `--KeycloakUrl` | `http://localhost:8080` | KeyCloak server URL |
| `--ClientId` | `blazor-server` | KeyCloak client ID |
| `--ClientSecret` | `your-blazor-client-secret-here` | KeyCloak client secret |
| `--ApiBaseUrl` | `https://localhost:7002` | API server base URL |
| `--RequireHttpsMetadata` | `false` | Require HTTPS metadata |
| `--IncludeApiIntegration` | `true` | Include API integration services |
| `--EnableDiagnostics` | `true` | Enable authentication diagnostics |

## ?? Management Scripts

| Script | Purpose |
|--------|---------|
| `pack.bat` / `pack.ps1` | Package both templates for distribution |
| `install-template.bat` / `install-template.ps1` | Install both templates locally |
| `uninstall-template.bat` / `uninstall-template.ps1` | Remove both templates |

## ?? Usage Examples

### Example 1: Simple API + Blazor App
```bash
# Create API
dotnet new keycloak-api --name "MyCompany.Api"

# Create Blazor Server app  
dotnet new keycloak-blazor-server --name "MyCompany.Web"
```

### Example 2: Custom KeyCloak Configuration
```bash
# Create API with custom settings
dotnet new keycloak-api \
  --name "MyCompany.ProductApi" \
  --KeycloakRealm "production-realm" \
  --KeycloakUrl "https://auth.mycompany.com" \
  --ApiAudience "product-api"

# Create Blazor app with matching settings
dotnet new keycloak-blazor-server \
  --name "MyCompany.ProductWeb" \
  --KeycloakRealm "production-realm" \
  --KeycloakUrl "https://auth.mycompany.com" \
  --ClientId "product-web" \
  --ApiBaseUrl "https://api.mycompany.com"
```

### Example 3: Development Setup
```bash
# Minimal setup for local development
dotnet new keycloak-api --name "DevApi" --ApiAudience "dev-api"
dotnet new keycloak-blazor-server --name "DevWeb" --ClientId "dev-web"
```

## ??? Architecture Overview

```
???????????????????????    ???????????????????????    ???????????????????
?   Blazor Server     ?    ?     REST API        ?    ?    KeyCloak     ?
? (OIDC + Cookies)    ?????? (JWT Bearer Auth)   ??????   (Identity     ?
?                     ?    ?                     ?    ?    Provider)    ?
???????????????????????    ???????????????????????    ???????????????????
         ?                           ?                          ?
         ????????????????????????????????????????????????????????
                                     ?
                         ?????????????????????????
                         ?   Shared KeyCloak     ?
                         ?       Realm           ?
                         ?   - Users & Roles     ?
                         ?   - Client Configs    ?
                         ?   - Audience Mappers  ?
                         ?????????????????????????
```

## ?? Testing the Templates

### REST API Template Testing
1. **Create project**: `dotnet new keycloak-api --name "TestApi"`
2. **Run**: `dotnet run`
3. **Access Swagger**: Navigate to `https://localhost:5001`
4. **Test endpoints**:
   - `/api/authtest/ping` (public)
   - `/api/authtest/analyze-token` (requires auth)
   - `/api/values/protected` (requires auth)
   - `/api/values/admin-only` (requires admin role)

### Blazor Server Template Testing
1. **Create project**: `dotnet new keycloak-blazor-server --name "TestWeb"`
2. **Run**: `dotnet run`  
3. **Access app**: Navigate to `https://localhost:5001`
4. **Test authentication**:
   - Visit welcome page (public)
   - Login with KeyCloak
   - Access protected pages
   - Use API test page for diagnostics

## ?? Troubleshooting

### Common Issues

1. **Template packaging fails**:
   ```bash
   # Clean and rebuild
   dotnet clean
   ./pack.ps1
   ```

2. **Template installation fails**:
   ```bash
   # Uninstall old versions first
   ./uninstall-template.ps1
   ./install-template.ps1
   ```

3. **Generated projects don't build**:
   - Ensure .NET 9.0 SDK is installed
   - Check template parameter values
   - Verify KeyCloak configuration

### Template Development

To modify templates:
1. Make changes in `BlazorApi` or `BlazorServer` directories
2. Run `pack.ps1` to repackage
3. Run `uninstall-template.ps1` then `install-template.ps1` to update

## ?? Requirements

- **.NET 9.0 SDK** (or .NET 8.0 if using Framework parameter)
- **KeyCloak instance** (for runtime authentication)
- **PowerShell 7.0+** (for cross-platform scripts)

## ?? Project Structure

```
BlazorKeycloakApp/
??? BlazorApi/                          # REST API Template Source
?   ??? .template.config/               # Template configuration
?   ??? Controllers/                    # API controllers
?   ??? BlazorApi.csproj               # Template project file
?   ??? README.md                      # Template documentation
??? BlazorServer/                      # Blazor Server Template Source  
?   ??? .template.config/              # Template configuration
?   ??? Pages/                         # Blazor pages
?   ??? Services/                      # Authentication services
?   ??? BlazorServer.csproj           # Template project file
?   ??? README.md                     # Template documentation
??? template-packages/                 # Generated NuGet packages
??? pack.bat / pack.ps1               # Packaging scripts
??? install-template.bat / .ps1       # Installation scripts
??? uninstall-template.bat / .ps1     # Uninstallation scripts
??? TEMPLATE-README.md                # This file
```

## ?? License

These templates are designed for creating KeyCloak-authenticated applications with comprehensive testing and debugging capabilities.

---

**Template Collection Version**: 2.0.0  
**Compatible with**: .NET 8.0, .NET 9.0  
**KeyCloak**: Any compatible version