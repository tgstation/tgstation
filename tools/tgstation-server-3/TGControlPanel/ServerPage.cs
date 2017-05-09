using System;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{
	partial class Main
	{
		enum FullUpdateAction
		{
			UpdateHard,
			UpdateMerge,
			UpdateHardTestmerge,
			Testmerge,
		}

		FullUpdateAction fuAction;
		int testmergePR;
		string updateError;
		bool updatingPort = true;

		string DDStatusString = null;
		void InitServerPage()
		{
			LoadServerPage();
			ServerTimer.Start();
			WorldStatusChecker.RunWorkerAsync();
			WorldStatusChecker.RunWorkerCompleted += WorldStatusChecker_RunWorkerCompleted;
			FullUpdateWorker.RunWorkerCompleted += FullUpdateWorker_RunWorkerCompleted;
		}

		private void FullUpdateWorker_RunWorkerCompleted(object sender, System.ComponentModel.RunWorkerCompletedEventArgs e)
		{
			if (updateError != null)
				MessageBox.Show(updateError);
			UpdateHardButton.Enabled = true;
			UpdateMergeButton.Enabled = true;
			TestmergeButton.Enabled = true;
			UpdateTestmergeButton.Enabled = true;
			LoadServerPage();
			ServerTimer.Start();
		}

		private void WorldStatusChecker_RunWorkerCompleted(object sender, System.ComponentModel.RunWorkerCompletedEventArgs e)
		{
			if (DDStatusString != "Topic recieve error!" || ServerStatusLabel.Text == "OFFLINE")
				ServerStatusLabel.Text = DDStatusString;
			WorldStatusTimer.Start();
		}

		void LoadServerPage()
		{
			var DM = Server.GetComponent<ITGCompiler>();
			var DD = Server.GetComponent<ITGDreamDaemon>();

			AutostartCheckbox.Checked = DD.Autostart();
			updatingPort = true;
			PortSelector.Value = DD.Port();
			updatingPort = false;

			switch (DM.GetStatus())
			{
				case TGCompilerStatus.Compiling:
					CompilerStatusLabel.Text = "Compiling...";
					compilerProgressBar.Style = ProgressBarStyle.Marquee;
					compileButton.Enabled = false;
					initializeButton.Enabled = false;
					break;
				case TGCompilerStatus.Initializing:
					CompilerStatusLabel.Text = "Initializing...";
					compilerProgressBar.Style = ProgressBarStyle.Marquee;
					compileButton.Enabled = false;
					initializeButton.Enabled = false;
					break;
				case TGCompilerStatus.Initialized:
					CompilerStatusLabel.Text = "Idle";
					compilerProgressBar.Style = ProgressBarStyle.Blocks;
					initializeButton.Enabled = true;
					compileButton.Enabled = true;
					break;
				case TGCompilerStatus.Uninitialized:
					CompilerStatusLabel.Text = "Uninitialized";
					compilerProgressBar.Style = ProgressBarStyle.Blocks;
					compileButton.Enabled = false;
					initializeButton.Enabled = true;
					break;
				default:
					CompilerStatusLabel.Text = "Unknown!";
					compilerProgressBar.Style = ProgressBarStyle.Blocks;
					initializeButton.Enabled = true;
					compileButton.Enabled = true;
					break;
			}
			var error = DM.CompileError();
			if (error != null)
				MessageBox.Show("Error: " + error);
		}

		private void ServerTimer_Tick(object sender, System.EventArgs e)
		{
			LoadServerPage();
		}

		private void PortSelector_ValueChanged(object sender, EventArgs e)
		{
			if(!updatingPort)
				Server.GetComponent<ITGDreamDaemon>().SetPort((ushort)PortSelector.Value);
		}

		private void RunServerUpdate(FullUpdateAction fua, int tm = 0)
		{
			if (FullUpdateWorker.IsBusy)
				return;
			testmergePR = tm;
			fuAction = fua;
			initializeButton.Enabled = false;
			compileButton.Enabled = false;
			UpdateHardButton.Enabled = false;
			UpdateMergeButton.Enabled = false;
			TestmergeButton.Enabled = false;
			UpdateTestmergeButton.Enabled = false;
			compilerProgressBar.Style = ProgressBarStyle.Marquee;
			switch (fuAction)
			{
				case FullUpdateAction.Testmerge:
					CompilerStatusLabel.Text = String.Format("Testmerging pull request #{0}...", testmergePR);
					break;
				case FullUpdateAction.UpdateHard:
					CompilerStatusLabel.Text = String.Format("Updating Server (RESET)...");
					break;
				case FullUpdateAction.UpdateMerge:
					CompilerStatusLabel.Text = String.Format("Updating Server (MERGE)...");
					break;
				case FullUpdateAction.UpdateHardTestmerge:
					CompilerStatusLabel.Text = String.Format("Updating and testmerging pull request #{0}...", testmergePR);
					break;
			}
			ServerTimer.Stop();
			FullUpdateWorker.RunWorkerAsync();
		}

		private void InitializeButton_Click(object sender, EventArgs e)
		{
			if (!Server.GetComponent<ITGCompiler>().Initialize())
				MessageBox.Show("Unable to start initialization!");
		}
		private void CompileButton_Click(object sender, EventArgs e)
		{
			if(!Server.GetComponent<ITGCompiler>().Compile())
				MessageBox.Show("Unable to start compilation!");
		}
		//because of lol byond this can take some time...
		private void WorldStatusChecker_DoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
		{
			DDStatusString = Server.GetComponent<ITGDreamDaemon>().StatusString();
		}

		private void WorldStatusTimer_Tick(object sender, System.EventArgs e)
		{
			WorldStatusTimer.Stop();
			WorldStatusChecker.RunWorkerAsync();
		}

		private void AutostartCheckbox_CheckedChanged(object sender, System.EventArgs e)
		{
			var DD = Server.GetComponent<ITGDreamDaemon>();
			if(DD.Autostart() != AutostartCheckbox.Checked)
				DD.SetAutostart(AutostartCheckbox.Checked);
		}
		private void ServerStartButton_Click(object sender, System.EventArgs e)
		{
			var res = Server.GetComponent<ITGDreamDaemon>().Start();
			if (res != null)
				MessageBox.Show(res);
		}

		private void ServerStopButton_Click(object sender, System.EventArgs e)
		{
			var DialogResult = MessageBox.Show("This will immediately shut down the server. Continue?", "Confim", MessageBoxButtons.YesNo);
			if (DialogResult == DialogResult.No)
				return;
			var res = Server.GetComponent<ITGDreamDaemon>().Stop();
			if (res != null)
				MessageBox.Show(res);
		}

		private void ServerRestartButton_Click(object sender, System.EventArgs e)
		{
			var DialogResult = MessageBox.Show("This will immediately restart the server. Continue?", "Confim", MessageBoxButtons.YesNo);
			if (DialogResult == DialogResult.No)
				return;
			var res = Server.GetComponent<ITGDreamDaemon>().Restart();
			if (res != null)
				MessageBox.Show(res);
		}

		private void ServerGStopButton_Click(object sender, System.EventArgs e)
		{
			var DialogResult = MessageBox.Show("This will shut down the server when the current round ends. Continue?", "Confim", MessageBoxButtons.YesNo);
			if (DialogResult == DialogResult.No)
				return;
			Server.GetComponent<ITGDreamDaemon>().RequestStop();
		}

		private void ServerGRestartButton_Click(object sender, System.EventArgs e)
		{
			var DialogResult = MessageBox.Show("This will restart the server when the current round ends. Continue?", "Confim", MessageBoxButtons.YesNo);
			if (DialogResult == DialogResult.No)
				return;
			Server.GetComponent<ITGDreamDaemon>().RequestRestart();
		}
		private void FullUpdateWorker_DoWork(object sender, System.ComponentModel.DoWorkEventArgs e)
		{
			var Updater = Server.GetComponent<ITGServerUpdater>();
			switch (fuAction)
			{
				case FullUpdateAction.Testmerge:
					updateError = Updater.UpdateServer(TGRepoUpdateMethod.None, false, (ushort)testmergePR);
					break;
				case FullUpdateAction.UpdateHard:
					updateError = Updater.UpdateServer(TGRepoUpdateMethod.Hard, true);
					break;
				case FullUpdateAction.UpdateHardTestmerge:
					updateError = Updater.UpdateServer(TGRepoUpdateMethod.Hard, true, (ushort)testmergePR);
					break;
				case FullUpdateAction.UpdateMerge:
					updateError = Updater.UpdateServer(TGRepoUpdateMethod.Merge, true, (ushort)testmergePR);
					break;
			}
		}
		private void UpdateHardButton_Click(object sender, System.EventArgs e)
		{
			RunServerUpdate(FullUpdateAction.UpdateHard);
		}

		private void UpdateTestmergeButton_Click(object sender, System.EventArgs e)
		{
			RunServerUpdate(FullUpdateAction.UpdateHardTestmerge, (int)TestmergeSelector.Value);
		}

		private void UpdateMergeButton_Click(object sender, System.EventArgs e)
		{
			RunServerUpdate(FullUpdateAction.UpdateMerge);
		}
		private void TestmergeButton_Click(object sender, System.EventArgs e)
		{
			RunServerUpdate(FullUpdateAction.Testmerge, (int)TestmergeSelector.Value);
		}
	}
}
