using Microsoft.Extensions.CommandLineUtils;
using System;
using System.Net.Http;
using System.Threading.Tasks;

namespace PartsUnlimited.TestConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            var app = new CommandLineApplication();
			app.Name = "pu-ping";
			app.Description = "Ping a URL using a host header.";

			// set up options
			var urlOpt = app.Option("-u|--url <url>", "The URL to ping. e.g. http://localhost:8082/health/all", CommandOptionType.SingleValue);
			var hostOpt = app.Option("-h|--host <host>", "The host header to use. e.g. pu-api.local", CommandOptionType.SingleValue);
			var freqOpt = app.Option("-f|--frequency <frequency>", "The frequency (in ms) to ping - defaults to 100", CommandOptionType.SingleValue);

			// execute
			app.OnExecute(async () =>
			{
				if (urlOpt.HasValue() && hostOpt.HasValue())
				{
					Console.WriteLine("Press CNTRL-C to stop");
					Console.WriteLine();
					await Task.Run(async () =>
					{
						while (true)
						{
							var result = await CallUrl(urlOpt.Value(), hostOpt.Value());
							Console.WriteLine(result);
							await Task.Delay(int.Parse(freqOpt.Value() ?? "100"));
						}
					});
					return 0;
				}
				else
				{
					app.ShowHint();
					return -1;
				}
			});

			app.Execute(args);
        }

		static async Task<string> CallUrl(string url, string host)
		{
			using (var client = new HttpClient())
			{
				client.DefaultRequestHeaders.Host = host;
				try
				{
					return await client.GetStringAsync(url);
				}
				catch(Exception e)
				{
					var color = Console.ForegroundColor;
					Console.ForegroundColor = ConsoleColor.Red;
					Console.WriteLine(e.Message);
					Console.ForegroundColor = color;
					return null;
				}
			}
		}
    }
}
