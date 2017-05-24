using System;
using System.Collections.Generic;
using TGServiceInterface;

namespace TGCommandLine
{
	class DDCommand : RootCommand
	{
		public DDCommand()
		{
			Keyword = "dd";
			Children = new Command[] { new DDStartCommand(), new DDStopCommand(), new DDRestartCommand(), new DDStatusCommand(), new DDAutostartCommand(), new DDPortCommand(), new DDVisibilityCommand(), new DDSecurityCommand() };
		}
		protected override string GetHelpText()
		{
			return "Manage DreamDaemon";
		}
	}

	class DDStartCommand : Command
	{
		public DDStartCommand()
		{
			Keyword = "start";
		}

		protected override string GetHelpText()
		{
			return "Starts the server and watchdog";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGDreamDaemon>().Start();
			Console.WriteLine(res ?? "Success!");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
	}

	class DDStopCommand : Command
	{
		public DDStopCommand()
		{
			Keyword = "stop";
		}
		protected override string GetArgumentString()
		{
			return "[--graceful]";
		}

		protected override string GetHelpText()
		{
			return "Stops the server and watchdog optionally waiting for the current round to end";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var DD = Server.GetComponent<ITGDreamDaemon>();
			if (parameters.Count > 0 && parameters[0].ToLower() == "--graceful")
			{
				if (DD.DaemonStatus() != TGDreamDaemonStatus.Online)
				{
					Console.WriteLine("Error: The game is not currently running!");
					return ExitCode.ServerError;
				}
				DD.RequestStop();
				return ExitCode.Normal;
			}
			var res = DD.Stop();
			Console.WriteLine(res ?? "Success!");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
	}
	class DDRestartCommand : Command
	{
		public DDRestartCommand()
		{
			Keyword = "restart";
		}

		protected override string GetArgumentString()
		{
			return "[--graceful]";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var DD = Server.GetComponent<ITGDreamDaemon>();
			if (parameters.Count > 0 && parameters[0].ToLower() == "--graceful")
			{
				if (DD.DaemonStatus() != TGDreamDaemonStatus.Online)
				{
					Console.WriteLine("Error: The game is not currently running!");
					return ExitCode.ServerError;
				}
				DD.RequestRestart();
				return ExitCode.Normal;
			}
			var res = DD.Restart();
			Console.WriteLine(res ?? "Success!");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}

		protected override string GetHelpText()
		{
			return "Restarts the server and watchdog optionally waiting for the current round to end";
		}
	}
	class DDStatusCommand : Command
	{
		public DDStatusCommand()
		{
			Keyword = "status";
		}

		protected override string GetHelpText()
		{
			return "Gets the current status of the watchdog and server";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Console.WriteLine(Server.GetComponent<ITGDreamDaemon>().StatusString(true));
			return ExitCode.Normal;
		}
	}

	class DDAutostartCommand : Command
	{
		public DDAutostartCommand()
		{
			Keyword = "autostart";
			RequiredParameters = 1;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var DD = Server.GetComponent<ITGDreamDaemon>();
			switch (parameters[0].ToLower())
			{
				case "on":
					DD.SetAutostart(true);
					break;
				case "off":
					DD.SetAutostart(false);
					break;
				case "check":
					Console.WriteLine("Autostart is: " + (DD.Autostart() ? "On" : "Off"));
					break;
				default:
					Console.WriteLine("Invalid parameter: " + parameters[0]);
					return ExitCode.BadCommand;
			}
			return ExitCode.Normal;
		}

		protected override string GetArgumentString()
		{
			return "<on|off|check>";
		}
		protected override string GetHelpText()
		{
			return "Change or check autostarting of the game server with the service";
		}
	}
	class DDPortCommand : Command
	{
		public DDPortCommand()
		{
			Keyword = "set-port";
			RequiredParameters = 1;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			ushort port;
			try
			{
				port = Convert.ToUInt16(parameters[0]);
			}
			catch
			{
				Console.WriteLine("Invalid port number!");
				return ExitCode.BadCommand;
			}

			Server.GetComponent<ITGDreamDaemon>().SetPort(port);
			return ExitCode.Normal;
		}

		protected override string GetArgumentString()
		{
			return "<number>";
		}

		protected override string GetHelpText()
		{
			return "Sets the port DreamDaemon will open the server on. Requires a server restart to apply and queues a graceful one up";
		}
	}

	class DDVisibilityCommand : Command
	{
		public DDVisibilityCommand()
		{
			Keyword = "set-visibility";
			RequiredParameters = 1;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			TGDreamDaemonVisibility vis;
			switch (parameters[0].ToLower())
			{
				case "invisible":
				case "invis":
					vis = TGDreamDaemonVisibility.Invisible;
					break;
				case "private":
				case "priv":
					vis = TGDreamDaemonVisibility.Private;
					break;
				case "public":
				case "pub":
					vis = TGDreamDaemonVisibility.Public;
					break;
				default:
					Console.WriteLine("Invalid visiblity word!");
					return ExitCode.BadCommand;
			}
			Server.GetComponent<ITGDreamDaemon>().SetVisibility(vis);
			return ExitCode.Normal;
		}

		protected override string GetHelpText()
		{
			return "Sets the visibility option for the DreamDaemon world. Requires a server restart to apply and queues a graceful one up";
		}

		protected override string GetArgumentString()
		{
			return "<public|private|invisible>";
		}
	}

	class DDSecurityCommand : Command
	{
		public DDSecurityCommand()
		{
			Keyword = "set-security";
			RequiredParameters = 1;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			TGDreamDaemonSecurity sec;
			switch (parameters[0].ToLower())
			{
				case "safe":
					sec = TGDreamDaemonSecurity.Safe;
					break;
				case "ultra":
				case "ultrasafe":
					sec = TGDreamDaemonSecurity.Ultrasafe;
					break;
				case "trust":
				case "trusted":
					sec = TGDreamDaemonSecurity.Trusted;
					break;
				default:
					Console.WriteLine("Invalid security word!");
					return ExitCode.BadCommand;
			}
			Server.GetComponent<ITGDreamDaemon>().SetSecurityLevel(sec);
			return ExitCode.Normal;
		}

		protected override string GetArgumentString()
		{
			return "<safe|ultrasafe|trusted>";
		}

		protected override string GetHelpText()
		{
			return "Sets the visibility option for the DreamDaemon world";
		}
	}
}
