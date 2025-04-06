using System.Collections.Generic;

namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// App settings.
	/// </summary>
	sealed class Settings
	{
		/// <summary>
		/// The <see cref="PRAnnouncer.TopicTimeouts"/>. These require a server restart to change.
		/// </summary>
		public TopicTimeouts? TopicTimeouts { get; set; }

		/// <summary>
		/// Secret for communication with game servers.
		/// </summary>
		public string? CommsKey { get; set; }

		/// <summary>
		/// The secret for the GitHub webhook, if any.
		/// </summary>
		public string? GitHubSecret { get; set; }

		/// <summary>
		/// The number of seconds between ping checks on configured <see cref="Servers"/>.
		/// </summary>
		public uint GameServerHealthCheckSeconds { get; set; }

		/// <summary>
		/// The <see cref="ServerConfig"/>s for each server to forward topics to.
		/// </summary>
		public IReadOnlyList<ServerConfig>? Servers { get; set; }
	}
}
