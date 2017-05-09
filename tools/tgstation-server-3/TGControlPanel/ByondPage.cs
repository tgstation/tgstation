using System;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{
	partial class Main
	{
		string lastReadError = null;
		void InitBYONDPage()
		{
			var BYOND = Server.GetComponent<ITGByond>();
			var CV = BYOND.GetVersion(false);
			if (CV == null)
				CV = BYOND.GetVersion(true);
			if (CV != null)
			{
				var splits = CV.Split('.');
				if(splits.Length == 2)
				{
					try
					{
						var Major = Convert.ToInt32(splits[0]);
						var Minor = Convert.ToInt32(splits[1]);
						MajorVersionNumeric.Value = Major;
						MinorVersionNumeric.Value = Minor;
					}
					catch { }
				}
			}

			UpdateBYONDButtons();
			BYONDTimer.Start();
		}
		private void UpdateButton_Click(object sender, EventArgs e)
		{
			UpdateBYONDButtons();
			if (!Server.GetComponent<ITGByond>().UpdateToVersion((int)MajorVersionNumeric.Value, (int)MinorVersionNumeric.Value))
				MessageBox.Show("Unable to begin update, there is another operation in progress.");
		}

		void UpdateBYONDButtons()
		{
			var BYOND = Server.GetComponent<ITGByond>();

			VersionLabel.Text = BYOND.GetVersion(false) ?? "Not Installed";

			StagedVersionTitle.Visible = false;
			StagedVersionLabel.Visible = false;
			switch (BYOND.CurrentStatus())
			{
				case TGByondStatus.Idle:
				case TGByondStatus.Starting:
					UpdateProgressBar.Value = 0;
					StatusLabel.Text = "Idle";
					UpdateButton.Enabled = true;
					UpdateProgressBar.Style = ProgressBarStyle.Blocks;
					break;
				case TGByondStatus.Downloading:
					UpdateProgressBar.Value = 50;
					StatusLabel.Text = "Downloading...";
					UpdateButton.Enabled = false;
					UpdateProgressBar.Style = ProgressBarStyle.Blocks;
					break;
				case TGByondStatus.Staging:
					UpdateProgressBar.Value = 100;
					StatusLabel.Text = "Staging...";
					UpdateButton.Enabled = false;
					UpdateProgressBar.Style = ProgressBarStyle.Blocks;
					break;
				case TGByondStatus.Staged:
					StagedVersionTitle.Visible = true;
					StagedVersionLabel.Visible = true;
					StagedVersionLabel.Text = BYOND.GetVersion(true) ?? "Unknown";
					if (UpdateProgressBar.Style != ProgressBarStyle.Marquee || UpdateProgressBar.MarqueeAnimationSpeed != 50)						
					{
						UpdateProgressBar.Style = ProgressBarStyle.Marquee;
						UpdateProgressBar.MarqueeAnimationSpeed = 50;
					}
					StatusLabel.Text = "Staged and waiting for BYOND to shutdown...";
					UpdateButton.Enabled = true;
					break;
				case TGByondStatus.Updating:
					UpdateProgressBar.Style = ProgressBarStyle.Marquee;
					UpdateProgressBar.MarqueeAnimationSpeed = 200;
					StatusLabel.Text = "Applying update...";
					UpdateButton.Enabled = false;
					break;
			}
		}

		private void BYONDTimer_Tick(object sender, EventArgs e)
		{
			UpdateBYONDButtons();
			var error = Server.GetComponent<ITGByond>().GetError();
			if(error != lastReadError)
			{
				lastReadError = error;
				if(error != null)
					MessageBox.Show("An error occurred: " + lastReadError);
			}
		}
	}
}
