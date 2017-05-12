using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Diagnostics;
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
		/// <returns></returns>
		string SendMessageDirect(string message, string channel);
	}

	/// <summary>
	/// Callback for the chat provider recieving a message
	/// </summary>
	/// <param name="speaker"></param>
	/// <param name="channel"></param>
	/// <param name="message"></param>
	/// <param name="tagged"></param>
	public delegate void OnChatMessage(string speaker, string channel, string message, bool tagged);

	partial class TGStationServer : ITGChat
	{
		ITGChatProvider ChatProvider;
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
					TGServerService.ActiveService.EventLog.WriteEntry(String.Format("Invalid chat provider: {0}", info.Provider), EventLogEntryType.Error);
					break;
			}
			ChatProvider.OnChatMessage += ChatProvider_OnChatMessage;
			if (Properties.Settings.Default.ChatEnabled)
			{
				var res = ChatProvider.Connect();
				if (res != null)
					TGServerService.ActiveService.EventLog.WriteEntry(String.Format("Unable to connect to chat! Provider {0}, Error: {1}", ChatProvider.GetType().ToString(), res));
			}
		}

		private void ChatProvider_OnChatMessage(string speaker, string channel, string message, bool tagged)
		{
			var splits = message.Split(' ');

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
				ChatProvider.SendMessage("Hi!");
				return;
			}

			var asList = new List<string>(splits);
			var command = asList[0].ToLower();
			asList.RemoveAt(0);

			ChatProvider.SendMessageDirect(ChatCommand(command, speaker, channel, asList), channel);
		}

		string HasChatAdmin(string speaker, string channel)
		{
			if (!Properties.Settings.Default.ChatAdmins.Contains(speaker.ToLower()))
				return "You are not authorized to use that command!";
			if (channel.ToLower() != Properties.Settings.Default.ChatAdminChannel.ToLower())
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
			TGServerService.ActiveService.EventLog.WriteEntry(String.Format("IRC Command from {0}: {1} {2}", speaker, command, String.Join(" ", parameters)));
			switch (command)
			{
				case "check":
					return StatusString(HasChatAdmin(speaker, channel) == null);
				case "byond":
					if (parameters.Count > 0 && parameters[0].ToLower() == "--staged")
						return GetVersion(true) ?? "None";
					return GetVersion(false) ?? "Uninstalled";
				case "status":
					return HasChatAdmin(speaker, channel) ?? SendCommand(SCIRCStatus);
				case "adminwho":
					return HasChatAdmin(speaker, channel) ?? SendCommand(SCAdminWho);
				case "ahelp":
					var res = HasChatAdmin(speaker, channel);
					if (res != null)
						return res;
					if (parameters.Count < 2)
						return "Usage: pm <ckey> <message>";
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
			}
			if (!enable && Connected())
				ChatProvider.Disconnect();
			else if (enable && !Connected())
				return ChatProvider.Connect();
			return null;
		}

		//public api
		public string[] Channels()
		{
			lock (ChatLock)
			{
				return CollectionToArray(Properties.Settings.Default.ChatChannels);
			}
		}
		//public api
		public string[] CollectionToArray(StringCollection sc)
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
			var Config = Properties.Settings.Default;
			var rawdata = Config.ChatProviderData;
			if (rawdata == "NEEDS INITIALIZING")
				return new TGIRCSetupInfo()
				{
					Nickname = "TGS3",
					URL = "irc.rizon.net",
					Port = 6667
				};
			var Deserializer = new JavaScriptSerializer();
			lock (ChatLock)
			{
				return new TGChatSetupInfo(Deserializer.Deserialize<List<string>>(rawdata), (TGChatProvider)Config.ChatProvider);
			}
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
				return ChatProvider.SetProviderInfo(info);
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
					si.AddRange(channels);
					if (!si.Contains(Config.ChatAdminChannel))
						si.Add(Config.ChatAdminChannel);
					Config.ChatChannels = si;
				}
				if (adminchannel != null)
					Config.ChatAdminChannel = adminchannel;
			}
			if (channels != null && Connected())
				ChatProvider.SetChannels(channels, null);				
		}
	
		//public api
		public bool Connected()
		{
			return ChatProvider.Connected();
		}

		//public api
		public string Reconnect()
		{
			return ChatProvider.Reconnect();
		}

		//public api
		public string SendMessage(string msg, bool adminOnly = false)
		{
			return ChatProvider.SendMessage(msg, adminOnly);
		}
	}
}
