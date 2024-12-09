using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Extensions.DependencyInjection;

using Octokit;

using Remora.Discord.API.Abstractions.Gateway.Events;
using Remora.Discord.API.Abstractions.Objects;
using Remora.Discord.API.Abstractions.Rest;
using Remora.Discord.API.Objects;
using Remora.Discord.Gateway;
using Remora.Discord.Gateway.Extensions;
using Remora.Rest.Core;
using Remora.Rest.Results;
using Remora.Results;

namespace Tgstation.DiscordDiscussions
{
	public sealed partial class Program : IDiscordResponders
	{
		const bool LockPullRequest = true;
		const int InitSlowModeSeconds = 60;

		[GeneratedRegex(@"https://discord.com/channels/[0-9]+/([0-9]+)")]
		private static partial Regex ChannelLinkRegex();

		readonly TaskCompletionSource gatewayReadyTcs;

		public static Task<int> Main(string[] args)
			=> new Program().RunAsync(args);

		/// <summary>
		/// Converts a given <paramref name="result"/> into a log entry <see cref="string"/>.
		/// </summary>
		/// <param name="result">The <see cref="IResult"/> to convert.</param>
		/// <param name="level">Used internally for nesting.</param>
		/// <returns>The <see cref="string"/> formatted <paramref name="result"/>.</returns>
		static string LogFormat(IResult result, uint level = 0)
		{
			ArgumentNullException.ThrowIfNull(result);

			if (result.IsSuccess)
				return "SUCCESS?";

			var stringBuilder = new StringBuilder();
			if (result.Error != null)
			{
				stringBuilder.Append(result.Error.Message);
				if (result.Error is RestResultError<RestError> restError)
				{
					stringBuilder.Append(" (");
					if (restError.Error != null)
					{
						stringBuilder.Append(restError.Error.Code);
						stringBuilder.Append(": ");
						stringBuilder.Append(restError.Error.Message);
						stringBuilder.Append('|');
					}

					stringBuilder.Append(restError.Message);
					if ((restError.Error?.Errors.HasValue ?? false) && restError.Error.Errors.Value.Count > 0)
					{
						stringBuilder.Append(" (");
						foreach (var error in restError.Error.Errors.Value)
						{
							stringBuilder.Append(error.Key);
							stringBuilder.Append(':');
							if (error.Value.IsT0)
							{
								FormatErrorDetails(error.Value.AsT0, stringBuilder);
							}
							else
								FormatErrorDetails(error.Value.AsT1, stringBuilder);
							stringBuilder.Append(',');
						}

						stringBuilder.Remove(stringBuilder.Length - 1, 1);
					}

					stringBuilder.Append(')');
				}
			}

			if (result.Inner != null)
			{
				stringBuilder.Append(Environment.NewLine);
				++level;
				for (var i = 0; i < level; ++i)
					stringBuilder.Append('\t');
				stringBuilder.Append(LogFormat(result.Inner, level));
			}

			return stringBuilder.ToString();
		}

		/// <summary>
		/// Formats given <paramref name="propertyErrorDetails"/> into a given <paramref name="stringBuilder"/>.
		/// </summary>
		/// <param name="propertyErrorDetails">The <see cref="IPropertyErrorDetails"/>.</param>
		/// <param name="stringBuilder">The <see cref="StringBuilder"/> to mutate.</param>
		static void FormatErrorDetails(IPropertyErrorDetails propertyErrorDetails, StringBuilder stringBuilder)
		{
			if (propertyErrorDetails == null)
				return;

			FormatErrorDetails(propertyErrorDetails.Errors, stringBuilder);

			if (propertyErrorDetails.Errors != null && propertyErrorDetails.MemberErrors != null)
			{
				stringBuilder.Append(',');
			}

			if (propertyErrorDetails.MemberErrors != null)
			{
				stringBuilder.Append('{');
				foreach (var error in propertyErrorDetails.MemberErrors)
				{
					stringBuilder.Append(error.Key);
					stringBuilder.Append(':');
					FormatErrorDetails(error.Value, stringBuilder);
					stringBuilder.Append(',');
				}

				stringBuilder.Remove(stringBuilder.Length - 1, 1);
				stringBuilder.Append('}');
			}
		}

		/// <summary>
		/// Formats given <paramref name="errorDetails"/> into a given <paramref name="stringBuilder"/>.
		/// </summary>
		/// <param name="errorDetails">The <see cref="IEnumerable{T}"/> of <see cref="IErrorDetails"/>.</param>
		/// <param name="stringBuilder">The <see cref="StringBuilder"/> to mutate.</param>
		static void FormatErrorDetails(IEnumerable<IErrorDetails>? errorDetails, StringBuilder stringBuilder)
		{
			if (errorDetails == null)
				return;

			stringBuilder.Append('[');
			foreach (var error in errorDetails)
			{
				stringBuilder.Append(error.Code);
				stringBuilder.Append(':');
				stringBuilder.Append(error.Message);
				stringBuilder.Append(',');
			}

			stringBuilder.Remove(stringBuilder.Length - 1, 1);
			stringBuilder.Append(']');
		}

		Program()
		{
			gatewayReadyTcs = new TaskCompletionSource();
		}

		async Task<int> RunAsync(string[] args)
		{
			try
			{
				var gitHubToken = args[0];
				var repoOwner = args[1];
				var repoName = args[2];
				var prNumber = Int32.Parse(args[3]);
				var state = Enum.Parse<PullRequestState>(args[4]);
				var discordToken = args[5];
				var discussionsChannelId = UInt64.Parse(args[6]);
				var isReopen = Boolean.Parse(args[7]);
				var joinLink = args.Length > 8 ? args[8] : null;

				var prTitle = Environment.GetEnvironmentVariable("GITHUB_PULL_REQUEST_TITLE")!;

				var gitHubClient = new GitHubClient(new ProductHeaderValue("Tgstation.DiscordDiscussions"))
				{
					Credentials = new Credentials(gitHubToken),
				};

				const string GitHubCommentPrefix = "Maintainers have requested non-technical related discussion regarding this pull request be moved to the Discord.";

				async ValueTask<ulong?> FindThreadID()
				{
					var comments = await gitHubClient.Issue.Comment.GetAllForIssue(repoOwner, repoName, prNumber);

					var commentInQuestion = comments.FirstOrDefault(comment => comment.Body.StartsWith(GitHubCommentPrefix));
					if (commentInQuestion == null)
						return null;

					// https://discord.com/channels/<guild ID>/<thread ID>
					var threadId = UInt64.Parse(ChannelLinkRegex().Match(commentInQuestion.Body).Groups[1].Value);
					return threadId;
				}

				var threadIdTask = FindThreadID();

				await using var serviceProvider = new ServiceCollection()
					.AddDiscordGateway(serviceProvider => discordToken)
					.AddSingleton(serviceProvider => (IDiscordResponders)this)
					.AddResponder<DiscordForwardingResponder>()
					.BuildServiceProvider();

				var gatewayClient = serviceProvider.GetRequiredService<DiscordGatewayClient>();
				using var gatewayCts = new CancellationTokenSource();
				var localGatewayTask = gatewayClient.RunAsync(gatewayCts.Token);
				try
				{
					await gatewayReadyTcs.Task.WaitAsync(TimeSpan.FromMinutes(5));

					var prLink = $"https://github.com/{repoOwner}/{repoName}/pull/{prNumber}";
					var messageContent = $"#{prNumber} - {prTitle}";

					// thread titles can only be 100 long
					if (messageContent.Length > 100)
					{
						messageContent = $"#{prNumber} - {prTitle[..^(messageContent.Length - 97)]}...";
					}

					var channelsClient = serviceProvider.GetRequiredService<IDiscordRestChannelAPI>();

					var channelId = new Snowflake(discussionsChannelId);

					var threadId = await threadIdTask;
					Snowflake messageId;
					if (!threadId.HasValue)
					{
						var channel = await channelsClient.GetChannelAsync(channelId);
						if (!channel.IsSuccess)
							throw new Exception(LogFormat(channel));

						var threadMessage = await channelsClient.StartThreadInForumChannelAsync(channelId, messageContent, AutoArchiveDuration.Week, InitSlowModeSeconds, $"Maintainers have requested that discussion for [this pull request]({prLink}) be moved here.");
						if (!threadMessage.IsSuccess)
							throw new Exception(LogFormat(threadMessage));

						messageId = threadMessage.Entity.ID;

						var gitHubComment = $"{GitHubCommentPrefix}\nClick [here](https://discord.com/channels/{channel.Entity.GuildID.Value}/{messageId.Value}) to view the discussion.";
						if (joinLink != null)
							gitHubComment += $"\nClick [here]({joinLink}) to join the Discord!";

						await gitHubClient.Issue.Comment.Create(repoOwner, repoName, prNumber, gitHubComment);
					}
					else
					{
						messageId = new Snowflake(threadId.Value);

						// open/close thread
						if (state != PullRequestState.open)
						{
							var archiveMessage = await channelsClient.CreateMessageAsync(messageId, $"The associated pull request for this thread has been {state.ToString().ToLowerInvariant()}. This thread will now be archived.");
							if (!archiveMessage.IsSuccess)
								throw new Exception(LogFormat(archiveMessage));

							var archiveAction = await channelsClient.ModifyThreadChannelAsync(messageId, messageContent, autoArchiveDuration: AutoArchiveDuration.Hour, isArchived: true);
							if (!archiveAction.IsSuccess)
								throw new Exception(LogFormat(archiveAction));
						}
						else if (isReopen)
						{
							var unarchiveMessage = await channelsClient.CreateMessageAsync(messageId, "The associated pull request for this thread has been reopened. This thread will now be reopened.");
							if (!unarchiveMessage.IsSuccess)
								throw new Exception(LogFormat(unarchiveMessage));

							var unarchiveAction = await channelsClient.ModifyThreadChannelAsync(messageId, messageContent, autoArchiveDuration: AutoArchiveDuration.Week, isArchived: false);
							if (!unarchiveMessage.IsSuccess)
								throw new Exception(LogFormat(unarchiveMessage));
						}
						else
						{
							var response = await channelsClient.ModifyThreadChannelAsync(messageId, messageContent);
							if (!response.IsSuccess)
								throw new Exception(LogFormat(response));
						}
					}

					// ensure the PR is locked
					if (LockPullRequest)
					{
						await gitHubClient.PullRequest.LockUnlock.Lock(repoOwner, repoName, prNumber);
					}

					return 0;
				}
				finally
				{
					gatewayCts.Cancel();
					try
					{
						await localGatewayTask.WaitAsync(TimeSpan.FromSeconds(10));
					}
					catch (OperationCanceledException)
					{
					}
				}
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.ToString());
				return 1;
			}
		}

		public Task<Result> RespondAsync(IReady gatewayEvent, CancellationToken ct = default)
		{
			gatewayReadyTcs.TrySetResult();
			return Task.FromResult(Result.FromSuccess());
		}
	}
}
