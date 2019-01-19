using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Reflection;

namespace PartsUnlimited.API.Controllers
{
	[Route("health")]
	[ApiController]
	public class HealthController : ControllerBase
	{
		private readonly IConfiguration _configuration;

		public HealthController(IConfiguration configuration)
		{
			_configuration = configuration;
		}

		// GET health
		[HttpGet]
		public ActionResult Get()
		{
			return Ok();
		}

		// GET health/version
		[HttpGet("version")]
		public ActionResult<string> Version()
		{
			return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>()
				.Version.ToString();
		}

		// GET health/canary
		[HttpGet("canary")]
		public ActionResult<string> Canary()
		{
			return _configuration["CANARY"];
		}
	}
}
