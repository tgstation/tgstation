namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// The "payload" option for the PR announce topic.
	/// </summary>
	sealed class PRAnnouncePayload
	{
		/// <summary>
		/// The <see cref="PRAnnouncePayloadPullRequest"/>.
		/// </summary>
		public required PRAnnouncePayloadPullRequest PullRequest { get; init; }
	}
}
