using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Threading;
using TGServiceInterface;
using Meebey.SmartIrc4net;


namespace TGServerService
{
	//hunter2
	partial class TGStationServer : ITGIRC
	{
		IrcClient irc;
		int reconnectAttempt = 0;

		object IRCLock = new object();

		//Setup the object and autoconnect if necessary
		void InitIRC()
		{
			irc = new IrcClient() { SupportNonRfc = true };
			irc.OnChannelMessage += Irc_OnChannelMessage;
			Connect();
		}

		//For IRC server commands: <nick> <command>
		private void Irc_OnChannelMessage(object sender, IrcEventArgs e)
		{
			var speaker = e.Data.Nick;
			var message = e.Data.Message.Trim();
			var channel = e.Data.Channel;

			var splits = message.Split(' ');

			var s0l = splits[0].ToLower();

			if (s0l == "@check")
				lock (IRCLock)
				{
					SendMessageDirect(StatusString(HasIRCAdmin(speaker, channel) == null), channel);
					return;
				}

			if (s0l != irc.Nickname.ToLower())
				return;
			if (splits.Length == 1)
			{
				SendMessage("Hi!");
				return;
			}

			var asList = new List<string>(splits);
			asList.RemoveAt(0);
			var command = asList[0].ToLower();
			asList.RemoveAt(0);

			lock (IRCLock)
			{
				SendMessageDirect(IrcCommand(command, speaker, channel, asList), channel);
			}
		}
		
		string HasIRCAdmin(string speaker, string channel)
		{
			if (!Properties.Settings.Default.IRCAdmins.Contains(speaker.ToLower()))
				return "You are not authorized to use that command!";
			if (channel.ToLower() != Properties.Settings.Default.IRCAdminChannel.ToLower())
				return "Use this command in the admin channel!";
			return null;
		}

		//Do stuff with words that were spoken to us
		string IrcCommand(string command, string speaker, string channel, IList<string> parameters)
		{
			TGServerService.ActiveService.EventLog.WriteEntry(String.Format("IRC Command from {0}: {1} {2}", speaker, command, String.Join(" ", parameters)));
			switch (command)
			{
				case "check":
					return StatusString(HasIRCAdmin(speaker, channel) == null);
				case "byond":
					if (parameters.Count > 0 && parameters[0].ToLower() == "--staged")
						return GetVersion(true) ?? "None";
					return GetVersion(false) ?? "Uninstalled";
				case "status":
					return HasIRCAdmin(speaker, channel) ?? SendCommand(SCIRCStatus);
				case "adminwho":
					return HasIRCAdmin(speaker, channel) ?? SendCommand(SCAdminWho);
				case "ahelp":
					var res = HasIRCAdmin(speaker, channel);
					if (res != null)
						return res;
					if (parameters.Count < 2)
						return "Usage: pm <ckey> <message>";
					var ckey = parameters[0];
					parameters.RemoveAt(0);
					return SendPM(ckey, speaker, String.Join(" ", parameters));
				case "namecheck":
					res = HasIRCAdmin(speaker, channel);
					if (res != null)
						return res;
					if (parameters.Count < 1)
						return "Usage: namecheck <target>";
					return NameCheck(parameters[0], speaker);
			}
			return "Unknown command: " + command;
		}

		//public api
		public void Setup(string url, ushort port, string username, string[] channels, string adminChannel, TGIRCEnableType enabled)
		{
			var ServerChange = false;
			var Config = Properties.Settings.Default;
			StringCollection oldchannels;
			lock (IRCLock)
			{
				if (url != null)
				{
					Config.IRCServer = url;
					ServerChange = true;
				}
				if (port != 0)
				{
					Config.IRCPort = port;
					ServerChange = true;
				}
				if (username != null)
					Config.IRCNick = username;
				if (adminChannel != null)
					Config.IRCAdminChannel = adminChannel;
				oldchannels = Properties.Settings.Default.IRCChannels;
				if (channels != null)
				{
					var si = new StringCollection();
					si.AddRange(channels);
					if (!si.Contains(Config.IRCAdminChannel))
						si.Add(Config.IRCAdminChannel);
					Config.IRCChannels = si;
				}
				switch (enabled)
				{
					case TGIRCEnableType.Enable:
						Config.IRCEnabled = true;
						break;
					case TGIRCEnableType.Disable:
						Config.IRCEnabled = false;
						break;
					default:
						break;
				}
			}
			if (Connected())
				if (!Config.IRCEnabled)
					Disconnect();
				else if (ServerChange)
					Reconnect();
				else
				{
					lock (IRCLock)
					{
						irc.RfcNick(Config.IRCNick);
						if (channels != null)
						{
							foreach (var I in channels)
							{
								if (!oldchannels.Contains(I))
									irc.RfcJoin(I);
							}
							foreach (var I in oldchannels)
							{
								if (!Config.IRCChannels.Contains(I))
									irc.RfcPart(I);
							}
						}
					}
				}
			else if (Config.IRCEnabled)
				Connect();
		}
		//public api
		public string[] Channels()
		{
			lock (IRCLock)
			{
				return CollectionToArray(Properties.Settings.Default.IRCChannels);
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
			lock (IRCLock)
			{
				return Properties.Settings.Default.IRCAdminChannel;
			}
		}
		//public api
		public void SetupAuth(string identifyTarget, string identifyCommand)
		{
			lock (IRCLock)
			{
				var Config = Properties.Settings.Default;
				Config.IRCIdentifyTarget = identifyTarget;
				Config.IRCIdentifyCommand = identifyCommand;
			}
			if (Connected())
				Login();
		}
		//Joins configured channels
		void JoinChannels()
		{
			foreach (var I in Properties.Settings.Default.IRCChannels)
				irc.RfcJoin(I);
		}
		//runs the login command
		void Login()
		{
			lock (IRCLock)
			{
				var Config = Properties.Settings.Default;
				if (Config.IRCIdentifyTarget != null)
					irc.SendMessage(SendType.Message, Config.IRCIdentifyTarget, Config.IRCIdentifyCommand);
			}
		}
		//public api
		public string Connect()
		{
			if (Connected())
				return null;
			lock (IRCLock)
			{
				var Config = Properties.Settings.Default;
				if (!Config.IRCEnabled)
					return "IRC disabled by config.";
				try
				{
					try
					{
						irc.Connect(Config.IRCServer, Config.IRCPort);
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
						irc.Login(Config.IRCNick, Config.IRCNick);
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
					irc.Disconnect();
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
		public string SendMessage(string message, bool adminOnly = false)
		{
			try
			{
				if (!Connected())
					return "Disconnected.";
				lock (IRCLock)
				{
					var Config = Properties.Settings.Default;
					if (adminOnly)
						irc.SendMessage(SendType.Message, Config.IRCAdminChannel, message);
					else
						foreach (var I in Config.IRCChannels)
							irc.SendMessage(SendType.Message, I, message);
				}
				TGServerService.ActiveService.EventLog.WriteEntry(String.Format("IRC Send{0}: {1}", adminOnly ? " (ADMIN)" : "", message));
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		/// <summary>
		/// Send a message to a channel
		/// </summary>
		/// <param name="message">The message to send</param>
		/// <param name="channel">The channel to send to</param>
		/// <returns></returns>
		string SendMessageDirect(string message, string channel)
		{
			try
			{
				if (!Connected())
					return "Disconnected.";
				lock (IRCLock)
				{
					irc.SendMessage(SendType.Message, channel, message);
				}
				TGServerService.ActiveService.EventLog.WriteEntry(String.Format("IRC Send ({0}): {1}", channel, message));
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public bool Enabled()
		{
			lock (IRCLock)
			{
				return Properties.Settings.Default.IRCEnabled;
			}
		}

		//public api
		public string[] ListAdmins()
		{
			lock (IRCLock)
			{
				return CollectionToArray(Properties.Settings.Default.IRCAdmins);
			}
		}

		//public api
		public void SetAdmins(string[] admins)
		{
			var si = new StringCollection();
			foreach (var I in admins)
				si.Add(I.Trim().ToLower());
			lock (IRCLock)
			{
				Properties.Settings.Default.IRCAdmins = si;
			}
		}
	}
}
