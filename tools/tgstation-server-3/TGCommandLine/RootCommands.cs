using System;
using System.Collections.Generic;
using TGServiceInterface;
using TGSharedFunctions;

namespace TGCommandLine
{
	class ConsoleCommand : RootCommand
	{
		public ConsoleCommand()
		{
			Children = new Command[] { new UpdateCommand(), new TestmergeCommand(), new IRCCommand(), new RepoCommand(), new BYONDCommand(), new DMCommand(), new DDCommand(), new ConfigCommand(), new ChatCommand() };
		}
		public override void PrintHelp()
		{
			OutputProc("/tg/station 13 Server");
			base.PrintHelp();
		}
	}
	class UpdateCommand : Command
	{
		public UpdateCommand()
		{
			Keyword = "update";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var gen_cl = parameters.Count > 1 && parameters[1].ToLower() == "--cl";
			TGRepoUpdateMethod method;
			switch (parameters[0].ToLower())
			{
				case "hard":
					method = TGRepoUpdateMethod.Hard;
					break;
				case "merge":
					method = TGRepoUpdateMethod.Merge;
					break;
				default:
					Console.WriteLine("Please specify hard or merge");
					return ExitCode.BadCommand;
			}
			var result = Server.GetComponent<ITGServerUpdater>().UpdateServer(method, gen_cl);
			Console.WriteLine(result ?? "Compilation started!");
			return result == null ? ExitCode.Normal : ExitCode.ServerError;
		}

		protected override string GetArgumentString()
		{
			return "<merge|hard> [--cl]";
		}

		protected override string GetHelpText()
		{
			return "Updates the server fully, optionally generating and pushing a changelog. Runs asynchronously once compilation starts";
		}

	}

	class TestmergeCommand : Command
	{
		public TestmergeCommand()
		{
			Keyword = "testmerge";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			ushort tm;
			try
			{
				tm = Convert.ToUInt16(parameters[0]);
				if (tm == 0)
					throw new Exception();
			}
			catch
			{
				Console.WriteLine("Invalid tesmerge #: " + parameters[0]);
				return ExitCode.BadCommand;
			}
			var result = Server.GetComponent<ITGServerUpdater>().UpdateServer(TGRepoUpdateMethod.None, false, tm);
			Console.WriteLine(result ?? "Compilation started!");
			return result == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		protected override string GetArgumentString()
		{
			return "<pull request #>";
		}

		protected override string GetHelpText()
		{
			return "Merges the specified pull request and updates the server";
		}
	}
}
