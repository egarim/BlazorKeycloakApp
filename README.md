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
- Keycloak instance running on `http://localhost:8080`

### Keycloak Configuration

You need to configure Keycloak with the following setup:

1. **Create Realm**: `blazor-app`
2. **Create Clients**:
   - **blazor-server**: 
     - Client Type: OpenID Connect
     - Access Type: Confidential
     - Valid Redirect URIs: `https://localhost:7001/*`
     - Web Origins: `https://localhost:7001`
   - **blazor-api**:
     - Client Type: OpenID Connect
     - Access Type: Bearer-only

3. **Create Roles**: `admin`, `user`
4. **Create Test User**:
   - Username: `testuser`
   - Password: `Test123!`
   - Assign appropriate roles

### Running the Applications

1. **Clone and navigate to the repository:**
   ```bash
   git clone <repository-url>
   cd BlazorKeycloakApp
   ```

2. **Update configuration** (if needed):
   - Modify `BlazorServer/appsettings.json` with your Keycloak settings
   - Modify `BlazorApi/appsettings.json` with your Keycloak settings

3. **Run the API** (Terminal 1):
   ```bash
   cd BlazorApi
   dotnet run
   ```
   API will be available at `https://localhost:7002`

4. **Run the Blazor Server app** (Terminal 2):
   ```bash
   cd BlazorServer
   dotnet run
   ```
   App will be available at `https://localhost:7001`

### Test Credentials

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

## Development Notes

- The application uses HTTPS redirect but allows HTTP for Keycloak in development (`RequireHttpsMetadata: false`)
- PKCE is enabled for enhanced security
- Tokens are automatically stored and managed by the authentication middleware
- Role claims are automatically transformed from Keycloak's realm roles
- CORS is configured to allow requests from the Blazor Server app to the API