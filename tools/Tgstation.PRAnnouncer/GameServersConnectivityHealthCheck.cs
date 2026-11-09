using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Byond.TopicSender;

using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// An <see cref="IHealthCheck"/> that checks connectivity to configured game servers.
	/// </summary>
	sealed class GameServersConnectivityHealthCheck : IHealthCheck, IDisposable
	{
		/// <summary>
		/// The name of the health check.
		/// </summary>
		public const string Name = "GameServerConnectivity";

		/// <summary>
		/// The <see cref="ITopicClient"/> to use.
		/// </summary>
		readonly ITopicClient topicClient;

		/// <summary>
		/// The <see cref="IOptionsMonitor{TOptions}"/> for the <see cref="Settings"/>.
		/// </summary>
		readonly IOptionsMonitor<Settings> settings;

		/// <summary>
		/// The <see cref="ILogger"/> to write to.
		/// </summary>
		readonly ILogger<GameServersConnectivityHealthCheck> logger;

		/// <summary>
		/// The <see cref="IDisposable"/> returned from <see cref="IOptionsMonitor{TOptions}.OnChange(Action{TOptions, string?})"/> for <see cref="settings"/>.
		/// </summary>
		readonly IDisposable? optionsMonitorRegistration;

		/// <summary>
		/// The last time <see cref="LiveHealthCheck(CancellationToken)"/> was run.
		/// </summary>
		DateTimeOffset lastCheck;

		/// <summary>
		/// The last response from <see cref="LiveHealthCheck(CancellationToken)"/>.
		/// </summary>
		HealthCheckResult cachedResult;

		/// <summary>
		/// Initializes a new instance of the <see cref="GameServersConnectivityHealthCheck"/> class..
		/// </summary>
		/// <param name="topicClient">The value of <see cref="topicClient"/>.</param>
		/// <param name="settings">The value of <see cref="settings"/>.</param>
		/// <param name="logger">The value of <see cref="logger"/>.</param>
		public GameServersConnectivityHealthCheck(
			ITopicClient topicClient,
			IOptionsMonitor<Settings> settings,
			ILogger<GameServersConnectivityHealthCheck> logger)
		{
			this.topicClient = topicClient ?? throw new ArgumentNullException(nameof(topicClient));
			this.settings = settings ?? throw new ArgumentNullException(nameof(settings));
			this.logger = logger ?? throw new ArgumentNullException(nameof(logger));

			optionsMonitorRegistration = settings.OnChange(_ => lastCheck = DateTimeOffset.MinValue);
		}

		/// <inheritdoc />
		public void Dispose()
			=> optionsMonitorRegistration?.Dispose();

		/// <inheritdoc />
		public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken)
		{
			var now = DateTimeOffset.UtcNow;
			var nextCheck = lastCheck + TimeSpan.FromSeconds(settings.CurrentValue.GameServerHealthCheckSeconds);
			if (now >= nextCheck)
			{
				cachedResult = await LiveHealthCheck(cancellationToken);
				lastCheck = now;
			}

			return cachedResult;
		}

		/// <summary>
		/// Run a non-cached health check.
		/// </summary>
		/// <param name="cancellationToken">The <see cref="CancellationToken"/> for the operation.</param>
		/// <returns>A <see cref="ValueTask{TResult}"/> resulting in the <see cref="HealthCheckResult"/>.</returns>
		async ValueTask<HealthCheckResult> LiveHealthCheck(CancellationToken cancellationToken)
		{
			var servers = settings.CurrentValue.Servers;
			if (servers == null || servers.Count == 0)
				return HealthCheckResult.Healthy("No servers to check on");

			var tasks = servers.ToDictionary(server => server, server => CheckServer(server, cancellationToken));
			await Task.WhenAll(tasks.Values);

			var failedTasks = tasks.Where(kvp => kvp.Value.Result != null).ToArray();
			var counter = 0;
			var data = tasks.ToDictionary(
				kvp => $"#{++counter}: {kvp.Key.Address}:{kvp.Key.Port}",
				kvp => kvp.Value.Result == null ? (object)"Success" : "Failed");
			if (failedTasks.Length > 0)
			{
				var exception = new AggregateException(failedTasks.Select(kvp => kvp.Value.Result!));
				if (failedTasks.Length == servers.Count)
					return HealthCheckResult.Degraded("All servers have failed the ping test!", exception, data);

				return HealthCheckResult.Degraded("Some servers have failed the ping test!", exception, data);
			}

			return HealthCheckResult.Healthy("All servers passed the ping test", data);
		}

		/// <summary>
		/// Check on a given <paramref name="server"/>.
		/// </summary>
		/// <param name="server">The <see cref="ServerConfig"/> of the server to check on.</param>
		/// <param name="cancellationToken">The <see cref="CancellationToken"/> for the operation.</param>
		/// <returns>A <see cref="Task{TResult}"/> resulting in <see langword="null"/> on a successful connection test, or an <see cref="Exception"/> if an error occurred.</returns>
		async Task<Exception?> CheckServer(ServerConfig server, CancellationToken cancellationToken)
		{
			var address = server.Address;
			try
			{
				if (address == null)
					throw new Exception($"A server has a null {nameof(ServerConfig.Address)}!");

				var result = await topicClient.SendTopic(address, "ping", server.Port, cancellationToken)
					?? throw new Exception("Topic client returned null!");
				if (result.ResponseType != TopicResponseType.FloatResponse)
					throw new Exception("Response was not a float!");
			}
			catch (Exception ex)
			{
				logger.LogWarning(ex, "Server \"{address}:{port}\" failed health check!", address, server.Port);
				return ex;
			}

			return null;
		}
	}
}
