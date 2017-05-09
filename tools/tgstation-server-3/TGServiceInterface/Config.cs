using System.Collections.Generic;
using System.Runtime.Serialization;
using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// The type of string -> string config being modified
	/// </summary>
	public enum TGConfigType
	{
		Database,
		Game,
		General,
	}

	/// <summary>
	/// Single line string configuration to edit
	/// </summary>
	public enum TGStringConfig{
		Admin_NickNames,
		Silicon_Laws,
		SillyTips,
		Whitelist,
		AwayMissions,
		LavaRuinBlacklist,
		SpaceRuinBlacklist,
		ShuttleBlacklist,
		ExternalRSCURLs,
	}

	/// <summary>
	/// Admin permission sets
	/// </summary>
	public enum TGPermissions
	{
		ADMIN,
		SPAWN,
		FUN,
		BAN,
		STEALTH,
		POSSESS,
		REJUV,
		BUILD,
		SERVER,
		DEBUG,
		VAREDIT,
		RIGHTS,
		SOUND,
	}

	/// <summary>
	/// Map configuration settings
	/// </summary>
	[DataContract]
	public class MapSetting
	{
		/// <summary>
		/// The name of the map
		/// </summary>
		[DataMember]
		public string Name { get; set; }
		/// <summary>
		/// If this is the default voted map
		/// </summary>
		[DataMember]
		public bool Default { get; set; }
		/// <summary>
		/// The voteweight of the map
		/// </summary>
		[DataMember]
		public float VoteWeight { get; set; }
		/// <summary>
		/// The minimum number of players to run this map
		/// </summary>
		[DataMember]
		public int MinPlayers { get; set; }
		/// <summary>
		/// The maximum number of players to run this map
		/// </summary>
		[DataMember]
		public int MaxPlayers { get; set; }
		/// <summary>
		/// If the map is enabled
		/// </summary>
		[DataMember]
		public bool Enabled { get; set; }
	}

	/// <summary>
	/// Used for white/blacklisting certain map files
	/// </summary>
	[DataContract]
	public class MapEnabled
	{
		/// <summary>
		/// The file name of the map
		/// </summary>
		[DataMember]
		public string Filename { get; set; }
		/// <summary>
		/// True if the map is enabled, false otherwise
		/// </summary>
		[DataMember]
		public bool Enabled { get; set; }
	}

	/// <summary>
	/// Game configuration setting
	/// </summary>
	[DataContract]
	public class ConfigSetting
	{
		/// <summary>
		/// The setting name
		/// </summary>
		[DataMember]
		public string Name { get; set; }
		/// <summary>
		/// Comments above the setting
		/// </summary>
		[DataMember]
		public string Comment { get; set; }
		/// <summary>
		/// True if this setting exists in the current configuration
		/// </summary>
		[DataMember]
		public bool ExistsInStatic { get; set; }
		/// <summary>
		/// True if this setting exists in the repo's config
		/// </summary>
		[DataMember]
		public bool ExistsInRepo { get; set; }
		/// <summary>
		/// True if this value appears more than once in either config
		/// </summary>
		[DataMember]
		public bool IsMultiKey { get; set; }
		/// <summary>
		/// Value of the setting
		/// null means unset, empty string means flag
		/// </summary>
		[DataMember]
		public string Value { get; set; }
		/// <summary>
		/// For when the first word of the config setting can be repeated many times
		/// Usually null
		/// </summary>
		[DataMember]
		public List<string> Values { get; set; }
		/// <summary>
		/// Value of the setting in the repo
		/// null means unset, empty string means flag
		/// </summary>
		[DataMember]
		public string DefaultValue { get; set; }
		/// <summary>
		/// For when the first word of the config setting can be repeated many times
		/// Usually null
		/// </summary>
		[DataMember]
		public List<string> DefaultValues { get; set; }
	}
	/// <summary>
	/// Setting for job populations
	/// </summary>
	[DataContract]
	public class JobSetting
	{
		/// <summary>
		/// The name of the job
		/// </summary>
		[DataMember]
		public string Name { get; set; }
		/// <summary>
		/// Number of total positions for this job, -1 for infinite
		/// </summary>
		[DataMember]
		public int TotalPositions { get; set; }
		/// <summary>
		/// Number of positions for this job when the game starts, -1 for infinite
		/// </summary>
		[DataMember]
		public int SpawnPositions { get; set; }
	}

	/// <summary>
	/// For modifying the in game config
	/// Most if not all of these will not apply until the next server reboot
	/// </summary>
	[ServiceContract]
	public interface ITGConfig
	{
		/// <summary>
		/// Gets the config settings of some config
		/// </summary>
		/// <param name="type">The type of config to retrieve</param>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The list of configs on success or null on failure</returns>
		[OperationContract]
		IList<ConfigSetting> Retrieve(TGConfigType type, out string error);

		/// <summary>
		/// Sets a config setting of some config
		/// </summary>
		/// <param name="type">The type of config to retrieve</param>
		/// <param name="newSetting">The updated config setting, only name and value fields are read</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string SetItem(TGConfigType type, ConfigSetting newSetting);

		/// <summary>
		/// Get the configured admin ranks
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>A dictionary of rank -> permissions on success, null on failure</returns>
		[OperationContract]
		IDictionary<string, IList<TGPermissions>> AdminRanks(out string error);

		/// <summary>
		/// List the admins
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>a dictionary of ckey -> admin rank on success, null on failure</returns>
		[OperationContract]
		IDictionary<string, string> Admins(out string error);

		/// <summary>
		/// Add or modify a ckey's admin status
		/// </summary>
		/// <param name="ckey">The byond ckey to modify</param>
		/// <param name="rank">The rank of the admin</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Addmin(string ckey, string rank);

		/// <summary>
		/// Remove the admin status of a ckey
		/// </summary>
		/// <param name="admin">The ckey to deadmin</param>
		/// <returns></returns>
		[OperationContract]
		string Deadmin(string admin);

		/// <summary>
		/// List the job population limits
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>A list of JobSettings</returns>
		[OperationContract]
		IList<JobSetting> Jobs(out string error);

		/// <summary>
		/// Set the population limits for a job
		/// </summary>
		/// <param name="job">The population limits</param>
		/// <returns>null on success, error on failure</returns>
		[OperationContract]
		string SetJob(JobSetting job);

		/// <summary>
		/// Lists game map settings
		/// </summary>
		/// <param name="error">null on success, error on failure</param>
		/// <returns>The list of MapSettings</returns>
		[OperationContract]
		IList<MapSetting> MapSettings(out string error);

		/// <summary>
		/// Sets a game map's settings
		/// </summary>
		/// <param name="newSetting">The new setting for the map</param>
		/// <returns>null on success, error on failure</returns>
		[OperationContract]
		string SetMapSettings(MapSetting newSetting);

		/// <summary>
		/// Gets the port DD uses to talk to the service
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The port DD uses to talk to the service or 0 on failure</returns>
		[OperationContract]
		ushort NudgePort(out string error);

		/// <summary>
		/// Sets the  port DD uses to talk to the service
		/// </summary>
		/// <param name="port">The port DD uses to talk to the service</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string SetNudgePort(ushort port);

		/// <summary>
        /// Get the entries of a per line string config
        /// </summary>
        /// <param name="type">The config file to get</param>
        /// <param name="error">null on success, error message on failure</param>
        /// <returns>A list of entries</returns>
		[OperationContract]
		IList<string> GetEntries(TGStringConfig type, out string error);

		/// <summary>
        /// Add a line entry to a config
        /// </summary>
        /// <param name="type">The config file to add to</param>
        /// <param name="entry">The entry add</param>
        /// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string AddEntry(TGStringConfig type, string entry);

		/// <summary>
		/// Remove a line entry from a config
		/// </summary>
		/// <param name="type">The config file to remove from</param>
		/// <param name="entry">The entry to remove</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string RemoveEntry(TGStringConfig type, string entry);

		/// <summary>
		/// Return the directory of the server on the host machine
		/// </summary>
		/// <returns>The path to the directory on success, null on failure</returns>
		[OperationContract]
		string ServerDirectory();

		/// <summary>
		/// Moves the entire server installation, requires no operations to be running
		/// </summary>
		/// <param name="new_location">The new path to place the server</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string MoveServer(string new_location);

		/// <summary>
		/// Upload a titlescreen image
		/// </summary>
		/// <param name="filename">The name of the file saved in config/title_screens/images</param>
		/// <param name="data">The bytes of the file, null will delete the file</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string SetTitleImage(string filename, byte[] data);

		/// <summary>
		/// For when you really just need to see the raw data of the config
		/// </summary>
		/// <param name="configRelativePath">The path from the configDir. E.g. config.txt</param>
		/// <param name="repo">if true, the file will be read </param>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The full text of the file on success, null on failure</returns>
		[OperationContract]
		string ReadRaw(string configRelativePath, bool repo, out string error);

		/// <summary>
		/// For when you really just need to set the raw data of the config
		/// </summary>
		/// <param name="configRelativePath">The path from the configDir. E.g. config.txt</param>
		/// <param name="data">The full text of the config file</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string WriteRaw(string configRelativePath, string data);
	}
}
