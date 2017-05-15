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
		const int ConfigConfig = 0;
		const int DatabaseConfig = 1;
		const int GameConfig = 2;
		const int JobsConfig = 3;
		const int MapsConfig = 4;

		IList<ConfigSetting> GeneralChangelist, DatabaseChangelist, GameChangelist;
		IList<JobSetting> JobsChangelist;
		IList<MapSetting> MapsChangelist;

		FlowLayoutPanel ConfigConfigFlow, DatabaseConfigFlow, GameConfigFlow, JobsConfigFlow, MapsConfigFlow;

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
		void LoadConfig()
		{
			ConfigConfigFlow = CreateFLP(ConfigConfigPanel);
			GeneralChangelist = new List<ConfigSetting>();
			LoadGenericConfig(TGConfigType.General);

			DatabaseConfigFlow = CreateFLP(DatabaseConfigPanel);
			DatabaseChangelist = new List<ConfigSetting>();
			LoadGenericConfig(TGConfigType.Database);

			GameConfigFlow = CreateFLP(GameConfigPanel);
			GameChangelist = new List<ConfigSetting>();
			LoadGenericConfig(TGConfigType.Game);

			JobsConfigFlow = CreateFLP(JobsConfigPanel);
			JobsChangelist = new List<JobSetting>();
			LoadJobsConfig();

			MapsConfigFlow = CreateFLP(MapsConfigPanel);
			MapsChangelist = new List<MapSetting>();
			LoadMapsConfig();

			ConfigPanels.SelectedIndex = Properties.Settings.Default.LastConfigPageIndex;
			ConfigPanels.SelectedIndexChanged += ConfigPanels_SelectedIndexChanged;

			Resize += ReadjustFlow;
		}

		private void ConfigPanels_SelectedIndexChanged(object sender, EventArgs e)
		{
			Properties.Settings.Default.LastConfigPageIndex = Panels.SelectedIndex;
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
			switch (ConfigPanels.SelectedIndex)
			{
				case ConfigConfig:
					LoadGenericConfig(TGConfigType.General);
					break;
				case DatabaseConfig:
					LoadGenericConfig(TGConfigType.Database);
					break;
				case GameConfig:
					LoadGenericConfig(TGConfigType.Game);
					break;
				case JobsConfig:
					LoadJobsConfig();
					break;
				case MapsConfig:
					LoadMapsConfig();
					break;
			}
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
			switch (ConfigPanels.SelectedIndex)
			{
				case ConfigConfig:
					ApplyGenericConfig(GeneralChangelist, TGConfigType.General);
					break;
				case DatabaseConfig:
					ApplyGenericConfig(DatabaseChangelist, TGConfigType.Database);
					break;
				case GameConfig:
					ApplyGenericConfig(GameChangelist, TGConfigType.Game);
					break;
				case JobsConfig:
					var Config = Server.GetComponent<ITGConfig>();
					foreach (var I in JobsChangelist)
						Config.SetJob(I);
					break;
				case MapsConfig:
					Config = Server.GetComponent<ITGConfig>();
					foreach (var I in MapsChangelist)
						Config.SetMapSettings(I);
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
