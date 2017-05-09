using System.ServiceModel;

namespace TGServiceInterface
{
	public enum TGIRCEnableType
	{
		DoNotModify,
		Enable,
		Disable,
	}
	[ServiceContract]
	public interface ITGIRC
	{
		//Sets up IRC info, default fields don't change the current value
		[OperationContract]
		void Setup(string url_port = null, ushort port = 0, string username = null, string[] channels = null, string adminchannel = null, TGIRCEnableType enabled = TGIRCEnableType.DoNotModify);

		//Sets up auth IRC info, null fields don't change the current value
		[OperationContract]
		void SetupAuth(string identifyTarget, string identifyCommand);

		//returns true if the irc bot is connected, false otherwise
		[OperationContract]
		bool Connected();

		//what is says on the tin
		[OperationContract]
		string Reconnect();

		[OperationContract]
		//Sends a message to irc
		//returns null on success, error on failure
		string SendMessage(string msg, bool adminOnly = false);

		//Get channels we are set to connect to, includes the admin channel
		[OperationContract]
		string[] Channels();

		//Get the admin channel
		[OperationContract]
		string AdminChannel();

		/// <summary>
		/// Check if the configuration allows the IRC bot
		/// </summary>
		/// <returns>true if the bot is enabled, false otherwise</returns>
		[OperationContract]
		bool Enabled();

		/// <summary>
		/// Print out the users who can use admin restricted commands over IRC from the admin channel
		/// </summary>
		/// <returns>A list of irc nicknames</returns>
		[OperationContract]
		string[] ListAdmins();

		/// <summary>
		/// Set the users who can use admin restricted commands over IRC from the admin channel
		/// </summary>
		/// <param name="nicknames">The list of irc admin nicknames</param>
		[OperationContract]
		void SetAdmins(string[] nicknames);
	}
}
