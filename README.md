# BlazorKeycloakApp

This repository contains a comprehensive Blazor solution demonstrating authentication with Keycloak, consisting of three applications and two reusable .NET project templates:

- **BlazorServer**: A Blazor Server application using OpenID Connect authentication
- **BlazorApi**: A Web API using JWT Bearer authentication
- **BlazorWebAssembly**: A Blazor WebAssembly application using OIDC authentication
- **RestApiWithKeyClock Template**: A .NET project template for creating REST APIs with Keycloak authentication
- **BlazorServerWithKeyClock Template**: A .NET project template for creating Blazor Server apps with Keycloak authentication

## 🚀 Quick Start

### Prerequisites
- .NET 9.0 SDK
- Keycloak server running on http://localhost:8080
- PowerShell (for setup scripts)

### Setup Steps

1. **Start Keycloak** (if not already running)
2. **(Optional) Set environment variables for secure credential management**:
   ```powershell
   $env:KEYCLOAK_ADMIN_PASSWORD = "your-admin-password"  # if different from 'admin'
   ```
3. **Run the automated setup**:
   ```powershell
   .\setup-keycloak-complete.ps1
   ```
4. **⚠️ IMPORTANT: Configure Client Secret**:
   - The setup script will show instructions to get the client secret from Keycloak
   - Open: http://localhost:8080/admin
   - Navigate to: Realms > blazor-app > Clients > blazor-server > Credentials tab
   - Copy the "Client secret" value
   - Update `BlazorServer/appsettings.json`:
   ```json
   {
     "Keycloak": {
       "Authority": "http://localhost:8080/realms/blazor-app",
       "ClientId": "blazor-server",
       "ClientSecret": "YOUR_ACTUAL_CLIENT_SECRET_HERE",
       "RequireHttpsMetadata": false
     }
   }
   ```
5. **Start the applications**:
   ```powershell
   # Terminal 1 - API
   cd BlazorApi
   dotnet run
   
   # Terminal 2 - Blazor Server
   cd BlazorServer
   dotnet run
   
   # Terminal 3 - Blazor WebAssembly
   cd BlazorWebAssembly
   dotnet run
   ```
6. **Test the application**:
   - Navigate to: https://localhost:7001 (Server) or https://localhost:7003 (WebAssembly)
   - Login with: `testuser / Test123!`
   - Test API endpoints at: https://localhost:7001/api-test or https://localhost:7003/api-test
   - Test with Swagger UI at: https://localhost:7002/swagger

## 📦 Project Templates

### REST API Template - RestApiWithKeyClock

The **RestApiWithKeyClock** template allows you to quickly create new REST API projects with Keycloak JWT authentication pre-configured.

#### Pack and Install REST API Template

You can use either the batch file (Windows) or PowerShell script (cross-platform):

**Windows Batch File:**
```batch
# From the solution root directory
pack-template.bat
```

**PowerShell (Cross-Platform):**
```powershell
# Basic usage
.\pack-template.ps1

# With options
.\pack-template.ps1 -Verbose -Force
```

#### Using the REST API Template

```bash
# Basic usage - creates a project with default settings
dotnet new restapiwithkeycloak --name MyApiProject

# Customize Keycloak settings
dotnet new restapiwithkeycloak --name MyApiProject \
  --AuthorityUrl "http://localhost:8080/realms/my-realm" \
  --Audience "my-api" \
  --CorsOrigin "https://localhost:3000"
```

**What the REST API Template Includes:**
- ✅ JWT Bearer Authentication with Keycloak
- ✅ Swagger UI with JWT Bearer support
- ✅ CORS configuration
- ✅ Authorization policies (Admin, User, Authentication)
- ✅ Sample controllers with role-based security
- ✅ Comprehensive error handling

### Blazor Server Template - BlazorServerWithKeyClock

The **BlazorServerWithKeyClock** template allows you to quickly create new Blazor Server projects with Keycloak OpenID Connect authentication pre-configured.

#### Pack and Install Blazor Server Template

**Windows Batch File:**
```batch
# From the solution root directory
pack-blazorserver-template.bat
```

**PowerShell (Cross-Platform):**
```powershell
# Basic usage
.\pack-blazorserver-template.ps1

# With options
.\pack-blazorserver-template.ps1 -Verbose -Force
```

#### Using the Blazor Server Template

```bash
# Basic usage - creates a project with default settings
dotnet new blazorserverwithkeycloak --name MyBlazorApp

# Customize Keycloak settings
dotnet new blazorserverwithkeycloak --name MyBlazorApp \
  --AuthorityUrl "http://localhost:8080/realms/my-realm" \
  --ClientId "my-blazor-client" \
  --ApiBaseUrl "https://localhost:5001"
```

**What the Blazor Server Template Includes:**
- ✅ OpenID Connect Authentication with Keycloak
- ✅ Cookie-based session management
- ✅ Role-based authorization policies
- ✅ Comprehensive API integration with JWT token handling
- ✅ Authentication diagnostic tools
- ✅ Protected and public pages (Home, Profile, API Test, Welcome)
- ✅ User profile management with claims display
- ✅ Token analysis and debugging capabilities

#### Template Parameters

**REST API Template Parameters:**
| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `--name` | Project name and namespace | Required |
| `--AuthorityUrl` | Keycloak authority URL | http://localhost:8080/realms/your-realm |
| `--Audience` | JWT audience for validation | your-api |
| `--CorsOrigin` | CORS allowed origin | https://localhost:7001 |

**Blazor Server Template Parameters:**
| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `--name` | Project name and namespace | Required |
| `--AuthorityUrl` | Keycloak authority URL | http://localhost:8080/realms/your-realm |
| `--ClientId` | Keycloak client ID | your-blazor-client |
| `--ClientSecret` | Client secret placeholder | your-client-secret-here |
| `--ApiBaseUrl` | API base URL for integration | https://localhost:7002 |

### Combined Template Management

**Pack Both Templates:**
```powershell
# Pack and install both templates
.\pack-all-templates.ps1

# Pack only (don't install)
.\pack-all-templates.ps1 -SkipInstall

# Pack only API template
.\pack-all-templates.ps1 -ApiOnly

# Pack only Blazor Server template
.\pack-all-templates.ps1 -BlazorOnly
```

**Test Templates:**
```powershell
# Test REST API template
.\test-template.ps1

# Test Blazor Server template
.\test-blazorserver-template.ps1
```

**Template Management Commands:**
```bash
# List all installed templates
dotnet new list

# View specific template details
dotnet new restapiwithkeycloak --help
dotnet new blazorserverwithkeycloak --help

# Uninstall templates
dotnet new uninstall RestApiWithKeyClock
dotnet new uninstall BlazorServerWithKeyClock
```

### Template Development Workflow

When working on the templates:

1. **Make Changes**: Edit files in the BlazorApi or BlazorServer projects
2. **Test Changes**: Run the projects to verify functionality
3. **Update Templates**: Run the appropriate pack script to repack and install
4. **Test Templates**: Run the test scripts to verify templates work correctly
5. **Validate**: Create test projects and verify all features work

## 🔧 Features & Tools

### 🔍 Comprehensive Diagnostics
The applications include advanced debugging tools accessible at `/api-test`:

- **🔍 Run Full Diagnostics**: Complete authentication analysis
- **🎟️ Analyze Token**: Deep JWT token inspection with audience/issuer validation
- **🔒 Test Protected Endpoint**: Detailed HTTP request/response analysis
- **⚙️ Check Configuration**: Verify all settings
- **📋 Copy Token**: One-click token copying for Swagger testing

### 🔧 Swagger UI with JWT Authentication
Enhanced Swagger UI with JWT Bearer token support:
- **URL**: https://localhost:7002
- **Features**: 
  - JWT Bearer authentication
  - Test all endpoints directly
  - Detailed authentication debugging endpoints
  - Copy tokens directly from Blazor app

### 🛠️ Setup & Management Scripts

| Script | Purpose |
|--------|---------|
| `setup-keycloak-complete.ps1` | **Complete automated setup** - Creates realm, clients, users, roles, and audience mappers |
| `delete-realm.ps1` | **Clean slate** - Safely deletes realm for fresh start |
| `pack-template.bat` / `pack-template.ps1` | **REST API template packaging** - Creates and installs the REST API template |
| `pack-blazorserver-template.bat` / `pack-blazorserver-template.ps1` | **Blazor Server template packaging** - Creates and installs the Blazor Server template |
| `pack-all-templates.ps1` | **Combined template packaging** - Handles both templates |
| `test-template.ps1` | **REST API template testing** - Verifies REST API template functionality |
| `test-blazorserver-template.ps1` | **Blazor Server template testing** - Verifies Blazor Server template functionality |

## 🔐 Authentication Implementation

### BlazorServer Authentication

The Blazor Server application implements OpenID Connect authentication with Cookie authentication for session management:

**Key Features:**
- OpenID Connect with PKCE (Proof Key for Code Exchange) for enhanced security
- Cookie-based session management
- Automatic token storage and refresh
- Role-based authorization with Keycloak realm roles
- Custom error handling and authentication events

### BlazorApi Authentication

The API implements JWT Bearer authentication to validate tokens issued by Keycloak:

**Key Features:**
- JWT Bearer token validation
- Keycloak realm role transformation
- CORS configuration for Blazor requests
- Token lifetime validation with 5-minute clock skew tolerance
- Custom token validation events for role mapping

### BlazorWebAssembly Authentication

The WebAssembly app implements OIDC authentication with public client configuration:

**Key Features:**
- OIDC authentication with public client
- JWT token management in browser storage
- Automatic token inclusion in API requests
- Role-based authorization
- Comprehensive token analysis tools

## Project Structure

### BlazorServer Project (Template Source)
- **Program.cs**: OpenID Connect authentication and authorization configuration
- **Pages/**: Protected and public pages including comprehensive API testing
- **Services/**: Custom services for authentication and API communication
- **.template.config/**: Template configuration for project generation

### BlazorApi Project (Template Source)
- **Program.cs**: JWT authentication and CORS configuration
- **Controllers/**: API endpoints protected with `[Authorize]` attributes
- **.template.config/**: Template configuration for project generation

### BlazorWebAssembly Project
- **Program.cs**: OIDC authentication configuration
- **Pages/**: Protected and public pages
- **Services/**: API communication services with authentication

## Architecture

### Authentication Flow
1. User initiates login via Blazor Server/WebAssembly
2. Redirected to Keycloak for authentication
3. Keycloak returns authorization code
4. Application exchanges code for tokens
5. Access token used for API calls
6. JWT tokens include proper audience claims for API validation

### Token Management
- Access tokens automatically included in API requests
- Tokens cached and managed by authentication middleware
- Automatic token refresh handled by the framework
- Comprehensive token analysis available via diagnostic tools

## Test Credentials

The application includes test credentials for development:
- **Username**: `testuser`
- **Password**: `Test123!`

## Development Notes

- The applications use HTTPS redirect but allow HTTP for Keycloak in development (`RequireHttpsMetadata: false`)
- PKCE is enabled for enhanced security
- Tokens are automatically stored and managed by the authentication middleware
- Role claims are automatically transformed from Keycloak's realm roles
- CORS is configured to allow requests from the Blazor apps to the API
- All necessary redirect URIs are pre-configured for seamless authentication flows

## Contributing

When contributing to this project or using the templates:

1. **Update Templates**: Make changes to the BlazorApi or BlazorServer projects
2. **Test Changes**: Run the projects to verify functionality
3. **Repack Templates**: Run the appropriate pack scripts to update the templates
4. **Test Templates**: Run the test scripts to verify template functionality
5. **Update Documentation**: Update this README with any new features or changes

This comprehensive setup provides a complete foundation for building secure, modern web applications with Keycloak authentication, plus the ability to quickly scaffold new projects using the included templates.