using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// The status of the DD instance
	/// </summary>
	public enum TGDreamDaemonStatus
	{
		Offline,
		HardRebooting,
		Online,
	}

	/// <summary>
	/// DD's security level
	/// </summary>
	public enum TGDreamDaemonSecurity
	{
		Trusted = 0,    //default config
		Safe,
		Ultrasafe
	}

	/// <summary>
	/// DD's visibility
	/// </summary>
	public enum TGDreamDaemonVisibility
	{
		Public,
		Private,
		Invisible = 2,  //default config
	}

	[ServiceContract]
	public interface ITGDreamDaemon
	{
		/// <summary>
		/// Gets the status of DD
		/// </summary>
		/// <returns>The appropriate TGDreamDaemonStatus</returns>
		[OperationContract]
		TGDreamDaemonStatus DaemonStatus();

		/// <summary>
		/// Returns a human readable string of the current server status
		/// </summary>
		/// <returns>A human readable string of the current server status</returns>
		[OperationContract]
		string StatusString(bool includeMetaInfo = true);

		/// <summary>
		/// Check if a call to Start will fail
		/// Of course, be aware of race conditions with other control panels
		/// </summary>
		/// <returns>returns the error that would occur, null otherwise</returns>
		[OperationContract]
		string CanStart();
		
		/// <summary>
		/// Starts the server if it isn't running
		/// </summary>
		/// <returns>null on success or error message on failure</returns>
		[OperationContract]
		string Start();

		/// <summary>
		/// Immediately kills the server
		/// </summary>
		/// <returns>null on success or error message on failure</returns>
		[OperationContract]
		string Stop();
		
		/// <summary>
		/// Immediately kills and restarts the server
		/// </summary>
		/// <returns>null on success or error message on failure</returns>
		[OperationContract]
		string Restart();

		/// <summary>
		/// Restart the server after the currently running round ends
		/// Has no effect if the server isn't running
		/// </summary>
		[OperationContract]
		void RequestRestart();

		/// <summary>
		/// Stop the server after the currently running round ends
		/// Has no effect if the server isn't running
		/// </summary>
		[OperationContract]
		void RequestStop();

		/// <summary>
		/// Sets the security level of the server. Requires reboot to apply
		/// Implies a call to RequestRestart()
		/// note that anything higher than Trusted will disable interop from DD
		/// </summary>
		/// <param name="level">The new security level</param>
		[OperationContract]
		void SetSecurityLevel(TGDreamDaemonSecurity level);

		/// <summary>
		/// Sets the visiblity level of the server. Requires reboot to apply
		/// Implies a call to RequestRestart()
		/// </summary>
		/// <param name="vis">The new visibility level</param>
		[OperationContract]
		void SetVisibility(TGDreamDaemonVisibility vis);

		/// <summary>
		/// Get the configured port. Not necessarily the running port if it has since changed
		/// </summary>
		/// <returns>The configured port</returns>
		[OperationContract]
		ushort Port();

		/// <summary>
		/// Set the port to host DD on. Requires reboot to apply
		/// Implies a call to RequestRestart()
		/// </summary>
		/// <param name="new_port">The new port</param>
		[OperationContract]
		void SetPort(ushort new_port);

		/// <summary>
		/// Check if the watchdog will start when the service starts
		/// </summary>
		/// <returns>true if autostart is enabled, false otherwise</returns>
		[OperationContract]
		bool Autostart();

		/// <summary>
		/// Set the autostart config
		/// </summary>
		/// <param name="on">true to start the watchdog with the service, false otherwise</param>
		[OperationContract]
		void SetAutostart(bool on);
	}
}
