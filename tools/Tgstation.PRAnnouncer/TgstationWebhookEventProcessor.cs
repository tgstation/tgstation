using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web;

using Byond.TopicSender;

using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

using Octokit.Webhooks;
using Octokit.Webhooks.Events;
using Octokit.Webhooks.Events.PullRequest;

using Prometheus;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// Tgstation webhook processor.
	/// </summary>
	sealed class TgstationWebhookEventProcessor : WebhookEventProcessor
	{
		/// <summary>
		/// The <see cref="ITopicClient"/> to use.
		/// </summary>
		readonly ITopicClient topicClient;

		/// <summary>
		/// The <see cref="ILogger"/> to write to.
		/// </summary>
		readonly ILogger<TgstationWebhookEventProcessor> logger;

		/// <summary>
		/// The <see cref="IOptionsMonitor{TOptions}"/> for the <see cref="Settings"/>.
		/// </summary>
		readonly IOptionsMonitor<Settings> options;

		readonly Counter announcementsTriggered;
		readonly Counter badCalls;
		readonly Counter successfulTopicCalls;
		readonly Counter failedTopicCalls;

		/// <summary>
		/// Initializes a new instanc eof the <see cref="TgstationWebhookEventProcessor"/> class.
		/// </summary>
		/// <param name="topicClient">The value of <see cref="topicClient"/>.</param>
		/// <param name="metricFactory">The <see cref="IMetricFactory"/> used to create metrics.</param>
		/// <param name="options">The value of <see cref="options"/>.</param>
		/// <param name="logger">The value of <see cref="logger"/>.</param>
		public TgstationWebhookEventProcessor(
			ITopicClient topicClient,
			IMetricFactory metricFactory,
			IOptionsMonitor<Settings> options,
			ILogger<TgstationWebhookEventProcessor> logger)
		{
			this.topicClient = topicClient ?? throw new ArgumentNullException(nameof(topicClient));
			ArgumentNullException.ThrowIfNull(metricFactory);
			this.options = options ?? throw new ArgumentNullException(nameof(options));
			this.logger = logger ?? throw new ArgumentNullException(nameof(logger));

			announcementsTriggered = metricFactory.CreateCounter("pr_announcer_announcements_triggered", "The number of webhooks that triggered a PR announcement that have been processed");
			badCalls = metricFactory.CreateCounter("pr_announcer_bad_calls", "The number of malformed webhook calls received");
			successfulTopicCalls = metricFactory.CreateCounter("pr_announcer_successful_topic_calls", "Total number of successful topic calls");
			failedTopicCalls = metricFactory.CreateCounter("pr_announcer_failed_topic_calls", "Total number of failed topic calls");
		}

		/// <inheritdoc />
		protected override Task ProcessPullRequestWebhookAsync(WebhookHeaders headers, PullRequestEvent pullRequestEvent, PullRequestAction action)
		{
			var repo = pullRequestEvent.Repository;
			if (repo == null)
			{
				logger.LogWarning("Bad payload: Repo was null");
				badCalls.Inc();
				return Task.CompletedTask;
			}

			var slug = $"{repo.Owner.Login}/{repo.Name}";
			if (!(action == PullRequestAction.Closed
				|| action == PullRequestAction.Opened))
			{
				logger.LogDebug(
					 "Ignoring unwanted PR action {action}: {slug} #{number} by @{author}",
					pullRequestEvent.Action,
					slug,
					pullRequestEvent.Number,
					pullRequestEvent.PullRequest.User.Login);
				return Task.CompletedTask;
			}

			logger.LogInformation(
				"Received pull request webhook: {slug} #{number} by @{author} {action}",
				slug,
				pullRequestEvent.Number,
				pullRequestEvent.PullRequest.User.Login,
				pullRequestEvent.Action);

#pragma warning disable IDE0059 // Unnecessary assignment of a value, WTF VS?
			if (pullRequestEvent.AdditionalProperties?.TryGetValue("author_association", out var authorAssociation) ?? false
#pragma warning restore IDE0059
				&& (authorAssociation.ValueEquals("FIRST_TIMER") || authorAssociation.ValueEquals("FIRST_TIME_CONTRIBUTROR")))
			{
				logger.LogInformation(
					"Not triggering announcement, first time contributor detected");
				return Task.CompletedTask;
			}

			var settings = options.CurrentValue;
			var commsKey = settings.CommsKey;

			if(commsKey == null)
			{
				logger.LogError("Cannot process webhook, {commsKey} is null!", nameof(Settings.CommsKey));
				return Task.CompletedTask;
			}

			var relevantServers = (IReadOnlyCollection<ServerConfig>?)settings
				.Servers
				?.Where(
					config => config
						.InterestedRepoSlugs
						?.Any(
							interestedSlug => interestedSlug.Equals(
								slug,
								StringComparison.OrdinalIgnoreCase))
						?? true)
				.ToList()
				?? [];

			if (relevantServers.Count == 0)
			{
				logger.LogInformation("No servers interested");
				return Task.CompletedTask;
			}

			announcementsTriggered.Inc();

			var payload = new PRAnnounceQuery(pullRequestEvent, commsKey);

			return Task.WhenAll(relevantServers.Select(server => SendPayload(server, payload)));
		}

		/// <summary>
		/// Send a given <paramref name="payload"/> to a given <paramref name="server"/>.
		/// </summary>
		/// <param name="server">The <see cref="ServerConfig"/> of the server to send to.</param>
		/// <param name="payload">The <see cref="PRAnnounceQuery"/></param>
		/// <returns></returns>
		async Task SendPayload(ServerConfig server, PRAnnounceQuery payload)
		{
			var address = server.Address;
			if(address == null)
			{
				logger.LogError("A server has a null Address configured!");
				return;
			}

			var encodedPayload = payload.Serialize();

			try
			{
				var result = await topicClient.SendTopic(address, encodedPayload, server.Port);
				successfulTopicCalls.Inc();
			}
			catch (Exception ex)
			{
				failedTopicCalls.Inc();
				logger.LogError(ex, "Failed to send topic to game server {address}:{port}", address, server.Port);
			}
		}
	}
}
