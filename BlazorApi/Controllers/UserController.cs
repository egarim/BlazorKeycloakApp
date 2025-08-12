using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BlazorApi.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UserController : ControllerBase
{
    [HttpGet("profile")]
    public IActionResult GetProfile()
    {
        var user = HttpContext.User;
        
        return Ok(new
        {
            Username = user.Identity?.Name,
            Claims = user.Claims.Select(c => new { c.Type, c.Value }),
            Roles = user.FindAll(ClaimTypes.Role).Select(c => c.Value),
            IsAuthenticated = user.Identity?.IsAuthenticated ?? false
        });
    }
    
    [HttpGet("admin-only")]
    [Authorize(Policy = "RequireAdmin")]
    public IActionResult AdminOnly()
    {
        return Ok(new { Message = "This endpoint requires admin role", User = HttpContext.User.Identity?.Name });
    }
    
    [HttpGet("user-data")]
    [Authorize(Policy = "RequireUser")]
    public IActionResult UserData()
    {
        return Ok(new { Message = "This endpoint requires user or admin role", User = HttpContext.User.Identity?.Name });
    }
}
