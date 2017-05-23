using System.Collections.Generic;
using System.ServiceModel;

namespace TGServiceInterface
{
	//for managing the code repository
	//note, the only way to run git clean on the repo is to run Setup again
	[ServiceContract]
	public interface ITGRepository
	{
		//returns true if something is using the repo
		//calls are serialized, so calling a git operation function if this is true will cause it to block until the previous operation completes
		[OperationContract]
		bool OperationInProgress();

		//returns the current progress of a setup, update, or checkout operation
		[OperationContract]
		int CheckoutProgress();

		//check if the repository is valid, if not Setup must be called
		[OperationContract]
		bool Exists();
		
		/// <summary>
		/// Deletes whatever may be left over and clones the repo at remote and checks out branch master
		/// Will move config and data dirs to a backup location if they exist
		/// runs asyncronously
		/// </summary>
		/// <param name="remote">The address of the repo to clone. If ssh protocol is used, repository_private_key.txt must exist in the server directory.</param>
		/// <param name="branch">The branch of the repo to checkout</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Setup(string remote, string branch = "master");

		//returns the sha of the current HEAD
		//if null, error will contain the error
		[OperationContract]
		string GetHead(out string error);

		//returns the name of the current branch
		//if null, error will contain the error
		[OperationContract]
		string GetBranch(out string error);

		//returns the url of the current origin
		//if null, error will contain the error
		[OperationContract]
		string GetRemote(out string error);

		//hard checks outW the passed branch or sha
		//returns null on success, error message on failure
		[OperationContract]
		string Checkout(string branchorsha);

		//Fetches the origin and merges it into the current branch
		//if reset is true a hard reset is performed to the origin branch instead
		//returns null on success, error message on failure
		[OperationContract]
		string Update(bool reset);

		/// <summary>
		/// Runs git reset --hard
		/// </summary>
		/// <param name="tracked">Changes command to git reset --hard origin/branch_name if true</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Reset(bool tracked);

		//Merges the pull request number if the remote is a github repository
		//returns null on success, error message on failure
		[OperationContract]
		string MergePullRequest(int PRnumber);

		//Returns a list of PR# -> Sha of the currently merged pull requests
		//returns null on failure and error will be set
		[OperationContract]
		IDictionary<string, IDictionary<string, string>> MergedPullRequests(out string error);

		//Gets the name of the current git committer
		[OperationContract]
		string GetCommitterName();

		//Sets the name of the current git committer
		[OperationContract]
		void SetCommitterName(string newName);
		//Gets the name of the current git email
		[OperationContract]
		string GetCommitterEmail();

		//Sets the name of the current git email
		[OperationContract]
		void SetCommitterEmail(string newEmail);

		/// <summary>
		/// Updates the html changelog
		/// </summary>
		/// <param name="error">null on success, error on failure</param>
		/// <returns>The output of the python script</returns>
		[OperationContract]
		string GenerateChangelog(out string error);

		/// <summary>
		/// Sets the path to the python 2.7 installation
		/// </summary>
		/// <param name="path">The new path</param>
		/// <returns>true if the path exists, false otherwise</returns>
		[OperationContract]
		bool SetPythonPath(string path);

		/// <summary>
		/// Gets the path to the python 2.7 installation
		/// </summary>
		/// <returns>The path to the python 2.7 installation</returns>
		[OperationContract]
		string PythonPath();

		/// <summary>
		/// List the tagged commits of the repo at which compiles took place
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>A dictionary of tag name -> commit on success, null on failure</returns>
		[OperationContract]
		IDictionary<string, string> ListBackups(out string error);
	}
}
