using Microsoft.AspNetCore.Mvc;
using System.Reflection;
using System.Threading.Tasks;

namespace PartsUnlimited.API.Controllers
{
	[Route("health")]
	public class HealthController : ControllerBase
	{
		// GET health
		[HttpGet]
		public ActionResult Get()
		{
			return Ok();
		}

		[HttpGet("version")]
		public string Version()
		{
			return Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>()
				.Version.ToString();
		}
	}
}
