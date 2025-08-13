# KeyCloak REST API Template

This template creates a REST API with KeyCloak JWT authentication integration.

## Features

? **Complete KeyCloak Integration** - JWT Bearer authentication with comprehensive token validation  
? **Swagger Integration** - Interactive API documentation with JWT authentication support  
? **Authentication Testing** - Comprehensive endpoints for testing authentication flow  
? **Role-based Authorization** - Support for admin/user roles from KeyCloak  
? **CORS Configuration** - Configurable cross-origin resource sharing  
? **Comprehensive Diagnostics** - Full authentication debugging tools  

## Usage

```bash
dotnet new keycloak-api --name "My.Api" --KeycloakRealm "my-realm" --ApiAudience "my-api"
```

## Parameters

- `--name`: The name of the project (default: current directory name)
- `--Framework`: Target framework - net9.0 or net8.0 (default: net9.0)
- `--KeycloakRealm`: KeyCloak realm name (default: blazor-app)
- `--KeycloakUrl`: KeyCloak server URL (default: http://localhost:8080)
- `--ApiAudience`: API audience for JWT validation (default: my-api)
- `--AllowedOrigins`: Comma-separated CORS origins (default: https://localhost:7001,https://localhost:7003)
- `--EnableSwaggerInProduction`: Enable Swagger in production (default: false)
- `--RequireHttpsMetadata`: Require HTTPS for KeyCloak metadata (default: false)

## Quick Start

1. **Create new project**:
   ```bash
   dotnet new keycloak-api --name "MyCompany.MyApi"
   ```

2. **Configure KeyCloak**:
   - Update `appsettings.json` with your KeyCloak settings
   - Ensure your KeyCloak realm has the appropriate client configured

3. **Run the application**:
   ```bash
   dotnet run
   ```

4. **Test with Swagger**:
   - Navigate to: `https://localhost:5001`
   - Use the authentication endpoints to get a JWT token
   - Test protected endpoints with Bearer authentication

## API Endpoints

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

## Configuration

The template generates an `appsettings.json` with KeyCloak configuration:

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/my-realm",
    "Audience": "my-api",
    "RequireHttpsMetadata": false
  },
  "Cors": {
    "AllowedOrigins": ["https://localhost:7001", "https://localhost:7003"]
  }
}
```

## KeyCloak Setup

1. Create a realm in KeyCloak
2. Create a client with:
   - **Client Type**: Bearer-only or Public
   - **Valid Redirect URIs**: Configure as needed
   - **Audience Mapper**: Add audience mapper to include API audience in tokens

3. Create roles (admin, user) and assign to users

## Advanced Features

- **Comprehensive JWT Validation**: Validates issuer, audience, lifetime, and signing key
- **Role Transformation**: Maps KeyCloak realm roles to .NET role claims
- **Error Handling**: Detailed error responses and logging
- **CORS Support**: Configurable cross-origin resource sharing
- **Swagger Integration**: JWT Bearer authentication in Swagger UI
- **Health Checks**: Built-in health check endpoints

## Troubleshooting

- Check KeyCloak realm and client configuration
- Verify JWT token includes correct audience claim
- Ensure CORS origins match your client application URLs
- Use the `/api/authtest/analyze-token` endpoint for token debugging