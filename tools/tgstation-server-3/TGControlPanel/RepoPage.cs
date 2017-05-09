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
			Commit,
			Push,
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
			var Repo = Server.GetComponent<ITGRepository>();
			PopulateRepoFields();
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

			if (!Repo.Exists())
			{
				//repo unavailable
				RepoProgressBarLabel.Text = "Unable to locate repository";
				CloneRepositoryButton.Visible = true;
			}
			else
			{
				RepoProgressBarLabel.Visible = false;

				CurrentRevisionLabel.Visible = true;
				CurrentRevisionTitle.Visible = true;
				IdentityLabel.Visible = true;
				CommiterNameTitle.Visible = true;
				CommitterEmailTitle.Visible = true;
				RepoCommitterNameTextBox.Visible = true;
				RepoEmailTextBox.Visible = true;
				MergePRButton.Visible = true;
				TestMergeListLabel.Visible = true;
				TestMergeListTitle.Visible = true;
				UpdateRepoButton.Visible = true;
				HardReset.Visible = true;
				RepoApplyButton.Visible = true;
				TestmergeSelector.Visible = true;
				CommiterLoginTitle.Visible = true;
				CommitterPasswordTitle.Visible = true;
				CommitterPasswordTextBox.Visible = true;
				CommitterLoginTextBox.Visible = true;
				RepoGenChangelogButton.Visible = true;
				RepoCommitButton.Visible = true;
				RepoPushButton.Visible = true;

				CurrentRevisionLabel.Text = Repo.GetHead(out string error) ?? "Unknown";
				RepoRemoteTextBox.Text = Repo.GetRemote(out error) ?? "Unknown";
				RepoBranchTextBox.Text = Repo.GetBranch(out error) ?? "Unknown";
				CommitterLoginTextBox.Text = Repo.GetCredentialUsername() ?? "Unknown";
				RepoCommitterNameTextBox.Text = Repo.GetCommitterName() ?? "Unknown";
				RepoEmailTextBox.Text = Repo.GetCommitterEmail() ?? "Unknown";


				var PRs = Repo.MergedPullRequests(out error);
				if(PRs != null)
				{
					if (PRs.Count == 0)
						TestMergeListLabel.Text = "None";
					else
					{
						TestMergeListLabel.Text = "";
						foreach (var I in PRs)
							TestMergeListLabel.Text += String.Format("#{0} at commit {1}\r\n", I.Key, I.Value);
					}
				}
				else
					TestMergeListLabel.Text = "Unknown";

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
					repoError = Repo.Setup(CloneRepoURL, CheckoutBranch) ? null : "The repository is currently undergoing an operation. Please wait for it to complete.";
					break;
				case RepoAction.Checkout:
					repoError = Repo.Checkout(CheckoutBranch);
					break;
				case RepoAction.Merge:
					repoError = Repo.Update(false);
					break;
				case RepoAction.Reset:
					repoError = Repo.Reset();
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
				case RepoAction.Commit:
					repoError = Repo.Commit();
					break;
				case RepoAction.Push:
					repoError = Repo.Push();
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

		private void CloneRepositoryButton_Click(object sender, EventArgs e)
		{
			CloneRepoURL = RepoRemoteTextBox.Text;
			CheckoutBranch = RepoBranchTextBox.Text;

			DoAsyncOp(RepoAction.Clone, String.Format("Cloning {0} branch of {1}...", CheckoutBranch, CloneRepoURL));
		}
		void DoAsyncOp(RepoAction ra, string message)
		{
			if (ra != RepoAction.Wait && RepoBusyCheck())
				return;

			CurrentRevisionLabel.Visible = false;
			CurrentRevisionTitle.Visible = false;
			CommiterNameTitle.Visible = false;
			CommitterEmailTitle.Visible = false;
			RepoCommitterNameTextBox.Visible = false;
			RepoEmailTextBox.Visible = false;
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
			CommiterLoginTitle.Visible = false;
			CommitterPasswordTitle.Visible = false;
			CommitterPasswordTextBox.Visible = false;
			CommitterLoginTextBox.Visible = false;
			RepoGenChangelogButton.Visible = false;
			RepoCommitButton.Visible = false;
			RepoPushButton.Visible = false;

			RepoPanel.UseWaitCursor = true;

			RepoProgressBar.Value = 0;
			RepoProgressBar.Style = System.Windows.Forms.ProgressBarStyle.Marquee;

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

				Repo.SetCommitterName(RepoCommitterNameTextBox.Text);
				Repo.SetCommitterEmail(RepoEmailTextBox.Text);
				if (CommitterPasswordTextBox.Text != "hunter2butseriouslyyoubetterfuckingrenamethis")
				{
					Repo.SetCredentials(CommitterLoginTextBox.Text, CommitterPasswordTextBox.Text);
					CommitterPasswordTextBox.Text = "hunter2butseriouslyyoubetterfuckingrenamethis";
				}
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
			DoAsyncOp(RepoAction.Update, "Updating and resetting to origin branch...");
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

		private void RepoCommitButton_Click(object sender, System.EventArgs e)
		{
			DoAsyncOp(RepoAction.Commit, "Committing changes...");
		}

		private void RepoPushButton_Click(object sender, System.EventArgs e)
		{
			DoAsyncOp(RepoAction.Push, "Pushing changes...");
		}
	}
}
