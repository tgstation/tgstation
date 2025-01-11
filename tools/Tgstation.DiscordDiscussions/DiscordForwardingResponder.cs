using System;
using System.Threading;
using System.Threading.Tasks;

using Remora.Discord.API.Abstractions.Gateway.Events;
using Remora.Discord.Gateway.Responders;
using Remora.Results;

namespace Tgstation.DiscordDiscussions
{
	/// <summary>
	/// An <see cref="IResponder{TGatewayEvent}"/> that forwards to another <see cref="targetResponder"/>.
	/// </summary>
	/// <remarks>
	/// Initializes a new instance of the <see cref="DiscordForwardingResponder"/> class.
	/// </remarks>
	/// <param name="targetResponder">The value of <see cref="targetResponder"/>.</param>
	sealed class DiscordForwardingResponder(IDiscordResponders targetResponder) : IDiscordResponders
	{
		/// <summary>
		/// The <see cref="IResponder{TGatewayEvent}"/> to forward the event to.
		/// </summary>
		readonly IDiscordResponders targetResponder = targetResponder ?? throw new ArgumentNullException(nameof(targetResponder));

		/// <inheritdoc />
		public Task<Result> RespondAsync(IReady gatewayEvent, CancellationToken ct) => targetResponder.RespondAsync(gatewayEvent, ct);
	}
}
