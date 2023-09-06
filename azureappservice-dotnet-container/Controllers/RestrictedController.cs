using Microsoft.AspNetCore.Mvc;

namespace SampleWebApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class RestrictedController : ControllerBase
    {
        [HttpGet("restricted-path")]
        public IActionResult Get()
        {
            var json = new
            {
                message = "This is restricted content.",
                ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString(),
                userAgent = HttpContext.Request.Headers["User-Agent"].ToString()
            };

            return Ok(json);
        }
    }
}