using System;
using System.Collections.Generic;
using TGServiceInterface;

namespace TGCommandLine
{

	class RootCommand : Command
	{
		bool IsRealRoot()
		{
			return !GetType().IsSubclassOf(typeof(RootCommand));
		}
		public RootCommand()
		{
			if (IsRealRoot())	//stack overflows
				Children = new Command[] { new UpdateCommand(), new TestmergeCommand(), new IRCCommand(), new RepoCommand(), new BYONDCommand(), new DMCommand(), new DDCommand(), new ConfigCommand() };
		}
		public override ExitCode Run(IList<string> parameters)
		{
			if (parameters.Count > 0)
			{
				var LocalKeyword = parameters[0].Trim().ToLower();
				parameters.RemoveAt(0);

				switch (LocalKeyword)
				{
					case "help":
					case "?":
						if (IsRealRoot())
							PrintHelp();
						else {
							Console.WriteLine(Keyword + " commands:");
							Console.WriteLine();
							foreach (var c in Children)
								c.PrintHelp();
						}
						return ExitCode.Normal;
					default:
						foreach (var c in Children)
							if (c.Keyword == LocalKeyword)
							{
								if (parameters.Count < c.RequiredParameters)
								{
									Console.WriteLine("Not enough parameters!");
									return ExitCode.BadCommand;
								}
								return c.Run(parameters);
							}
						parameters.Insert(0, LocalKeyword);
						break;
				}
			}
			Console.WriteLine(String.Format("Invalid command: {0} {1}", Keyword, String.Join(" ", parameters)));
			Console.WriteLine(String.Format("Type '{0}?' or '{0}help' for available commands.", Keyword != null ? Keyword + " " : ""));
			return ExitCode.BadCommand;
		}

		public override void PrintHelp()
		{
			Console.WriteLine("/tg/station 13 Server Command Line");
			Console.WriteLine("Avaiable commands (type '?' or 'help' after command for more info):");
			Console.WriteLine();
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
		public override void PrintHelp()
		{
			Console.WriteLine("testmerge <pull request #>\t-\tMerges the specified pull request and updates the server");
		}
	}

	class TestmergeCommand : Command
	{
		public TestmergeCommand()
		{
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
		public override void PrintHelp()
		{
			Console.WriteLine("update <merge|hard> [--cl]\t-\tUpdates the server fully, optionally generating and pushing a changelog. Runs asynchronously once compilation starts");
		}
	}
}
