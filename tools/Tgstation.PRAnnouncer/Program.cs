using System;
using System.Threading.Tasks;

using Byond.TopicSender;

using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

using Octokit.Webhooks;
using Octokit.Webhooks.AspNetCore;

using Prometheus;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// The program.
	/// </summary>
	public class Program
	{
		/// <summary>
		/// Program entrypoint.
		/// </summary>
		/// <param name="args">Command line arguments.</param>
		/// <returns>A <see cref="Task"/> representing the lifetime of the program.</returns>
		public static async Task Main(string[] args)
		{
			var appBuilder = WebApplication.CreateBuilder(args);

			appBuilder.Host.UseSystemd();

			var servicesBuilder = appBuilder.Services;

			servicesBuilder.AddOptions();

			servicesBuilder.AddHealthChecks()
				.AddCheck<GameServersConnectivityHealthCheck>(GameServersConnectivityHealthCheck.Name)
				.ForwardToPrometheus();

			servicesBuilder.AddLogging(loggingBuilder => loggingBuilder.AddConsole());

			servicesBuilder.Configure<Settings>(appBuilder.Configuration.GetSection("Settings"));

			servicesBuilder.AddSingleton<ITopicClient>(services => {
				var timeouts = services.GetRequiredService<IOptionsSnapshot<Settings>>().Value.TopicTimeouts;
				return new TopicClient(
					new SocketParameters
					{
						ConnectTimeout = TimeSpan.FromSeconds(timeouts?.ConnectTimeoutSeconds ?? TopicTimeouts.DefaultTimeoutSeconds),
						SendTimeout = TimeSpan.FromSeconds(timeouts?.SendTimeoutSeconds ?? TopicTimeouts.DefaultTimeoutSeconds),
						ReceiveTimeout = TimeSpan.FromSeconds(timeouts?.ReceiveTimeoutSeconds ?? TopicTimeouts.DefaultTimeoutSeconds),
						DisconnectTimeout = TimeSpan.FromSeconds(timeouts?.DisconnectTimeoutSeconds ?? TopicTimeouts.DefaultTimeoutSeconds),
					},
					services.GetService<ILogger<TopicClient>>());
			});

			servicesBuilder.AddSingleton<IMetricFactory>(_ => Metrics.DefaultFactory);

			servicesBuilder.AddSingleton<WebhookEventProcessor, TgstationWebhookEventProcessor>();

			await using var app = appBuilder.Build();
			var services = app.Services;
			var logger = services.GetRequiredService<ILogger<Program>>();
			try
			{
				var settings = services.GetRequiredService<IOptions<Settings>>();
				var secret = settings.Value.GitHubSecret;

				app.MapGitHubWebhooks(secret: secret);
				app.MapMetrics();
				app.MapHealthChecks("/health");

				await app.RunAsync();
			}
			catch (Exception ex)
			{
				logger.LogCritical(ex, "Application crashed!");
			}
		}
	}
}
