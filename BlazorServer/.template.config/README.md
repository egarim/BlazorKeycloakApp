# Blazor Server with Keycloak Template

This template creates a Blazor Server project pre-configured with Keycloak OpenID Connect authentication.

## Features

- ? OpenID Connect Authentication with Keycloak
- ? Cookie-based session management
- ? Role-based authorization policies
- ? Comprehensive API integration with JWT token handling
- ? Authentication diagnostic tools
- ? Protected and public pages
- ? User profile management
- ? Token analysis and debugging capabilities

## Getting Started

1. **Configure Keycloak**: Update `appsettings.json` with your Keycloak settings
2. **Set Client Secret**: Obtain and configure the client secret from Keycloak Admin Console
3. **Run the project**: `dotnet run`
4. **Test authentication**: Navigate to the application and try logging in

## Configuration

### appsettings.json

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/your-realm",
    "ClientId": "your-blazor-client",
    "ClientSecret": "your-client-secret-here",
    "RequireHttpsMetadata": false,
    "ResponseType": "code",
    "SaveTokens": true,
    "GetClaimsFromUserInfoEndpoint": true,
    "Scopes": [ "openid", "profile", "email", "roles" ]
  },
  "ApiSettings": {
    "BaseUrl": "https://localhost:7002"
  }
}
```

### Keycloak Setup

1. Create a realm in Keycloak
2. Create a confidential client for your Blazor Server app
3. Configure redirect URIs:
   - `https://localhost:7001/signin-oidc`
   - `https://localhost:7001/signout-callback-oidc`
4. Set up user roles (admin, user)
5. Configure role mappers
6. **Important**: Get the client secret from Keycloak Admin Console

## Pages and Features

### Public Pages
- `/welcome` - Welcome page with login link

### Protected Pages  
- `/` - Home page (requires authentication)
- `/counter` - Counter demo page
- `/fetchdata` - Weather data page
- `/profile` - User profile with claims information
- `/api-test` - Comprehensive API testing and diagnostics

### Authentication Features
- **Single Sign-On**: Full OIDC integration with Keycloak
- **Role-based Access**: Admin and user role support
- **Token Management**: Automatic token storage and refresh
- **API Integration**: Seamless API calls with JWT tokens
- **Diagnostics**: Comprehensive authentication debugging tools

## API Integration

The template includes comprehensive API integration capabilities:

- **HTTP Client Configuration**: Pre-configured for authenticated API calls
- **Token Handling**: Automatic JWT token inclusion in API requests
- **Error Handling**: Detailed error reporting for API failures
- **Diagnostics Service**: API connectivity and authentication testing

## Testing Authentication

Use the API Test page (`/api-test`) to verify your authentication setup:

- **Token Analysis**: View JWT token details and claims
- **API Testing**: Test authenticated and unauthenticated endpoints
- **Configuration Validation**: Verify Keycloak and API settings
- **Diagnostics**: Comprehensive authentication flow analysis

## Security Policies

The template includes pre-configured authorization policies:

- **RequireAuthentication**: Valid authentication required
- **RequireAdmin**: Admin role required  
- **RequireUser**: User or admin role required

## Authentication Flow

1. User visits protected page
2. Redirected to Keycloak for authentication
3. User authenticates with Keycloak
4. Keycloak redirects back with authorization code
5. Application exchanges code for tokens
6. Tokens stored in cookies for session management
7. API calls automatically include JWT tokens

## Development Notes

- **HTTPS**: Application supports HTTPS but allows HTTP for Keycloak in development
- **PKCE**: Proof Key for Code Exchange is enabled for enhanced security
- **Token Storage**: Tokens are securely stored server-side
- **Role Mapping**: Keycloak roles are automatically mapped to .NET claims
- **Session Management**: Cookie-based authentication for optimal server-side performance