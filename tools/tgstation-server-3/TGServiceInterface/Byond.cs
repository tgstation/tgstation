using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// The status of a BYOND update job
	/// </summary>
	public enum TGByondStatus
	{
		Idle,	//no byond update in progress
		Starting,	//Preparing to update
		Downloading,	//byond downloading
		Staging,	//byond unzipping
		Staged,	//byond ready, waiting for dream daemon reboot
		Updating,	//applying update
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
		/// <param name="staged">If true, will check the verision of the staged update</param>
		/// <returns>null if no version is detected, the version string otherwise</returns>
		[OperationContract]
		string GetVersion(bool staged);
	}
}
