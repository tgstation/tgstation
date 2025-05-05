using System;

using Octokit.Webhooks.Models.PullRequestEvent;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// The pull_request entry in the announce payload.
	/// </summary>
	public class PRAnnouncePayloadPullRequest
	{
		/// <summary>
		/// The <see cref="PullRequest.Id"/>.
		/// </summary>
		public long Id { get; }

		/// <summary>
		/// Initializes a new instance of the <see cref="PRAnnouncePayloadPullRequest"/>.
		/// </summary>
		/// <param name="pullRequest">The <see cref="PullRequest"/>.</param>
		public PRAnnouncePayloadPullRequest(PullRequest pullRequest)
		{
			ArgumentNullException.ThrowIfNull(pullRequest);
			Id = pullRequest.Id;
		}
	}
}
