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
			ValueChanged += JobNumeric_ValueChanged;
		}

		private void JobNumeric_ValueChanged(object sender, EventArgs e)
		{
			if (spawn)
				Setting.SpawnPositions = (int)Value;
			else
				Setting.TotalPositions = (int)Value;
			if (!ChangeList.Contains(Setting))
				ChangeList.Add(Setting);
		}
	}
	enum MapNumType
	{
		MaxPlayers,
		MinPlayers,
		VoteWeight,
	}
	class MapNumeric : NumericUpDown
	{
		IList<MapSetting> ChangeList;
		MapSetting Setting;
		MapNumType type;
		public MapNumeric(MapSetting c, IList<MapSetting> cl, MapNumType t)
		{
			type = t;
			Setting = c;
			ChangeList = cl;
			Minimum = -1;
			Maximum = 10000;
			switch (type)
			{
				case MapNumType.MaxPlayers:
					Value = Setting.MaxPlayers;
					break;
				case MapNumType.MinPlayers:
					Value = Setting.MinPlayers;
					break;
				case MapNumType.VoteWeight:
					DecimalPlaces = 5;
					Value = Convert.ToDecimal(Setting.VoteWeight);
					break;
			}
			ValueChanged += MapNumeric_ValueChanged;
		}

		private void MapNumeric_ValueChanged(object sender, EventArgs e)
		{
			switch (type)
			{
				case MapNumType.MaxPlayers:
					Setting.MaxPlayers = (int)Value;
					break;
				case MapNumType.MinPlayers:
					Setting.MinPlayers = (int)Value;
					break;
				case MapNumType.VoteWeight:
					Setting.VoteWeight = (float)Value;
					break;
			}
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

	class MapRadioButton : RadioButton
	{
		IList<MapSetting> ChangeList;
		IList<MapRadioButton> AllButtons;
		MapSetting Setting;
		public MapRadioButton(MapSetting c, IList<MapSetting> cl, IList<MapRadioButton> others)
		{
			ChangeList = cl;
			Setting = c;
			AllButtons = others;
			Font = new Font("Verdana", 8.0f);
			ForeColor = Color.FromArgb(248, 248, 242);
			Text = "Default";
			AllButtons.Add(this);
			if (Setting.Default)
				Checked = true;
			CheckedChanged += MapRadioButton_CheckedChanged;
		}

		private void MapRadioButton_CheckedChanged(object sender, EventArgs e)
		{
			if (!Checked)
				return;
			foreach(var I in AllButtons)
				if(I != this && I.Checked)
				{
					I.Checked = false;
					I.Setting.Default = false;
					if(!ChangeList.Contains(I.Setting))
						ChangeList.Add(I.Setting);
					break;
				}
			Setting.Default = true;
			if (!ChangeList.Contains(Setting))
				ChangeList.Add(Setting);
		}
	}

	class MapCheckBox : CheckBox
	{
		IList<MapSetting> ChangeList;
		MapSetting Setting;
		public MapCheckBox(MapSetting c, IList<MapSetting> cl)
		{
			Setting = c;
			CheckStateChanged += ConfigCheckBox_CheckStateChanged;
			ChangeList = cl;
			Text = "Enabled";
			Font = new Font("Verdana", 8.0f);
			ForeColor = Color.FromArgb(248, 248, 242);
			Checked = Setting.Enabled;
		}

		private void ConfigCheckBox_CheckStateChanged(object sender, EventArgs e)
		{
			Setting.Enabled = Checked;
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
