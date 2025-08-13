# BlazorServer - KeyCloak Blazor Server Template

A comprehensive Blazor Server template with KeyCloak OIDC authentication integration.

## ?? Quick Start

```bash
dotnet new keycloak-blazor-server --name "My.BlazorApp"
cd My.BlazorApp
dotnet run
```

Navigate to `https://localhost:5001` to access the application.

## ?? Features

? **Complete KeyCloak Integration** - OIDC authentication with OpenID Connect flow  
? **Server-Side Rendering** - Blazor Server with SignalR connectivity  
? **API Integration** - Built-in services for calling protected APIs  
? **Authentication Testing** - Comprehensive diagnostic tools and test pages  
? **Role-based Authorization** - Support for admin/user roles from KeyCloak  
? **Session Management** - Proper login/logout flows with token cleanup  
? **Comprehensive Diagnostics** - Full authentication debugging tools  

## ??? Configuration

Update `appsettings.json` with your KeyCloak settings:

```json
{
  "Keycloak": {
    "Authority": "http://localhost:8080/realms/your-realm",
    "ClientId": "your-client-id",
    "ClientSecret": "your-client-secret",
    "RequireHttpsMetadata": false
  },
  "ApiSettings": {
    "BaseUrl": "https://localhost:7002"
  }
}
```

## ?? Application Pages

### Public Pages
- **Welcome** (`/welcome`) - Public landing page with login option

### Protected Pages  
- **Home** (`/`) - Protected dashboard (requires authentication)
- **Counter** (`/counter`) - Simple counter demo
- **Fetch Data** (`/fetchdata`) - Weather data from service
- **Profile** (`/profile`) - User profile with claims information
- **API Test** (`/api-test`) - Comprehensive API testing and diagnostics

## ?? KeyCloak Setup

1. **Create a realm** in KeyCloak
2. **Create a client** with these settings:
   - **Client Type**: OpenID Connect
   - **Client Authentication**: On (confidential client)
   - **Valid Redirect URIs**: 
     - `https://localhost:5001/signin-oidc`
     - `https://localhost:5001/signout-callback-oidc`
   - **Valid Post Logout Redirect URIs**: `https://localhost:5001/signout-callback-oidc`
3. **Create roles** (admin, user) and assign to users
4. **Configure audience mappers** if using API integration

## ?? Project Structure

```
MyBlazorApp/
??? Data/
?   ??? WeatherForecast.cs
?   ??? WeatherForecastService.cs
??? Pages/
?   ??? Index.razor              # Protected home page
?   ??? Counter.razor            # Counter demo
?   ??? FetchData.razor          # Data fetching demo
?   ??? Profile.razor            # User profile
?   ??? Welcome.razor            # Public welcome page
?   ??? ApiTest.razor            # API testing page
?   ??? _Host.cshtml             # Host page
??? Services/
?   ??? IAuthService.cs          # Authentication service interface
?   ??? AuthService.cs           # Authentication service implementation
?   ??? IApiService.cs           # API service interface (if enabled)
?   ??? ApiService.cs            # API service implementation (if enabled)
?   ??? ApiDiagnosticsService.cs # Diagnostics service (if enabled)
??? Shared/
?   ??? MainLayout.razor         # Main layout
?   ??? NavMenu.razor           # Navigation menu
?   ??? RedirectToLogin.razor   # Login redirect component
??? wwwroot/                     # Static files
??? appsettings.json            # Configuration (parameterized)
??? Program.cs                  # Application startup (parameterized)
??? MyBlazorApp.csproj          # Project file
```

## ?? Testing the Application

1. **Start the application**:
   ```bash
   dotnet run
   ```

2. **Access the application**: Navigate to `https://localhost:5001`

3. **Test Authentication**:
   - Visit the welcome page (public)
   - Click "Login with KeyCloak"
   - Authenticate with your KeyCloak credentials
   - Access protected pages

4. **API Testing**: If API integration is enabled, use the `/api-test` page for:
   - Token analysis and debugging
   - Testing protected API endpoints
   - Comprehensive authentication diagnostics

## ?? Troubleshooting

### Common Issues

1. **Authentication failures**:
   - Verify KeyCloak realm and client configuration
   - Check redirect URIs match your application URLs
   - Ensure client secret is correctly configured

2. **Token issues**:
   - Use the API test page for token debugging
   - Check token expiration and refresh
   - Verify audience claims if using API integration

3. **Navigation issues**:
   - Ensure proper authorization attributes on pages
   - Check role mappings from KeyCloak
   - Verify user has required roles assigned

### Development Tips

- Use the comprehensive diagnostics on the API test page
- Check browser developer tools for authentication errors
- Review application logs for detailed error information
- Test with different user roles to verify authorization

## ?? License

This template is designed for creating KeyCloak-authenticated Blazor Server applications with comprehensive testing and debugging capabilities.

---

**Template Version**: 2.0.0  
**Compatible with**: .NET 8.0, .NET 9.0  
**KeyCloak**: Any compatible version