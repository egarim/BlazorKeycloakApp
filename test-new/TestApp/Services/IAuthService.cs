using System.Security.Claims;

namespace TestApp.Services;

public interface IAuthService
{
    Task<string?> GetAccessTokenAsync();
    Task<ClaimsPrincipal?> GetCurrentUserAsync();
    Task<bool> IsInRoleAsync(string role);
}
