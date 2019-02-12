using Microsoft.AspNetCore.Builder;
using Prometheus;

namespace PartsUnlimited.Telemetry.Providers
{
	public static class PrometheusAppExtensions
	{
		static readonly Counter counter = Metrics.CreateCounter("RequestCounter", "Counts requests to endpoints", new CounterConfiguration
		{
			LabelNames = new[] { "method", "endpoint" }
		});

		public static void UseMethodTracking(this IApplicationBuilder app)
		{
			app.Use((context, next) =>
			{
				counter.WithLabels(context.Request.Method, context.Request.Path).Inc();
				return next();
			});
		}
	}
}
