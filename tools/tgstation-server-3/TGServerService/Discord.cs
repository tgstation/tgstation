using System;
using TGServiceInterface;

namespace TGServerService
{
	class TGDiscordChatProvider : ITGChatProvider
	{
		public event OnChatMessage OnChatMessage;

		public TGDiscordChatProvider(TGChatSetupInfo info)
		{
			throw new NotImplementedException();
		}

		public bool Connected()
		{
			throw new NotImplementedException();
		}

		public string Reconnect()
		{
			throw new NotImplementedException();
		}

		public string SendMessage(string msg, bool adminOnly = false)
		{
			throw new NotImplementedException();
		}

		public string SendMessageDirect(string message, string channel)
		{
			throw new NotImplementedException();
		}

		public void SetChannels(string[] channels = null, string adminchannel = null)
		{
			throw new NotImplementedException();
		}

		public string SetProviderInfo(TGChatSetupInfo info)
		{
			throw new NotImplementedException();
		}
		
		public TGChatSetupInfo Shutdown()
		{
			throw new NotImplementedException();
		}

		#region IDisposable Support
		private bool disposedValue = false; // To detect redundant calls

		protected virtual void Dispose(bool disposing)
		{
			if (!disposedValue)
			{
				if (disposing)
				{
					// TODO: dispose managed state (managed objects).
				}

				// TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
				// TODO: set large fields to null.

				disposedValue = true;
			}
		}

		// TODO: override a finalizer only if Dispose(bool disposing) above has code to free unmanaged resources.
		// ~TGDiscordChatProvider() {
		//   // Do not change this code. Put cleanup code in Dispose(bool disposing) above.
		//   Dispose(false);
		// }

		// This code added to correctly implement the disposable pattern.
		public void Dispose()
		{
			// Do not change this code. Put cleanup code in Dispose(bool disposing) above.
			Dispose(true);
			// TODO: uncomment the following line if the finalizer is overridden above.
			// GC.SuppressFinalize(this);
		}

		public string Connect()
		{
			throw new NotImplementedException();
		}

		public void Disconnect()
		{
			throw new NotImplementedException();
		}
		#endregion
	}
}
