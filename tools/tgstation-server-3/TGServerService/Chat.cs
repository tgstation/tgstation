using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using TGServiceInterface;

namespace TGServerService
{
	interface ITGChatProvider : ITGChatBase, IDisposable
	{
		/// <summary>
		/// Called with chat message info
		/// </summary>
		event OnChatMessage OnChatMessage;

		/// <summary>
		/// Connects the chat provider
		/// </summary>
		/// <returns>null on success, error message on failure</returns>
		string Connect();

		/// <summary>
		/// Disconnects the chat provider
		/// </summary>
		void Disconnect();

		/// <summary>
		/// Send a message to a channel
		/// </summary>
		/// <param name="message">The message to send</param>
		/// <param name="channel">The channel to send to</param>
		/// <returns>null on success, error message on failure</returns>
		string SendMessageDirect(string message, string channel);
	}

	/// <summary>
	/// Callback for the chat provider recieving a message
	/// </summary>
	/// <param name="speaker">The username of the speaker</param>
	/// <param name="channel">The name of the channel</param>
	/// <param name="message">The message text</param>
	/// <param name="tagged">true if the bot was mentioned in the first word, false otherwise</param>
	public delegate void OnChatMessage(string speaker, string channel, string message, bool tagged);

	partial class TGStationServer : ITGChat
	{
		ITGChatProvider ChatProvider;
		TGChatProvider currentProvider;
		object ChatLock = new object();

		public void InitChat(TGChatSetupInfo info = null)
		{
			if (info == null)
				info = ProviderInfo();
			switch (info.Provider)
			{
				case TGChatProvider.Discord:
					ChatProvider = new TGDiscordChatProvider(info);
					break;
				case TGChatProvider.IRC:
					ChatProvider = new TGIRCChatProvider(info);
					break;
				default:
					TGServerService.WriteLog(String.Format("Invalid chat provider: {0}", info.Provider), EventLogEntryType.Error);
					break;
			}
			currentProvider = info.Provider;
			ChatProvider.OnChatMessage += ChatProvider_OnChatMessage;
			if (Properties.Settings.Default.ChatEnabled)
			{
				var res = ChatProvider.Connect();
				if (res != null)
					TGServerService.WriteLog(String.Format("Unable to connect to chat! Provider {0}, Error: {1}", ChatProvider.GetType().ToString(), res));
			}
		}

		private void ChatProvider_OnChatMessage(string speaker, string channel, string message, bool tagged)
		{
			var splits = message.Trim().Split(' ');

			var s0l = splits[0].ToLower();

			if (s0l == "!check")
			{
				ChatProvider.SendMessageDirect(StatusString(HasChatAdmin(speaker, channel) == null), channel);
				return;
			}

			if (!tagged)
				return;

			if (splits.Length == 1 && splits[0] == "")
			{
				ChatProvider.SendMessageDirect("Hi!", channel);
				return;
			}

			var asList = new List<string>(splits);
			var command = asList[0].ToLower();
			asList.RemoveAt(0);

			ChatProvider.SendMessageDirect(ChatCommand(command, speaker, channel, asList), channel);
		}

		string HasChatAdmin(string speaker, string channel)
		{
			var Config = Properties.Settings.Default;
			if (!Config.ChatAdmins.Contains(speaker.ToLower()))
				return "You are not authorized to use that command!";
			if (channel.ToLower() != Config.ChatAdminChannel.ToLower())
				return "Use this command in the admin channel!";
			return null;
		}

		void DisposeChat()
		{
			ChatProvider.Dispose();
		}

		//Do stuff with words that were spoken to us
		string ChatCommand(string command, string speaker, string channel, IList<string> parameters)
		{
			TGServerService.WriteLog(String.Format("IRC Command from {0}: {1} {2}", speaker, command, String.Join(" ", parameters)));
			switch (command)
			{
				case "check":
					return StatusString(HasChatAdmin(speaker, channel) == null);
				case "byond":
					if (parameters.Count > 0)
						if (parameters[0].ToLower() == "--staged")
							return GetVersion(TGByondVersion.Staged) ?? "None";
						else if (parameters[0].ToLower() == "--latest")
							return GetVersion(TGByondVersion.Latest) ?? "Unknown";
					return GetVersion(TGByondVersion.Staged) ?? "Uninstalled";
				case "status":
					return HasChatAdmin(speaker, channel) ?? SendCommand(SCIRCStatus);
				case "adminwho":
					return HasChatAdmin(speaker, channel) ?? SendCommand(SCAdminWho);
				case "ahelp":
					var res = HasChatAdmin(speaker, channel);
					if (res != null)
						return res;
					if (parameters.Count < 2)
						return "Usage: ahelp <ckey> <message>";
					var ckey = parameters[0];
					parameters.RemoveAt(0);
					return SendPM(ckey, speaker, String.Join(" ", parameters));
				case "namecheck":
					res = HasChatAdmin(speaker, channel);
					if (res != null)
						return res;
					if (parameters.Count < 1)
						return "Usage: namecheck <target>";
					return NameCheck(parameters[0], speaker);
			}
			return "Unknown command: " + command;
		}

		//public api
		public string SetEnabled(bool enable)
		{
			lock (ChatLock)
			{
				Properties.Settings.Default.ChatEnabled = enable;
				if (!enable && Connected())
					ChatProvider.Disconnect();
				else if (enable && !Connected())
					return ChatProvider.Connect();
				return null;
			}
		}

		//public api
		public string[] Channels()
		{
			lock (ChatLock)
			{
				return CollectionToArray(Properties.Settings.Default.ChatChannels);
			}
		}

		//what it says on the tin
		string[] CollectionToArray(StringCollection sc)
		{
			string[] strArray = new string[sc.Count];
			sc.CopyTo(strArray, 0);
			return strArray;
		}
		//public api
		public string AdminChannel()
		{
			lock (ChatLock)
			{
				return Properties.Settings.Default.ChatAdminChannel;
			}
		}
		//public api
		public bool Enabled()
		{
			lock (ChatLock)
			{
				return Properties.Settings.Default.ChatEnabled;
			}
		}

		//public api
		public string[] ListAdmins()
		{
			lock (ChatLock)
			{
				return CollectionToArray(Properties.Settings.Default.ChatAdmins);
			}
		}

		//public api
		public void SetAdmins(string[] admins)
		{
			var si = new StringCollection();
			foreach (var I in admins)
				si.Add(I.Trim().ToLower());
			lock (ChatLock)
			{
				Properties.Settings.Default.ChatAdmins = si;
			}
		}

		//public api
		public TGChatSetupInfo ProviderInfo()
		{
			lock (ChatLock)
			{
				var Config = Properties.Settings.Default;
				var rawdata = Config.ChatProviderData;
				if (rawdata == "NEEDS INITIALIZING")
					switch ((TGChatProvider)Config.ChatProvider)
					{
						case TGChatProvider.Discord:
							return new TGDiscordSetupInfo();
						case TGChatProvider.IRC:
							return new TGIRCSetupInfo();
						default:
							TGServerService.WriteLog("Invalid chat provider: " + Config.ChatProvider.ToString());
							return null;
					}

				byte[] plaintext;
				try
				{
					plaintext = ProtectedData.Unprotect(Convert.FromBase64String(Config.ChatProviderData), Convert.FromBase64String(Config.ChatProviderEntropy), DataProtectionScope.CurrentUser);

					var Deserializer = new JavaScriptSerializer();
					return new TGChatSetupInfo(Deserializer.Deserialize<List<string>>(Encoding.UTF8.GetString(plaintext)), (TGChatProvider)Config.ChatProvider);
				}
				catch
				{
					Config.ChatProviderData = "NEEDS INITIALIZING";
				}
			}
			//if we get here we want to retry
			return ProviderInfo();
		}

		//public api
		public string SetProviderInfo(TGChatSetupInfo info)
		{
			lock (ChatLock)
			{
				var Serializer = new JavaScriptSerializer();
				var rawdata = Serializer.Serialize(info.DataFields);
				var Config = Properties.Settings.Default;
				Config.ChatProvider = (int)info.Provider;
				Config.ChatProviderData = rawdata;
				
				byte[] plaintext = Encoding.UTF8.GetBytes(rawdata);

				// Generate additional entropy (will be used as the Initialization vector)
				byte[] entropy = new byte[20];
				using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
				{
					rng.GetBytes(entropy);
				}

				byte[] ciphertext = ProtectedData.Protect(plaintext, entropy, DataProtectionScope.CurrentUser);
				
				Config.ChatProviderEntropy = Convert.ToBase64String(entropy, 0, entropy.Length);
				Config.ChatProviderData = Convert.ToBase64String(ciphertext, 0, ciphertext.Length);
				
				if (info.Provider == currentProvider)
					return ChatProvider.SetProviderInfo(info);
				else
				{
					DisposeChat();
					InitChat(info);
					return null;
				}
			}
		}

		//public api
		public void SetChannels(string[] channels = null, string adminchannel = null)
		{
			var Config = Properties.Settings.Default;
			lock (ChatLock)
			{
				if (channels != null)
				{
					var oldchannels = Config.ChatChannels;
					var si = new StringCollection();
					foreach(var c in channels)
					{
						var working = c.Trim();
						if (working.Length == 0)
							continue;
						if (working[0] != '#')
							working = "#" + working;
						si.Add(working);
					}
					if (!si.Contains(Config.ChatAdminChannel))
						si.Add(Config.ChatAdminChannel);
					Config.ChatChannels = si;
				}
				if (adminchannel != null)
					Config.ChatAdminChannel = adminchannel;
				if (channels != null && Connected())
					ChatProvider.SetChannels(CollectionToArray(Config.ChatChannels), null);
			}			
		}
	
		//public api
		public bool Connected()
		{
			lock (ChatLock)
			{
				return ChatProvider.Connected();
			}
		}

		//public api
		public string Reconnect()
		{
			lock (ChatLock)
			{
				if (!Properties.Settings.Default.ChatEnabled)
					return "Chat is disabled!";
				return ChatProvider.Reconnect();
			}
		}

		//public api
		public string SendMessage(string msg, bool adminOnly = false)
		{
			lock (ChatLock)
			{
				return ChatProvider.SendMessage(msg, adminOnly);
			}
		}
	}
}
