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
		readonly Histogram productHistogram = Metrics.CreateHistogram(
			"ProductCounter", "Counts products when added to basket", 
			new HistogramConfiguration
			{
				LabelNames = new[] { "category", "product", "version", "environment", "canary" }
			});

		readonly Gauge sqlGauge = Metrics.CreateGauge(
			"AddProductsSQLGauge", "Counts products when added to basket",
			new GaugeConfiguration
			{
				LabelNames = new[] { "category", "product", "version", "environment", "canary" }
			});

		readonly string version;
		readonly string environment;
		readonly string canary;

		public PrometheusTelemetryProvider(string version, string environment, string canary)
		{
			this.version = version;
			this.environment = environment;
			this.canary = canary;
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
					var price = measurements["Price"];
					productHistogram.WithLabels(labels).Observe(price);
				}
				if (measurements.ContainsKey("ElapsedMilliseconds"))
				{
					var elapsed = measurements["ElapsedMilliseconds"];
					sqlGauge.WithLabels(labels).Set(elapsed);
				}
			}
			catch
			{
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
