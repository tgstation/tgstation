using System;
using System.Collections.Generic;
using TGServiceInterface;

namespace TGCommandLine
{
	class RepoCommand : RootCommand
	{
		public RepoCommand()
		{
			Keyword = "repo";
			Children = new Command[] { new RepoSetupCommand(), new RepoUpdateCommand(), new RepoChangelogCommand(), new RepoCommitCommand(), new RepoPushCommand(), new RepoPythonPathCommand(), new RepoSetEmailCommand(), new RepoSetNameCommand(), new RepoSetCredentialsCommand() };
		}
		public override void PrintHelp()
		{
			Console.WriteLine("repo\t-\tManage the git repository");
		}
	}

	class RepoSetupCommand : Command
	{
		public RepoSetupCommand()
		{
			Keyword = "setup";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			if (!Server.GetComponent<ITGRepository>().Setup(parameters[0], parameters.Count > 1 ? parameters[1] : "master"))
			{
				Console.WriteLine("Error: Repo is busy!");
				return ExitCode.ServerError;
			}
			Console.WriteLine("Setting up repo. This will take a while...");
			return ExitCode.Normal;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("setup <git-url> [branchname]\t-\tClean up everything and clones the repo at git-url with optional branch name");
		}
	}

	class RepoUpdateCommand : Command
	{
		public RepoUpdateCommand()
		{
			Keyword = "update";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			bool hard;
			switch (parameters[0].ToLower())
			{
				case "hard":
					hard = true;
					break;
				case "merge":
					hard = false;
					break;
				default:
					Console.WriteLine("Invalid parameter: " + parameters[0]);
					return ExitCode.BadCommand;
			}
			var res = Server.GetComponent<ITGRepository>().Update(hard);
			Console.WriteLine(res ?? "Success");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("update <hard|merge>\t-\tUpdates the current branch the repo is on either via a merge or hard reset");
		}
	}
	class RepoChangelogCommand : Command
	{
		public RepoChangelogCommand()
		{
			Keyword = "gen-changelog";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var result = Server.GetComponent<ITGRepository>().GenerateChangelog(out string error);
			Console.WriteLine(error ?? "Success!");
			if (result != null)
				Console.WriteLine(result);
			return error == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("gen-changelog\t-\tCompiles the html changelog");
		}
	}
	class RepoCommitCommand : Command
	{
		public RepoCommitCommand()
		{
			Keyword = "commit";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGRepository>().Commit(parameters[0]);
			Console.WriteLine(res ?? "Success");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("commit <message>\t-\tCommits all current changes to the repository using the configured identity");
		}
	}
	class RepoPushCommand : Command
	{
		public RepoPushCommand()
		{
			Keyword = "push";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGRepository>().Push();
			Console.WriteLine(res ?? "Success");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("push\t-\tPushes commits to the origin branch using the configured credentials");
		}
	}
	class RepoSetEmailCommand : Command
	{
		public RepoSetEmailCommand()
		{
			Keyword = "set-email";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGRepository>().SetCommitterEmail(parameters[0]);
			return ExitCode.Normal;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("set-email <e-mail>\t-\tSet the e-mail used for commits");
		}
	}
	class RepoSetNameCommand : Command
	{
		public RepoSetNameCommand()
		{
			Keyword = "set-name";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGRepository>().SetCommitterName(parameters[0]);
			return ExitCode.Normal;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("set-name <name>\t-\tSet the name used for commits");
		}
	}
	class RepoPythonPathCommand : Command
	{
		public RepoPythonPathCommand()
		{
			Keyword = "python-path";
			RequiredParameters = 1;
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Server.GetComponent<ITGRepository>().SetPythonPath(parameters[0]);
			return ExitCode.Normal;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("python-path <path>\t-\tSet the path to the folder containing the python 2.7 installation");
		}
	}
	class RepoSetCredentialsCommand : Command
	{
		public RepoSetCredentialsCommand()
		{
			Keyword = "set-credentials";
		}
		public override ExitCode Run(IList<string> parameters)
		{
			Console.WriteLine("Enter username:");
			var user = Console.ReadLine();
			if (user.Length == 0)
			{
				Console.WriteLine("Invalid username!");
				return ExitCode.BadCommand;
			}
			Console.WriteLine("Enter password:");
			var pass = Program.ReadLineSecure();
			if (pass.Length == 0)
			{
				Console.WriteLine("Invalid password!");
				return ExitCode.BadCommand;
			}
			Server.GetComponent<ITGRepository>().SetCredentials(user, pass);
			return ExitCode.Normal;
		}
		public override void PrintHelp()
		{
			Console.WriteLine("set-credentials\t-\tSet the credentials used for pushing commits");
		}
	}
}
