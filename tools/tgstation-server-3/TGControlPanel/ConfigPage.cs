using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{

	partial class Main
	{
		enum ConfigIndex
		{
			Config = 0,
			Database = 1,
			Game = 2,
			Jobs = 3,
			Maps = 4,
			Admins = 5,
		}

		IList<ConfigSetting> GeneralChangelist, DatabaseChangelist, GameChangelist;
		IList<JobSetting> JobsChangelist;
		IList<MapSetting> MapsChangelist;

		FlowLayoutPanel ConfigConfigFlow, DatabaseConfigFlow, GameConfigFlow, JobsConfigFlow, MapsConfigFlow;

		bool updatingAdminPerms = false;

		FlowLayoutPanel CreateFLP(Control parent)
		{
			var res = new FlowLayoutPanel()
			{
				AutoSize = true,
				FlowDirection = FlowDirection.TopDown,
			};
			AdjustFlow(res, parent);
			parent.Controls.Add(res);
			return res;
		}
		void AdjustFlow(FlowLayoutPanel flow, Control parent)
		{
			flow.MaximumSize = new Size(parent.Width - 90, 9999999);
		}
		void InitConfigPage()
		{
			ConfigPanels.SelectedIndex = Properties.Settings.Default.LastConfigPageIndex;
			ConfigApply.Enabled = (ConfigIndex)ConfigPanels.SelectedIndex != ConfigIndex.Admins;
			ConfigPanels.SelectedIndexChanged += ConfigPanels_SelectedIndexChanged;

			Resize += ReadjustFlow;

			ConfigConfigFlow = CreateFLP(ConfigConfigPanel);
			GeneralChangelist = new List<ConfigSetting>();

			DatabaseConfigFlow = CreateFLP(DatabaseConfigPanel);
			DatabaseChangelist = new List<ConfigSetting>();

			GameConfigFlow = CreateFLP(GameConfigPanel);
			GameChangelist = new List<ConfigSetting>();

			JobsConfigFlow = CreateFLP(JobsConfigPanel);
			JobsChangelist = new List<JobSetting>();

			MapsConfigFlow = CreateFLP(MapsConfigPanel);
			MapsChangelist = new List<MapSetting>();

			AdminRanksListBox.SelectedIndexChanged += AdminRanksListBox_SelectedIndexChanged;
			PermissionsListBox.ItemCheck += AdjustCurrentRankPermissions;
			NegativePermissions.ItemCheck += AdjustCurrentRankPermissions;

			LoadConfig();
		}
		void LoadConfig()
		{
			var RepoReady = Server.GetComponent<ITGRepository>().Exists();
			ConfigPanels.Visible = RepoReady;
			ConfigApply.Visible = RepoReady;
			ConfigDownload.Visible = RepoReady;
			ConfigDownloadRepo.Visible = RepoReady;
			ConfigUpload.Visible = RepoReady;
			if (!RepoReady)
				return;
			LoadGenericConfig(TGConfigType.General);
			LoadGenericConfig(TGConfigType.Database);
			LoadGenericConfig(TGConfigType.Game);
			LoadJobsConfig();
			LoadMapsConfig();
			LoadAdminsConfig();
		}

		private void RemoveRankButton_Click(object sender, EventArgs e)
		{
			var rank = (string)AdminRanksListBox.SelectedItem;
			var result = Server.GetComponent<ITGConfig>().RemoveAdminRank(rank);
			if (result != null)
				MessageBox.Show("Error: " + result);
			LoadRanksList();
		}

		private void AddRankButton_Click(object sender, EventArgs e)
		{
			var result = Server.GetComponent<ITGConfig>().SetAdminRank(AddRankTextBox.Text, new Dictionary<string, bool>());
			if (result != null)
				MessageBox.Show("Error: " + result);
			else
				AddRankTextBox.Text = "";
			LoadRanksList();
		}

		private void ApplyAdminRankButton_Click(object sender, EventArgs e)
		{
			var rank = (string)AdminRanksListBox.SelectedItem;
			var admin = (string)AdminsListBox.SelectedItem;
			if(rank == null || admin == null)
			{
				MessageBox.Show("Please select a rank and admin!");
				return;
			}
			admin = admin.Split(' ')[0];
			var result = Server.GetComponent<ITGConfig>().Addmin(admin, rank);
			if (result != null)
				MessageBox.Show("Error: " + result);
			LoadAdminsList();
		}

		private void DeadminButton_Click(object sender, EventArgs e)
		{
			var selectedAdmin = (string)AdminsListBox.SelectedItem;
			if(selectedAdmin == null)
			{
				MessageBox.Show("You must select an admin first!");
				return;
			}
			var result = Server.GetComponent<ITGConfig>().Deadmin(selectedAdmin.Split(' ')[0]);
			if (result != null)
				MessageBox.Show("Error: " + result);
			LoadAdminsList();
		}

		private void AddminButton_Click(object sender, EventArgs e)
		{
			var rank = (string)AdminRanksListBox.SelectedItem;
			if(rank == null)
			{
				MessageBox.Show("You must select a rank first!");
				return;
			}
			var result = Server.GetComponent<ITGConfig>().Addmin(AddminTextBox.Text, rank);
			if (result != null)
				MessageBox.Show("Error: " + result);
			else
				AddminTextBox.Text = "";
			LoadAdminsList();
		}
		private void AdjustCurrentRankPermissions(object sender, ItemCheckEventArgs e)
		{
			if (updatingAdminPerms)
				return;
			if (AdminRanksListBox.SelectedIndex == -1)
			{
				MessageBox.Show("No admin rank selected!");
				return;
			}
			var perms = new Dictionary<string, bool>();
			for (var I = 0; I < PermissionsListBox.Items.Count; ++I)
			{
				var negChecked = NegativePermissions.GetItemChecked(I) || (sender == NegativePermissions && e.Index == I && e.NewValue == CheckState.Checked);
				var posChecked = PermissionsListBox.GetItemChecked(I) || (sender == PermissionsListBox && e.Index == I && e.NewValue == CheckState.Checked);
				var perm = ((string)PermissionsListBox.Items[I]).Split(' ')[0];
				if (posChecked ^ negChecked)
					perms.Add(perm, posChecked);
			}

			var result = Server.GetComponent<ITGConfig>().SetAdminRank((string)AdminRanksListBox.SelectedItem, perms);
			if (result != null)
				MessageBox.Show("Error: " + result);
			UpdatePermissionsDisplay();
		}

		private void AdminRanksListBox_SelectedIndexChanged(object sender, EventArgs e)
		{
			UpdatePermissionsDisplay();
		}
		void UpdatePermissionsDisplay() { 
			var rank = (string)AdminRanksListBox.SelectedItem;
			var ranks = Server.GetComponent<ITGConfig>().AdminRanks(out string error);
			if (ranks != null && !ranks.ContainsKey(rank))
				error = "Could not find rank: " + rank + "!";
			if (error != null)
			{
				MessageBox.Show("Error: " + error);
				return;
			}
			var ourRank = ranks[rank];
			updatingAdminPerms = true;
			for (var I = 0; I < PermissionsListBox.Items.Count; ++I)
			{
				PermissionsListBox.SetItemChecked(I, false);
				NegativePermissions.SetItemChecked(I, false);
			}
			foreach (var I in ourRank)
				if (I.Value)
				{
					for (var J = 0; J < PermissionsListBox.Items.Count; ++J)
						if (((string)PermissionsListBox.Items[J]).Split(' ')[0] == I.Key)
							PermissionsListBox.SetItemChecked(J, true);
				}
				else
					for (var J = 0; J < PermissionsListBox.Items.Count; ++J)
						if (((string)NegativePermissions.Items[J]).Split(' ')[0] == I.Key)
							NegativePermissions.SetItemChecked(J, false);
			updatingAdminPerms = false;
		}

		private void ConfigPanels_SelectedIndexChanged(object sender, EventArgs e)
		{
			ConfigApply.Enabled = (ConfigIndex)ConfigPanels.SelectedIndex != ConfigIndex.Admins;
			Properties.Settings.Default.LastConfigPageIndex = ConfigPanels.SelectedIndex;
		}

		void ReadjustFlow(object sender, EventArgs e)
		{
			AdjustFlow(ConfigConfigFlow, ConfigConfigPanel);
			AdjustFlow(GameConfigFlow, GameConfigPanel);
			AdjustFlow(DatabaseConfigFlow, DatabaseConfigPanel);
			AdjustFlow(JobsConfigFlow, JobsConfigPanel);
			AdjustFlow(MapsConfigFlow, MapsConfigPanel);
		}

		void LoadGenericConfig(TGConfigType type)
		{
			FlowLayoutPanel flow;
			IList<ConfigSetting> changeList;
			switch (type)
			{
				case TGConfigType.Database:
					flow = DatabaseConfigFlow;
					changeList = DatabaseChangelist;
					break;
				case TGConfigType.Game:
					flow = GameConfigFlow;
					changeList = GameChangelist;
					break;
				case TGConfigType.General:
					flow = ConfigConfigFlow;
					changeList = GeneralChangelist;
					break;
				default:
					throw new Exception(String.Format("Invalid TGConfigType {0}", type));
			}
			changeList.Clear();
			flow.Controls.Clear();
			flow.SuspendLayout();

			var Entries = Server.GetComponent<ITGConfig>().Retrieve(type, out string error);
			if (Entries != null)
				foreach (var I in Entries)
					HandleConfigEntry(I, flow, changeList, type);
			else
				flow.Controls.Add(new Label() { Text = "Unable to load related config!" });

			flow.ResumeLayout();
		}

		void ConfigRefresh_Click(object sender, System.EventArgs e)
		{
			RefreshCurrentPage();
		}

		public void RefreshCurrentPage()
		{
			if (!ConfigPanels.Visible)
			{
				LoadConfig();
				return;
			}

			switch ((ConfigIndex)ConfigPanels.SelectedIndex)
			{
				case ConfigIndex.Config:
					LoadGenericConfig(TGConfigType.General);
					break;
				case ConfigIndex.Database:
					LoadGenericConfig(TGConfigType.Database);
					break;
				case ConfigIndex.Game:
					LoadGenericConfig(TGConfigType.Game);
					break;
				case ConfigIndex.Jobs:
					LoadJobsConfig();
					break;
				case ConfigIndex.Maps:
					LoadMapsConfig();
					break;
				case ConfigIndex.Admins:
					LoadAdminsConfig();
					break;
			}
		}

		void LoadRanksList()
		{
			var ranks = Server.GetComponent<ITGConfig>().AdminRanks(out string error);
			AdminRanksListBox.Items.Clear();
			if (ranks == null)
				MessageBox.Show("Error: " + error);
			else
				foreach (var I in ranks)
					AdminRanksListBox.Items.Add(I.Key);
			if (AdminRanksListBox.Items.Count > 0 && AdminRanksListBox.SelectedIndex == -1)
			{
				AdminRanksListBox.SelectedIndex = 0;
				RemoveRankButton.Enabled = true;
			}
			else
				RemoveRankButton.Enabled = false;
		}

		void LoadAdminsList()
		{
			var admins = Server.GetComponent<ITGConfig>().Admins(out string error);
			AdminsListBox.Items.Clear();
			if (admins == null)
				MessageBox.Show("Error: " + error);
			else
				foreach (var I in admins)
					AdminsListBox.Items.Add(String.Format("{0} ({1})", I.Key, I.Value));
			if(AdminsListBox.Items.Count > 0 && AdminsListBox.SelectedIndex == -1) { 
				AdminsListBox.SelectedIndex = 0;
				DeadminButton.Enabled = true;
			}
			else
				DeadminButton.Enabled = false;
		}

		void LoadAdminsConfig()
		{
			var perms = Server.GetComponent<ITGConfig>().ListPermissions(out string error);
			PermissionsListBox.Items.Clear();
			if (perms == null)
				MessageBox.Show("Error: " + error);
			else
				foreach (var I in perms)
				{
					var formattedDisplay = String.Format("{0} ({1})", I.Key, I.Value);
					PermissionsListBox.Items.Add(formattedDisplay);
					NegativePermissions.Items.Add(formattedDisplay);
				}
			LoadRanksList();
			LoadAdminsList();
		}

		void ApplyGenericConfig(IList<ConfigSetting> changelist, TGConfigType type)
		{
			var Config = Server.GetComponent<ITGConfig>();
			foreach (var I in changelist)
			{
				var error = Config.SetItem(type, I);
				if (error != null)
				{
					MessageBox.Show("An error occurred: {1}" + error);
					break;
				}
			}
		}

		void ConfigApply_Click(object sender, EventArgs e)
		{
			switch ((ConfigIndex)ConfigPanels.SelectedIndex)
			{
				case ConfigIndex.Config:
					ApplyGenericConfig(GeneralChangelist, TGConfigType.General);
					break;
				case ConfigIndex.Database:
					ApplyGenericConfig(DatabaseChangelist, TGConfigType.Database);
					break;
				case ConfigIndex.Game:
					ApplyGenericConfig(GameChangelist, TGConfigType.Game);
					break;
				case ConfigIndex.Jobs:
					var Config = Server.GetComponent<ITGConfig>();
					foreach (var I in JobsChangelist)
						Config.SetJob(I);
					break;
				case ConfigIndex.Maps:
					Config = Server.GetComponent<ITGConfig>();
					foreach (var I in MapsChangelist)
						Config.SetMapSettings(I);
					break;
				case ConfigIndex.Admins:
					MessageBox.Show("How were you able to click that???");
					break;
			}
			RefreshCurrentPage();
		}

		void LoadMapsConfig()
		{
			MapsConfigFlow.Controls.Clear();
			var Maps = Server.GetComponent<ITGConfig>().MapSettings(out string error);
			if (Maps == null)
			{
				MapsConfigFlow.Controls.Add(new Label()
				{
					Text = "Error: " + error,
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				return;
			}

			MapsConfigFlow.SuspendLayout();
			MapsConfigFlow.Controls.Add(new Label()
			{
				Text = "Set a player limit to 0 for it to be ignored",
				AutoSize = true,
				Font = new Font("Verdana", 10.0f),
				ForeColor = Color.FromArgb(248, 248, 242)
			});
			MapsConfigFlow.Controls.Add(new Label());
			var mapRadios = new List<MapRadioButton>();
			foreach(var M in Maps)
			{
				var p = new FlowLayoutPanel() { FlowDirection = FlowDirection.LeftToRight, AutoSize = true };
				p.Controls.Add(new Label()
				{
					Text = M.Name + ":",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new MapCheckBox(M, MapsChangelist));
				p.Controls.Add(new MapRadioButton(M, MapsChangelist, mapRadios));
				MapsConfigFlow.Controls.Add(p);
				p = new FlowLayoutPanel() { FlowDirection = FlowDirection.LeftToRight, AutoSize = true };
				p.Controls.Add(new Label()
				{
					Text = "Min Players:",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new MapNumeric(M, MapsChangelist, MapNumType.MinPlayers));
				p.Controls.Add(new Label()
				{
					Text = "Max Players:",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new MapNumeric(M, MapsChangelist, MapNumType.MaxPlayers));
				p.Controls.Add(new Label()
				{
					Text = "Vote Weight:",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new MapNumeric(M, MapsChangelist, MapNumType.VoteWeight));
				MapsConfigFlow.Controls.Add(p);
				MapsConfigFlow.Controls.Add(new Label()); //line break
			}
			MapsConfigFlow.ResumeLayout();
		}

		void LoadJobsConfig()
		{
			JobsConfigFlow.Controls.Clear();
			var Jobs = Server.GetComponent<ITGConfig>().Jobs(out string error);

			if(Jobs == null)
			{
				JobsConfigFlow.Controls.Add(new Label()
				{
					Text = "Error: " + error,
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				return;
			}
			JobsConfigFlow.SuspendLayout();
			JobsConfigFlow.Controls.Add(new Label()
			{
				Text = "Set a value to -1 for infinite positions",
				AutoSize = true,
				Font = new Font("Verdana", 10.0f),
				ForeColor = Color.FromArgb(248, 248, 242)
			});
			JobsConfigFlow.Controls.Add(new Label());
			foreach (var J in Jobs)
			{
				JobsConfigFlow.Controls.Add(new Label()
				{
					Text = J.Name + ":",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				var p = new FlowLayoutPanel() { FlowDirection = FlowDirection.LeftToRight, AutoSize = true };
				p.Controls.Add(new Label()
				{
					Text = "Total Positions:",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new JobNumeric(J, JobsChangelist, false));
				p.Controls.Add(new Label()
				{
					Text = "Spawn Positions:",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
				p.Controls.Add(new JobNumeric(J, JobsChangelist, true));
				JobsConfigFlow.Controls.Add(p);
				JobsConfigFlow.Controls.Add(new Label()); //line break
			}
			JobsConfigFlow.ResumeLayout();
		}

		void ConfigUpload_Click(object sender, EventArgs eva)
		{
			var ofd = new OpenFileDialog()
			{
				CheckFileExists = true,
				CheckPathExists = true,
				DefaultExt = ".txt",
				Multiselect = false,
				Title = "Config Upload",
				ValidateNames = true,
				Filter = "Text files (*.txt)|*.txt|PNG files (*.png)|*.png|All files (*.*)|*.*",
				AddExtension = false,
				SupportMultiDottedExtensions = true,
			};
			if (ofd.ShowDialog() != DialogResult.OK)
				return;

			var fileToUpload = ofd.FileName;

			var originalFileName = Program.TextPrompt("Config Upload", "Enter the path of the destination file in the config folder:");
			if (originalFileName == null)
				return;

			string fileContents = null;
			string error = null;
			try
			{
				fileContents = File.ReadAllText(fileToUpload);
			} catch (Exception e)
			{
				error = e.ToString();
			}
			if (error == null)
				error = Server.GetComponent<ITGConfig>().WriteRaw(originalFileName, fileContents);
			if (error != null)
				MessageBox.Show("An error occurred: " + error);
		}

		void DownloadConfig(string remotePath, bool repo)
		{
			if (remotePath == null)
				return;
			var text = Server.GetComponent<ITGConfig>().ReadRaw(remotePath, repo, out string error);
			if (text != null)
			{

				var ofd = new SaveFileDialog()
				{
					CheckFileExists = false,
					CheckPathExists = true,
					DefaultExt = ".txt",
					Title = "Config Download",
					ValidateNames = true,
					Filter = "Text files (*.txt)|*.txt|PNG files (*.png)|*.png|All files (*.*)|*.*",
					AddExtension = false,
					CreatePrompt = false,
					OverwritePrompt = true,
					SupportMultiDottedExtensions = true,
				};
				if (ofd.ShowDialog() != DialogResult.OK)
					return;

				try
				{
					File.WriteAllText(ofd.FileName, text);
					return;
				}
				catch (Exception e)
				{
					error = e.ToString();
				}
			}
			MessageBox.Show("An error occurred: " + error);
		}

		void ConfigDownload_Click(object sender, EventArgs eva)
		{
			DownloadConfig(Program.TextPrompt("Config Download", "Enter the path of the source file in the config folder:"), false);
		}

		void ConfigDownloadRepo_Click(object sender, EventArgs e)
		{
			DownloadConfig(Program.TextPrompt("Repo Config Download", "Enter the path of the source file in the repository's config folder:"), true);
		}

		void HandleConfigEntry(ConfigSetting setting, FlowLayoutPanel flow, IList<ConfigSetting> changelist, TGConfigType type)
		{
			flow.Controls.Add(new Label()
			{
				Text = setting.Name + (setting.ExistsInRepo ? "" : " (Does not exist in repository!)"),
				AutoSize = true,
				Font = new Font("Verdana", 10.0f),
				ForeColor = Color.FromArgb(248, 248, 242)
			});

			if (setting.ExistsInRepo)
				flow.Controls.Add(new Label()
				{
					AutoSize = true,
					Font = new Font("Verdana", 8.0f),
					ForeColor = Color.FromArgb(248, 248, 242),
					Text = setting.Comment
				});

			if (setting.IsMultiKey)
			{
				flow.Controls.Add(new Label()
				{
					Text = "MANUAL EDIT REQUIRED!",
					AutoSize = true,
					Font = new Font("Verdana", 10.0f),
					ForeColor = Color.FromArgb(248, 248, 242)
				});
			}
			else
			{

				var IsSwitch = setting.DefaultValue == "" || setting.DefaultValue == null;

				if (!IsSwitch || !setting.ExistsInRepo)
					flow.Controls.Add(new ConfigAddRemoveButton(setting, this, type));

				if (IsSwitch || setting.ExistsInStatic)
					flow.Controls.Add(IsSwitch ? (Control)new ConfigCheckBox(setting, changelist) : new ConfigTextBox(setting, changelist));
			}
			flow.Controls.Add(new Label()); //line break
		}
	}
}
