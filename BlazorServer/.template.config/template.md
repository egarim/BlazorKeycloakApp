# KeyCloak Blazor Server Template

This template creates a Blazor Server application with KeyCloak OIDC authentication integration.

## Features

? **Complete KeyCloak Integration** - OIDC authentication with OpenID Connect flow  
? **Server-Side Rendering** - Blazor Server with SignalR connectivity  
? **API Integration** - Built-in services for calling protected APIs  
? **Authentication Testing** - Comprehensive diagnostic tools and test pages  
? **Role-based Authorization** - Support for admin/user roles from KeyCloak  
? **Session Management** - Proper login/logout flows with token cleanup  
? **Comprehensive Diagnostics** - Full authentication debugging tools  

## Usage

```bash
dotnet new keycloak-blazor-server --name "My.BlazorApp" --KeycloakRealm "my-realm" --ClientId "my-client"
```

## Parameters

- `--name`: The name of the project (default: current directory name)
- `--Framework`: Target framework - net9.0 or net8.0 (default: net9.0)
- `--KeycloakRealm`: KeyCloak realm name (default: blazor-app)
- `--KeycloakUrl`: KeyCloak server URL (default: http://localhost:8080)
- `--ClientId`: KeyCloak client ID (default: blazor-server)
- `--ClientSecret`: KeyCloak client secret (default: placeholder)
- `--ApiBaseUrl`: API server base URL (default: https://localhost:7002)
- `--RequireHttpsMetadata`: Require HTTPS for KeyCloak metadata (default: false)
- `--IncludeApiIntegration`: Include API integration services (default: true)
- `--EnableDiagnostics`: Enable authentication diagnostics (default: true)

## Quick Start

1. **Create new project**:
   ```bash
   dotnet new keycloak-blazor-server --name "MyCompany.MyApp"
   ```

2. **Configure KeyCloak**:
   - Update `appsettings.json` with your KeyCloak settings
   - Set the correct `ClientSecret` from your KeyCloak client

3. **Run the application**:
   ```bash
   dotnet run
   ```

4. **Test authentication**:
   - Navigate to: `https://localhost:5001`
   - Login with your KeyCloak credentials
   - Test API integration at: `/api-test`

## Application Structure

### Authentication Flow
- Uses OpenID Connect with Cookie authentication
- Supports PKCE (Proof Key for Code Exchange) for enhanced security
- Automatic token storage and refresh
- Role-based authorization with KeyCloak realm roles

### Pages & Features
- **Welcome Page** - Public landing page with login option
- **Protected Pages** - Require authentication to access
- **API Test Page** - Comprehensive API testing and diagnostics
- **Profile Page** - User profile with claims information

### Services
- **AuthService** - Authentication management and token access
- **ApiService** - HTTP client for calling protected APIs
- **ApiDiagnosticsService** - Authentication debugging and analysis

## Configuration

The template generates an `appsettings.json` with KeyCloak configuration:

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/my-realm",
    "ClientId": "my-client",
    "ClientSecret": "your-client-secret-here",
    "RequireHttpsMetadata": false,
    "ResponseType": "code",
    "SaveTokens": true,
    "GetClaimsFromUserInfoEndpoint": true,
    "Scopes": ["openid", "profile", "email", "roles"]
  },
  "ApiSettings": {
    "BaseUrl": "https://localhost:7002"
  }
}
```

## KeyCloak Setup

1. Create a realm in KeyCloak
2. Create a client with:
   - **Client Type**: OpenID Connect
   - **Client Authentication**: On (confidential client)
   - **Valid Redirect URIs**: 
     - `https://localhost:5001/signin-oidc`
     - `https://localhost:5001/signout-callback-oidc`
   - **Valid Post Logout Redirect URIs**: `https://localhost:5001/signout-callback-oidc`

3. Create roles (admin, user) and assign to users
4. Configure audience mappers if using API integration

## Advanced Features

- **Comprehensive Authentication** - Full OIDC implementation with KeyCloak
- **Role Transformation** - Maps KeyCloak realm roles to .NET role claims
- **API Integration** - Seamless authenticated calls to protected APIs
- **Error Handling** - Detailed authentication error handling and logging
- **Diagnostics Tools** - Built-in debugging for authentication issues
- **Token Management** - Automatic token refresh and secure storage

## Troubleshooting

- Check KeyCloak realm and client configuration
- Verify redirect URIs match your application URLs
- Ensure client secret is correctly configured
- Use the API test page for authentication debugging