using System;
using System.Collections.Generic;
using System.Linq;
using TGServiceInterface;

namespace TGCommandLine
{
	enum ExitCode
	{
		Normal = 0,
		ConnectionError = 1,
		BadCommand = 2,
		ServerError = 3,
	}

	abstract class Command
	{
		public string Keyword { get; protected set; }
		public Command[] Children { get; protected set; } = { };
		public int RequiredParameters { get; protected set; }
		public abstract ExitCode Run(IList<string> parameters);
		public virtual void PrintHelp()
		{
			foreach (var c in Children)
				c.PrintHelp();
		}
	}

	class Program
	{
		static ExitCode RunCommandLine(IList<string> argsAsList)
		{
			var res = Server.VerifyConnection();
			if (res != null)
			{
				Console.WriteLine("Unable to connect to service!");
				return ExitCode.ConnectionError;
			}
			try {
				return new RootCommand().Run(argsAsList);
			}
			catch
			{
				Console.WriteLine("Service connection interrupted!");
				return ExitCode.ConnectionError;
			};
		}
		public static string ReadLineSecure()
		{
			string result = "";
			while (true)
			{
				ConsoleKeyInfo i = Console.ReadKey(true);
				if (i.Key == ConsoleKey.Enter)
				{
					break;
				}
				else if (i.Key == ConsoleKey.Backspace)
				{
					if (result.Length > 0)
					{
						result = result.Substring(0, result.Length - 1);
						Console.Write("\b \b");
					}
				}
				else
				{
					result += i.KeyChar;
					Console.Write("*");
				}
			}
			return result;
		}
		
		static int Main(string[] args)
		{
			if (args.Length != 0)
				return (int)RunCommandLine(new List<string>(args));

			//interactive mode
			while (true)
			{
				Console.Write("Enter command: ");
				var NextCommand = Console.ReadLine();
				switch (NextCommand.ToLower())
				{
					case "quit":
					case "exit":
						return (int)ExitCode.Normal;
					default:
						//linq voodoo to get quoted strings
						var formattedCommand = NextCommand.Split('"')
										   .Select((element, index) => index % 2 == 0  // If even index
										   ? element.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries)  // Split the item
										   : new string[] { element })  // Keep the entire item
										   .SelectMany(element => element).ToList();

						formattedCommand = formattedCommand.Select(x => x.Trim()).ToList();
						formattedCommand.Remove("");
						RunCommandLine(formattedCommand);
						break;
				}
			}
		}
	}
}