using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{
	class ConfigTextBox : TextBox
	{
		IList<ConfigSetting> ChangeList;
		ConfigSetting Setting;
		public ConfigTextBox(ConfigSetting c, IList<ConfigSetting> cl)
		{
			Setting = c;
			TextChanged += ConfigTextbox_TextChanged;
			ChangeList = cl;
			Text = Setting.Value;
			Multiline = true;
			Width = 560;
			Height *= 3;
			ScrollBars = ScrollBars.Both;
		}

		private void ConfigTextbox_TextChanged(object sender, EventArgs e)
		{
			Setting.Value = Text;
			if (!ChangeList.Contains(Setting))
				ChangeList.Add(Setting);
		}
	}
	class JobNumeric : NumericUpDown
	{
		IList<JobSetting> ChangeList;
		JobSetting Setting;
		bool spawn;
		public JobNumeric(JobSetting c, IList<JobSetting> cl, bool s)
		{
			spawn = s;
			Setting = c;
			ChangeList = cl;
			Minimum = -1;
			Maximum = 10000;
			Value = spawn ? c.SpawnPositions : c.TotalPositions;
			ValueChanged += JobTextBox_ValueChanged;
		}

		private void JobTextBox_ValueChanged(object sender, EventArgs e)
		{
			if (spawn)
				Setting.SpawnPositions = (int)Value;
			else
				Setting.TotalPositions = (int)Value;
			if (!ChangeList.Contains(Setting))
				ChangeList.Add(Setting);
		}
	}

	class ConfigCheckBox : CheckBox
	{
		IList<ConfigSetting> ChangeList;
		ConfigSetting Setting;
		public ConfigCheckBox(ConfigSetting c, IList<ConfigSetting> cl)
		{
			Setting = c;
			CheckStateChanged += ConfigCheckBox_CheckStateChanged;
			ChangeList = cl;
			Text = "Enabled";
			Font = new Font("Verdana", 8.0f);
			ForeColor = Color.FromArgb(248, 248, 242);
			Checked = Setting.Value != null;
		}

		private void ConfigCheckBox_CheckStateChanged(object sender, EventArgs e)
		{
			Setting.Value = Checked ? "" : null;
			if (!ChangeList.Contains(Setting))
				ChangeList.Add(Setting);
		}
	}

	class ConfigAddRemoveButton : Button
	{
		ConfigSetting Setting;
		Main main;
		TGConfigType type;
		bool remove;
		public ConfigAddRemoveButton(ConfigSetting c, Main m, TGConfigType t)
		{
			Setting = c;
			main = m;
			type = t;
			Click += ConfigAddRemoveButton_Click;
			UseVisualStyleBackColor = true;
			remove = Setting.ExistsInStatic || !Setting.ExistsInRepo;
			Text = remove ? "Remove" : "Add";
		}

		private void ConfigAddRemoveButton_Click(object sender, EventArgs e)
		{
			if (remove)
			{
				Setting.Values = Setting.DefaultValues;
				Setting.Value = null;
			}
			else
			{
				Setting.Value = Setting.DefaultValue;
				Setting.Values = Setting.DefaultValues;
			}

			var Result = Server.GetComponent<ITGConfig>().SetItem(type, Setting);
			if (Result != null)
				MessageBox.Show("Error: " + Result);

			main.RefreshCurrentPage();
		}
	}
}
