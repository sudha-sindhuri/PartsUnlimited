using Microsoft.AspNetCore.Mvc;
using System.Reflection;

namespace PartsUnlimited.API.Controllers
{
	[Route("health")]
	[ApiController]
	public class HealthController : ControllerBase
	{
		// GET health
		[HttpGet]
		public ActionResult Get()
		{
			return Ok();
		}

		[HttpGet("version")]
		public ActionResult<string> Version()
		{
			return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>()
				.Version.ToString();
		}
	}
}
