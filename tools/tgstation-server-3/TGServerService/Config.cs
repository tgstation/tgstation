using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using TGServiceInterface;
using System.Threading;

namespace TGServerService
{
	//knobs and such
	partial class TGStationServer : ITGConfig
	{
		const string ConfigPostfix = "/config.txt";
		const string DBConfigPostfix = "/dbconfig.txt";
		const string GameConfigPostfix = "/game_options.txt";

		const string AdminRanksConfig = StaticConfigDir + "/admin_ranks.txt";
		const string AdminConfig = StaticConfigDir + "/admins.txt";
		const string NudgeConfig = StaticConfigDir + "/nudge_port.txt";
		const string MapConfig = StaticConfigDir + "/maps.txt";
		const string JobsConfig = StaticConfigDir + "/jobs.txt";

		const string TitleImagesConfig = StaticConfigDir + "/title_screens/images";

		object configLock = new object();	//for atomic reads/writes

		//public api
		public string AddEntry(TGStringConfig type, string entry)
		{
			var currentEntries = GetEntries(type, out string error);
			if (currentEntries == null)
				return error;

			if (currentEntries.Contains(entry))
				return null;

			lock (configLock) {
				try
				{
					using (var f = File.AppendText(StringConfigToPath(type)))
					{
						f.WriteLine(entry);
					}
					return null;
				}
				catch (Exception e)
				{
					return e.ToString();
				}
			}
		}

		//Enum to string file
		string StringConfigToPath(TGStringConfig type)
		{
			var result = StaticConfigDir + "/";
			switch (type)
			{
				case TGStringConfig.Admin_NickNames:
					result += "Admin_NickNames";
					break;
				case TGStringConfig.Silicon_Laws:
					result += "Silicon_Laws";
					break;
				case TGStringConfig.SillyTips:
					result += "SillyTips";
					break;
				case TGStringConfig.Whitelist:
					result += "Whitelist";
					break;
				case TGStringConfig.AwayMissions:
					result += "awaymissionconfig";
					break;
				case TGStringConfig.LavaRuinBlacklist:
					result += "LavaRuinBlacklist";
					break;
				case TGStringConfig.SpaceRuinBlacklist:
					result += "SpaceRuinBlacklist";
					break;
				case TGStringConfig.ShuttleBlacklist:
					result += "unbuyableshuttles";
					break;
				case TGStringConfig.ExternalRSCURLs:
					result += "external_rsc_urls";
					break;
			}
			return result + ".txt";
		}

		//Write out the admin assoiciations to admins.txt
		string WriteMins(IDictionary<string, string> current_mins)
		{ 
			string outText = "";
			foreach (var I in current_mins)
				outText += I.Key + " = " + I.Value + "\r\n";

			try
			{
				lock (configLock)
				{
					File.WriteAllText(AdminConfig, outText);
				}
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public string Addmin(string ckey, string rank)
		{
			var Aranks = AdminRanks(out string error);
			if (Aranks != null)
			{
				if (Aranks.Keys.Contains(rank))
				{
					var current_mins = Admins(out error);
					if (current_mins != null)
					{
						current_mins[ckey] = rank;
						return WriteMins(current_mins);
					}
					return error;
				}
				return "Rank " + rank + " does not exist";
			}
			return error;
		}

		//public api
		public IDictionary<string, IList<TGPermissions>> AdminRanks(out string error)
		{

			List<string> fileLines;
			lock (configLock)
			{
				try
				{
					fileLines = new List<string>(File.ReadAllLines(AdminRanksConfig));
				}
				catch (Exception e)
				{
					error = e.ToString();
					return null;
				}
			}

			var result = new Dictionary<string, IList<TGPermissions>>();
			IList<TGPermissions> previousPermissions = new List<TGPermissions>();
			foreach (var L in fileLines)
			{
				if (L.Length > 0 && L[0] == '#')
					continue;

				var splits = L.Split('=');

				if (splits.Length < 2)  //???
					continue;

				var rank = splits[0].Trim();

				var asList = new List<string>(splits);
				asList.RemoveAt(0);

				var perms = ProcessPermissions(asList, previousPermissions);
				result.Add(rank, perms);
				previousPermissions = perms;
			}
			error = null;
			return result;
		}

		//same thing the proc in admin_ranks.dm does, properly calculates string permission sets and returns them as an enum
		IList<TGPermissions> ProcessPermissions(IList<string> text, IList<TGPermissions> previousPermissions)
		{
			IList<TGPermissions> permissions = new List<TGPermissions>();
			foreach(var E in text)
			{
				var trimmed = E.Trim();
				bool removing;
				switch (trimmed[0])
				{
					case '-':
						removing = true;
						break;
					case '+':
					default:
						removing = false;
						break;
				}
				trimmed = trimmed.Substring(1).ToLower();

				if (trimmed.Length == 0)
					continue;

				var perms = StringToPermission(trimmed, previousPermissions);

				if(perms != null)
					foreach(var perm in perms)
					{
						if (removing)
							permissions.Remove(perm);
						else if (!permissions.Contains(perm))
							permissions.Add(perm);
					}

			}
			return permissions;
		}

		//basic conversion
		IList<TGPermissions> StringToPermission(string permstring, IList<TGPermissions> oldpermissions)
		{
			TGPermissions perm;
			switch (permstring)
			{
				case "@":
				case "prev":
					return oldpermissions;
				case "buildmode":
				case "build":
					perm = TGPermissions.BUILD;
					break;
				case "admin":
					perm = TGPermissions.ADMIN;
					break;
				case "ban":
					perm = TGPermissions.BAN;
					break;
				case "fun":
					perm = TGPermissions.FUN;
					break;
				case "server":
					perm = TGPermissions.SERVER;
					break;
				case "debug":
					perm = TGPermissions.DEBUG;
					break;
				case "permissions":
				case "rights":
					perm = TGPermissions.RIGHTS;
					break;
				case "possess":
					perm = TGPermissions.POSSESS;
					break;
				case "stealth":
					perm = TGPermissions.STEALTH;
					break;
				case "rejuv":
				case "rejuvinate":
					perm = TGPermissions.REJUV;
					break;
				case "varedit":
					perm = TGPermissions.VAREDIT;
					break;
				case "everything":
				case "host":
				case "all":
					return new List<TGPermissions> {
						TGPermissions.ADMIN,
						TGPermissions.SPAWN,
						TGPermissions.FUN,
						TGPermissions.BAN,
						TGPermissions.STEALTH,
						TGPermissions.POSSESS,
						TGPermissions.REJUV,
						TGPermissions.BUILD,
						TGPermissions.SERVER,
						TGPermissions.DEBUG,
						TGPermissions.VAREDIT,
						TGPermissions.RIGHTS,
						TGPermissions.SOUND,
					};
				case "sound":
				case "sounds":
					perm = TGPermissions.SOUND;
					break;
				case "spawn":
				case "create":
					perm = TGPermissions.SPAWN;
					break;
				default:
					return null;
			}
			return new List<TGPermissions> { perm };
		}

		//public api
		public IDictionary<string, string> Admins(out string error)
		{

			List<string> fileLines;
			lock (configLock)
			{
				try
				{
					fileLines = new List<string>(File.ReadAllLines(AdminConfig));
				}
				catch (Exception e)
				{
					error = e.ToString();
					return null;
				}
			}

			var mins = new Dictionary<string, string>();
			foreach(var L in fileLines)
			{
				var trimmed = L.Trim();
				if (L.Length == 0 || L[0] == '#')
					continue;

				var splits = L.Split('=');

				if (splits.Length != 2)
					continue;

				mins.Add(splits[0].Trim(), splits[1].Trim());
			}
			error = null;
			return mins;
		}

		//public api
		public string Deadmin(string admin)
		{
			var current_mins = Admins(out string error);
			if (current_mins != null)
			{
				if (current_mins.ContainsKey(admin))
				{
					current_mins.Remove(admin);
					return WriteMins(current_mins);
				}
				return null;
			}
			return error;
		}

		//public api
		public IList<string> GetEntries(TGStringConfig type, out string error)
		{
			try
			{
				IList<string> result;
				lock (configLock)
				{
					result = new List<string>(File.ReadAllLines(StringConfigToPath(type)));
				}
				result = result.Select(x => x.Trim()).ToList();
				result.Remove(result.Single(x => x.Length == 0 || x[0] == '#'));
				error = null;
				return result;
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		//public api
		public IList<JobSetting> Jobs(out string error)
		{
			try
			{
				IList<string> lines;
				lock (configLock)
				{
					lines = File.ReadAllLines(JobsConfig);
				}
				
				IList<JobSetting> results = new List<JobSetting>();

				//TODO

				foreach (var L in lines)
				{
					var trimmed = L.Trim();
					if (trimmed.Length == 0 || trimmed[0] == '#')
						continue;

					var splits = trimmed.Split('=');

					if (splits.Length < 2)
						continue;

					var countSplits = splits[1].Split(',');
					if (countSplits.Length < 2)
						continue;

					int total, spawn;
					try
					{
						total = Convert.ToInt32(countSplits[0]);
						spawn = Convert.ToInt32(countSplits[1]);
					}
					catch
					{
						continue;
					}

					results.Add(new JobSetting()
					{
						Name = splits[0],
						TotalPositions = total,
						SpawnPositions = spawn,
					});
				}

				error = null;
				return results;
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		//public api
		public string MoveServer(string new_location)
		{
			try
			{
				var di1 = new DirectoryInfo(Environment.CurrentDirectory);
				var di2 = new DirectoryInfo(new_location);

				var copy = di1.Root.FullName != di2.Root.FullName;

				new_location = di2.FullName;

				while (di2.Parent != null)
				{
					if (di2.Parent.FullName == di1.FullName)
					{
						return "Cannot move to child of current directory!";
					}
					else di2 = di2.Parent;
				}


				if (!Monitor.TryEnter(RepoLock))
					return "Repo locked!";
				try
				{
					if (RepoBusy)
						return "Repo busy!";
					if (!Monitor.TryEnter(ByondLock))
						return "BYOND locked";
					try
					{
						if (updateStat != TGByondStatus.Idle)
							return "BYOND busy!";
						if (!Monitor.TryEnter(CompilerLock))
							return "Compiler locked!";

						try
						{
							if (compilerCurrentStatus != TGCompilerStatus.Uninitialized && compilerCurrentStatus != TGCompilerStatus.Initialized)
								return "Compiler busy!";
							if (!Monitor.TryEnter(watchdogLock))
								return "Watchdog locked!";
							try
							{
								if (currentStatus != TGDreamDaemonStatus.Offline)
									return "Watchdog running!";
								var Config = Properties.Settings.Default;
								lock (configLock)
								{
									CleanGameFolder();
									Program.DeleteDirectory(GameDir);
									string error = null;
									if (copy)
									{
										Program.CopyDirectory(Config.ServerDirectory, new_location);
										Directory.CreateDirectory(new_location);
										Environment.CurrentDirectory = new_location;
										try
										{
											Program.DeleteDirectory(Config.ServerDirectory);
										}
										catch
										{
											error = "The move was successful, but the path " + Config.ServerDirectory + " was unable to be deleted fully!";
										}
									}
									else
									{
										try
										{
											Environment.CurrentDirectory = di2.Root.FullName;
											Directory.Move(Config.ServerDirectory, new_location);
											Environment.CurrentDirectory = new_location;
										}
										catch
										{
											Environment.CurrentDirectory = Config.ServerDirectory;
											throw;
										}
									}
									Config.ServerDirectory = new_location;
									TGServerService.ActiveService.EventLog.WriteEntry("Server moved to: " + new_location);
									return null;
								}
							}
							finally
							{
								Monitor.Exit(watchdogLock);
							}
						}
						finally
						{
							Monitor.Exit(CompilerLock);
						}
					}
					finally
					{
						Monitor.Exit(ByondLock);
					}
				}
				finally
				{
					Monitor.Exit(RepoLock);
				}
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public ushort NudgePort(out string error)
		{
			try
			{
				error = null;
				return Convert.ToUInt16(File.ReadAllText(NudgeConfig));
			}
			catch (Exception e)
			{
				error = e.ToString();
				return 0;
			}
		}

		//public api
		public string RemoveEntry(TGStringConfig type, string entry)
		{
			var entries = GetEntries(type, out string error);
			if (entries == null)
				return error;
			if (!entries.Remove(entry))
				return null;

			lock (configLock)
			{
				try
				{
					File.WriteAllLines(StringConfigToPath(type), entries.ToArray());
					return null;
				}
				catch (Exception e)
				{
					return e.ToString();
				}
			}
		}

		//TGConfigType to the right path, Repo or static
		string ConfigTypeToPath(TGConfigType type, bool repo)
		{
			var path = repo ? RepoConfig : StaticConfigDir;
			switch (type)
			{
				case TGConfigType.Database:
					return path + DBConfigPostfix;
				case TGConfigType.Game:
					return path + GameConfigPostfix;
				case TGConfigType.General:
					return path + ConfigPostfix;
				default:
					throw new Exception("Bad TGConfigType: " + type);
			}
		}

		//public api
		public IList<ConfigSetting> Retrieve(TGConfigType type, out string error)
		{
			try
			{
				IList<string> RepoConfigData, StaticConfigData;
				var repolocked = false;
				if (!Monitor.TryEnter(RepoLock))
					repolocked = true;
				try
				{
					if (!repolocked && RepoBusy)
						repolocked = true;
					if (repolocked)
					{
						error = "Repo locked!";
						return null;
					}

					lock (configLock)
					{
						RepoConfigData = new List<string>(File.ReadAllLines(ConfigTypeToPath(type, true)));
						StaticConfigData = new List<string>(File.ReadAllLines(ConfigTypeToPath(type, false)));
					}
				}
				finally
				{
					Monitor.Exit(RepoLock);
				}

				//## designates an option comment
				//# designates a commented out option

				IDictionary<string, ConfigSetting> repoConfig = new Dictionary<string, ConfigSetting>();
				IList<ConfigSetting> results = new List<ConfigSetting>();

				ConfigSetting currentSetting = new ConfigSetting();

				foreach (var I in RepoConfigData)
				{
					var trimmed = I.Trim();
					if (trimmed.Length == 0)
						continue;
					var commented = trimmed[0] == '#';
					if (commented)
					{
						if (trimmed.Length == 1)
							continue;

						if (trimmed[1] == '#')
						{
							//comment line
							if (currentSetting.Comment == null)
								currentSetting.Comment = trimmed.Substring(2).Trim();
							else
								currentSetting.Comment += "\r\n" + trimmed.Substring(2).Trim();
							continue;
						}
						if (trimmed.Length == 2)
							continue;
						trimmed = trimmed.Substring(1).Trim();
					}
					var splits = new List<string>(trimmed.Split(' '));
					currentSetting.Name = splits.First().ToUpper();
					splits.RemoveAt(0);
					var value = String.Join(" ", splits);
					if (commented && value == "")
						value = null;
					currentSetting.ExistsInRepo = true;

					//multi-keying
					if (repoConfig.Keys.Contains(currentSetting.Name))
					{
						currentSetting = repoConfig[currentSetting.Name];
						if (!currentSetting.IsMultiKey)
						{
							currentSetting.IsMultiKey = true;
							currentSetting.DefaultValues = new List<string> { currentSetting.DefaultValue, value };
							currentSetting.DefaultValue = null;
						}
						else
							currentSetting.DefaultValues.Add(value);
					}
					else
					{
						currentSetting.DefaultValue = value;
						repoConfig.Add(currentSetting.Name, currentSetting);
						results.Add(currentSetting);
					}
					currentSetting = new ConfigSetting();
				}
				//gather the stuff from our config
				foreach (var I in StaticConfigData)
				{

					var trimmed = I.Trim();
					if (trimmed.Length == 0)
						continue;
					var commented = trimmed[0] == '#';
					if (trimmed.Length < 3 || trimmed[1] == '#' || commented)
						continue;
					if (commented)
						trimmed = trimmed.Substring(1).Trim();
					var splits = new List<string>(trimmed.Split(' '));
					var name = splits[0].ToUpper();
					if (!repoConfig.Keys.Contains(name))
					{
						currentSetting = new ConfigSetting()
						{
							Comment = "SETTING DOES NOT EXIST IN REPOSITORY",
							Name = name
						};
						//don't support multikeying here
						results.Add(currentSetting);
					}
					else if (commented)
						continue;
					else
						currentSetting = repoConfig[name];
					currentSetting.ExistsInStatic = true;
					splits.RemoveAt(0);
					var value = String.Join(" ", splits);
					if (currentSetting.IsMultiKey)
					{
						if (currentSetting.Values == null)
							currentSetting.Values = new List<string> { value };
						else
							currentSetting.Values.Add(value);
					}
					else
						currentSetting.Value = value;
				}
				error = null;
				return results;
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		//public api
		public string ServerDirectory()
		{
			return Environment.CurrentDirectory;
		}

		//public api
		public string SetItem(TGConfigType type, ConfigSetting newSetting)
		{
			try
			{
				var entries = Retrieve(type, out string error);
				if (entries == null)
					return error;

				//serialize it
				var asStrings = new List<string>();
				bool somethingChanged = false;
				foreach (var I in entries)
				{
					if (newSetting.Name == I.Name)
					{
						somethingChanged = true;
						if (newSetting.Value == null && newSetting.Values == null)  //unset
							continue;
						I.Value = newSetting.Value;
						I.Values = newSetting.Values;
						I.IsMultiKey = newSetting.IsMultiKey;
					}
					else if (!I.ExistsInStatic)
						continue;
					if (I.IsMultiKey)
						foreach (var J in I.Values)
							asStrings.Add((I.Name + " " + J).Trim());
					else
						asStrings.Add((I.Name + " " + I.Value).Trim());
				}

				if (!somethingChanged)
					return null;

				//write it out
				lock (configLock)
				{
					File.WriteAllLines(ConfigTypeToPath(type, false), asStrings);
				}

				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public string SetJob(JobSetting job)
		{
			try
			{
				var entries = Jobs(out string error);
				if (entries == null)
					return error;

				var lines = new List<string>();
				foreach (var J in entries)
				{
					var thingToUse = J.Name == job.Name ? job : J;
					lines.Add(String.Format("{0}={1},{2}", thingToUse.Name, thingToUse.TotalPositions, thingToUse.SpawnPositions));
				}

				lock (configLock)
				{
					File.WriteAllLines(JobsConfig, lines);
				}
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public string SetNudgePort(ushort port)
		{
			try
			{
				lock (configLock) {
					File.WriteAllText(NudgeConfig, port.ToString());
				}
				InitInterop();
				return null;
			}catch(Exception e)
			{
				return e.ToString();
			}
		}

		public IList<MapSetting> MapSettings(out string error)
		{
			try
			{
				IList<string> lines;
				lock (configLock)
				{
					lines = File.ReadAllLines(MapConfig);
				}

				MapSetting currentMap = null, lastDefaultMap = null;
				IList<MapSetting> results = new List<MapSetting>();
				foreach(var L in lines)
				{
					var trimmed = L.Trim();
					if (trimmed.Length == 0 || trimmed[0] == '#')
						continue;
					var splits = trimmed.Split(' ');
					switch (splits[0].ToLower())
					{
						case "map":
							if (splits.Length < 2)
								continue;
							currentMap = new MapSetting()
							{
								Name = splits[1],	//defaults in game
								Enabled = true,
								VoteWeight = 1,
							};
							break;
						case "endmap":
							if (currentMap != null)
								results.Add(currentMap);
							currentMap = null;
							break;
						case "minplayer":
						case "minplayers":
							if (splits.Length < 2)
								continue;
							if (currentMap != null)
								try
								{
									currentMap.MinPlayers = Convert.ToInt32(splits[1]);
								}
								catch {
									continue;
								}
							break;
						case "maxplayer":
						case "maxplayers":
							if (splits.Length < 2)
								continue;
							if (currentMap != null)
								try
								{
									currentMap.MaxPlayers = Convert.ToInt32(splits[1]);
								}
								catch
								{
									continue;
								}
							break;
						case "weight":
						case "voteweight":
							if (splits.Length < 2)
								continue;
							if (currentMap != null)
								try
								{
									currentMap.VoteWeight = float.Parse(splits[1]);
								}
								catch
								{
									continue;
								}
							break;
						case "default":
						case "defaultmap":
							if (currentMap == null)
								continue;
							if (lastDefaultMap != null)
								lastDefaultMap.Default = false;
							currentMap.Default = true;
							lastDefaultMap = currentMap;
							break;
						case "disabled":
							currentMap = null;
							break;
					}
				}
				error = null;
				return results;
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		public string SetMapSettings(MapSetting newSetting)
		{
			try
			{
				var entries = MapSettings(out string error);
				if (entries == null)
					return error;

				IList<string> asStrings = new List<string>();
				foreach (var I in entries)
				{
					var entryToUse = I.Name == newSetting.Name ? newSetting : I;

					asStrings.Add("map " + entryToUse.Name + "\r\n");
					if (!entryToUse.Enabled)
						asStrings.Add("\tdisabled\r\n");
					if (entryToUse.MinPlayers > 0)
						asStrings.Add(String.Format("\tminplayers {0}\r\n", entryToUse.MinPlayers));
					if (entryToUse.MaxPlayers > 0)
						asStrings.Add(String.Format("\tmaxplayers {0}\r\n", entryToUse.MaxPlayers));
					if (entryToUse.VoteWeight != 1)
						asStrings.Add(String.Format("\tvoteweight {0}\r\n", entryToUse.VoteWeight));
					if (entryToUse.Default)
						asStrings.Add("\tdefault\r\n");
					asStrings.Add("endmap\r\n\r\n");
				}

				lock (configLock)
				{
					File.WriteAllLines(MapConfig, asStrings);
				}

				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		public string ReadRaw(string configRelativePath, bool repo, out string error)
		{
			try
			{
				var configDir = repo ? RepoConfig : StaticConfigDir;
				var path = configDir + "/" + configRelativePath;
				lock (configLock) {
					var di1 = new DirectoryInfo(configDir);
					var di2 = new DirectoryInfo(new FileInfo(path).Directory.FullName);

					var good = false;
					while (di2 != null)
					{
						if (di2.FullName == di1.FullName)
						{
							good = true;
							break;
						}
						else di2 = di2.Parent;
					}

					if (!good)
					{
						error = "Cannot read above config directory!";
						return null;
					}

					error = null;
					return File.ReadAllText(path);
				}
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		public string WriteRaw(string configRelativePath, string data)
		{
			try
			{
				var path = StaticConfigDir + "/" + configRelativePath;
				lock (configLock)
				{
					var di1 = new DirectoryInfo(StaticConfigDir);
					var destdir = new FileInfo(path).Directory.FullName;
					var di2 = new DirectoryInfo(destdir);

					var good = false;
					while (di2 != null)
					{
						if (di2.FullName == di1.FullName)
						{
							good = true;
							break;
						}
						else di2 = di2.Parent;
					}

					if (!good)
						return "Cannot write above config directory!";
					Directory.CreateDirectory(destdir);
					File.WriteAllText(path, data);
					return null;
				}
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		public string SetTitleImage(string filename, byte[] data)
		{
			try
			{
				lock (configLock)
				{
					var path = StaticConfigDir + TitleImagesConfig + "/" + filename;
					File.WriteAllBytes(path, data);
					return null;
				}
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}
	}
}
