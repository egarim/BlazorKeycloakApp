using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BlazorApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ValuesController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new[] { "value1", "value2", "value3" });
    }
    
    [HttpGet("protected")]
    [Authorize]
    public IActionResult GetProtected()
    {
        return Ok(new { Message = "This is protected data", User = HttpContext.User.Identity?.Name });
    }
    
    [HttpGet("admin-only")]
    [Authorize(Policy = "RequireAdmin")]
    public IActionResult GetAdminOnly()
    {
        return Ok(new { Message = "Admin only data", User = HttpContext.User.Identity?.Name });
    }
}
