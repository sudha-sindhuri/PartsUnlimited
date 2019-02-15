using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Prometheus;
using System.Diagnostics;

namespace PartsUnlimited.Telemetry.Providers
{
	public static class PrometheusAppExtensions
	{
		static readonly string[] labelNames = new[] { "version", "environment", "canary", "method", "statuscode", "controller", "action" };

		static readonly Counter counter = Metrics.CreateCounter("http_requests_received_total", "Counts requests to endpoints", new CounterConfiguration
		{
			LabelNames = labelNames
		});

		static readonly Gauge inProgressGauge = Metrics.CreateGauge("http_requests_in_progress", "Counts requests currently in progress", new GaugeConfiguration
		{
			LabelNames = labelNames
		});

		static readonly Histogram requestHisto = Metrics.CreateHistogram("http_request_duration_seconds", "Duration of requests to endpoints", new HistogramConfiguration
		{
			LabelNames = labelNames
		});

		public static void UseMethodTracking(this IApplicationBuilder app, string version, string environment, string canary)
		{
			app.Use(async (context, next) =>
			{
				// extract values for this event
				var routeData = context.GetRouteData();
				var action = routeData?.Values["Action"] as string ?? "";
				var controller = routeData?.Values["Controller"] as string ?? "";
				var labels = new string[] { version, environment, canary,
					context.Request.Method, context.Response.StatusCode.ToString(), controller, action };

				// start a timer for the histogram
				var stopWatch = Stopwatch.StartNew();
				using (inProgressGauge.WithLabels(labels).TrackInProgress()) // increments the inProgress, decrementing when disposed
				{
					try
					{
						await next.Invoke();
					}
					finally
					{
						// record the duration
						stopWatch.Stop();
						requestHisto.WithLabels(labels).Observe(stopWatch.Elapsed.TotalSeconds);

						// increment the counter
						counter.WithLabels(labels).Inc();
					}
				}
			});
		}
	}
}
