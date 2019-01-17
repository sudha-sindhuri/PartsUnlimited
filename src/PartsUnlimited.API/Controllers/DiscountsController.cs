using Microsoft.AspNetCore.Mvc;
using PartsUnlimited.Models;
using System.Collections.Generic;

namespace PartsUnlimited.API.Controllers
{
	[Route("api/[controller]")]
    [ApiController]
    public class DiscountsController : ControllerBase
    {
        // GET api/discounts
        [HttpGet]
        public ActionResult<IEnumerable<CategoryDiscount>> Get()
        {
			return new CategoryDiscount[]
			{
				new CategoryDiscount() { CategoryId = 5, Discount = 25 }
			};
        }

		// GET api/discounts/5
		[HttpGet("{categoryId}")]
        public ActionResult<decimal> Get(int categoryId)
        {
			if (categoryId == 5) return 20;
			return 0;
        }

        // POST api/values
        [HttpPost]
        public void Post([FromBody] string value)
        {
			// TODO
        }

        // PUT api/values/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
			// TODO
		}

		// DELETE api/values/5
		[HttpDelete("{id}")]
        public void Delete(int id)
        {
			// TODO
		}
	}
}
