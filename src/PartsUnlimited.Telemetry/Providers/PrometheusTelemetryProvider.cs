using Microsoft.Extensions.Logging;
using PartsUnlimited.Telemetry;
using Prometheus;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PartsUnlimitedWebsite.Telemetry.Providers
{
	public class PrometheusTelemetryProvider : ITelemetryProvider
	{
		static readonly string[] labelNames = new[] { "category", "product", "version", "environment", "canary"  };

		readonly Counter productCounter = Metrics.CreateCounter(
			"pu_product_add", "Increments when product is added to basket", 
			new CounterConfiguration
			{
				LabelNames = labelNames
			});

		readonly Histogram dependencyHisto = Metrics.CreateHistogram(
			"pu_dependency_duration", "Duration of dependency call",
			new HistogramConfiguration
			{
				// 1m to 32K ms
				Buckets = Histogram.ExponentialBuckets(0.001, 2, 16),
				LabelNames = labelNames
			});

		readonly string version;
		readonly string environment;
		readonly string canary;
		readonly ILogger logger;

		public PrometheusTelemetryProvider(string version, string environment, string canary, ILogger logger = null)
		{
			this.version = version;
			this.environment = environment;
			this.canary = canary;
			this.logger = logger;
		}

		public void TrackEvent(string message)
		{
		}

		public void TrackEvent(string message, Dictionary<string, string> properties, Dictionary<string, double> measurements)
		{
			try
			{
				var labels = new string[] { properties["ProductCategory"], properties["Product"], version, environment, canary };
				if (measurements.ContainsKey("Price"))
				{
					productCounter.WithLabels(labels).Inc();
					logger.LogInformation("Logged price info");
				}
				if (measurements.ContainsKey("ElapsedMilliseconds"))
				{
					var elapsed = measurements["ElapsedMilliseconds"];
					dependencyHisto.WithLabels(labels).Observe(elapsed);
					logger.LogInformation("Logged sql info");
				}
			}
			catch (Exception ex)
			{
				logger.LogError(ex, ex.Message);
				// swallow
			}
		}

		public void TrackException(Exception exception)
		{
		}

		public void TrackTrace(string message)
		{
		}
	}
}
