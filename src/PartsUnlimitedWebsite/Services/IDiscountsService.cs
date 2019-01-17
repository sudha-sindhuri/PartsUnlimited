using System.Collections.Generic;
using System.Threading.Tasks;
using PartsUnlimited.Models;

namespace PartsUnlimitedWebsite.Services
{
	public interface IDiscountsService
	{
		Task<IEnumerable<CategoryDiscount>> GetDiscounts();
	}
}