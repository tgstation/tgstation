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
		public override void PrintHelp()
		{
			Console.WriteLine("irc\t-\tManage the IRC bot");
		}
	}
	class IRCNickCommand : Command
	{
		public IRCNickCommand()
		{
			Keyword = "nick";
			RequiredParameters = 1;
		}

		public override void PrintHelp()
		{
			Console.WriteLine("nick <name>\t-\tSets the IRC nickname");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().Setup(null, 0, parameters[0]);
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

		public override void PrintHelp()
		{
			Console.WriteLine("join <channel>\t-\tJoins a channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGIRC>();
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
			IRC.Setup(null, 0, null, channels);
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

		public override void PrintHelp()
		{
			Console.WriteLine("part <channel>\t-\tLeaves a channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGIRC>();
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
			IRC.Setup(null, 0, null, new_channels.ToArray());
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

		public override void PrintHelp()
		{
			Console.WriteLine("announce <message>\t-\tSends a message to all connected channels");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGIRC>().SendMessage("SCP: " + parameters[0]);
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

		public override void PrintHelp()
		{
			Console.WriteLine("list-admins\t-\tList users which can use restricted commands in the admin channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGIRC>().ListAdmins();
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

		public override void PrintHelp()
		{
			Console.WriteLine("reconnect\t-\tRestablish the IRC connection");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGIRC>().Reconnect();
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

		public override void PrintHelp()
		{
			Console.WriteLine("addmin [nick]\t-\tAdd a user which can use restricted commands in the admin channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGIRC>();
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

		public override void PrintHelp()
		{
			Console.WriteLine("deadmin [nick]\t-\tRemove a user which can use restricted commands in the admin channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGIRC>();
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

		public override void PrintHelp()
		{
			Console.WriteLine("setup-auth <target> <message>\t-\tSet the authentication message to send to target for identification. e.g. <NickServ> <identify hunter2>");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().SetupAuth(parameters[0], parameters[1]);
			return ExitCode.Normal;
		}
	}

	class IRCDisableAuthCommand : Command
	{
		public IRCDisableAuthCommand()
		{
			Keyword = "disable-auth";
		}

		public override void PrintHelp()
		{
			Console.WriteLine("disable-auth\t-\tTurns off IRC authentication");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().SetupAuth(null, null);
			return ExitCode.Normal;
		}
	}

	class IRCStatusCommand : Command
	{
		public IRCStatusCommand()
		{
			Keyword = "status";
		}

		public override void PrintHelp()
		{
			Console.WriteLine("status\t-\tLists channels and connections status");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var IRC = Server.GetComponent<ITGIRC>();
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

		public override void PrintHelp()
		{
			Console.WriteLine("admin\t-\tSets the admin IRC channel");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().Setup(null, 0, null, null, parameters[0]);
			return ExitCode.Normal;
		}
	}
	class IRCEnableCommand : Command
	{
		public IRCEnableCommand()
		{
			Keyword = "enable";
		}

		public override void PrintHelp()
		{
			Console.WriteLine("enable\t-\tEnables the IRC bot");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().Setup(null, 0, null, null, null, TGIRCEnableType.Enable);
			return ExitCode.Normal;
		}
	}
	class IRCDisableCommand : Command
	{
		public IRCDisableCommand()
		{
			Keyword = "disable";
		}

		public override void PrintHelp()
		{
			Console.WriteLine("disable\t-\tDisables the IRC bot");
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGIRC>().Setup(null, 0, null, null, null, TGIRCEnableType.Disable);
			return ExitCode.Normal;
		}
	}
}