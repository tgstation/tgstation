using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{
	partial class Main
	{
		TGChatProvider modifyingProvider;
		bool updatingChat = false;
		
		void LoadChatPage()
		{
			updatingChat = true;
			var Chat = Server.GetComponent<ITGChat>();
			var PI = Chat.ProviderInfo();
			modifyingProvider = PI.Provider;
			switch (modifyingProvider)
			{
				case TGChatProvider.Discord:
					var DPI = new TGDiscordSetupInfo(PI);
					DiscordProviderSwitch.Select();
					AuthField1.Text = DPI.BotToken; //it's invisible so whatever
					AuthField1Title.Text = "Bot Token:";
					AuthField2.Visible = false;
					AuthField2Title.Visible = false;
					ChatServerText.Visible = false;
					ChatPortSelector.Visible = false;
					ChatServerTitle.Visible = false;
					ChatPortTitle.Visible = false;
					ChatNicknameText.Visible = false;
					ChatNicknameTitle.Visible = false;
					break;
				case TGChatProvider.IRC:
					var IRC = new TGIRCSetupInfo(PI);
					IRCProviderSwitch.Select();
					AuthField1.Text = IRC.AuthTarget;
					AuthField2.Text = IRC.AuthMessage;
					AuthField2.Visible = true;
					AuthField2Title.Visible = true;
					AuthField1Title.Text = "Auth Target:";
					AuthField2Title.Text = "Auth Message:";
					ChatServerText.Visible = true;
					ChatPortSelector.Visible = true;
					ChatServerTitle.Visible = true;
					ChatPortTitle.Visible = true;
					ChatServerText.Text = IRC.URL;
					ChatPortSelector.Value = IRC.Port;
					ChatNicknameText.Visible = true;
					ChatNicknameTitle.Visible = true;
					ChatNicknameText.Text = IRC.Nickname;
					break;
				default:
					MessageBox.Show("This is a bug, I'll try and recover. Provider was " + modifyingProvider.ToString());
					MessageBox.Show(Chat.SetProviderInfo(new TGIRCSetupInfo()) ?? "Success!");
					LoadChatPage();
					return;
			}

			var Enabled = Chat.Enabled();
			ChatEnabledCheckbox.Checked = Enabled;
			if (!Enabled)
				ChatStatusLabel.Text = "Disabled";
			else if (Chat.Connected())
				ChatStatusLabel.Text = "Connected";
			else
				ChatStatusLabel.Text = "Disconnected";
			ChatReconnectButton.Enabled = Enabled;

			AdminChannelText.Text = Chat.AdminChannel();

			ChatAdminsTextBox.Text = "";
			foreach (var I in Chat.ListAdmins())
				ChatAdminsTextBox.Text += I + "\r\n";

			ChatChannelsTextBox.Text = "";
			foreach (var I in Chat.Channels())
				ChatChannelsTextBox.Text += I + "\r\n";
			updatingChat = false;
		}

		private void ChatRefreshButton_Click(object sender, EventArgs e)
		{
			LoadChatPage();
		}

		private void ChatReconnectButton_Click(object sender, EventArgs e)
		{
			Server.GetComponent<ITGChat>().Reconnect();
			LoadChatPage();
		}

		static string[] SplitByLine(TextBox t)
		{
			var channels = t.Text.Split('\n');

			var finalChannels = new List<string>();
			foreach (var I in channels)
			{
				var trimmed = I.Trim();
				if(trimmed != "")
					finalChannels.Add(trimmed);
			}
			return finalChannels.ToArray();
		}

		private void DiscordProviderSwitch_CheckedChanged(object sender, EventArgs e)
		{
			if (!updatingChat && DiscordProviderSwitch.Checked)
			{
				var res = Server.GetComponent<ITGChat>().SetProviderInfo(new TGDiscordSetupInfo());
				if (res != null)
					MessageBox.Show(res);
			}
		}

		private void IRCProviderSwitch_CheckedChanged(object sender, EventArgs e)
		{
			if (!updatingChat && IRCProviderSwitch.Checked)
			{
				var res = Server.GetComponent<ITGChat>().SetProviderInfo(new TGIRCSetupInfo());
				if (res != null)
					MessageBox.Show(res);
			}
		}

		private void ChatApplyButton_Click(object sender, EventArgs e)
		{
			var Chat = Server.GetComponent<ITGChat>();
			
			Chat.SetChannels(SplitByLine(ChatChannelsTextBox), AdminChannelText.Text);
			Chat.SetAdmins(SplitByLine(ChatAdminsTextBox));
			Chat.SetEnabled(ChatEnabledCheckbox.Checked);

			string res;
			switch (modifyingProvider)
			{
				case TGChatProvider.Discord:
					res = Chat.SetProviderInfo(new TGDiscordSetupInfo() { BotToken = AuthField1.Text });
					break;
				case TGChatProvider.IRC:
					res = Chat.SetProviderInfo(new TGIRCSetupInfo() {
						AuthMessage = AuthField2.Text,
						AuthTarget = AuthField1.Text,
						Nickname = ChatNicknameText.Text,
						URL = ChatServerText.Text,
						Port = (ushort)ChatPortSelector.Value,
					});
					break;
				default:
					res = "You really shouldn't be able to read this.";
					break;
			}

			if (res != null)
				MessageBox.Show(res);

			LoadChatPage();
		}
	}
}
