using LibGit2Sharp;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Security.Cryptography;
using System.Web.Script.Serialization;
using TGServiceInterface;

namespace TGServerService
{
	partial class TGStationServer : ITGRepository, IDisposable
	{
		const string RepoPath = "Repository";
		const string RepoConfig = RepoPath + "/config";
		const string RepoData = RepoPath + "/data";
		const string RepoErrorUpToDate = "Already up to date!";

		const string PRJobFile = "prtestjob.json";

		object RepoLock = new object();
		bool RepoBusy = false;

		Repository Repo;
		int currentProgress = -1;

		//public api
		public bool OperationInProgress()
		{
			lock(RepoLock)
			{
				return RepoBusy;
			}
		}

		//public api
		public int CheckoutProgress()
		{
			return currentProgress;
		}

		//Sets up the repo object
		string LoadRepo()
		{
			if (Repo != null)
				return null;
			if (!Repository.IsValid(RepoPath))
				return "Repository does not exist";
			try
			{
				Repo = new LibGit2Sharp.Repository(RepoPath);
			}
			catch (Exception e)
			{
				return e.ToString();
			}
			return null;
		}

		//Cleans up the repo object
		void DisposeRepo()
		{
			if (Repo != null)
			{
				Repo.Dispose();
				Repo = null;
			}
		}

		//public api
		public bool Exists()
		{
			lock (RepoLock)
			{
				return RepoBusy || Repository.IsValid(RepoPath);
			}
		}

		//Updates the currentProgress var
		//no locks required because who gives a shit, it's a fucking 32-bit integer
		bool HandleTransferProgress(TransferProgress progress)
		{
			currentProgress = (int)(((float)progress.ReceivedObjects / progress.TotalObjects) * 100) / 2;
			currentProgress += (int)(((float)progress.IndexedObjects / progress.TotalObjects) * 100) / 2;
			return true;
		}

		//see above
		void HandleCheckoutProgress(string path, int completedSteps, int totalSteps)
		{
			currentProgress = (int)(((float)completedSteps / totalSteps) * 100);
		}

		//For the thread parameter
		private class TwoStrings
		{
			public string a, b;
		}

		//This is the thread that resets za warldo
		//clones, checksout, sets up static dir
		void Clone(object twostrings)
		{
			//busy flag set by caller
			try
			{
				var ts = (TwoStrings)twostrings;
				var RepoURL = ts.a;
				var BranchName = ts.b;
				SendMessage(String.Format("REPO: {2} started: Cloning {0} branch of {1} ...", BranchName, RepoURL, Repository.IsValid(RepoPath) ? "Full reset" : "Setup"));
				try
				{
					DisposeRepo();
					Program.DeleteDirectory(RepoPath);
					Program.DeleteDirectory(StaticBackupDir);	//you had your chance
					DeletePRList();
					lock (configLock)
					{
						if (Directory.Exists(StaticDirs))
							Program.CopyDirectory(StaticDirs, StaticBackupDir);
						Program.DeleteDirectory(StaticDirs);
					}

					var Opts = new CloneOptions()
					{
						BranchName = BranchName,
						RecurseSubmodules = true,
						OnTransferProgress = HandleTransferProgress,
						OnCheckoutProgress = HandleCheckoutProgress
					};
					Repository.Clone(RepoURL, RepoPath, Opts);
					currentProgress = -1;
					LoadRepo();
					lock (configLock)
					{
						Program.CopyDirectory(RepoConfig, StaticConfigDir);
					}
					Program.CopyDirectory(RepoData, StaticDataDir);
					File.Copy(RepoPath + LibMySQLFile, StaticDirs + LibMySQLFile, true);
					SendMessage("REPO: Clone complete!");
				}
				finally
				{
					currentProgress = -1;
				}
			}
			catch(Exception e)

			{
				SendMessage("REPO: Setup failed!");
				TGServerService.ActiveService.EventLog.WriteEntry("Clone error: " + e.ToString(), EventLogEntryType.Error);
			}
			finally
			{
				lock (RepoLock)
				{
					RepoBusy = false;
				}
			}
		}

		//kicks off the cloning thread
		//public api
		public bool Setup(string RepoURL, string BranchName)
		{
			lock (RepoLock)
			{
				if (RepoBusy)
					return false;
				if (!CompilerIdleNoLock())
					return false;
				if (DaemonStatus() != TGDreamDaemonStatus.Offline)
					return false;
				RepoBusy = true;
				new Thread(new ParameterizedThreadStart(Clone))
				{
					IsBackground = true //make sure we don't hold up shutdown
				}.Start(new TwoStrings { a = RepoURL, b = BranchName });
				return true;
			}
		}

		//Gets what HEAD is pointing to
		string GetShaOrBranch(out string error, bool branch)
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
				{
					error = result;
					return null;
				}

				try
				{
					error = null;
					return branch ? Repo.Head.FriendlyName : Repo.Head.Tip.Sha; ;
				}
				catch (Exception e)
				{
					error = e.ToString();
					return null;
				}
			}
		}

		//moist shleppy noises
		//public api
		public string GetHead(out string error)
		{
			return GetShaOrBranch(out error, true);
		}

		//public api
		public string GetBranch(out string error)
		{
			return GetShaOrBranch(out error, true);
		}

		//public api
		public string GetRemote(out string error)
		{
			try
			{
				var res = LoadRepo();
				if (res != null)
				{
					error = res;
					return null;
				}
				error = null;
				return Repo.Network.Remotes.First().Url;
			}
			catch (Exception e)
			{
				error = e.ToString();
				return null;
			}
		}

		//calls git reset --hard on HEAD
		//requires RepoLock
		string ResetNoLock()
		{
			try
			{
				var result = LoadRepo();
				if (result != null)
					return result;
				Repo.Reset(ResetMode.Hard);
				return null;
			}
			catch (Exception e)
			{
				return e.ToString();
			}
		}

		//public api
		public string Checkout(string sha)
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
					return result;
				SendMessage("REPO: Checking out object: " + sha);
				try
				{
					var Opts = new CheckoutOptions()
					{
						CheckoutModifiers = CheckoutModifiers.Force,
						OnCheckoutProgress = HandleCheckoutProgress,
					};
					Commands.Checkout(Repo, sha, Opts);
					var res = ResetNoLock();
					SendMessage("REPO: Checkout complete!");
					return res;
				}
				catch (Exception E)
				{
					SendMessage("REPO: Checkout failed!");
					return E.ToString();
				}
			}
		}

		//Merges a thing into HEAD, not even necessarily a branch
		string MergeBranch(string branchname)
		{
			var mo = new MergeOptions()
			{
				OnCheckoutProgress = HandleCheckoutProgress
			};
			var Result = Repo.Merge(branchname, MakeSig());
			currentProgress = -1;
			switch (Result.Status)
			{
				case MergeStatus.Conflicts:
					ResetNoLock();
					SendMessage("REPO: Merge conflicted, aborted.");
					return "Merge conflict occurred.";
				case MergeStatus.UpToDate:
					SendMessage("REPO: Merge already up to date!");
					return RepoErrorUpToDate;
			}
			SendMessage(String.Format("REPO: Branch {0} successfully {1}!", branchname, Result.Status == MergeStatus.FastForward ? "fast-forwarded" : "merged"));
			return null;
		}

		//public api
		public string Update(bool reset)
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
					return result;
				SendMessage(String.Format("REPO: Updating origin branch...({0})", reset ? "Hard Reset" : "Merge"));
				try
				{
					string logMessage = "";
					foreach (Remote R in Repo.Network.Remotes)
					{
						IEnumerable<string> refSpecs = R.FetchRefSpecs.Select(X => X.Specification);
						var fos = new FetchOptions();
						fos.OnTransferProgress += HandleTransferProgress;
						Commands.Fetch(Repo, R.Name, refSpecs, null, logMessage);
					}

					var originBranch = String.Format("origin/{0}", Repo.Head.FriendlyName);
					if (reset)
					{
						Repo.Reset(ResetMode.Hard, originBranch);
						var error = ResetNoLock();
						if (error == null)
						{
							DeletePRList();
							SendMessage("REPO: Update complete!");
						}
						else
							SendMessage("REPO: Update failed!");
						return error;
					}
					return MergeBranch(originBranch);
				}
				catch (Exception E)
				{
					SendMessage("REPO: Update failed!");
					return E.ToString();
				}
			}
		}

		//public api
		public string Reset()
		{
			lock (RepoLock)
			{
				return ResetNoLock();
			}
		}

		//Makes the LibGit2Sharp sig we'll use for committing based on the configured stuff
		Signature MakeSig()
		{
			var Config = Properties.Settings.Default;
			return new Signature(new Identity(Config.CommitterName, Config.CommitterEmail), DateTimeOffset.Now);
		}

		//I wonder...
		void DeletePRList()
		{
			if (File.Exists(PRJobFile))
				File.Delete(PRJobFile);
		}

		//json_decode(file2text())
		IDictionary<string, string> GetCurrentPRList()
		{
			if (!File.Exists(PRJobFile))
				return new Dictionary<string, string>();
			var rawdata = File.ReadAllText(PRJobFile);
			var Deserializer = new JavaScriptSerializer();
			return Deserializer.Deserialize<Dictionary<string, string>>(rawdata);
		}

		//text2file(json_encode())
		void SetCurrentPRList(IDictionary<string, string> list)
		{
			var Serializer = new JavaScriptSerializer();
			var rawdata = Serializer.Serialize(list);
			File.WriteAllText(PRJobFile, rawdata);
		}

		//public api
		public string MergePullRequest(int PRNumber)
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
					return result;
				SendMessage(String.Format("REPO: Merging PR #{0}...", PRNumber));
				try
				{
					//only supported with github
					if (!Repo.Network.Remotes.First().Url.Contains("github"))
						return "Only supported with Github based repositories.";


					var Refspec = new List<string>();
					var PRBranchName = String.Format("pr-{0}", PRNumber);
					var LocalBranchName = String.Format("pull/{0}/headrefs/heads/{1}", PRNumber, PRBranchName);
					Refspec.Add(String.Format("pull/{0}/head:{1}", PRNumber, PRBranchName));
					var logMessage = "";
					var fo = new FetchOptions() { OnTransferProgress = HandleTransferProgress, Prune = true };

					var branch = Repo.Branches[LocalBranchName];
					if(branch != null)
						//Need to delete the branch first in case of rebase
						Repo.Branches.Remove(branch);


					Commands.Fetch(Repo, "origin", Refspec, fo, logMessage);  //shitty api has no failure state for this

					currentProgress = -1;

					var Config = Properties.Settings.Default;


					branch = Repo.Branches[LocalBranchName];
					if (branch == null)
					{
						SendMessage("REPO: PR could not be fetched. Does it exist?");
						return String.Format("PR #{0} could not be fetched. Does it exist?", PRNumber);
					}

					//so we'll know if this fails
					var Result = MergeBranch(LocalBranchName);

					if (Result == null)
					{
						var CurrentPRs = GetCurrentPRList();
						var PRNumberString = PRNumber.ToString();
						CurrentPRs.Remove(PRNumberString);
						CurrentPRs.Add(PRNumberString, branch.Tip.Sha);
						SetCurrentPRList(CurrentPRs);
					}
					return Result;
				}
				catch (Exception E)
				{
					SendMessage("REPO: PR merge failed!");
					return E.ToString();
				}
			}
		}

		//public api
		public IDictionary<string, string> MergedPullRequests(out string error)
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
				{
					error = result;
					return null;
				}
				try
				{
					error = null;
					return GetCurrentPRList();
				}
				catch (Exception e)
				{
					error = e.ToString();
					return null;
				}
			}
		}

		//public api
		public string GetCommitterName()
		{
			lock (RepoLock)
			{
				return Properties.Settings.Default.CommitterName;
			}
		}

		//public api
		public void SetCommitterName(string newName)
		{
			lock (RepoLock)
			{
				Properties.Settings.Default.CommitterName = newName;
			}
		}

		//public api
		public string GetCommitterEmail()
		{
			lock (RepoLock)
			{
				return Properties.Settings.Default.CommitterEmail;
			}
		}

		//public api
		public void SetCommitterEmail(string newEmail)
		{
			lock (RepoLock)
			{
				Properties.Settings.Default.CommitterEmail = newEmail;
			}
		}

		//public api
		public string GetCredentialUsername()
		{
			lock (RepoLock)
			{
				return Properties.Settings.Default.CredentialUsername;
			}
		}

		//public api
		public void SetCredentials(string username, string password)
		{
			lock (RepoLock)
			{
				byte[] plaintext = Encoding.UTF8.GetBytes(password);

				// Generate additional entropy (will be used as the Initialization vector)
				byte[] entropy = new byte[20];
				using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
				{
					rng.GetBytes(entropy);
				}

				byte[] ciphertext = ProtectedData.Protect(plaintext, entropy, DataProtectionScope.CurrentUser);

				var Config = Properties.Settings.Default;
				Config.CredentialUsername = username;
				Config.CredentialEntropy = Convert.ToBase64String(entropy, 0, entropy.Length);
				Config.CredentialCyphertext = Convert.ToBase64String(ciphertext, 0, ciphertext.Length);
			}
		}

		//public api
		public string Commit(string message = "Automatic changelog compile, [ci skip]")
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
					return result;
				try
				{
					// Stage the file
					Commands.Stage(Repo, "*");

					// Create the committer's signature and commit
					var authorandcommitter = MakeSig();

					// Commit to the repository
					Repo.Commit(message, authorandcommitter, authorandcommitter);
					DeletePRList();
					return null;
				}
				catch (Exception e)
				{
					return e.ToString();
				}
			}
		}

		//public api
		public string Push()
		{
			lock (RepoLock)
			{
				var result = LoadRepo();
				if (result != null)
					return result;

				var Config = Properties.Settings.Default;
				try
				{
					byte[] plaintext;
					try
					{
						plaintext = ProtectedData.Unprotect(Convert.FromBase64String(Config.CredentialCyphertext), Convert.FromBase64String(Config.CredentialEntropy), DataProtectionScope.CurrentUser);
					}
					catch 
					{
						return "Git password decryption failed! Did you set one?";
					}

					var options = new PushOptions()
					{
						CredentialsProvider = new LibGit2Sharp.Handlers.CredentialsHandler(
						(url, usernameFromUrl, types) =>
							new UsernamePasswordCredentials()
							{
								Username = Config.CredentialUsername,
								Password = Encoding.UTF8.GetString(plaintext)
							})
					};
					Repo.Network.Push(Repo.Head, options);
					DeletePRList();
					return null;
				}
				catch (Exception e)
				{
					return e.ToString();
				}
			}
		}

		//public api
		public string GenerateChangelog(out string error)
		{
			return GenerateChangelogImpl(out error);
		}

		//impl proc just for single level recursion
		public string GenerateChangelogImpl(out string error, bool recurse = false)
		{
			const string ChangelogPy = RepoPath + "/tools/ss13_genchangelog.py";
			const string ChangelogHtml = RepoPath + "/html/changelog.html";
			const string ChangelogDir = RepoPath + "/html/changelogs";
			if (!Exists())
			{
				error = "Repo does not exist!";
				return null;
			}

			lock (RepoLock)
			{
				if (RepoBusy)
				{
					error = "Repo is busy!";
					return null;
				}
				if (!File.Exists(ChangelogPy))
				{
					error = "Missing changelog generation script!";
					return null;
				}
				if (!File.Exists(ChangelogHtml))
				{
					error = "Missing changelog html!";
					return null;
				}
				if (!Directory.Exists(ChangelogDir))
				{
					error = "Missing auto changelog directory!";
					return null;
				}

				var Config = Properties.Settings.Default;

				var PythonFile = Config.PythonPath + "/python.exe";
				if (!File.Exists(PythonFile))
				{
					error = "Cannot locate python 2.7!";
					return null;
				}
				try
				{
					string result;
					int exitCode;
					using (var python = new Process())
					{
						python.StartInfo.FileName = PythonFile;
						python.StartInfo.Arguments = String.Format("{0} {1} {2}", ChangelogPy, ChangelogHtml, ChangelogDir);
						python.StartInfo.UseShellExecute = false;
						python.StartInfo.RedirectStandardOutput = true;
						python.Start();
						using (StreamReader reader = python.StandardOutput)
						{
							result = reader.ReadToEnd();

						}
						python.WaitForExit();
						exitCode = python.ExitCode;
					}
					if (exitCode != 0)
					{
						if (recurse)
						{
							error = "Script failed!";
							return result;
						}
						//update pip deps and try again

						string PipFile = Config.PythonPath + "/scripts/pip.exe";
						bool runningBSoup = false;
						while (true)
							using (var pip = new Process())
							{
								pip.StartInfo.FileName = PipFile;
								pip.StartInfo.Arguments = !runningBSoup ? "install PyYaml" : "install beautifulsoup4";
								pip.StartInfo.UseShellExecute = false;
								pip.StartInfo.RedirectStandardOutput = true;
								pip.Start();
								using (StreamReader reader = pip.StandardOutput)
								{
									result += "\r\n---BEGIN-PIP-OUTPUT---\r\n" + reader.ReadToEnd();
								}
								pip.WaitForExit();
								if (pip.ExitCode != 0)
								{
									error = "Script and pip failed!";
									return result;
								}

								if (runningBSoup)
									break;
								else
									runningBSoup = true;
							}
						//and recurse
						return GenerateChangelogImpl(out error, true);
					}
					error = null;
					return result;
				}
				catch (Exception e)
				{
					error = e.ToString();
					return null;
				}
			}
		}

		//public api
		public bool SetPythonPath(string path)
		{
			if (!Directory.Exists(path))
				return false;
			Properties.Settings.Default.PythonPath = Path.GetFullPath(path);
			return true;
		}
	}
}
