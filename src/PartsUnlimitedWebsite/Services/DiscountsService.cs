using Newtonsoft.Json;
using PartsUnlimited.Models;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace PartsUnlimitedWebsite.Services
{
	public class DiscountsService : IDiscountsService
	{
		private readonly HttpClient _httpClient;

		public DiscountsService(HttpClient httpClient)
		{
			_httpClient = httpClient;
		}

		public async Task<List<CategoryDiscount>> GetDiscounts()
		{
			var discounts = new List<CategoryDiscount>();
			try
			{
				var responseString = await _httpClient.GetStringAsync("").ConfigureAwait(false);
				discounts = JsonConvert.DeserializeObject<CategoryDiscount[]>(responseString).ToList();
			}
			catch (Exception ex)
			{
				// TODO: log exception
				Trace.TraceError(ex.ToString());
			}
			return discounts.ToList();
		}
	}
}
