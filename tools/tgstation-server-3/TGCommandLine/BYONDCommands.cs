using System;
using System.Collections.Generic;
using System.Threading;
using TGServiceInterface;

namespace TGCommandLine
{
	class BYONDCommand : RootCommand
	{
		public BYONDCommand()
		{
			Keyword = "byond";
			Children = new Command[] { new BYONDUpdateCommand(), new BYONDVersionCommand(), new BYONDStatusCommand() };
		}
		protected override string GetHelpText()
		{
			return "Manage BYOND installation";
		}
	}

	class BYONDVersionCommand : Command
	{
		public BYONDVersionCommand()
		{
			Keyword = "version";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var type = TGByondVersion.Installed;
			if (parameters.Count > 0)
				if (parameters[0].ToLower() == "--staged")
					type = TGByondVersion.Staged;
				else if (parameters[0].ToLower() == "--latest")
					type = TGByondVersion.Latest;
			Console.WriteLine(Server.GetComponent<ITGByond>().GetVersion(type) ?? "Unistalled");
			return ExitCode.Normal;
		}
		protected override string GetArgumentString()
		{
			return "[--staged|--latest]";
		}

		protected override string GetHelpText()
		{
			return "Print the currently installed BYOND version";
		}
	}


	class BYONDStatusCommand : Command
	{
		public BYONDStatusCommand()
		{
			Keyword = "status";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			switch (Server.GetComponent<ITGByond>().CurrentStatus())
			{
				case TGByondStatus.Downloading:
					Console.WriteLine("Downloading update...");
					break;
				case TGByondStatus.Idle:
					Console.WriteLine("Updater Idle");
					break;
				case TGByondStatus.Staged:
					Console.WriteLine("Update staged and awaiting server restart");
					break;
				case TGByondStatus.Staging:
					Console.WriteLine("Staging update...");
					break;
				case TGByondStatus.Starting:
					Console.WriteLine("Starting update...");
					break;
				case TGByondStatus.Updating:
					Console.WriteLine("Applying update...");
					break;
				default:
					Console.WriteLine("Limmexing (This is an error).");
					return ExitCode.ServerError;
			}
			return ExitCode.Normal;
		}
		protected override string GetHelpText()
		{
			return "Print the current status of the BYOND updater";
		}
	}

	class BYONDUpdateCommand : Command
	{
		public BYONDUpdateCommand()
		{
			Keyword = "update";
			RequiredParameters = 2;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			int Major = 0, Minor = 0;
			try
			{
				Major = Convert.ToInt32(parameters[0]);
				Minor = Convert.ToInt32(parameters[1]);
			}
			catch
			{
				Console.WriteLine("Please enter version as <Major>.<Minor>");
				return ExitCode.BadCommand;
			}

			var BYOND = Server.GetComponent<ITGByond>();
			if (!BYOND.UpdateToVersion(Major, Minor))

			{
				Console.WriteLine("Failed to begin update!");
				return ExitCode.ServerError;
			}
			
			var stat = BYOND.CurrentStatus();
			while (stat != TGByondStatus.Idle && stat != TGByondStatus.Staged)
			{
				Thread.Sleep(100);
				stat = BYOND.CurrentStatus();
			}
			var res = BYOND.GetError();
			Console.WriteLine(res ?? (stat == TGByondStatus.Staged ? "Update staged and will apply next DD reboot" : "Update finished"));
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		protected override string GetArgumentString()
		{
			return "<Major> <Minor>";
		}
		protected override string GetHelpText()
		{
			return "Updates the BYOND installation to the specified version";
		}
	}
}
