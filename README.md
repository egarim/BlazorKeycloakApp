# BlazorKeycloakApp

This repository contains a Blazor solution demonstrating authentication with Keycloak, consisting of two applications:
- **BlazorServer**: A Blazor Server application using OpenID Connect authentication
- **BlazorApi**: A Web API using JWT Bearer authentication

## About Keycloak

Keycloak is an open-source Identity and Access Management solution that provides single sign-on with Identity and Access Management for applications and services. This application uses Keycloak as the central authentication server for both the Blazor Server app and the API.

## Authentication Implementation

### BlazorServer Authentication

The Blazor Server application implements OpenID Connect authentication with Cookie authentication for session management:

**Key Features:**
- OpenID Connect with PKCE (Proof Key for Code Exchange) for enhanced security
- Cookie-based session management
- Automatic token storage and refresh
- Role-based authorization with Keycloak realm roles
- Custom error handling and authentication events

**Configuration (`appsettings.json`):**
```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/blazor-app",
    "ClientId": "blazor-server",
    "ClientSecret": "9lUH5Ik00gmPGqM2Ul8144YQ3qmm8mtA",
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

**Authentication Setup:**
- Uses Cookie authentication as the default scheme
- OpenID Connect for challenging unauthenticated users
- Configures callback paths: `/signin-oidc`, `/signout-callback-oidc`, `/signout-oidc`
- Maps Keycloak's `preferred_username` to the Name claim
- Transforms Keycloak realm roles to .NET role claims
- Stores access, refresh, and ID tokens for API calls

**Authorization Policies:**
- `RequireAuthentication`: Requires authenticated user
- `RequireAdmin`: Requires "admin" role
- `RequireUser`: Requires "user" or "admin" role

### BlazorApi Authentication

The API implements JWT Bearer authentication to validate tokens issued by Keycloak:

**Configuration (`appsettings.json`):**
```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/blazor-app",
    "Audience": "blazor-api",
    "RequireHttpsMetadata": false
  },
  "Cors": {
    "AllowedOrigins": ["https://localhost:7001"]
  }
}
```

**Key Features:**
- JWT Bearer token validation
- Keycloak realm role transformation
- CORS configuration for Blazor Server requests
- Token lifetime validation with 5-minute clock skew tolerance
- Custom token validation events for role mapping

**Token Validation:**
- Validates issuer, audience, lifetime, and signing key
- Maps `preferred_username` to Name claim
- Extracts roles from `realm_access.roles` claim
- Supports the same authorization policies as the Blazor Server app

## Keycloak Setup Scripts

### setup-keycloak-complete.ps1 (Recommended)

This comprehensive PowerShell script automates the complete Keycloak configuration:

**Features:**
- **Full Setup**: Creates realm, clients, roles, and test users
- **Update Mode**: Updates existing client configurations
- **Manual Instructions**: Shows step-by-step manual configuration guide
- **Error Handling**: Comprehensive error handling with troubleshooting tips
- **Flexible Parameters**: Customizable URLs, credentials, and client names

**Usage Examples:**
```powershell
# Full automated setup (recommended)
.\setup-keycloak-complete.ps1

# Update existing client configuration only
.\setup-keycloak-complete.ps1 -UpdateOnly

# Show manual configuration instructions
.\setup-keycloak-complete.ps1 -ShowInstructions

# Custom configuration
.\setup-keycloak-complete.ps1 -KeycloakUrl "http://localhost:8080" -AdminUsername "admin" -AdminPassword "admin"
```

**What it does:**
- Creates `blazor-app` realm with proper security settings
- Configures `blazor-server` client (OpenID Connect, confidential)
- Configures `blazor-api` client (JWT Bearer, resource server)
- Sets up comprehensive redirect URIs for all authentication scenarios:
  - `/signin-oidc` - OpenID Connect callback
  - `/signout-callback-oidc` - Logout callback
  - `/authentication/login-callback` - Additional login callback
  - `/authentication/logout-callback` - Additional logout callback
- Creates realm roles: `admin`, `user`, `manager`
- Creates test user: `testuser` / `Test123!`
- Configures PKCE (S256) for enhanced security
- Sets proper token lifespans and session timeouts

### Legacy Scripts (Deprecated)

**setup-keycloak.ps1**: Original setup script - use `setup-keycloak-complete.ps1` instead
**update-keycloak-client.ps1**: Manual instruction guide - integrated into complete script

## Project Structure

### BlazorServer Project
- **Program.cs**: Authentication and authorization configuration
- **Pages/Index.razor**: Protected home page requiring authentication
- **Pages/Welcome.razor**: Public welcome page with login link
- **Services/**: Custom services for authentication and API communication

### BlazorApi Project
- **Program.cs**: JWT authentication and CORS configuration
- **Controllers/**: API endpoints protected with `[Authorize]` attributes

## Setup Instructions

### Prerequisites
- .NET 9 SDK
- PowerShell 7.0+
- Keycloak instance running on `http://localhost:8080`

### Quick Start (Automated Setup)

1. **Start Keycloak** (ensure it's running on localhost:8080)

2. **Run the setup script:**
   ```powershell
   .\setup-keycloak-complete.ps1
   ```
   
   The script will prompt for admin credentials if needed (default: admin/admin)

3. **Update configuration** if the generated client secret differs:
   ```json
   // BlazorServer/appsettings.json
   {
     "Keycloak": {
       "ClientSecret": "use-the-secret-from-script-output"
     }
   }
   ```

4. **Run the applications:**
   ```bash
   # Terminal 1 - API
   cd BlazorApi
   dotnet run
   
   # Terminal 2 - Blazor Server
   cd BlazorServer
   dotnet run
   ```

5. **Test the application:**
   - Navigate to `https://localhost:7001`
   - Click "Login with Keycloak"
   - Use credentials: `testuser` / `Test123!`

### Manual Setup (If Scripts Fail)

If the automated script fails, you can configure Keycloak manually:

```powershell
.\setup-keycloak-complete.ps1 -ShowInstructions
```

This will display detailed step-by-step instructions for manual configuration.

### Troubleshooting

**Common Issues:**

1. **Authentication Failed**: Run update script to fix redirect URIs:
   ```powershell
   .\setup-keycloak-complete.ps1 -UpdateOnly
   ```

2. **Token Validation Errors**: Verify API client configuration and realm authority URL

3. **CORS Issues**: Ensure BlazorServer URL is in the API's allowed origins

4. **Logout Redirect Issues**: The complete script configures all necessary logout redirect URIs

## Test Credentials

The application includes test credentials for development:
- **Username**: `testuser`
- **Password**: `Test123!`

## Features

- **Secure Authentication**: Full OpenID Connect implementation with Keycloak
- **Role-Based Access Control**: Admin and user roles with different permissions
- **JWT Token Integration**: Seamless token passing between Blazor Server and API
- **Session Management**: Proper login/logout flows with token cleanup
- **API Integration**: Authenticated API calls from Blazor Server to Web API
- **Error Handling**: Comprehensive authentication error handling and logging
- **Automated Setup**: Complete PowerShell automation for Keycloak configuration

## Development Notes

- The application uses HTTPS redirect but allows HTTP for Keycloak in development (`RequireHttpsMetadata: false`)
- PKCE is enabled for enhanced security
- Tokens are automatically stored and managed by the authentication middleware
- Role claims are automatically transformed from Keycloak's realm roles
- CORS is configured to allow requests from the Blazor Server app to the API
- All necessary redirect URIs are pre-configured for seamless authentication flows