using System.Collections.Generic;
using System.Runtime.Serialization;
using System.ServiceModel;

namespace TGServiceInterface
{
	/// <summary>
	/// Information about a pull request
	/// </summary>
	[DataContract]
	public class PullRequestInfo
	{
		/// <summary>
		/// Construct a PullRequestInfo
		/// </summary>
		/// <param name="number">The PR number</param>
		/// <param name="author">The PR's author</param>
		/// <param name="title">The PR's title</param>
		/// <param name="sha">The commit the PR was merged locally at</param>
		public PullRequestInfo(int number, string author, string title, string sha)
		{
			Number = number;
			Author = author;
			Title = title;
			Sha = sha;
		}

		/// <summary>
		/// The PR number
		/// </summary>
		[DataMember]
		public int Number { get; private set; }
		/// <summary>
		/// The PR's author
		/// </summary>
		[DataMember]
		public string Author { get; private set; }
		/// <summary>
		/// The PR's title
		/// </summary>
		[DataMember]
		public string Title { get; private set; }
		/// <summary>
		/// The commit the PR was merged locally at
		/// </summary>
		[DataMember]
		public string Sha { get; private set; }
	}
	/// <summary>
	/// Interface for managing the code repository
	/// </summary>
	[ServiceContract]
	public interface ITGRepository
	{
		/// <summary>
		/// If the repo is currently undergoing an operation
		/// </summary>
		/// <returns>true if the repo is busy, false otherwise</returns>
		[OperationContract]
		bool OperationInProgress();

		/// <summary>
		/// Gets the progress of repository operations, not all operations are supported
		/// </summary>
		/// <returns>A value between 0 and 100 representing the progress of the current operation or -1 if the operation cannot be monitored</returns>
		[OperationContract]
		int CheckoutProgress();

		/// <summary>
		/// Check if the repository is valid, if not Setup must be called
		/// </summary>
		/// <returns>true if the repository is valid, false otherwise</returns>
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

		/// <summary>
		/// Gets the sha of the current HEAD
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The sha of the current HEAD on success, null on failure</returns>
		[OperationContract]
		string GetHead(out string error);
		
		/// <summary>
		/// Gets the name of the current branch
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The name of the current branch on success, null on failure</returns>
		[OperationContract]
		string GetBranch(out string error);
		
		/// <summary>
		/// Gets the url of the current origin
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>The url of the current origin on success, null on failure</returns>
		[OperationContract]
		string GetRemote(out string error);
		
		/// <summary>
		/// Hard checks out the passed object name
		/// </summary>
		/// <param name="branchorsha">The branch, commit, or tag to checkout</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Checkout(string objectName);

		/// <summary>
		/// Fetches the origin and merges it into the current branch
		/// </summary>
		/// <param name="reset">If true, the operation will perform a hard reset instead of a merge</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Update(bool reset);

		/// <summary>
		/// Runs git reset --hard
		/// </summary>
		/// <param name="tracked">Changes command to git reset --hard origin/branch_name if true</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string Reset(bool tracked);
		
		/// <summary>
		/// Merges the target pull request into the current branch if the remote is a github repository
		/// </summary>
		/// <param name="PRnumber">The github pull request number in the remote repository</param>
		/// <returns>null on success, error message on failure</returns>
		[OperationContract]
		string MergePullRequest(int PRnumber);

		//Returns a list of PR# -> Sha of the currently merged pull requests
		//returns null on failure and error will be set

		/// <summary>
		/// Get the currently merged pull requests. Note that switching branches will delete this list and switching back won't restore it
		/// </summary>
		/// <param name="error">null on success, error message on failure</param>
		/// <returns>A list of PullRequestInfo</returns>
		[OperationContract]
		IList<PullRequestInfo> MergedPullRequests(out string error);

		/// <summary>
		/// Gets the name of the configured git committer
		/// </summary>
		/// <returns>The name of the configured git committer</returns>
		[OperationContract]
		string GetCommitterName();

		/// <summary>
		/// Sets the name of the configured git committer
		/// </summary>
		/// <param name="newName">The name to set</param>
		[OperationContract]
		void SetCommitterName(string newName);

		/// <summary>
		/// Gets the email of the configured git committer
		/// </summary>
		/// <returns>The email of the configured git committer</returns>
		[OperationContract]
		string GetCommitterEmail();

		/// <summary>
		/// Sets the email of the configured git committer
		/// </summary>
		/// <param name="newEmail">The email to set</param>
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
