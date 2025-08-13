# REST API with Keycloak Template

This template creates a REST API project pre-configured with Keycloak JWT Bearer authentication.

## Features

- ? JWT Bearer Authentication with Keycloak
- ? Swagger UI with JWT Bearer support
- ? CORS configuration
- ? Role-based authorization policies
- ? Sample controllers with authentication examples
- ? Comprehensive error handling

## Getting Started

1. **Configure Keycloak**: Update `appsettings.json` with your Keycloak settings
2. **Run the project**: `dotnet run`
3. **Test with Swagger**: Navigate to `https://localhost:5001/swagger`
4. **Test authentication**: Use the `/api/authtest/*` endpoints

## Configuration

### appsettings.json

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/your-realm",
    "Audience": "your-api",
    "RequireHttpsMetadata": false
  },
  "Cors": {
    "AllowedOrigins": [ "https://localhost:7001" ]
  }
}
```

### Keycloak Setup

1. Create a realm in Keycloak
2. Create a client for your API
3. Configure audience mappers
4. Set up user roles (admin, user)

## API Endpoints

### Public Endpoints
- `GET /api/values` - Public endpoint, no authentication required

### Protected Endpoints  
- `GET /api/values/protected` - Requires valid JWT token
- `GET /api/authtest/auth-required` - Test authentication
- `GET /api/user/profile` - Get user profile with claims

### Admin Only Endpoints
- `GET /api/values/admin-only` - Requires admin role
- `GET /api/user/admin-only` - Admin-only user data

## Testing Authentication

Use the AuthTest controller endpoints to verify your authentication setup:

- `/api/authtest/ping` - Health check (no auth)
- `/api/authtest/analyze-token` - Analyze JWT token details
- `/api/authtest/auth-required` - Test basic authentication
- `/api/authtest/admin-required` - Test admin role requirement
- `/api/authtest/user-required` - Test user/admin role requirement

## Security Policies

The template includes pre-configured authorization policies:

- **RequireAuthentication**: Valid JWT token required
- **RequireAdmin**: Admin role required  
- **RequireUser**: User or admin role required