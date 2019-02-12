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
		public PrometheusTelemetryProvider()
		{
			var counter = Metrics.CreateCounter("PathCounter", "Counts requests to endpoints", new CounterConfiguration
			{
				LabelNames = new[] { "method", "endpoint" }
			});
		}

		public void TrackEvent(string message)
		{
			throw new NotImplementedException();
		}

		public void TrackEvent(string message, Dictionary<string, string> properties, Dictionary<string, double> measurements)
		{
			throw new NotImplementedException();
		}

		public void TrackException(Exception exception)
		{
			throw new NotImplementedException();
		}

		public void TrackTrace(string message)
		{
			throw new NotImplementedException();
		}
	}
}
