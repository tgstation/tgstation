using System.Collections.Generic;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// Configuration for a game server to send announcement messages to.
	/// </summary>
	sealed class ServerConfig
	{
		/// <summary>
		/// The server's address.
		/// </summary>
		public string? Address { get; set; }

		/// <summary>
		/// The server's port.
		/// </summary>
		public ushort Port { get; set; }

		/// <summary>
		/// The list of repository slugs that the server should listen to pull request events for. If <see langword="null"/>, all repositories will be listened to.
		/// </summary>
		/// <example>tgstation/tgstation</example>
		public IReadOnlyList<string>? InterestedRepoSlugs { get; set; }
	}
}
