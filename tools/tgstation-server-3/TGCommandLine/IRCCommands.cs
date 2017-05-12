using System;
using System.Collections.Generic;
using TGServiceInterface;

namespace TGCommandLine
{
	class IRCCommand : RootCommand
	{
		public IRCCommand()
		{
			Keyword = "irc";
			Children = new Command[] { new IRCNickCommand(), new IRCJoinCommand(), new IRCPartCommand(), new IRCAnnounceCommand(), new IRCStatusCommand(), new IRCAdminCommand(), new IRCEnableCommand(), new IRCDisableCommand(), new IRCReconnectCommand(), new IRCListAdminsCommand(), new IRCAddminCommand(), new IRCDeadminCommand(), new IRCAuthCommand(), new IRCDisableAuthCommand() };
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

	class IRCJoinCommand : Command
	{
		public IRCJoinCommand()
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
			return "Joins a channel";
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

	class IRCPartCommand : Command
	{
		public IRCPartCommand()
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
			return "Leaves a channel";
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
	class IRCAnnounceCommand : Command
	{
		public IRCAnnounceCommand()
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
	class IRCListAdminsCommand : Command
	{
		public IRCListAdminsCommand()
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
	class IRCReconnectCommand : Command
	{
		public IRCReconnectCommand()
		{
			Keyword = "reconnect";
		}
		
		protected override string GetHelpText()
		{
			return "Restablish the IRC connection";
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
	class IRCAddminCommand : Command
	{
		public IRCAddminCommand()
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
	class IRCDeadminCommand : Command
	{
		public IRCDeadminCommand()
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

	class IRCStatusCommand : Command
	{
		public IRCStatusCommand()
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
			Console.WriteLine("Currently configured channels:");
			Console.WriteLine("\tAdmin Channel: " + IRC.AdminChannel());
			foreach (var I in IRC.Channels())
				Console.WriteLine("\t" + I);
			Console.WriteLine("IRC bot is: " + (!IRC.Enabled() ? "Disabled" : IRC.Connected() ? "Connected" : "Disconnected"));
			return ExitCode.Normal;
		}
	}
	class IRCAdminCommand : Command
	{
		public IRCAdminCommand()
		{
			Keyword = "admin";
			RequiredParameters = 1;
		}
		protected override string GetArgumentString()
		{
			return "<channel>";
		}
		protected override string GetHelpText()
		{
			return "Sets the admin IRC channel";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetChannels(null, parameters[0]);
			return ExitCode.Normal;
		}
	}
	class IRCEnableCommand : Command
	{
		public IRCEnableCommand()
		{
			Keyword = "enable";
		}
		
		protected override string GetHelpText()
		{
			return "Enables the IRC bot";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetEnabled(true);
			return ExitCode.Normal;
		}
	}
	class IRCDisableCommand : Command
	{
		public IRCDisableCommand()
		{
			Keyword = "disable";
		}
	
		protected override string GetHelpText()
		{
			return "Disables the IRC bot";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGChat>().SetEnabled(true);
			return ExitCode.Normal;
		}
	}
}