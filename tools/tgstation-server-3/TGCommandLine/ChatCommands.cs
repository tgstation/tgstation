using System;
using System.Collections.Generic;
using TGServiceInterface;

namespace TGCommandLine
{
	class ChatCommand : RootCommand
	{
		public ChatCommand()
		{
			Keyword = "chat";
			Children = new Command[] { new ChatAnnounceCommand(), new ChatStatusCommand(), new ChatSetAdminChannelCommand(), new ChatEnableCommand(), new ChatDisableCommand(), new ChatReconnectCommand(), new ChatListAdminsCommand(), new ChatAddminCommand(), new ChatDeadminCommand(), new ChatSetProviderCommand(), new ChatJoinCommand(), new ChatPartCommand() };
		}
		protected override string GetHelpText()
		{
			return "Manages general chat settings";
		}
	}
	class ChatSetProviderCommand : Command {
		public ChatSetProviderCommand()
		{
			Keyword = "set-provider";
			RequiredParameters = 1;
		}
		protected override string GetHelpText()
		{
			return "Set the chat provider";
		}
		protected override string GetArgumentString()
		{
			return "<irc|discord> [if discord, add the bot token]";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var Chat = Server.GetComponent<ITGChat>();
			string res;
			switch (parameters[0].ToLower())
			{
				case "irc":
					res = Chat.SetProviderInfo(new TGIRCSetupInfo());
					break;
				case "discord":
					if(parameters.Count < 2)
					{
						Console.WriteLine("Missing discord bot token!");
						return ExitCode.BadCommand;
					}
					res = Chat.SetProviderInfo(new TGDiscordSetupInfo() { BotToken = parameters[1] });
					break;
				default:
					Console.WriteLine("Invalid provider!");
					return ExitCode.BadCommand;
			}
			Console.WriteLine(res ?? "Success!");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
	}
	class IRCCommand : RootCommand
	{
		public IRCCommand()
		{
			Keyword = "irc";
			Children = new Command[] { new IRCNickCommand(), new IRCAuthCommand(), new IRCDisableAuthCommand() };
		}
		public override ExitCode Run(IList<string> parameters)
		{
			if (Server.GetComponent<ITGChat>().ProviderInfo().Provider != TGChatProvider.IRC)
			{
				Console.WriteLine("The current provider is not IRC. Please switch providers first!");
				return ExitCode.ServerError;
			}
			return base.Run(parameters);
		}
		protected override string GetHelpText()
		{
			return "Manages the IRC bot";
		}
	}
	class IRCNickCommand : Command
	{
		public IRCNickCommand()
		{
			Keyword = "nick";
			RequiredParameters = 1;
		}
		
		protected override string GetArgumentString()
		{
			return "<name>";
		}
		protected override string GetHelpText()
		{
			return "Sets the IRC nickname";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var Chat = Server.GetComponent<ITGChat>();
			Chat.SetProviderInfo(new TGIRCSetupInfo(Chat.ProviderInfo())
			{
				Nickname = parameters[0],
			});
			return ExitCode.Normal;
		}
	}

	class ChatJoinCommand : Command
	{
		public ChatJoinCommand()
		{
			Keyword = "join";
			RequiredParameters = 1;
		}

		protected override string GetArgumentString()
		{
			return "<channel>";
		}
		protected override string GetHelpText()
		{
			return "Joins a channel for listening and broadcasting";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			var channels = IRC.Channels();
			var lowerParam = parameters[0].ToLower();
			foreach (var I in channels)
			{
				if (I.ToLower() == lowerParam)
				{
					Console.WriteLine("Already in this channel!");
					return ExitCode.BadCommand;
				}
			}
			Array.Resize(ref channels, channels.Length + 1);
			channels[channels.Length - 1] = parameters[0];
			IRC.SetChannels(channels, null);
			return ExitCode.Normal;
		}
	}

	class ChatPartCommand : Command
	{
		public ChatPartCommand()
		{
			Keyword = "part";
			RequiredParameters = 1;
		}
		
		protected override string GetArgumentString()
		{
			return "<channel>";
		}
		protected override string GetHelpText()
		{
			return "Stops listening and broadcasting on a channel";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			var channels = IRC.Channels();
			var lowerParam = parameters[0].ToLower();
			var new_channels = new List<string>();
			foreach (var I in channels)
			{
				if (I.ToLower() == lowerParam)
					continue;
				new_channels.Add(I);
			}
			if (new_channels.Count == 0)
			{
				Console.WriteLine("Error: Cannot part from the last channel!");
				return ExitCode.BadCommand;
			}
			IRC.SetChannels(new_channels.ToArray(), null);
			return ExitCode.Normal;
		}
	}
	class ChatAnnounceCommand : Command
	{
		public ChatAnnounceCommand()
		{
			Keyword = "announce";
			RequiredParameters = 1;
		}
		protected override string GetArgumentString()
		{
			return "<message>";
		}
		protected override string GetHelpText()
		{
			return "Sends a message to all connected channels";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGChat>().SendMessage("SCP: " + parameters[0]);
			if (res != null)
			{
				Console.WriteLine("Error: " + res);
				return ExitCode.ServerError;
			}
			return ExitCode.Normal;
		}
	}
	class ChatListAdminsCommand : Command
	{
		public ChatListAdminsCommand()
		{
			Keyword = "list-admins";
		}
		
		protected override string GetHelpText()
		{
			return "List users which can use restricted commands in the admin channel";
		}
		
		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGChat>().ListAdmins();
			foreach (var I in res)
				Console.WriteLine(I);
			return ExitCode.Normal;
		}
	}
	class ChatReconnectCommand : Command
	{
		public ChatReconnectCommand()
		{
			Keyword = "reconnect";
		}
		
		protected override string GetHelpText()
		{
			return "Restablish the chat connection";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGChat>().Reconnect();
			if (res != null)
			{
				Console.WriteLine("Error: " + res);
				return ExitCode.ServerError;
			}
			return ExitCode.Normal;
		}
	}
	class ChatAddminCommand : Command
	{
		public ChatAddminCommand()
		{
			Keyword = "addmin";
			RequiredParameters = 1;
		}
		
		protected override string GetArgumentString()
		{
			return "[nick]";
		}
		protected override string GetHelpText()
		{
			return "Add a user which can use restricted commands in the admin channel";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			var mins = new List<string>(IRC.ListAdmins());
			var newmin = parameters[0];

			foreach (var I in mins)
				if (I.ToLower() == newmin.ToLower())
				{
					Console.WriteLine(newmin + " is already an admin!");
					return ExitCode.Normal;
				}

			mins.Add(newmin);
			IRC.SetAdmins(mins.ToArray());
			return ExitCode.Normal;
		}
	}
	class ChatDeadminCommand : Command
	{
		public ChatDeadminCommand()
		{
			Keyword = "deadmin";
			RequiredParameters = 1;
		}
		protected override string GetArgumentString()
		{
			return "[nick]";
		}
		protected override string GetHelpText()
		{
			return "Remove a user which can use restricted commands in the admin channel";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			var mins = new List<string>(IRC.ListAdmins());
			var deadmin = parameters[0];

			foreach (var I in mins)
				if (I.ToLower() == deadmin.ToLower())
				{
					mins.Remove(I);
					IRC.SetAdmins(mins.ToArray());
					return ExitCode.Normal;
				}

			Console.WriteLine(deadmin + " is not an admin!");
			return ExitCode.Normal;
		}
	}

	class IRCAuthCommand : Command
	{
		public IRCAuthCommand()
		{
			Keyword = "setup-auth";
			RequiredParameters = 2;
		}

		protected override string GetArgumentString()
		{
			return "<target> <message>";
		}
		protected override string GetHelpText()
		{
			return "Set the authentication message to send to target for identification. e.g. NickServ \"identify hunter2\"";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			IRC.SetProviderInfo(new TGIRCSetupInfo(IRC.ProviderInfo())
			{
				AuthTarget = parameters[0],
				AuthMessage = parameters[1]
			});
			return ExitCode.Normal;
		}
	}

	class IRCDisableAuthCommand : Command
	{
		public IRCDisableAuthCommand()
		{
			Keyword = "disable-auth";
		}		
		protected override string GetHelpText()
		{
			return "Turns off IRC authentication";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			IRC.SetProviderInfo(new TGIRCSetupInfo(IRC.ProviderInfo())
			{
				AuthTarget = null,
				AuthMessage = null,
			});
			return ExitCode.Normal;
		}
	}

	class ChatStatusCommand : Command
	{
		public ChatStatusCommand()
		{
			Keyword = "status";
		}
		protected override string GetHelpText()
		{
			return "Lists channels and connections status";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGChat>();
			Console.WriteLine("Currently configured broadcast channels:");
			Console.WriteLine("\tAdmin Channel: " + IRC.AdminChannel());
			foreach (var I in IRC.Channels())
				Console.WriteLine("\t" + I);
			string provider;
			switch (IRC.ProviderInfo().Provider)
			{
				case TGChatProvider.Discord:
					provider = "Discord";
					break;
				case TGChatProvider.IRC:
					provider = "IRC";
					break;
				default:
					provider = "Unknown";
					break;
			}
			Console.WriteLine("Provider: " + provider);
			Console.WriteLine("Chat bot is: " + (!IRC.Enabled() ? "Disabled" : IRC.Connected() ? "Connected" : "Disconnected"));
			return ExitCode.Normal;
		}
	}
	class ChatSetAdminChannelCommand : Command
	{
		public ChatSetAdminChannelCommand()
		{
			Keyword = "set-admin-channel";
			RequiredParameters = 1;
		}
		protected override string GetArgumentString()
		{
			return "<channel>";
		}
		protected override string GetHelpText()
		{
			return "Sets the admin chat channel";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetChannels(null, parameters[0]);
			return ExitCode.Normal;
		}
	}
	class ChatEnableCommand : Command
	{
		public ChatEnableCommand()
		{
			Keyword = "enable";
		}
		
		protected override string GetHelpText()
		{
			return "Enables the chat bot";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetEnabled(true);
			return ExitCode.Normal;
		}
	}
	class ChatDisableCommand : Command
	{
		public ChatDisableCommand()
		{
			Keyword = "disable";
		}
	
		protected override string GetHelpText()
		{
			return "Disables the chat bot";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetEnabled(true);
			return ExitCode.Normal;
		}
	}
}