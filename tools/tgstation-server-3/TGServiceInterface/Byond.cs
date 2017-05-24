using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// The status of a BYOND update job
	/// </summary>
	public enum TGByondStatus
	{
		/// <summary>
		/// No byond update in progress
		/// </summary>
		Idle,
		/// <summary>
		/// Preparing to update
		/// </summary>
		Starting,
		/// <summary>
		/// Revision is downloading
		/// </summary>
		Downloading,
		/// <summary>
		/// Revision is deflating
		/// </summary>
		Staging,
		/// <summary>
		/// Revision is ready and waiting for DreamDaemon reboot
		/// </summary>
		Staged,
		/// <summary>
		/// Revision is being applied
		/// </summary>
		Updating,
	}

	/// <summary>
	/// Type of byond version
	/// </summary>
	public enum TGByondVersion
	{
		/// <summary>
		/// The highest version from http://www.byond.com/download/build/LATEST/
		/// </summary>
		Latest,
		/// <summary>
		/// The version in the staging directory
		/// </summary>
		Staged,
		/// <summary>
		/// The installed version
		/// </summary>
		Installed,
	}

	/// <summary>
	/// For managing the BYOND installation the server runs
	/// </summary>
	[ServiceContract]
	public interface ITGByond
	{
		/// <summary>
		/// Gets the current status of any BYOND updates
		/// </summary>
		/// <returns>A TGByondStatus</returns>
		[OperationContract]
		TGByondStatus CurrentStatus();
		
		/// <summary>
		/// updates the used byond version to that of version major.minor
		/// The change won't take place until dream daemon reboots
		/// the latest parameter overrides the other two and forces an update to the latest (beta?) version
		/// runs asyncronously, use CurrentStatus to see progress
		/// </summary>
		/// <param name="major">Major BYOND version. E.g. 511</param>
		/// <param name="minor">Minor BYOND version. E.g. 1381</param>
		/// <returns>True if the update started, false if another operation was in progress</returns>
		[OperationContract]
		bool UpdateToVersion(int major, int minor);

		/// <summary>
		/// Check the last update error
		/// Checking this will clear the value
		/// </summary>
		/// <returns>The last update error, if any</returns>
		[OperationContract]
		string GetError();

		/// <summary>
		/// Get the currently installed version as a string formatted as Major.Minor
		/// </summary>
		/// <param name="type">The type of version to retrieve</param>
		/// <returns>null if no version is detected, the version string otherwise</returns>
		[OperationContract]
		string GetVersion(TGByondVersion type);
	}
}
