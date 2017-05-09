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

		List<ConfigSetting> GeneralChangelist, DatabaseChangelist, GameChangelist;

		FlowLayoutPanel ConfigConfigFlow, DatabaseConfigFlow, GameConfigFlow;

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

			Resize += ReadjustFlow;
		}

		void ReadjustFlow(object sender, EventArgs e)
		{
			AdjustFlow(ConfigConfigFlow, ConfigConfigPanel);
			AdjustFlow(GameConfigFlow, GameConfigPanel);
			AdjustFlow(DatabaseConfigFlow, DatabaseConfigPanel);
		}

		void LoadGenericConfig(TGConfigType type)
		{
			FlowLayoutPanel flow;
			List<ConfigSetting> changeList;
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
			}
		}

		void ConfigApply_Click(object sender, System.EventArgs e)
		{
			var Config = Server.GetComponent<ITGConfig>();
			switch (ConfigPanels.SelectedIndex)
			{
				case ConfigConfig:
					for(var I = 0; I < GeneralChangelist.Count; ++I)
					{
						var error = Config.SetItem(TGConfigType.General, GeneralChangelist[I]);
						if (error != null)
						{
							MessageBox.Show("An error occurred: {1}" + error);
							break;
						}
					}
					RefreshCurrentPage();
					break;
			}
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
			
			var IsSwitch = setting.DefaultValue == "" || setting.DefaultValue == null;

			if (!IsSwitch || !setting.ExistsInRepo)
				flow.Controls.Add(new ConfigAddRemoveButton(setting, this, type));			

			if(IsSwitch || setting.ExistsInStatic)
				flow.Controls.Add(IsSwitch ? (Control)new ConfigCheckBox(setting, changelist) : new ConfigTextBox(setting, changelist));

			flow.Controls.Add(new Label()); //line break
		}
	}
}
