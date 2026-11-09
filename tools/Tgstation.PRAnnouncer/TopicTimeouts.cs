namespace Tgstation.PRAnnouncer
{
	/// <summary>
	/// Timeout controls for sending topics.
	/// </summary>
	sealed class TopicTimeouts
	{
		/// <summary>
		/// The default value for properties if they are <see langword="null"/>.
		/// </summary>
		public const uint DefaultTimeoutSeconds = 5;

		/// <summary>
		/// The timeout for the send operation.
		/// </summary>
		public uint? SendTimeoutSeconds { get; set; }

		/// <summary>
		/// The timeout for the receive operation.
		/// </summary>
		public uint? ReceiveTimeoutSeconds { get; set; }

		/// <summary>
		/// The timeout for the receive operation.
		/// </summary>
		public uint? ConnectTimeoutSeconds { get; set; }

		/// <summary>
		/// The timeout for the disconnect operation.
		/// </summary>
		public uint? DisconnectTimeoutSeconds { get; set; }
	}
}
