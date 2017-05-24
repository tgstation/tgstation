using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// The status of the compiler
	/// </summary>
	public enum TGCompilerStatus
	{
		/// <summary>
		/// Game folder is broken or does not exist
		/// </summary>
		Uninitialized,
		/// <summary>
		/// Game folder is being created
		/// </summary>
		Initializing,
		/// <summary>
		/// Game folder is setup, does not imply the dmb is compiled
		/// </summary>
		Initialized,
		/// <summary>
		/// Game is being compiled
		/// </summary>
		Compiling,
	}

	/// <summary>
	/// For managing the Game A/B/Live folders, compiling, and hotswapping them
	/// </summary>
	[ServiceContract]
	public interface ITGCompiler
	{
		/// <summary>
		/// Sets up the symlinks for hotswapping game code
		/// this will reset everything (except the static directories)
		/// this will not reset the static directories
		/// requires the repository to be set up and locks it for the duration of the operation
		/// does not compile the game
		/// runs asyncronously
		/// </summary>
		/// <returns>true if the operation began, false if it could not start</returns>
		[OperationContract]
		bool Initialize();
		
		/// <summary>
		/// Does all the necessary actions to take the revision currently in the repository
		/// and compile it to be run on the next server reboot
		/// requires byond to be set up and the compiler to be initialized
		/// runs asyncronously
		/// </summary>
		/// <returns>true if the operation began, false if it could not start</returns>
		[OperationContract]
		bool Compile();

		/// <summary>
		/// Cancels the current compilation
		/// </summary>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Cancel();

		/// <summary>
		/// Returns the current compiler status
		/// </summary>
		/// <returns>The current compiler status</returns>
		[OperationContract]
		TGCompilerStatus GetStatus();

		/// <summary>
		/// Returns the error message of the last operation
		/// Reading this will clear the stored value
		/// </summary>
		/// <returns>the error message of the last operation if it failed or null if it succeeded</returns>
		[OperationContract]
		string CompileError();

		/// <summary>
		/// Returns the relative path of the dme the compiler will look for without the .dme part
		/// </summary>
		/// <returns>The relative path of the dme the compiler will look for without the .dme part</returns>
		[OperationContract]
		string ProjectName();

		/// <summary>
		/// Sets the relative path of the dme the compiler will look for without the .dme part
		/// </summary>
		/// <param name="projectName">The relative path of the dme the compiler will look for without the .dme part</param>
		[OperationContract]
		void SetProjectName(string projectName);
	}
}
