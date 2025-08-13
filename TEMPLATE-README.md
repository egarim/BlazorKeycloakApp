# KeyCloak REST API Template

A comprehensive .NET template for creating REST APIs with KeyCloak JWT authentication integration.

## ?? Quick Start

### 1. Package the Template
```bash
# Windows (Command Prompt)
pack.bat

# Windows/Linux/macOS (PowerShell)
./pack.ps1
```

### 2. Install the Template
```bash
# Windows (Command Prompt)
install-template.bat

# Windows/Linux/macOS (PowerShell)
./install-template.ps1

# Or manually
dotnet new install "template-packages/KeyClokRestApi.2.0.0.nupkg"
```

### 3. Create a New API Project
```bash
# Basic usage
dotnet new keycloak-api --name "My.Api"

# With custom parameters
dotnet new keycloak-api --name "MyCompany.MyApi" --KeycloakRealm "my-realm" --ApiAudience "my-api"
```

### 4. Configure and Run
```bash
cd MyCompany.MyApi
# Update appsettings.json with your KeyCloak settings
dotnet run
```

Navigate to `https://localhost:5001` to access Swagger UI.

## ?? Template Information

- **Template Name**: KeyCloak REST API  
- **Short Name**: `keycloak-api`
- **Version**: 2.0.0
- **Package ID**: KeyClokRestApi

## ??? Template Parameters

| Parameter | Description | Default Value | Example |
|-----------|-------------|---------------|---------|
| `--name` | Project name | Current directory | `"My.Api"` |
| `--Framework` | Target framework | `net9.0` | `net8.0` |
| `--KeycloakRealm` | KeyCloak realm name | `blazor-app` | `"my-realm"` |
| `--KeycloakUrl` | KeyCloak server URL | `http://localhost:8080` | `"https://keycloak.mycompany.com"` |
| `--ApiAudience` | API audience for JWT validation | `my-api` | `"company-api"` |
| `--AllowedOrigins` | Comma-separated CORS origins | `https://localhost:7001,https://localhost:7003` | `"https://myapp.com,https://admin.myapp.com"` |
| `--EnableSwaggerInProduction` | Enable Swagger in production | `false` | `true` |
| `--RequireHttpsMetadata` | Require HTTPS metadata | `false` | `true` |

## ?? Features

? **Complete KeyCloak Integration** - JWT Bearer authentication with comprehensive token validation  
? **Swagger Integration** - Interactive API documentation with JWT authentication support  
? **Authentication Testing** - Comprehensive endpoints for testing authentication flow  
? **Role-based Authorization** - Support for admin/user roles from KeyCloak  
? **CORS Configuration** - Configurable cross-origin resource sharing  
? **Comprehensive Diagnostics** - Full authentication debugging tools  
? **Template Parameterization** - Customizable settings via template parameters

## ?? Generated API Endpoints

### Authentication Testing
- `GET /api/authtest/ping` - Health check (no auth required)
- `GET /api/authtest/analyze-token` - Detailed JWT token analysis
- `GET /api/authtest/auth-required` - Test basic authentication
- `GET /api/authtest/admin-required` - Test admin role requirement
- `GET /api/authtest/user-required` - Test user role requirement

### User Management  
- `GET /api/user/profile` - Get current user profile
- `GET /api/user/admin-only` - Admin-only endpoint
- `GET /api/user/user-data` - User or admin endpoint

### Sample Data
- `GET /api/values` - Public endpoint (no auth required)
- `GET /api/values/protected` - Protected endpoint
- `GET /api/values/admin-only` - Admin-only endpoint

## ?? KeyCloak Setup

1. **Create a realm** in KeyCloak
2. **Create a client** with appropriate settings:
   - **Client Type**: Bearer-only or Public
   - **Valid Redirect URIs**: Configure as needed
   - **Audience Mapper**: Add audience mapper to include API audience in tokens
3. **Create roles** (admin, user) and assign to users
4. **Update appsettings.json** with your KeyCloak configuration

## ?? Generated Project Structure

```
MyApi/
??? Controllers/
?   ??? AuthTestController.cs    # Authentication testing endpoints
?   ??? UserController.cs        # User management endpoints
?   ??? ValuesController.cs      # Sample data endpoints
??? appsettings.json             # Configuration (parameterized)
??? appsettings.Development.json # Development configuration
??? Program.cs                   # Application startup (parameterized)
??? MyApi.csproj                 # Project file
??? README.md                    # Project documentation
```

## ??? Management Scripts

| Script | Purpose |
|--------|---------|
| `pack.bat` / `pack.ps1` | Package the template for distribution |
| `install-template.bat` / `install-template.ps1` | Install the template locally |
| `uninstall-template.bat` / `uninstall-template.ps1` | Remove the template |

## ?? Usage Examples

### Example 1: Basic API
```bash
dotnet new keycloak-api --name "MyCompany.UserApi"
```

### Example 2: Custom KeyCloak Configuration
```bash
dotnet new keycloak-api \
  --name "MyCompany.ProductApi" \
  --KeycloakRealm "production-realm" \
  --KeycloakUrl "https://auth.mycompany.com" \
  --ApiAudience "product-api"
```

### Example 3: Production Ready
```bash
dotnet new keycloak-api \
  --name "MyCompany.SecureApi" \
  --KeycloakRealm "prod-realm" \
  --RequireHttpsMetadata true \
  --EnableSwaggerInProduction false \
  --AllowedOrigins "https://myapp.com,https://admin.myapp.com"
```

## ?? Testing the Generated API

1. **Start the API**:
   ```bash
   dotnet run
   ```

2. **Access Swagger UI**: Navigate to `https://localhost:5001`

3. **Test Authentication**:
   - Use the `/api/authtest/ping` endpoint to verify the API is running
   - Get a JWT token from your KeyCloak instance
   - Use the "Authorize" button in Swagger to add your Bearer token
   - Test protected endpoints

4. **Debugging**: Use the `/api/authtest/analyze-token` endpoint for detailed token analysis

## ?? Troubleshooting

### Common Issues

1. **Template not found**:
   ```bash
   # Ensure template is packaged
   ./pack.ps1
   # Then install
   ./install-template.ps1
   ```

2. **Authentication failures**:
   - Verify KeyCloak realm and client configuration
   - Check JWT token includes correct audience claim
   - Use `/api/authtest/analyze-token` for debugging

3. **CORS errors**:
   - Verify allowed origins in `appsettings.json`
   - Ensure client application URLs are included

### Template Development

To modify the template:
1. Make changes in the `BlazorApi` directory
2. Run `pack.ps1` to repackage
3. Run `uninstall-template.ps1` then `install-template.ps1` to update

## ?? License

This template is designed for creating KeyCloak-authenticated REST APIs with comprehensive testing and debugging capabilities.

---

**Template Version**: 2.0.0  
**Compatible with**: .NET 8.0, .NET 9.0  
**KeyCloak**: Any compatible version