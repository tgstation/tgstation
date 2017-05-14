using System;
using System.Collections.Generic;
using System.Threading;
using TGServiceInterface;
using Meebey.SmartIrc4net;


namespace TGServerService
{
	class TGIRCChatProvider : ITGChatProvider
	{
		IrcClient irc;
		int reconnectAttempt = 0;

		object IRCLock = new object();

		TGIRCSetupInfo IRCConfig;

		public event OnChatMessage OnChatMessage;
		
		public TGIRCChatProvider(TGChatSetupInfo info)
		{
			IRCConfig = new TGIRCSetupInfo(info);
			irc = new IrcClient() { SupportNonRfc = true };
			irc.OnChannelMessage += Irc_OnChannelMessage;
		}
		
		//public api
		public string SendMessageDirect(string message, string channel)
		{
			try
			{
				if (!Connected())
					return "Disconnected.";
				lock (IRCLock)
				{
					irc.SendMessage(SendType.Message, channel, message);
				}
				TGServerService.WriteLog(String.Format("IRC Send ({0}): {1}", channel, message));
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		public string SetProviderInfo(TGChatSetupInfo info)
		{
			var convertedInfo = (TGIRCSetupInfo)info;
			var serverChange = convertedInfo.URL != IRCConfig.URL || convertedInfo.Port != IRCConfig.Port;
			IRCConfig = convertedInfo;
			if (serverChange)
				return Reconnect();
			else if (convertedInfo.Nickname != irc.Nickname)
				irc.RfcNick(convertedInfo.Nickname);
			Login();
			return null;
		}

		public void SetChannels(string[] channels = null, string adminchannel = null)
		{
			throw new NotImplementedException();
		}

		private void Irc_OnChannelMessage(object sender, IrcEventArgs e)
		{
			var formattedMessage = e.Data.Message;

			var splits = new List<string>(formattedMessage.Split(' '));
			var tagged = splits[0].ToLower() == irc.Nickname.ToLower();

			if (tagged)
			{
				splits.RemoveAt(0);
				formattedMessage = String.Join(" ", splits);
			}

			OnChatMessage(e.Data.Nick, e.Data.Channel, formattedMessage, tagged);
		}
		//Joins configured channels
		void JoinChannels()
		{
			foreach (var I in Properties.Settings.Default.ChatChannels)
				irc.RfcJoin(I);
		}
		//runs the login command
		void Login()
		{
			lock (IRCLock)
			{
				if (IRCConfig.AuthTarget != null)
					irc.SendMessage(SendType.Message, IRCConfig.AuthTarget, IRCConfig.AuthMessage);
			}
		}
		//public api
		public string Connect()
		{
			if (Connected())
				return null;
			lock (IRCLock)
			{
				try
				{
					try
					{
						irc.Connect(IRCConfig.URL, IRCConfig.Port);
						reconnectAttempt = 0;
					}
					catch (Exception e)
					{
						reconnectAttempt++;
						if (reconnectAttempt <= 5)
						{
							Thread.Sleep(5000); //Reconnecting after 5 seconds.
							return Connect();
						}
						else
						{
							return "IRC server unreachable: " + e.ToString();
						}
					}

					try
					{
						irc.Login(IRCConfig.Nickname, IRCConfig.Nickname);
					}
					catch (Exception e)
					{
						return "Bot name is already taken: " + e.ToString();
					}
					Login();
					JoinChannels();
					new Thread(new ThreadStart(IRCListen)) { IsBackground = true }.Start();
					return null;
				}
				catch (Exception e)
				{
					return e.ToString();
				}
			}
		}

		//This is the thread that listens for irc messages
		void IRCListen()
		{
			while (Connected())
				try
				{
					irc.Listen();
				}
				catch { }
		}

		//public api
		public string Reconnect()
		{
			Disconnect();
			return Connect();
		}

		//public api
		public void Disconnect()
		{ 
			try
			{
				lock (IRCLock)
				{
					//because of a bug in smart irc this takes forever and there's nothing we can really do about it 
					//If you want it fixed, get this damn pull request through https://github.com/meebey/SmartIrc4net/pull/31
					if (irc.IsConnected)
					{
						var psrt = irc.SocketReceiveTimeout;
						var psst = irc.SocketSendTimeout;
						irc.SocketReceiveTimeout = 0;
						irc.SocketSendTimeout = 0;
						irc.Disconnect();
						irc.SocketReceiveTimeout = psrt;
						irc.SocketSendTimeout = psst;
					}
				}
			}
			catch
			{ }
		}
		//public api
		public bool Connected()
		{
			lock (IRCLock)
			{
				return irc.IsConnected;
			}
		}
		//public api
		public string SendMessage(string message, bool adminOnly)
		{
			try
			{
				if (!Connected())
					return "Disconnected.";
				lock (IRCLock)
				{
					var Config = Properties.Settings.Default;
					if (adminOnly)
						irc.SendMessage(SendType.Message, Config.ChatAdminChannel, message);
					else
						foreach (var I in Config.ChatChannels)
							irc.SendMessage(SendType.Message, I, message);
				}
				TGServerService.WriteLog(String.Format("IRC Send{0}: {1}", adminOnly ? " (ADMIN)" : "", message));
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
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
					Disconnect();
					irc = null;
				}

				// TODO: free unmanaged resources (unmanaged objects) and override a finalizer below.
				// TODO: set large fields to null.

				disposedValue = true;
			}
		}

		// TODO: override a finalizer only if Dispose(bool disposing) above has code to free unmanaged resources.
		// ~TGIRCChatProvider() {
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
		#endregion
	}
}
