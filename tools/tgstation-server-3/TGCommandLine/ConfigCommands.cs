using System;
using System.Collections.Generic;
using System.IO;
using TGServiceInterface;

namespace TGCommandLine
{
	class ConfigCommand : RootCommand
	{
		public ConfigCommand()
		{
			Keyword = "config";
			Children = new Command[] { new ConfigMoveServerCommand(), new ConfigServerDirectoryCommand(), new ConfigDownloadCommand(), new ConfigUploadCommand() };
		}
		protected override string GetHelpText()
		{
			return "Manage settings";
		}
	}

	class ConfigMoveServerCommand : Command
	{
		public ConfigMoveServerCommand()
		{
			Keyword = "move-server";
			RequiredParameters = 1;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var res = Server.GetComponent<ITGConfig>().MoveServer(parameters[0]);
			Console.WriteLine(res ?? "Success");
			return res == null ? ExitCode.Normal : ExitCode.ServerError;
		}

		protected override string GetArgumentString()
		{
			return "<new path>";
		}

		protected override string GetHelpText()
		{
			return "Move the server installation (BYOND, Repo, Game) to a new location. Nothing else may be running for this task to complete";
		}
	}

	class ConfigServerDirectoryCommand : Command
	{
		public ConfigServerDirectoryCommand()
		{
			Keyword = "server-dir";
		}

		public override ExitCode Run(IList<string> parameters)
		{
			Console.WriteLine(Server.GetComponent<ITGConfig>().ServerDirectory());
			return ExitCode.Normal;
		}
		
		protected override string GetHelpText()
		{
			return "Print the directory the server is installed in";
		}
	}

	class ConfigDownloadCommand : Command
	{
		public ConfigDownloadCommand()
		{
			Keyword = "download";
			RequiredParameters = 2;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			var bytes = Server.GetComponent<ITGConfig>().ReadRaw(parameters[0], parameters.Count > 2 && parameters[2].ToLower() == "--repo", out string error);
			if(bytes == null)
			{
				Console.WriteLine("Error: " + error);
				return ExitCode.ServerError;
			}

			try
			{
				File.WriteAllText(parameters[1], bytes);
			}
			catch (Exception e)
			{
				Console.WriteLine("Error: " + e.ToString());
			}

			return ExitCode.Normal;
		}
		protected override string GetArgumentString()
		{
			return "<source config file> <out file> [--repo]";
		}
		protected override string GetHelpText()
		{
			return "Downloads the specified file from the config tree and writes it to out file. --repo will fetch it from the repository instead of the game config";
		}
	}
	
	class ConfigUploadCommand : Command
	{
		public ConfigUploadCommand()
		{
			Keyword = "upload";
			RequiredParameters = 2;
		}

		public override ExitCode Run(IList<string> parameters)
		{
			try
			{
				var res = Server.GetComponent<ITGConfig>().WriteRaw(parameters[0], File.ReadAllText(parameters[1]));
				if (res != null)
				{
					Console.WriteLine("Error: " + res);
					return ExitCode.ServerError;
				}
			}
			catch (Exception e)
			{
				Console.WriteLine("Error: " + e.ToString());
			}
			return ExitCode.Normal;
		}

		protected override string GetArgumentString()
		{
			return "<destination config file> <source file> [--repo]";
		}

		protected override string GetHelpText()
		{
			return "Uploads the specified file to the config tree from source file";
		}
	}
}
