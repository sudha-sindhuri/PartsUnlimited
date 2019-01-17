using Newtonsoft.Json;
using PartsUnlimited.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;

namespace PartsUnlimitedWebsite.Services
{
	public class DiscountsService : IDiscountsService
	{
		private readonly HttpClient _httpClient;
		private readonly string _remoteServiceBaseUrl;

		public DiscountsService(HttpClient httpClient)
		{
			_httpClient = httpClient;
		}

		public async Task<IEnumerable<CategoryDiscount>> GetDiscounts()
		{
			var uri = $"{_remoteServiceBaseUrl}/api/discounts";

			var responseString = await _httpClient.GetStringAsync(uri);
			var discounts = JsonConvert.DeserializeObject<CategoryDiscount[]>(responseString);
			return discounts;
		}
	}
}
