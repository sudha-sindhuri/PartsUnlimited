using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System.Reflection;
using System.Threading.Tasks;

namespace PartsUnlimited.API.Controllers
{
	[Route("health")]
	public class HealthController : ControllerBase
	{
		private readonly IConfiguration _configuration;

		protected string VersionNumber
		{
			get
			{
				return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>()
				.Version.ToString();
			}
		}

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
		public string Version()
		{
			return VersionNumber;
		}

		// GET health/canary
		[HttpGet("canary")]
		public string Canary()
		{
			return _configuration["CANARY"];
		}

		// GET health/all
		[HttpGet("all")]
		public ActionResult<string> Version()
		{
			return $"{VersionNumber}|{_configuration["CANARY"]}";
		}
	}
}
