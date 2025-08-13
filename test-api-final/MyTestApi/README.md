# MyTestApi - KeyCloak REST API Template

A comprehensive REST API template with KeyCloak JWT authentication integration.

## ?? Quick Start

```bash
dotnet new keycloak-api --name "My.Api"
cd My.Api
dotnet run
```

Navigate to `https://localhost:5001` to access Swagger UI.

## ?? Features

? **Complete KeyCloak Integration** - JWT Bearer authentication with comprehensive token validation  
? **Swagger Integration** - Interactive API documentation with JWT authentication support  
? **Authentication Testing** - Comprehensive endpoints for testing authentication flow  
? **Role-based Authorization** - Support for admin/user roles from KeyCloak  
? **CORS Configuration** - Configurable cross-origin resource sharing  
? **Comprehensive Diagnostics** - Full authentication debugging tools  

## ??? Configuration

Update `appsettings.json` with your KeyCloak settings:

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/your-realm",
    "Audience": "your-api-audience",
    "RequireHttpsMetadata": false
  }
}
```

## ?? API Endpoints

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

1. Create a realm in KeyCloak
2. Create a client with appropriate settings
3. Create roles (admin, user) and assign to users
4. Configure audience mapper for JWT tokens

For detailed setup instructions, see the template documentation.