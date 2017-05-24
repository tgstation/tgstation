using System;
using System.ComponentModel;
using System.Windows.Forms;
using System.Threading;
using TGServiceInterface;

namespace TGControlPanel
{
	partial class Main
	{
		enum RepoAction {
			Clone,
			Checkout,
			Update,
			Merge,
			Reset,
			Test,
			Wait,
			GenCL,
		}

		RepoAction action;
		string CloneRepoURL;
		string CheckoutBranch;
		int TestPR;

		string repoError;

		private void InitRepoPage()
		{
			RepoBGW.ProgressChanged += RepoBGW_ProgressChanged;
			RepoBGW.RunWorkerCompleted += RepoBGW_RunWorkerCompleted;
			RepoBGW.DoWork += RepoBGW_DoWork;
			BackupTagsList.MouseDoubleClick += BackupTagsList_MouseDoubleClick;
			PopulateRepoFields();
		}

		private void BackupTagsList_MouseDoubleClick(object sender, MouseEventArgs e)
		{
			int index = BackupTagsList.IndexFromPoint(e.Location);
			if (index != ListBox.NoMatches)
			{
				var indexText = (string)BackupTagsList.Items[index];
				if (indexText == "None" || indexText == "Unknown")
					return;
				var tagname = indexText.Split(':')[0];
				var spaceSplits = indexText.Split(' ');
				var sha = spaceSplits[spaceSplits.Length - 1];

				if (MessageBox.Show(String.Format("Checkout tag {0} ({1})?", tagname, sha), "Restore Backup", MessageBoxButtons.YesNo) != DialogResult.Yes)
					return;

				CheckoutBranch = tagname;
				DoAsyncOp(RepoAction.Checkout, "Checking out " + tagname + "...");
			}
		}

		private void RepoBGW_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
		{
			RepoProgressBar.Value = 100;
			RepoProgressBar.Style = ProgressBarStyle.Blocks;
			RepoPanel.UseWaitCursor = false;
			PopulateRepoFields();
		}

		private void PopulateRepoFields()
		{
			if (repoError != null)
				MessageBox.Show("An error occured: " + repoError);

			if (RepoBusyCheck())
				return;

			var Repo = Server.GetComponent<ITGRepository>();

			RepoProgressBar.Style = ProgressBarStyle.Marquee;
			RepoProgressBar.Visible = false;
			RemoteNameTitle.Visible = true;
			RepoRemoteTextBox.Visible = true;
			BranchNameTitle.Visible = true;
			RepoBranchTextBox.Visible = true;
			PythonPathLabel.Visible = true;
			PythonPathText.Visible = true;
			PythonPathText.Text = Repo.PythonPath();

			if (!Repo.Exists())
			{
				//repo unavailable
				RepoRemoteTextBox.Text = "https://github.com/tgstation/tgstation";
				RepoBranchTextBox.Text = "master";
				RepoProgressBarLabel.Text = "Unable to locate repository";
				CloneRepositoryButton.Visible = true;
			}
			else
			{
				RepoProgressBarLabel.Visible = false;

				CurrentRevisionLabel.Visible = true;
				CurrentRevisionTitle.Visible = true;
				IdentityLabel.Visible = true;
				MergePRButton.Visible = true;
				TestMergeListLabel.Visible = true;
				TestMergeListTitle.Visible = true;
				UpdateRepoButton.Visible = true;
				BackupTagsList.Visible = true;
				HardReset.Visible = true;
				RepoApplyButton.Visible = true;
				TestmergeSelector.Visible = true;
				RepoGenChangelogButton.Visible = true;
				RecloneButton.Visible = true;
				ResetRemote.Visible = true;

				CurrentRevisionLabel.Text = Repo.GetHead(out string error) ?? "Unknown";
				RepoRemoteTextBox.Text = Repo.GetRemote(out error) ?? "Unknown";
				RepoBranchTextBox.Text = Repo.GetBranch(out error) ?? "Unknown";

				var Backups = Repo.ListBackups(out error);
				BackupTagsList.Items.Clear();
				if (Backups != null)
				{
					if (Backups.Count == 0)
						BackupTagsList.Items.Add("None");
					else
						foreach (var I in Backups)
							BackupTagsList.Items.Add(I.Key + ": " + I.Value);
				}
				else
					BackupTagsList.Items.Add("Unknown");

				var PRs = Repo.MergedPullRequests(out error);
				TestMergeListLabel.Items.Clear();
				if (PRs != null)
					if (PRs.Count == 0)
						TestMergeListLabel.Items.Add("None");
					else
						foreach (var I in PRs)
							TestMergeListLabel.Items.Add(String.Format("#{0}: {2} by {3} at commit {1}\r\n", I.Number, I.Sha, I.Title, I.Author));
				else
					TestMergeListLabel.Items.Add("Unknown");
			}
		}

		bool RepoBusyCheck()
		{
			if (Server.GetComponent<ITGRepository>().OperationInProgress())
			{
				DoAsyncOp(RepoAction.Wait, "Waiting for repository to finish another action...");
				return true;
			}
			return false;
		}
		private void RepoBGW_ProgressChanged(object sender, ProgressChangedEventArgs e)
		{
			var val = e.ProgressPercentage;
			if (val < 0)
			{
				RepoProgressBar.Style = ProgressBarStyle.Marquee;
				return;
			}
			RepoProgressBar.Style = ProgressBarStyle.Blocks;
			RepoProgressBar.Value = val;
		}

		private void RepoBGW_DoWork(object sender, DoWorkEventArgs e)
		{
			//Only for clones
			var Repo = Server.GetComponent<ITGRepository>();

			switch (action) {
				case RepoAction.Clone:
					repoError = Repo.Setup(CloneRepoURL, CheckoutBranch);
					break;
				case RepoAction.Checkout:
					repoError = Repo.Checkout(CheckoutBranch);
					break;
				case RepoAction.Merge:
					repoError = Repo.Update(false);
					break;
				case RepoAction.Reset:
					repoError = Repo.Reset(true);
					break;
				case RepoAction.Test:
					repoError = Repo.MergePullRequest(TestPR);
					break;
				case RepoAction.Update:
					repoError = Repo.Update(true);
					break;
				case RepoAction.Wait:
					break;
				case RepoAction.GenCL:
					var result = Repo.GenerateChangelog(out repoError);
					if(repoError != null)
						repoError += ": " + result;
					break;
				default:
					//reeee
					return;
			}

			do
			{
				Thread.Sleep(1000);
				RepoBGW.ReportProgress(Repo.CheckoutProgress());
			} while (Repo.OperationInProgress());
		}
		void UpdatePythonPath()
		{
			if (!Server.GetComponent<ITGRepository>().SetPythonPath(PythonPathText.Text))
				MessageBox.Show("Python could not be found in the selected location!");
		}
		private void CloneRepositoryButton_Click(object sender, EventArgs e)
		{
			CloneRepo();
		}

		void CloneRepo()
		{
			CloneRepoURL = RepoRemoteTextBox.Text;
			CheckoutBranch = RepoBranchTextBox.Text;
			UpdatePythonPath();

			DoAsyncOp(RepoAction.Clone, String.Format("Cloning {0} branch of {1}...", CheckoutBranch, CloneRepoURL));
		}
		private void RecloneButton_Click(object sender, EventArgs e)
		{
			var DialogResult = MessageBox.Show("This will re-clone the repository, backup, and reset the Static configuration folders. Continue?", "Confim", MessageBoxButtons.YesNo);
			if (DialogResult == DialogResult.No)
				return;
			CloneRepo();
		}
		void DoAsyncOp(RepoAction ra, string message)
		{
			if (ra != RepoAction.Wait && RepoBusyCheck())
				return;

			CurrentRevisionLabel.Visible = false;
			CurrentRevisionTitle.Visible = false;
			TestMergeListLabel.Visible = false;
			TestMergeListTitle.Visible = false;
			RepoApplyButton.Visible = false;
			UpdateRepoButton.Visible = false;
			MergePRButton.Visible = false;
			CloneRepositoryButton.Visible = false;
			RemoteNameTitle.Visible = false;
			RepoRemoteTextBox.Visible = false;
			BranchNameTitle.Visible = false;
			RepoBranchTextBox.Visible = false;
			RepoProgressBar.Visible = true;
			HardReset.Visible = false;
			IdentityLabel.Visible = false;
			TestmergeSelector.Visible = false;
			RepoGenChangelogButton.Visible = false;
			PythonPathLabel.Visible = false;
			PythonPathText.Visible = false;
			RecloneButton.Visible = false;
			ResetRemote.Visible = false;
			BackupTagsList.Visible = false;

			RepoPanel.UseWaitCursor = true;

			RepoProgressBar.Value = 0;
			RepoProgressBar.Style = ProgressBarStyle.Marquee;

			RepoProgressBarLabel.Text = message;
			RepoProgressBarLabel.Visible = true;

			action = ra;
			repoError = null;

			RepoBGW.RunWorkerAsync();
		}
		private void RepoApplyButton_Click(object sender, EventArgs e)
		{
			var Repo = Server.GetComponent<ITGRepository>();

			if (RepoBusyCheck())
				return;

			var remote = Repo.GetRemote(out string error);
			if (remote == null) {
				MessageBox.Show("Error: " + error);
				return;
			}
	
			var Reclone = remote != RepoRemoteTextBox.Text;
			if (Reclone)
			{
				var DialogResult = MessageBox.Show("Changing the remote URL requires a re-cloning of the repository. Continue?", "Confim", MessageBoxButtons.YesNo);
				if (DialogResult == DialogResult.No)
					return;
			}

			if (!Reclone)
			{
				var branch = Repo.GetBranch(out error);
				if(branch == null)
				{
					MessageBox.Show("Error: " + error);
					return;
				}
				
				CheckoutBranch = RepoBranchTextBox.Text;
				if(branch != CheckoutBranch)
					DoAsyncOp(RepoAction.Checkout, String.Format("Checking out {0}...", CheckoutBranch));
				
				UpdatePythonPath();
			}
			else
				CloneRepositoryButton_Click(null, null);
		}
		private void UpdateRepoButton_Click(object sender, EventArgs e)
		{
			DoAsyncOp(RepoAction.Merge, "Merging origin branch...");
		}

		private void HardReset_Click(object sender, EventArgs e)
		{
			DoAsyncOp(RepoAction.Reset, "Resetting to origin branch...");
		}
		
		private void ResetRemote_Click(object sender, EventArgs e)
		{
			DoAsyncOp(RepoAction.Update, "Updating and resetting to remote branch...");
		}

		private void TestMergeButton_Click(object sender, EventArgs e)
		{
			if (TestmergeSelector.Value == 0)
			{
				MessageBox.Show("Invalid PR number!");
				return;
			}
			TestPR = (int)TestmergeSelector.Value;
			DoAsyncOp(RepoAction.Test, String.Format("Merging latest commit of PR #{0}...", TestPR));
		}

		private void RepoGenChangelogButton_Click(object sender, System.EventArgs e)
		{
			DoAsyncOp(RepoAction.GenCL, "Generating changelog...");
		}
	}
}
