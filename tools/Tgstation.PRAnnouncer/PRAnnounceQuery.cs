using System;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Web;

using Octokit.Webhooks.Events;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// The payload the /datum/world_topic/pr_announce handler expects.
	/// </summary>
	sealed class PRAnnounceQuery
	{
		/// <summary>
		/// The <see cref="JsonSerializerOptions"/> for sending payloads to game servers.
		/// </summary>
		static readonly JsonSerializerOptions serializerOptions = new JsonSerializerOptions
		{
			PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
		};

		readonly PRAnnouncePayload payload;

		/// <summary>
		/// The raw html announce <see cref="string"/>.
		/// </summary>
		readonly string announce;

		/// <summary>
		/// The comms key.
		/// </summary>
		readonly string key;

		/// <summary>
		/// Initializes a new instance of the <see cref="PRAnnounceQuery"/> class.
		/// </summary>
		/// <param name="pullRequestEvent">The <see cref="PullRequestEvent"/> to announce.</param>
		/// <param name="commsKey">The value of <see cref="key"/>.</param>
		public PRAnnounceQuery(PullRequestEvent pullRequestEvent, string commsKey)
		{
			ArgumentNullException.ThrowIfNull(pullRequestEvent);
			key = commsKey ?? throw new ArgumentNullException(commsKey);
			payload = new PRAnnouncePayload
			{
				PullRequest = new PRAnnouncePayloadPullRequest(pullRequestEvent.PullRequest),
			};

            var action = pullRequestEvent.PullRequest.Merged == true ? "merged" : pullRequestEvent.Action;
            if (action != null && pullRequestEvent.Sender?.Login != null)
            {
                action += $" by {HtmlEncoder.Default.Encode(pullRequestEvent.Sender.Login)}";
            }

			announce = $"[{pullRequestEvent.PullRequest.Base.Repo.FullName}] Pull Request {action ?? "(NULL ACTION)"}: <a href=\"{pullRequestEvent.PullRequest.HtmlUrl}\">#{pullRequestEvent.PullRequest.Number} {HtmlEncoder.Default.Encode($"{pullRequestEvent.PullRequest.User.Login} - {pullRequestEvent.PullRequest.Title}")}</a>";
		}

		/// <summary>
		/// Serialize the <see cref="PRAnnounceQuery"/> to a topic <see cref="string"/>.
		/// </summary>
		/// <returns>The serialized <see cref="PRAnnounceQuery"/>.</returns>
		public string Serialize()
			=> $"?key={HttpUtility.UrlEncode(key)}&announce={HttpUtility.UrlEncode(announce)}&payload={HttpUtility.UrlEncode(JsonSerializer.Serialize(payload, serializerOptions))}";
	}
}
