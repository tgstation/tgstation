namespace TGControlPanel
{
	partial class Main
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
            this.Panels = new System.Windows.Forms.TabControl();
            this.RepoPanel = new System.Windows.Forms.TabPage();
            this.BackupTagsList = new System.Windows.Forms.ListBox();
            this.ResetRemote = new System.Windows.Forms.Button();
            this.RecloneButton = new System.Windows.Forms.Button();
            this.PythonPathText = new System.Windows.Forms.TextBox();
            this.PythonPathLabel = new System.Windows.Forms.Label();
            this.RepoGenChangelogButton = new System.Windows.Forms.Button();
            this.TestmergeSelector = new System.Windows.Forms.NumericUpDown();
            this.TestMergeListLabel = new System.Windows.Forms.ListBox();
            this.CurrentRevisionLabel = new System.Windows.Forms.Label();
            this.RepoApplyButton = new System.Windows.Forms.Button();
            this.RepoBranchTextBox = new System.Windows.Forms.TextBox();
            this.RepoRemoteTextBox = new System.Windows.Forms.TextBox();
            this.HardReset = new System.Windows.Forms.Button();
            this.UpdateRepoButton = new System.Windows.Forms.Button();
            this.MergePRButton = new System.Windows.Forms.Button();
            this.IdentityLabel = new System.Windows.Forms.Label();
            this.TestMergeListTitle = new System.Windows.Forms.Label();
            this.RemoteNameTitle = new System.Windows.Forms.Label();
            this.BranchNameTitle = new System.Windows.Forms.Label();
            this.CurrentRevisionTitle = new System.Windows.Forms.Label();
            this.CloneRepositoryButton = new System.Windows.Forms.Button();
            this.RepoProgressBarLabel = new System.Windows.Forms.Label();
            this.RepoProgressBar = new System.Windows.Forms.ProgressBar();
            this.BYONDPanel = new System.Windows.Forms.TabPage();
            this.LatestVersionLabel = new System.Windows.Forms.Label();
            this.LatestVersionTitle = new System.Windows.Forms.Label();
            this.StagedVersionLabel = new System.Windows.Forms.Label();
            this.StagedVersionTitle = new System.Windows.Forms.Label();
            this.StatusLabel = new System.Windows.Forms.Label();
            this.VersionLabel = new System.Windows.Forms.Label();
            this.VersionTitle = new System.Windows.Forms.Label();
            this.MinorVersionLabel = new System.Windows.Forms.Label();
            this.MajorVersionLabel = new System.Windows.Forms.Label();
            this.UpdateButton = new System.Windows.Forms.Button();
            this.MinorVersionNumeric = new System.Windows.Forms.NumericUpDown();
            this.MajorVersionNumeric = new System.Windows.Forms.NumericUpDown();
            this.UpdateProgressBar = new System.Windows.Forms.ProgressBar();
            this.ServerPanel = new System.Windows.Forms.TabPage();
            this.VisibilitySelector = new System.Windows.Forms.ComboBox();
            this.VisibilityTitle = new System.Windows.Forms.Label();
            this.SecuritySelector = new System.Windows.Forms.ComboBox();
            this.SecurityTitle = new System.Windows.Forms.Label();
            this.ResetTestmerge = new System.Windows.Forms.Button();
            this.NudgePortSelector = new System.Windows.Forms.NumericUpDown();
            this.NudgePortLabel = new System.Windows.Forms.Label();
            this.ServerPathLabel = new System.Windows.Forms.Label();
            this.ServerPathTextbox = new System.Windows.Forms.TextBox();
            this.CompileCancelButton = new System.Windows.Forms.Button();
            this.ProjectPathLabel = new System.Windows.Forms.Label();
            this.projectNameText = new System.Windows.Forms.TextBox();
            this.PortLabel = new System.Windows.Forms.Label();
            this.PortSelector = new System.Windows.Forms.NumericUpDown();
            this.ServerPRLabel = new System.Windows.Forms.Label();
            this.ServerTestmergeInput = new System.Windows.Forms.NumericUpDown();
            this.TestmergeButton = new System.Windows.Forms.Button();
            this.UpdateTestmergeButton = new System.Windows.Forms.Button();
            this.UpdateMergeButton = new System.Windows.Forms.Button();
            this.UpdateHardButton = new System.Windows.Forms.Button();
            this.ServerGRestartButton = new System.Windows.Forms.Button();
            this.ServerGStopButton = new System.Windows.Forms.Button();
            this.ServerRestartButton = new System.Windows.Forms.Button();
            this.ServerStopButton = new System.Windows.Forms.Button();
            this.ServerStartButton = new System.Windows.Forms.Button();
            this.AutostartCheckbox = new System.Windows.Forms.CheckBox();
            this.CompilerStatusLabel = new System.Windows.Forms.Label();
            this.CompilerLabel = new System.Windows.Forms.Label();
            this.compileButton = new System.Windows.Forms.Button();
            this.initializeButton = new System.Windows.Forms.Button();
            this.compilerProgressBar = new System.Windows.Forms.ProgressBar();
            this.ServerStatusLabel = new System.Windows.Forms.Label();
            this.ServerStatusTitle = new System.Windows.Forms.Label();
            this.ChatPanel = new System.Windows.Forms.TabPage();
            this.ChatRefreshButton = new System.Windows.Forms.Button();
            this.ChatNicknameText = new System.Windows.Forms.TextBox();
            this.ChatNicknameTitle = new System.Windows.Forms.Label();
            this.ChatPortSelector = new System.Windows.Forms.NumericUpDown();
            this.ChatPortTitle = new System.Windows.Forms.Label();
            this.ChatServerText = new System.Windows.Forms.TextBox();
            this.ChatServerTitle = new System.Windows.Forms.Label();
            this.ChatApplyButton = new System.Windows.Forms.Button();
            this.AuthField2Title = new System.Windows.Forms.Label();
            this.AuthField1Title = new System.Windows.Forms.Label();
            this.AuthField2 = new System.Windows.Forms.TextBox();
            this.AuthField1 = new System.Windows.Forms.TextBox();
            this.AdminChannelTitle = new System.Windows.Forms.Label();
            this.AdminChannelText = new System.Windows.Forms.TextBox();
            this.ChatReconnectButton = new System.Windows.Forms.Button();
            this.ChatStatusLabel = new System.Windows.Forms.Label();
            this.ChatStatusTitle = new System.Windows.Forms.Label();
            this.ChatEnabledCheckbox = new System.Windows.Forms.CheckBox();
            this.ChatProviderSelectorPanel = new System.Windows.Forms.Panel();
            this.DiscordProviderSwitch = new System.Windows.Forms.RadioButton();
            this.IRCProviderSwitch = new System.Windows.Forms.RadioButton();
            this.ChatProviderTitle = new System.Windows.Forms.Label();
            this.ChannelsTitle = new System.Windows.Forms.Label();
            this.ChatAdminsTextBox = new System.Windows.Forms.TextBox();
            this.ChatAdminsTitle = new System.Windows.Forms.Label();
            this.ChatChannelsTextBox = new System.Windows.Forms.TextBox();
            this.ConfigPanel = new System.Windows.Forms.TabPage();
            this.ConfigApply = new System.Windows.Forms.Button();
            this.ConfigDownloadRepo = new System.Windows.Forms.Button();
            this.ConfigUpload = new System.Windows.Forms.Button();
            this.ConfigDownload = new System.Windows.Forms.Button();
            this.ConfigRefresh = new System.Windows.Forms.Button();
            this.ConfigPanels = new System.Windows.Forms.TabControl();
            this.ConfigConfigPanel = new System.Windows.Forms.TabPage();
            this.DatabaseConfigPanel = new System.Windows.Forms.TabPage();
            this.GameConfigPanel = new System.Windows.Forms.TabPage();
            this.JobsConfigPanel = new System.Windows.Forms.TabPage();
            this.MapsConfigPanel = new System.Windows.Forms.TabPage();
            this.AdminsPanel = new System.Windows.Forms.TabPage();
            this.NegativePermissionsTitle = new System.Windows.Forms.Label();
            this.NegativePermissions = new System.Windows.Forms.CheckedListBox();
            this.ApplyAdminRankButton = new System.Windows.Forms.Button();
            this.PermissionsListBox = new System.Windows.Forms.CheckedListBox();
            this.PermissionsTItle = new System.Windows.Forms.Label();
            this.RemoveRankButton = new System.Windows.Forms.Button();
            this.AddRankTextBox = new System.Windows.Forms.TextBox();
            this.AddRankButton = new System.Windows.Forms.Button();
            this.AdminRanksListBox = new System.Windows.Forms.ListBox();
            this.RanksTitle = new System.Windows.Forms.Label();
            this.DeadminButton = new System.Windows.Forms.Button();
            this.AddminTextBox = new System.Windows.Forms.TextBox();
            this.AddminButton = new System.Windows.Forms.Button();
            this.AdminsListBox = new System.Windows.Forms.ListBox();
            this.AdminsTitle = new System.Windows.Forms.Label();
            this.ConfigDisabledLabel = new System.Windows.Forms.Label();
            this.RepoBGW = new System.ComponentModel.BackgroundWorker();
            this.BYONDTimer = new System.Windows.Forms.Timer(this.components);
            this.ServerTimer = new System.Windows.Forms.Timer(this.components);
            this.WorldStatusChecker = new System.ComponentModel.BackgroundWorker();
            this.WorldStatusTimer = new System.Windows.Forms.Timer(this.components);
            this.FullUpdateWorker = new System.ComponentModel.BackgroundWorker();
            this.Panels.SuspendLayout();
            this.RepoPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.TestmergeSelector)).BeginInit();
            this.BYONDPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.MinorVersionNumeric)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.MajorVersionNumeric)).BeginInit();
            this.ServerPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.NudgePortSelector)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.PortSelector)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ServerTestmergeInput)).BeginInit();
            this.ChatPanel.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ChatPortSelector)).BeginInit();
            this.ChatProviderSelectorPanel.SuspendLayout();
            this.ConfigPanel.SuspendLayout();
            this.ConfigPanels.SuspendLayout();
            this.AdminsPanel.SuspendLayout();
            this.SuspendLayout();
            // 
            // Panels
            // 
            this.Panels.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.Panels.Controls.Add(this.RepoPanel);
            this.Panels.Controls.Add(this.BYONDPanel);
            this.Panels.Controls.Add(this.ServerPanel);
            this.Panels.Controls.Add(this.ChatPanel);
            this.Panels.Controls.Add(this.ConfigPanel);
            this.Panels.Location = new System.Drawing.Point(12, 12);
            this.Panels.Name = "Panels";
            this.Panels.SelectedIndex = 0;
            this.Panels.Size = new System.Drawing.Size(876, 392);
            this.Panels.TabIndex = 3;
            // 
            // RepoPanel
            // 
            this.RepoPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.RepoPanel.Controls.Add(this.BackupTagsList);
            this.RepoPanel.Controls.Add(this.ResetRemote);
            this.RepoPanel.Controls.Add(this.RecloneButton);
            this.RepoPanel.Controls.Add(this.PythonPathText);
            this.RepoPanel.Controls.Add(this.PythonPathLabel);
            this.RepoPanel.Controls.Add(this.RepoGenChangelogButton);
            this.RepoPanel.Controls.Add(this.TestmergeSelector);
            this.RepoPanel.Controls.Add(this.TestMergeListLabel);
            this.RepoPanel.Controls.Add(this.CurrentRevisionLabel);
            this.RepoPanel.Controls.Add(this.RepoApplyButton);
            this.RepoPanel.Controls.Add(this.RepoBranchTextBox);
            this.RepoPanel.Controls.Add(this.RepoRemoteTextBox);
            this.RepoPanel.Controls.Add(this.HardReset);
            this.RepoPanel.Controls.Add(this.UpdateRepoButton);
            this.RepoPanel.Controls.Add(this.MergePRButton);
            this.RepoPanel.Controls.Add(this.IdentityLabel);
            this.RepoPanel.Controls.Add(this.TestMergeListTitle);
            this.RepoPanel.Controls.Add(this.RemoteNameTitle);
            this.RepoPanel.Controls.Add(this.BranchNameTitle);
            this.RepoPanel.Controls.Add(this.CurrentRevisionTitle);
            this.RepoPanel.Controls.Add(this.CloneRepositoryButton);
            this.RepoPanel.Controls.Add(this.RepoProgressBarLabel);
            this.RepoPanel.Controls.Add(this.RepoProgressBar);
            this.RepoPanel.Location = new System.Drawing.Point(4, 22);
            this.RepoPanel.Name = "RepoPanel";
            this.RepoPanel.Padding = new System.Windows.Forms.Padding(3);
            this.RepoPanel.Size = new System.Drawing.Size(868, 366);
            this.RepoPanel.TabIndex = 0;
            this.RepoPanel.Text = "Repository";
            // 
            // BackupTagsList
            // 
            this.BackupTagsList.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.BackupTagsList.Items.AddRange(new object[] {
            "None"});
            this.BackupTagsList.Location = new System.Drawing.Point(122, 142);
            this.BackupTagsList.Name = "BackupTagsList";
            this.BackupTagsList.Size = new System.Drawing.Size(535, 95);
            this.BackupTagsList.TabIndex = 34;
            this.BackupTagsList.Visible = false;
            // 
            // ResetRemote
            // 
            this.ResetRemote.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ResetRemote.Location = new System.Drawing.Point(722, 81);
            this.ResetRemote.Name = "ResetRemote";
            this.ResetRemote.Size = new System.Drawing.Size(140, 29);
            this.ResetRemote.TabIndex = 33;
            this.ResetRemote.Text = "Reset To Remote";
            this.ResetRemote.UseVisualStyleBackColor = true;
            this.ResetRemote.Visible = false;
            this.ResetRemote.Click += new System.EventHandler(this.ResetRemote_Click);
            // 
            // RecloneButton
            // 
            this.RecloneButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.RecloneButton.Location = new System.Drawing.Point(722, 212);
            this.RecloneButton.Name = "RecloneButton";
            this.RecloneButton.Size = new System.Drawing.Size(140, 29);
            this.RecloneButton.TabIndex = 32;
            this.RecloneButton.Text = "Reclone";
            this.RecloneButton.UseVisualStyleBackColor = true;
            this.RecloneButton.Visible = false;
            this.RecloneButton.Click += new System.EventHandler(this.RecloneButton_Click);
            // 
            // PythonPathText
            // 
            this.PythonPathText.Location = new System.Drawing.Point(122, 112);
            this.PythonPathText.Name = "PythonPathText";
            this.PythonPathText.Size = new System.Drawing.Size(535, 20);
            this.PythonPathText.TabIndex = 31;
            this.PythonPathText.Visible = false;
            // 
            // PythonPathLabel
            // 
            this.PythonPathLabel.AutoSize = true;
            this.PythonPathLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.PythonPathLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.PythonPathLabel.Location = new System.Drawing.Point(6, 112);
            this.PythonPathLabel.Name = "PythonPathLabel";
            this.PythonPathLabel.Size = new System.Drawing.Size(114, 18);
            this.PythonPathLabel.TabIndex = 30;
            this.PythonPathLabel.Text = "Python Path:";
            this.PythonPathLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.PythonPathLabel.Visible = false;
            // 
            // RepoGenChangelogButton
            // 
            this.RepoGenChangelogButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoGenChangelogButton.Location = new System.Drawing.Point(722, 177);
            this.RepoGenChangelogButton.Name = "RepoGenChangelogButton";
            this.RepoGenChangelogButton.Size = new System.Drawing.Size(140, 29);
            this.RepoGenChangelogButton.TabIndex = 27;
            this.RepoGenChangelogButton.Text = "Generate Changelog";
            this.RepoGenChangelogButton.UseVisualStyleBackColor = true;
            this.RepoGenChangelogButton.Visible = false;
            this.RepoGenChangelogButton.Click += new System.EventHandler(this.RepoGenChangelogButton_Click);
            // 
            // TestmergeSelector
            // 
            this.TestmergeSelector.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.TestmergeSelector.Location = new System.Drawing.Point(722, 151);
            this.TestmergeSelector.Maximum = new decimal(new int[] {
            1000000,
            0,
            0,
            0});
            this.TestmergeSelector.Name = "TestmergeSelector";
            this.TestmergeSelector.Size = new System.Drawing.Size(140, 20);
            this.TestmergeSelector.TabIndex = 22;
            this.TestmergeSelector.Visible = false;
            // 
            // TestMergeListLabel
            // 
            this.TestMergeListLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.TestMergeListLabel.HorizontalScrollbar = true;
            this.TestMergeListLabel.Items.AddRange(new object[] {
            "None"});
            this.TestMergeListLabel.Location = new System.Drawing.Point(122, 260);
            this.TestMergeListLabel.Name = "TestMergeListLabel";
            this.TestMergeListLabel.Size = new System.Drawing.Size(535, 95);
            this.TestMergeListLabel.TabIndex = 21;
            this.TestMergeListLabel.Visible = false;
            // 
            // CurrentRevisionLabel
            // 
            this.CurrentRevisionLabel.AutoSize = true;
            this.CurrentRevisionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CurrentRevisionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CurrentRevisionLabel.Location = new System.Drawing.Point(162, 14);
            this.CurrentRevisionLabel.Name = "CurrentRevisionLabel";
            this.CurrentRevisionLabel.Size = new System.Drawing.Size(82, 18);
            this.CurrentRevisionLabel.TabIndex = 20;
            this.CurrentRevisionLabel.Text = "Unknown";
            this.CurrentRevisionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.CurrentRevisionLabel.Visible = false;
            // 
            // RepoApplyButton
            // 
            this.RepoApplyButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoApplyButton.Location = new System.Drawing.Point(722, 331);
            this.RepoApplyButton.Name = "RepoApplyButton";
            this.RepoApplyButton.Size = new System.Drawing.Size(140, 29);
            this.RepoApplyButton.TabIndex = 17;
            this.RepoApplyButton.Text = "Apply Changes";
            this.RepoApplyButton.UseVisualStyleBackColor = true;
            this.RepoApplyButton.Visible = false;
            this.RepoApplyButton.Click += new System.EventHandler(this.RepoApplyButton_Click);
            // 
            // RepoBranchTextBox
            // 
            this.RepoBranchTextBox.Location = new System.Drawing.Point(122, 70);
            this.RepoBranchTextBox.Name = "RepoBranchTextBox";
            this.RepoBranchTextBox.Size = new System.Drawing.Size(535, 20);
            this.RepoBranchTextBox.TabIndex = 15;
            this.RepoBranchTextBox.Visible = false;
            // 
            // RepoRemoteTextBox
            // 
            this.RepoRemoteTextBox.Location = new System.Drawing.Point(122, 44);
            this.RepoRemoteTextBox.Name = "RepoRemoteTextBox";
            this.RepoRemoteTextBox.Size = new System.Drawing.Size(535, 20);
            this.RepoRemoteTextBox.TabIndex = 14;
            this.RepoRemoteTextBox.Visible = false;
            // 
            // HardReset
            // 
            this.HardReset.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.HardReset.Location = new System.Drawing.Point(722, 46);
            this.HardReset.Name = "HardReset";
            this.HardReset.Size = new System.Drawing.Size(140, 29);
            this.HardReset.TabIndex = 13;
            this.HardReset.Text = "Reset To Origin Branch";
            this.HardReset.UseVisualStyleBackColor = true;
            this.HardReset.Visible = false;
            this.HardReset.Click += new System.EventHandler(this.HardReset_Click);
            // 
            // UpdateRepoButton
            // 
            this.UpdateRepoButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.UpdateRepoButton.Location = new System.Drawing.Point(722, 11);
            this.UpdateRepoButton.Name = "UpdateRepoButton";
            this.UpdateRepoButton.Size = new System.Drawing.Size(140, 29);
            this.UpdateRepoButton.TabIndex = 12;
            this.UpdateRepoButton.Text = "Merge from Remote";
            this.UpdateRepoButton.UseVisualStyleBackColor = true;
            this.UpdateRepoButton.Visible = false;
            this.UpdateRepoButton.Click += new System.EventHandler(this.UpdateRepoButton_Click);
            // 
            // MergePRButton
            // 
            this.MergePRButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.MergePRButton.Location = new System.Drawing.Point(722, 116);
            this.MergePRButton.Name = "MergePRButton";
            this.MergePRButton.Size = new System.Drawing.Size(140, 29);
            this.MergePRButton.TabIndex = 11;
            this.MergePRButton.Text = "Merge Pull Request";
            this.MergePRButton.UseVisualStyleBackColor = true;
            this.MergePRButton.Visible = false;
            this.MergePRButton.Click += new System.EventHandler(this.TestMergeButton_Click);
            // 
            // IdentityLabel
            // 
            this.IdentityLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.IdentityLabel.AutoSize = true;
            this.IdentityLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.IdentityLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.IdentityLabel.Location = new System.Drawing.Point(6, 142);
            this.IdentityLabel.Name = "IdentityLabel";
            this.IdentityLabel.Size = new System.Drawing.Size(116, 18);
            this.IdentityLabel.TabIndex = 8;
            this.IdentityLabel.Text = "Backup Tags:";
            this.IdentityLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.IdentityLabel.Visible = false;
            // 
            // TestMergeListTitle
            // 
            this.TestMergeListTitle.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.TestMergeListTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TestMergeListTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.TestMergeListTitle.Location = new System.Drawing.Point(6, 260);
            this.TestMergeListTitle.Name = "TestMergeListTitle";
            this.TestMergeListTitle.Size = new System.Drawing.Size(110, 41);
            this.TestMergeListTitle.TabIndex = 6;
            this.TestMergeListTitle.Text = "Active Test Merges:";
            this.TestMergeListTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.TestMergeListTitle.Visible = false;
            // 
            // RemoteNameTitle
            // 
            this.RemoteNameTitle.AutoSize = true;
            this.RemoteNameTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.RemoteNameTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.RemoteNameTitle.Location = new System.Drawing.Point(6, 46);
            this.RemoteNameTitle.Name = "RemoteNameTitle";
            this.RemoteNameTitle.Size = new System.Drawing.Size(78, 18);
            this.RemoteNameTitle.TabIndex = 5;
            this.RemoteNameTitle.Text = "Remote:";
            this.RemoteNameTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.RemoteNameTitle.Visible = false;
            // 
            // BranchNameTitle
            // 
            this.BranchNameTitle.AutoSize = true;
            this.BranchNameTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.BranchNameTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.BranchNameTitle.Location = new System.Drawing.Point(6, 72);
            this.BranchNameTitle.Name = "BranchNameTitle";
            this.BranchNameTitle.Size = new System.Drawing.Size(70, 18);
            this.BranchNameTitle.TabIndex = 4;
            this.BranchNameTitle.Text = "Branch:";
            this.BranchNameTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.BranchNameTitle.Visible = false;
            // 
            // CurrentRevisionTitle
            // 
            this.CurrentRevisionTitle.AutoSize = true;
            this.CurrentRevisionTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CurrentRevisionTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CurrentRevisionTitle.Location = new System.Drawing.Point(6, 14);
            this.CurrentRevisionTitle.Name = "CurrentRevisionTitle";
            this.CurrentRevisionTitle.Size = new System.Drawing.Size(150, 18);
            this.CurrentRevisionTitle.TabIndex = 3;
            this.CurrentRevisionTitle.Text = "Current Revision:";
            this.CurrentRevisionTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.CurrentRevisionTitle.Visible = false;
            // 
            // CloneRepositoryButton
            // 
            this.CloneRepositoryButton.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.CloneRepositoryButton.Location = new System.Drawing.Point(311, 191);
            this.CloneRepositoryButton.Name = "CloneRepositoryButton";
            this.CloneRepositoryButton.Size = new System.Drawing.Size(229, 34);
            this.CloneRepositoryButton.TabIndex = 2;
            this.CloneRepositoryButton.Text = "Clone Repository";
            this.CloneRepositoryButton.UseVisualStyleBackColor = true;
            this.CloneRepositoryButton.Visible = false;
            this.CloneRepositoryButton.Click += new System.EventHandler(this.CloneRepositoryButton_Click);
            // 
            // RepoProgressBarLabel
            // 
            this.RepoProgressBarLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoProgressBarLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.RepoProgressBarLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.RepoProgressBarLabel.Location = new System.Drawing.Point(184, 142);
            this.RepoProgressBarLabel.Name = "RepoProgressBarLabel";
            this.RepoProgressBarLabel.Size = new System.Drawing.Size(499, 46);
            this.RepoProgressBarLabel.TabIndex = 1;
            this.RepoProgressBarLabel.Text = "Searching for Repository...";
            this.RepoProgressBarLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // RepoProgressBar
            // 
            this.RepoProgressBar.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoProgressBar.Location = new System.Drawing.Point(184, 191);
            this.RepoProgressBar.Name = "RepoProgressBar";
            this.RepoProgressBar.Size = new System.Drawing.Size(499, 23);
            this.RepoProgressBar.Style = System.Windows.Forms.ProgressBarStyle.Marquee;
            this.RepoProgressBar.TabIndex = 0;
            // 
            // BYONDPanel
            // 
            this.BYONDPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.BYONDPanel.Controls.Add(this.LatestVersionLabel);
            this.BYONDPanel.Controls.Add(this.LatestVersionTitle);
            this.BYONDPanel.Controls.Add(this.StagedVersionLabel);
            this.BYONDPanel.Controls.Add(this.StagedVersionTitle);
            this.BYONDPanel.Controls.Add(this.StatusLabel);
            this.BYONDPanel.Controls.Add(this.VersionLabel);
            this.BYONDPanel.Controls.Add(this.VersionTitle);
            this.BYONDPanel.Controls.Add(this.MinorVersionLabel);
            this.BYONDPanel.Controls.Add(this.MajorVersionLabel);
            this.BYONDPanel.Controls.Add(this.UpdateButton);
            this.BYONDPanel.Controls.Add(this.MinorVersionNumeric);
            this.BYONDPanel.Controls.Add(this.MajorVersionNumeric);
            this.BYONDPanel.Controls.Add(this.UpdateProgressBar);
            this.BYONDPanel.Location = new System.Drawing.Point(4, 22);
            this.BYONDPanel.Name = "BYONDPanel";
            this.BYONDPanel.Size = new System.Drawing.Size(868, 366);
            this.BYONDPanel.TabIndex = 1;
            this.BYONDPanel.Text = "BYOND";
            // 
            // LatestVersionLabel
            // 
            this.LatestVersionLabel.AutoSize = true;
            this.LatestVersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LatestVersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.LatestVersionLabel.Location = new System.Drawing.Point(425, 93);
            this.LatestVersionLabel.Name = "LatestVersionLabel";
            this.LatestVersionLabel.Size = new System.Drawing.Size(82, 18);
            this.LatestVersionLabel.TabIndex = 13;
            this.LatestVersionLabel.Text = "Unknown";
            this.LatestVersionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // LatestVersionTitle
            // 
            this.LatestVersionTitle.AutoSize = true;
            this.LatestVersionTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.LatestVersionTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.LatestVersionTitle.Location = new System.Drawing.Point(286, 93);
            this.LatestVersionTitle.Name = "LatestVersionTitle";
            this.LatestVersionTitle.Size = new System.Drawing.Size(133, 18);
            this.LatestVersionTitle.TabIndex = 12;
            this.LatestVersionTitle.Text = "Latest Version:";
            this.LatestVersionTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // StagedVersionLabel
            // 
            this.StagedVersionLabel.AutoSize = true;
            this.StagedVersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StagedVersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.StagedVersionLabel.Location = new System.Drawing.Point(425, 131);
            this.StagedVersionLabel.Name = "StagedVersionLabel";
            this.StagedVersionLabel.Size = new System.Drawing.Size(82, 18);
            this.StagedVersionLabel.TabIndex = 11;
            this.StagedVersionLabel.Text = "Unknown";
            this.StagedVersionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.StagedVersionLabel.Visible = false;
            // 
            // StagedVersionTitle
            // 
            this.StagedVersionTitle.AutoSize = true;
            this.StagedVersionTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StagedVersionTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.StagedVersionTitle.Location = new System.Drawing.Point(282, 131);
            this.StagedVersionTitle.Name = "StagedVersionTitle";
            this.StagedVersionTitle.Size = new System.Drawing.Size(137, 18);
            this.StagedVersionTitle.TabIndex = 10;
            this.StagedVersionTitle.Text = "Staged version:";
            this.StagedVersionTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            this.StagedVersionTitle.Visible = false;
            // 
            // StatusLabel
            // 
            this.StatusLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StatusLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.StatusLabel.Location = new System.Drawing.Point(303, 320);
            this.StatusLabel.Name = "StatusLabel";
            this.StatusLabel.Size = new System.Drawing.Size(253, 37);
            this.StatusLabel.TabIndex = 9;
            this.StatusLabel.Text = "Idle";
            this.StatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // VersionLabel
            // 
            this.VersionLabel.AutoSize = true;
            this.VersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.VersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.VersionLabel.Location = new System.Drawing.Point(425, 56);
            this.VersionLabel.Name = "VersionLabel";
            this.VersionLabel.Size = new System.Drawing.Size(82, 18);
            this.VersionLabel.TabIndex = 8;
            this.VersionLabel.Text = "Unknown";
            this.VersionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            // 
            // VersionTitle
            // 
            this.VersionTitle.AutoSize = true;
            this.VersionTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.VersionTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.VersionTitle.Location = new System.Drawing.Point(265, 56);
            this.VersionTitle.Name = "VersionTitle";
            this.VersionTitle.Size = new System.Drawing.Size(154, 18);
            this.VersionTitle.TabIndex = 7;
            this.VersionTitle.Text = "Installed Version:";
            this.VersionTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // MinorVersionLabel
            // 
            this.MinorVersionLabel.AutoSize = true;
            this.MinorVersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.MinorVersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.MinorVersionLabel.Location = new System.Drawing.Point(521, 180);
            this.MinorVersionLabel.Name = "MinorVersionLabel";
            this.MinorVersionLabel.Size = new System.Drawing.Size(59, 18);
            this.MinorVersionLabel.TabIndex = 6;
            this.MinorVersionLabel.Text = "Minor:";
            this.MinorVersionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // MajorVersionLabel
            // 
            this.MajorVersionLabel.AutoSize = true;
            this.MajorVersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.MajorVersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.MajorVersionLabel.Location = new System.Drawing.Point(276, 180);
            this.MajorVersionLabel.Name = "MajorVersionLabel";
            this.MajorVersionLabel.Size = new System.Drawing.Size(60, 18);
            this.MajorVersionLabel.TabIndex = 5;
            this.MajorVersionLabel.Text = "Major:";
            this.MajorVersionLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // UpdateButton
            // 
            this.UpdateButton.Location = new System.Drawing.Point(372, 252);
            this.UpdateButton.Name = "UpdateButton";
            this.UpdateButton.Size = new System.Drawing.Size(118, 28);
            this.UpdateButton.TabIndex = 3;
            this.UpdateButton.Text = "Update";
            this.UpdateButton.UseVisualStyleBackColor = true;
            this.UpdateButton.Click += new System.EventHandler(this.UpdateButton_Click);
            // 
            // MinorVersionNumeric
            // 
            this.MinorVersionNumeric.Location = new System.Drawing.Point(490, 210);
            this.MinorVersionNumeric.Maximum = new decimal(new int[] {
            10000,
            0,
            0,
            0});
            this.MinorVersionNumeric.Name = "MinorVersionNumeric";
            this.MinorVersionNumeric.Size = new System.Drawing.Size(120, 20);
            this.MinorVersionNumeric.TabIndex = 2;
            this.MinorVersionNumeric.Value = new decimal(new int[] {
            1381,
            0,
            0,
            0});
            // 
            // MajorVersionNumeric
            // 
            this.MajorVersionNumeric.Location = new System.Drawing.Point(245, 210);
            this.MajorVersionNumeric.Maximum = new decimal(new int[] {
            1000,
            0,
            0,
            0});
            this.MajorVersionNumeric.Name = "MajorVersionNumeric";
            this.MajorVersionNumeric.Size = new System.Drawing.Size(120, 20);
            this.MajorVersionNumeric.TabIndex = 1;
            this.MajorVersionNumeric.Value = new decimal(new int[] {
            511,
            0,
            0,
            0});
            // 
            // UpdateProgressBar
            // 
            this.UpdateProgressBar.Location = new System.Drawing.Point(107, 286);
            this.UpdateProgressBar.MarqueeAnimationSpeed = 50;
            this.UpdateProgressBar.Name = "UpdateProgressBar";
            this.UpdateProgressBar.Size = new System.Drawing.Size(650, 31);
            this.UpdateProgressBar.TabIndex = 0;
            // 
            // ServerPanel
            // 
            this.ServerPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ServerPanel.Controls.Add(this.VisibilitySelector);
            this.ServerPanel.Controls.Add(this.VisibilityTitle);
            this.ServerPanel.Controls.Add(this.SecuritySelector);
            this.ServerPanel.Controls.Add(this.SecurityTitle);
            this.ServerPanel.Controls.Add(this.ResetTestmerge);
            this.ServerPanel.Controls.Add(this.NudgePortSelector);
            this.ServerPanel.Controls.Add(this.NudgePortLabel);
            this.ServerPanel.Controls.Add(this.ServerPathLabel);
            this.ServerPanel.Controls.Add(this.ServerPathTextbox);
            this.ServerPanel.Controls.Add(this.CompileCancelButton);
            this.ServerPanel.Controls.Add(this.ProjectPathLabel);
            this.ServerPanel.Controls.Add(this.projectNameText);
            this.ServerPanel.Controls.Add(this.PortLabel);
            this.ServerPanel.Controls.Add(this.PortSelector);
            this.ServerPanel.Controls.Add(this.ServerPRLabel);
            this.ServerPanel.Controls.Add(this.ServerTestmergeInput);
            this.ServerPanel.Controls.Add(this.TestmergeButton);
            this.ServerPanel.Controls.Add(this.UpdateTestmergeButton);
            this.ServerPanel.Controls.Add(this.UpdateMergeButton);
            this.ServerPanel.Controls.Add(this.UpdateHardButton);
            this.ServerPanel.Controls.Add(this.ServerGRestartButton);
            this.ServerPanel.Controls.Add(this.ServerGStopButton);
            this.ServerPanel.Controls.Add(this.ServerRestartButton);
            this.ServerPanel.Controls.Add(this.ServerStopButton);
            this.ServerPanel.Controls.Add(this.ServerStartButton);
            this.ServerPanel.Controls.Add(this.AutostartCheckbox);
            this.ServerPanel.Controls.Add(this.CompilerStatusLabel);
            this.ServerPanel.Controls.Add(this.CompilerLabel);
            this.ServerPanel.Controls.Add(this.compileButton);
            this.ServerPanel.Controls.Add(this.initializeButton);
            this.ServerPanel.Controls.Add(this.compilerProgressBar);
            this.ServerPanel.Controls.Add(this.ServerStatusLabel);
            this.ServerPanel.Controls.Add(this.ServerStatusTitle);
            this.ServerPanel.Location = new System.Drawing.Point(4, 22);
            this.ServerPanel.Name = "ServerPanel";
            this.ServerPanel.Padding = new System.Windows.Forms.Padding(3);
            this.ServerPanel.Size = new System.Drawing.Size(868, 366);
            this.ServerPanel.TabIndex = 2;
            this.ServerPanel.Text = "Server";
            // 
            // VisibilitySelector
            // 
            this.VisibilitySelector.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.VisibilitySelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.VisibilitySelector.FormattingEnabled = true;
            this.VisibilitySelector.Items.AddRange(new object[] {
            "Public",
            "Private",
            "Invisible"});
            this.VisibilitySelector.Location = new System.Drawing.Point(566, 136);
            this.VisibilitySelector.Name = "VisibilitySelector";
            this.VisibilitySelector.Size = new System.Drawing.Size(121, 21);
            this.VisibilitySelector.TabIndex = 40;
            this.VisibilitySelector.SelectedIndexChanged += new System.EventHandler(this.VisibilitySelector_SelectedIndexChanged);
            // 
            // VisibilityTitle
            // 
            this.VisibilityTitle.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.VisibilityTitle.AutoSize = true;
            this.VisibilityTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.VisibilityTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.VisibilityTitle.Location = new System.Drawing.Point(474, 139);
            this.VisibilityTitle.Name = "VisibilityTitle";
            this.VisibilityTitle.Size = new System.Drawing.Size(86, 18);
            this.VisibilityTitle.TabIndex = 39;
            this.VisibilityTitle.Text = "Visibility:";
            this.VisibilityTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // SecuritySelector
            // 
            this.SecuritySelector.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.SecuritySelector.FormattingEnabled = true;
            this.SecuritySelector.Items.AddRange(new object[] {
            "Trusted",
            "Safe",
            "Ultrasafe"});
            this.SecuritySelector.Location = new System.Drawing.Point(136, 136);
            this.SecuritySelector.Name = "SecuritySelector";
            this.SecuritySelector.Size = new System.Drawing.Size(121, 21);
            this.SecuritySelector.TabIndex = 38;
            this.SecuritySelector.SelectedIndexChanged += new System.EventHandler(this.SecuritySelector_SelectedIndexChanged);
            // 
            // SecurityTitle
            // 
            this.SecurityTitle.AutoSize = true;
            this.SecurityTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.SecurityTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.SecurityTitle.Location = new System.Drawing.Point(44, 139);
            this.SecurityTitle.Name = "SecurityTitle";
            this.SecurityTitle.Size = new System.Drawing.Size(80, 18);
            this.SecurityTitle.TabIndex = 37;
            this.SecurityTitle.Text = "Security:";
            this.SecurityTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ResetTestmerge
            // 
            this.ResetTestmerge.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ResetTestmerge.Location = new System.Drawing.Point(602, 95);
            this.ResetTestmerge.Name = "ResetTestmerge";
            this.ResetTestmerge.Size = new System.Drawing.Size(142, 28);
            this.ResetTestmerge.TabIndex = 36;
            this.ResetTestmerge.Text = "Reset and Recompile";
            this.ResetTestmerge.UseVisualStyleBackColor = true;
            this.ResetTestmerge.Click += new System.EventHandler(this.ResetTestmerge_Click);
            // 
            // NudgePortSelector
            // 
            this.NudgePortSelector.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.NudgePortSelector.Location = new System.Drawing.Point(806, 60);
            this.NudgePortSelector.Maximum = new decimal(new int[] {
            65535,
            0,
            0,
            0});
            this.NudgePortSelector.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.NudgePortSelector.Name = "NudgePortSelector";
            this.NudgePortSelector.Size = new System.Drawing.Size(62, 20);
            this.NudgePortSelector.TabIndex = 34;
            this.NudgePortSelector.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.NudgePortSelector.ValueChanged += new System.EventHandler(this.NudgePortSelector_ValueChanged);
            // 
            // NudgePortLabel
            // 
            this.NudgePortLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.NudgePortLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.NudgePortLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.NudgePortLabel.Location = new System.Drawing.Point(745, 45);
            this.NudgePortLabel.Name = "NudgePortLabel";
            this.NudgePortLabel.Size = new System.Drawing.Size(61, 44);
            this.NudgePortLabel.TabIndex = 35;
            this.NudgePortLabel.Text = "Nudge Port:";
            this.NudgePortLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ServerPathLabel
            // 
            this.ServerPathLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.ServerPathLabel.AutoSize = true;
            this.ServerPathLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ServerPathLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ServerPathLabel.Location = new System.Drawing.Point(15, 165);
            this.ServerPathLabel.Name = "ServerPathLabel";
            this.ServerPathLabel.Size = new System.Drawing.Size(109, 18);
            this.ServerPathLabel.TabIndex = 33;
            this.ServerPathLabel.Text = "Server Path:";
            this.ServerPathLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ServerPathTextbox
            // 
            this.ServerPathTextbox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.ServerPathTextbox.Location = new System.Drawing.Point(136, 163);
            this.ServerPathTextbox.Name = "ServerPathTextbox";
            this.ServerPathTextbox.Size = new System.Drawing.Size(296, 20);
            this.ServerPathTextbox.TabIndex = 32;
            // 
            // CompileCancelButton
            // 
            this.CompileCancelButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.CompileCancelButton.Enabled = false;
            this.CompileCancelButton.Location = new System.Drawing.Point(737, 302);
            this.CompileCancelButton.Name = "CompileCancelButton";
            this.CompileCancelButton.Size = new System.Drawing.Size(69, 31);
            this.CompileCancelButton.TabIndex = 31;
            this.CompileCancelButton.Text = "Cancel";
            this.CompileCancelButton.UseVisualStyleBackColor = true;
            this.CompileCancelButton.Click += new System.EventHandler(this.CompileCancelButton_Click);
            // 
            // ProjectPathLabel
            // 
            this.ProjectPathLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.ProjectPathLabel.AutoSize = true;
            this.ProjectPathLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ProjectPathLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ProjectPathLabel.Location = new System.Drawing.Point(445, 165);
            this.ProjectPathLabel.Name = "ProjectPathLabel";
            this.ProjectPathLabel.Size = new System.Drawing.Size(115, 18);
            this.ProjectPathLabel.TabIndex = 30;
            this.ProjectPathLabel.Text = "Project Path:";
            this.ProjectPathLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // projectNameText
            // 
            this.projectNameText.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.projectNameText.Location = new System.Drawing.Point(566, 163);
            this.projectNameText.Name = "projectNameText";
            this.projectNameText.Size = new System.Drawing.Size(296, 20);
            this.projectNameText.TabIndex = 29;
            // 
            // PortLabel
            // 
            this.PortLabel.AutoSize = true;
            this.PortLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.PortLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.PortLabel.Location = new System.Drawing.Point(4, 60);
            this.PortLabel.Name = "PortLabel";
            this.PortLabel.Size = new System.Drawing.Size(48, 18);
            this.PortLabel.TabIndex = 28;
            this.PortLabel.Text = "Port:";
            this.PortLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // PortSelector
            // 
            this.PortSelector.Location = new System.Drawing.Point(59, 60);
            this.PortSelector.Maximum = new decimal(new int[] {
            65535,
            0,
            0,
            0});
            this.PortSelector.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.PortSelector.Name = "PortSelector";
            this.PortSelector.Size = new System.Drawing.Size(60, 20);
            this.PortSelector.TabIndex = 27;
            this.PortSelector.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.PortSelector.ValueChanged += new System.EventHandler(this.PortSelector_ValueChanged);
            // 
            // ServerPRLabel
            // 
            this.ServerPRLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ServerPRLabel.AutoSize = true;
            this.ServerPRLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ServerPRLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ServerPRLabel.Location = new System.Drawing.Point(745, 101);
            this.ServerPRLabel.Name = "ServerPRLabel";
            this.ServerPRLabel.Size = new System.Drawing.Size(49, 18);
            this.ServerPRLabel.TabIndex = 26;
            this.ServerPRLabel.Text = "PR#:";
            this.ServerPRLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ServerTestmergeInput
            // 
            this.ServerTestmergeInput.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ServerTestmergeInput.Location = new System.Drawing.Point(806, 99);
            this.ServerTestmergeInput.Maximum = new decimal(new int[] {
            1000000,
            0,
            0,
            0});
            this.ServerTestmergeInput.Name = "ServerTestmergeInput";
            this.ServerTestmergeInput.Size = new System.Drawing.Size(62, 20);
            this.ServerTestmergeInput.TabIndex = 25;
            // 
            // TestmergeButton
            // 
            this.TestmergeButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.TestmergeButton.Location = new System.Drawing.Point(454, 95);
            this.TestmergeButton.Name = "TestmergeButton";
            this.TestmergeButton.Size = new System.Drawing.Size(142, 28);
            this.TestmergeButton.TabIndex = 24;
            this.TestmergeButton.Text = "Testmerge";
            this.TestmergeButton.UseVisualStyleBackColor = true;
            this.TestmergeButton.Click += new System.EventHandler(this.TestmergeButton_Click);
            // 
            // UpdateTestmergeButton
            // 
            this.UpdateTestmergeButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.UpdateTestmergeButton.Location = new System.Drawing.Point(306, 95);
            this.UpdateTestmergeButton.Name = "UpdateTestmergeButton";
            this.UpdateTestmergeButton.Size = new System.Drawing.Size(142, 28);
            this.UpdateTestmergeButton.TabIndex = 23;
            this.UpdateTestmergeButton.Text = "Update and Testmerge";
            this.UpdateTestmergeButton.UseVisualStyleBackColor = true;
            this.UpdateTestmergeButton.Click += new System.EventHandler(this.UpdateTestmergeButton_Click);
            // 
            // UpdateMergeButton
            // 
            this.UpdateMergeButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.UpdateMergeButton.Location = new System.Drawing.Point(158, 95);
            this.UpdateMergeButton.Name = "UpdateMergeButton";
            this.UpdateMergeButton.Size = new System.Drawing.Size(142, 28);
            this.UpdateMergeButton.TabIndex = 22;
            this.UpdateMergeButton.Text = "Update (KeepTestmerge)";
            this.UpdateMergeButton.UseVisualStyleBackColor = true;
            this.UpdateMergeButton.Click += new System.EventHandler(this.UpdateMergeButton_Click);
            // 
            // UpdateHardButton
            // 
            this.UpdateHardButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.UpdateHardButton.Location = new System.Drawing.Point(7, 95);
            this.UpdateHardButton.Name = "UpdateHardButton";
            this.UpdateHardButton.Size = new System.Drawing.Size(145, 28);
            this.UpdateHardButton.TabIndex = 21;
            this.UpdateHardButton.Text = "Update (Reset Testmerge)";
            this.UpdateHardButton.UseVisualStyleBackColor = true;
            this.UpdateHardButton.Click += new System.EventHandler(this.UpdateHardButton_Click);
            // 
            // ServerGRestartButton
            // 
            this.ServerGRestartButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerGRestartButton.Location = new System.Drawing.Point(626, 54);
            this.ServerGRestartButton.Name = "ServerGRestartButton";
            this.ServerGRestartButton.Size = new System.Drawing.Size(118, 28);
            this.ServerGRestartButton.TabIndex = 20;
            this.ServerGRestartButton.Text = "Graceful Restart";
            this.ServerGRestartButton.UseVisualStyleBackColor = true;
            this.ServerGRestartButton.Click += new System.EventHandler(this.ServerGRestartButton_Click);
            // 
            // ServerGStopButton
            // 
            this.ServerGStopButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerGStopButton.Location = new System.Drawing.Point(502, 54);
            this.ServerGStopButton.Name = "ServerGStopButton";
            this.ServerGStopButton.Size = new System.Drawing.Size(118, 28);
            this.ServerGStopButton.TabIndex = 19;
            this.ServerGStopButton.Text = "Graceful Stop";
            this.ServerGStopButton.UseVisualStyleBackColor = true;
            this.ServerGStopButton.Click += new System.EventHandler(this.ServerGStopButton_Click);
            // 
            // ServerRestartButton
            // 
            this.ServerRestartButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerRestartButton.Location = new System.Drawing.Point(378, 54);
            this.ServerRestartButton.Name = "ServerRestartButton";
            this.ServerRestartButton.Size = new System.Drawing.Size(118, 28);
            this.ServerRestartButton.TabIndex = 18;
            this.ServerRestartButton.Text = "Restart";
            this.ServerRestartButton.UseVisualStyleBackColor = true;
            this.ServerRestartButton.Click += new System.EventHandler(this.ServerRestartButton_Click);
            // 
            // ServerStopButton
            // 
            this.ServerStopButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerStopButton.Location = new System.Drawing.Point(254, 54);
            this.ServerStopButton.Name = "ServerStopButton";
            this.ServerStopButton.Size = new System.Drawing.Size(118, 28);
            this.ServerStopButton.TabIndex = 17;
            this.ServerStopButton.Text = "Stop";
            this.ServerStopButton.UseVisualStyleBackColor = true;
            this.ServerStopButton.Click += new System.EventHandler(this.ServerStopButton_Click);
            // 
            // ServerStartButton
            // 
            this.ServerStartButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerStartButton.Location = new System.Drawing.Point(130, 54);
            this.ServerStartButton.Name = "ServerStartButton";
            this.ServerStartButton.Size = new System.Drawing.Size(118, 28);
            this.ServerStartButton.TabIndex = 16;
            this.ServerStartButton.Text = "Start";
            this.ServerStartButton.UseVisualStyleBackColor = true;
            this.ServerStartButton.Click += new System.EventHandler(this.ServerStartButton_Click);
            // 
            // AutostartCheckbox
            // 
            this.AutostartCheckbox.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.AutostartCheckbox.AutoSize = true;
            this.AutostartCheckbox.Font = new System.Drawing.Font("Verdana", 12F);
            this.AutostartCheckbox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AutostartCheckbox.Location = new System.Drawing.Point(758, 17);
            this.AutostartCheckbox.Name = "AutostartCheckbox";
            this.AutostartCheckbox.Size = new System.Drawing.Size(104, 22);
            this.AutostartCheckbox.TabIndex = 15;
            this.AutostartCheckbox.Text = "Autostart";
            this.AutostartCheckbox.UseVisualStyleBackColor = true;
            this.AutostartCheckbox.CheckedChanged += new System.EventHandler(this.AutostartCheckbox_CheckedChanged);
            // 
            // CompilerStatusLabel
            // 
            this.CompilerStatusLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.CompilerStatusLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CompilerStatusLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CompilerStatusLabel.Location = new System.Drawing.Point(110, 271);
            this.CompilerStatusLabel.Name = "CompilerStatusLabel";
            this.CompilerStatusLabel.Size = new System.Drawing.Size(618, 28);
            this.CompilerStatusLabel.TabIndex = 14;
            this.CompilerStatusLabel.Text = "Idle";
            this.CompilerStatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // CompilerLabel
            // 
            this.CompilerLabel.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.CompilerLabel.AutoSize = true;
            this.CompilerLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CompilerLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CompilerLabel.Location = new System.Drawing.Point(379, 203);
            this.CompilerLabel.Name = "CompilerLabel";
            this.CompilerLabel.Size = new System.Drawing.Size(80, 18);
            this.CompilerLabel.TabIndex = 13;
            this.CompilerLabel.Text = "Compiler";
            this.CompilerLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // compileButton
            // 
            this.compileButton.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.compileButton.Enabled = false;
            this.compileButton.Location = new System.Drawing.Point(456, 240);
            this.compileButton.Name = "compileButton";
            this.compileButton.Size = new System.Drawing.Size(159, 28);
            this.compileButton.TabIndex = 12;
            this.compileButton.Text = "Copy from Repo and Compile";
            this.compileButton.UseVisualStyleBackColor = true;
            this.compileButton.Click += new System.EventHandler(this.CompileButton_Click);
            // 
            // initializeButton
            // 
            this.initializeButton.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            this.initializeButton.Enabled = false;
            this.initializeButton.Location = new System.Drawing.Point(219, 240);
            this.initializeButton.Name = "initializeButton";
            this.initializeButton.Size = new System.Drawing.Size(159, 28);
            this.initializeButton.TabIndex = 11;
            this.initializeButton.Text = "Initialize Game Folders";
            this.initializeButton.UseVisualStyleBackColor = true;
            this.initializeButton.Click += new System.EventHandler(this.InitializeButton_Click);
            // 
            // compilerProgressBar
            // 
            this.compilerProgressBar.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.compilerProgressBar.Location = new System.Drawing.Point(110, 302);
            this.compilerProgressBar.MarqueeAnimationSpeed = 50;
            this.compilerProgressBar.Name = "compilerProgressBar";
            this.compilerProgressBar.Size = new System.Drawing.Size(618, 31);
            this.compilerProgressBar.TabIndex = 10;
            // 
            // ServerStatusLabel
            // 
            this.ServerStatusLabel.AutoSize = true;
            this.ServerStatusLabel.Font = new System.Drawing.Font("Verdana", 10F);
            this.ServerStatusLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ServerStatusLabel.Location = new System.Drawing.Point(136, 19);
            this.ServerStatusLabel.Name = "ServerStatusLabel";
            this.ServerStatusLabel.Size = new System.Drawing.Size(73, 17);
            this.ServerStatusLabel.TabIndex = 9;
            this.ServerStatusLabel.Text = "Unknown";
            this.ServerStatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ServerStatusTitle
            // 
            this.ServerStatusTitle.AutoSize = true;
            this.ServerStatusTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ServerStatusTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ServerStatusTitle.Location = new System.Drawing.Point(15, 17);
            this.ServerStatusTitle.Name = "ServerStatusTitle";
            this.ServerStatusTitle.Size = new System.Drawing.Size(125, 18);
            this.ServerStatusTitle.TabIndex = 8;
            this.ServerStatusTitle.Text = "Server Status:";
            this.ServerStatusTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatPanel
            // 
            this.ChatPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ChatPanel.Controls.Add(this.ChatRefreshButton);
            this.ChatPanel.Controls.Add(this.ChatNicknameText);
            this.ChatPanel.Controls.Add(this.ChatNicknameTitle);
            this.ChatPanel.Controls.Add(this.ChatPortSelector);
            this.ChatPanel.Controls.Add(this.ChatPortTitle);
            this.ChatPanel.Controls.Add(this.ChatServerText);
            this.ChatPanel.Controls.Add(this.ChatServerTitle);
            this.ChatPanel.Controls.Add(this.ChatApplyButton);
            this.ChatPanel.Controls.Add(this.AuthField2Title);
            this.ChatPanel.Controls.Add(this.AuthField1Title);
            this.ChatPanel.Controls.Add(this.AuthField2);
            this.ChatPanel.Controls.Add(this.AuthField1);
            this.ChatPanel.Controls.Add(this.AdminChannelTitle);
            this.ChatPanel.Controls.Add(this.AdminChannelText);
            this.ChatPanel.Controls.Add(this.ChatReconnectButton);
            this.ChatPanel.Controls.Add(this.ChatStatusLabel);
            this.ChatPanel.Controls.Add(this.ChatStatusTitle);
            this.ChatPanel.Controls.Add(this.ChatEnabledCheckbox);
            this.ChatPanel.Controls.Add(this.ChatProviderSelectorPanel);
            this.ChatPanel.Controls.Add(this.ChatProviderTitle);
            this.ChatPanel.Controls.Add(this.ChannelsTitle);
            this.ChatPanel.Controls.Add(this.ChatAdminsTextBox);
            this.ChatPanel.Controls.Add(this.ChatAdminsTitle);
            this.ChatPanel.Controls.Add(this.ChatChannelsTextBox);
            this.ChatPanel.Location = new System.Drawing.Point(4, 22);
            this.ChatPanel.Name = "ChatPanel";
            this.ChatPanel.Padding = new System.Windows.Forms.Padding(3);
            this.ChatPanel.Size = new System.Drawing.Size(868, 366);
            this.ChatPanel.TabIndex = 4;
            this.ChatPanel.Text = "Chat";
            // 
            // ChatRefreshButton
            // 
            this.ChatRefreshButton.Location = new System.Drawing.Point(174, 335);
            this.ChatRefreshButton.Name = "ChatRefreshButton";
            this.ChatRefreshButton.Size = new System.Drawing.Size(112, 25);
            this.ChatRefreshButton.TabIndex = 32;
            this.ChatRefreshButton.Text = "Refresh";
            this.ChatRefreshButton.UseVisualStyleBackColor = true;
            this.ChatRefreshButton.Click += new System.EventHandler(this.ChatRefreshButton_Click);
            // 
            // ChatNicknameText
            // 
            this.ChatNicknameText.Location = new System.Drawing.Point(174, 251);
            this.ChatNicknameText.Name = "ChatNicknameText";
            this.ChatNicknameText.Size = new System.Drawing.Size(151, 20);
            this.ChatNicknameText.TabIndex = 31;
            // 
            // ChatNicknameTitle
            // 
            this.ChatNicknameTitle.AutoSize = true;
            this.ChatNicknameTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatNicknameTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatNicknameTitle.Location = new System.Drawing.Point(30, 250);
            this.ChatNicknameTitle.Name = "ChatNicknameTitle";
            this.ChatNicknameTitle.Size = new System.Drawing.Size(94, 18);
            this.ChatNicknameTitle.TabIndex = 30;
            this.ChatNicknameTitle.Text = "Nickname:";
            this.ChatNicknameTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatPortSelector
            // 
            this.ChatPortSelector.Location = new System.Drawing.Point(174, 225);
            this.ChatPortSelector.Maximum = new decimal(new int[] {
            65535,
            0,
            0,
            0});
            this.ChatPortSelector.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.ChatPortSelector.Name = "ChatPortSelector";
            this.ChatPortSelector.Size = new System.Drawing.Size(151, 20);
            this.ChatPortSelector.TabIndex = 29;
            this.ChatPortSelector.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            // 
            // ChatPortTitle
            // 
            this.ChatPortTitle.AutoSize = true;
            this.ChatPortTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatPortTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatPortTitle.Location = new System.Drawing.Point(30, 227);
            this.ChatPortTitle.Name = "ChatPortTitle";
            this.ChatPortTitle.Size = new System.Drawing.Size(48, 18);
            this.ChatPortTitle.TabIndex = 28;
            this.ChatPortTitle.Text = "Port:";
            this.ChatPortTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatServerText
            // 
            this.ChatServerText.Location = new System.Drawing.Point(174, 199);
            this.ChatServerText.Name = "ChatServerText";
            this.ChatServerText.Size = new System.Drawing.Size(151, 20);
            this.ChatServerText.TabIndex = 27;
            // 
            // ChatServerTitle
            // 
            this.ChatServerTitle.AutoSize = true;
            this.ChatServerTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatServerTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatServerTitle.Location = new System.Drawing.Point(30, 201);
            this.ChatServerTitle.Name = "ChatServerTitle";
            this.ChatServerTitle.Size = new System.Drawing.Size(66, 18);
            this.ChatServerTitle.TabIndex = 26;
            this.ChatServerTitle.Text = "Server:";
            this.ChatServerTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatApplyButton
            // 
            this.ChatApplyButton.Location = new System.Drawing.Point(56, 335);
            this.ChatApplyButton.Name = "ChatApplyButton";
            this.ChatApplyButton.Size = new System.Drawing.Size(112, 25);
            this.ChatApplyButton.TabIndex = 25;
            this.ChatApplyButton.Text = "Apply";
            this.ChatApplyButton.UseVisualStyleBackColor = true;
            this.ChatApplyButton.Click += new System.EventHandler(this.ChatApplyButton_Click);
            // 
            // AuthField2Title
            // 
            this.AuthField2Title.AutoSize = true;
            this.AuthField2Title.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.AuthField2Title.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AuthField2Title.Location = new System.Drawing.Point(30, 311);
            this.AuthField2Title.Name = "AuthField2Title";
            this.AuthField2Title.Size = new System.Drawing.Size(45, 18);
            this.AuthField2Title.TabIndex = 24;
            this.AuthField2Title.Text = "AF2:";
            this.AuthField2Title.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // AuthField1Title
            // 
            this.AuthField1Title.AutoSize = true;
            this.AuthField1Title.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.AuthField1Title.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AuthField1Title.Location = new System.Drawing.Point(30, 285);
            this.AuthField1Title.Name = "AuthField1Title";
            this.AuthField1Title.Size = new System.Drawing.Size(45, 18);
            this.AuthField1Title.TabIndex = 23;
            this.AuthField1Title.Text = "AF1:";
            this.AuthField1Title.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // AuthField2
            // 
            this.AuthField2.Location = new System.Drawing.Point(174, 309);
            this.AuthField2.Name = "AuthField2";
            this.AuthField2.Size = new System.Drawing.Size(151, 20);
            this.AuthField2.TabIndex = 22;
            this.AuthField2.UseSystemPasswordChar = true;
            // 
            // AuthField1
            // 
            this.AuthField1.Location = new System.Drawing.Point(174, 283);
            this.AuthField1.Name = "AuthField1";
            this.AuthField1.Size = new System.Drawing.Size(151, 20);
            this.AuthField1.TabIndex = 21;
            this.AuthField1.UseSystemPasswordChar = true;
            // 
            // AdminChannelTitle
            // 
            this.AdminChannelTitle.AutoSize = true;
            this.AdminChannelTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.AdminChannelTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AdminChannelTitle.Location = new System.Drawing.Point(30, 174);
            this.AdminChannelTitle.Name = "AdminChannelTitle";
            this.AdminChannelTitle.Size = new System.Drawing.Size(138, 18);
            this.AdminChannelTitle.TabIndex = 20;
            this.AdminChannelTitle.Text = "Admin Channel:";
            this.AdminChannelTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // AdminChannelText
            // 
            this.AdminChannelText.Location = new System.Drawing.Point(174, 172);
            this.AdminChannelText.Name = "AdminChannelText";
            this.AdminChannelText.Size = new System.Drawing.Size(149, 20);
            this.AdminChannelText.TabIndex = 19;
            // 
            // ChatReconnectButton
            // 
            this.ChatReconnectButton.Enabled = false;
            this.ChatReconnectButton.Location = new System.Drawing.Point(174, 141);
            this.ChatReconnectButton.Name = "ChatReconnectButton";
            this.ChatReconnectButton.Size = new System.Drawing.Size(112, 25);
            this.ChatReconnectButton.TabIndex = 18;
            this.ChatReconnectButton.Text = "Reconnect";
            this.ChatReconnectButton.UseVisualStyleBackColor = true;
            this.ChatReconnectButton.Click += new System.EventHandler(this.ChatReconnectButton_Click);
            // 
            // ChatStatusLabel
            // 
            this.ChatStatusLabel.AutoSize = true;
            this.ChatStatusLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatStatusLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatStatusLabel.Location = new System.Drawing.Point(171, 113);
            this.ChatStatusLabel.Name = "ChatStatusLabel";
            this.ChatStatusLabel.Size = new System.Drawing.Size(82, 18);
            this.ChatStatusLabel.TabIndex = 17;
            this.ChatStatusLabel.Text = "Unknown";
            this.ChatStatusLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatStatusTitle
            // 
            this.ChatStatusTitle.AutoSize = true;
            this.ChatStatusTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatStatusTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatStatusTitle.Location = new System.Drawing.Point(30, 113);
            this.ChatStatusTitle.Name = "ChatStatusTitle";
            this.ChatStatusTitle.Size = new System.Drawing.Size(112, 18);
            this.ChatStatusTitle.TabIndex = 16;
            this.ChatStatusTitle.Text = "Chat Status:";
            this.ChatStatusTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatEnabledCheckbox
            // 
            this.ChatEnabledCheckbox.AutoSize = true;
            this.ChatEnabledCheckbox.Font = new System.Drawing.Font("Verdana", 12F);
            this.ChatEnabledCheckbox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatEnabledCheckbox.Location = new System.Drawing.Point(32, 142);
            this.ChatEnabledCheckbox.Name = "ChatEnabledCheckbox";
            this.ChatEnabledCheckbox.Size = new System.Drawing.Size(136, 22);
            this.ChatEnabledCheckbox.TabIndex = 15;
            this.ChatEnabledCheckbox.Text = "Chat Enabled";
            this.ChatEnabledCheckbox.UseVisualStyleBackColor = true;
            // 
            // ChatProviderSelectorPanel
            // 
            this.ChatProviderSelectorPanel.Controls.Add(this.DiscordProviderSwitch);
            this.ChatProviderSelectorPanel.Controls.Add(this.IRCProviderSwitch);
            this.ChatProviderSelectorPanel.Location = new System.Drawing.Point(23, 49);
            this.ChatProviderSelectorPanel.Name = "ChatProviderSelectorPanel";
            this.ChatProviderSelectorPanel.Size = new System.Drawing.Size(302, 50);
            this.ChatProviderSelectorPanel.TabIndex = 14;
            // 
            // DiscordProviderSwitch
            // 
            this.DiscordProviderSwitch.AutoSize = true;
            this.DiscordProviderSwitch.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.DiscordProviderSwitch.Location = new System.Drawing.Point(220, 17);
            this.DiscordProviderSwitch.Name = "DiscordProviderSwitch";
            this.DiscordProviderSwitch.Size = new System.Drawing.Size(61, 17);
            this.DiscordProviderSwitch.TabIndex = 13;
            this.DiscordProviderSwitch.TabStop = true;
            this.DiscordProviderSwitch.Text = "Discord";
            this.DiscordProviderSwitch.UseVisualStyleBackColor = true;
            this.DiscordProviderSwitch.CheckedChanged += new System.EventHandler(this.DiscordProviderSwitch_CheckedChanged);
            // 
            // IRCProviderSwitch
            // 
            this.IRCProviderSwitch.AutoSize = true;
            this.IRCProviderSwitch.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.IRCProviderSwitch.Location = new System.Drawing.Point(14, 17);
            this.IRCProviderSwitch.Name = "IRCProviderSwitch";
            this.IRCProviderSwitch.Size = new System.Drawing.Size(116, 17);
            this.IRCProviderSwitch.TabIndex = 12;
            this.IRCProviderSwitch.TabStop = true;
            this.IRCProviderSwitch.Text = "Internet Relay Chat";
            this.IRCProviderSwitch.UseVisualStyleBackColor = true;
            this.IRCProviderSwitch.CheckedChanged += new System.EventHandler(this.IRCProviderSwitch_CheckedChanged);
            // 
            // ChatProviderTitle
            // 
            this.ChatProviderTitle.AutoSize = true;
            this.ChatProviderTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatProviderTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatProviderTitle.Location = new System.Drawing.Point(20, 15);
            this.ChatProviderTitle.Name = "ChatProviderTitle";
            this.ChatProviderTitle.Size = new System.Drawing.Size(125, 18);
            this.ChatProviderTitle.TabIndex = 13;
            this.ChatProviderTitle.Text = "Chat Provider:";
            this.ChatProviderTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChannelsTitle
            // 
            this.ChannelsTitle.AutoSize = true;
            this.ChannelsTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChannelsTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChannelsTitle.Location = new System.Drawing.Point(628, 15);
            this.ChannelsTitle.Name = "ChannelsTitle";
            this.ChannelsTitle.Size = new System.Drawing.Size(234, 18);
            this.ChannelsTitle.TabIndex = 11;
            this.ChannelsTitle.Text = "Listen/Broadcast Channels:";
            this.ChannelsTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatAdminsTextBox
            // 
            this.ChatAdminsTextBox.Location = new System.Drawing.Point(369, 49);
            this.ChatAdminsTextBox.Multiline = true;
            this.ChatAdminsTextBox.Name = "ChatAdminsTextBox";
            this.ChatAdminsTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ChatAdminsTextBox.Size = new System.Drawing.Size(231, 311);
            this.ChatAdminsTextBox.TabIndex = 10;
            // 
            // ChatAdminsTitle
            // 
            this.ChatAdminsTitle.AutoSize = true;
            this.ChatAdminsTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ChatAdminsTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ChatAdminsTitle.Location = new System.Drawing.Point(366, 15);
            this.ChatAdminsTitle.Name = "ChatAdminsTitle";
            this.ChatAdminsTitle.Size = new System.Drawing.Size(75, 18);
            this.ChatAdminsTitle.TabIndex = 9;
            this.ChatAdminsTitle.Text = "Admins:";
            this.ChatAdminsTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ChatChannelsTextBox
            // 
            this.ChatChannelsTextBox.Location = new System.Drawing.Point(631, 49);
            this.ChatChannelsTextBox.Multiline = true;
            this.ChatChannelsTextBox.Name = "ChatChannelsTextBox";
            this.ChatChannelsTextBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.ChatChannelsTextBox.Size = new System.Drawing.Size(231, 311);
            this.ChatChannelsTextBox.TabIndex = 0;
            // 
            // ConfigPanel
            // 
            this.ConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ConfigPanel.Controls.Add(this.ConfigApply);
            this.ConfigPanel.Controls.Add(this.ConfigDownloadRepo);
            this.ConfigPanel.Controls.Add(this.ConfigUpload);
            this.ConfigPanel.Controls.Add(this.ConfigDownload);
            this.ConfigPanel.Controls.Add(this.ConfigRefresh);
            this.ConfigPanel.Controls.Add(this.ConfigPanels);
            this.ConfigPanel.Controls.Add(this.ConfigDisabledLabel);
            this.ConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.ConfigPanel.Name = "ConfigPanel";
            this.ConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.ConfigPanel.Size = new System.Drawing.Size(868, 366);
            this.ConfigPanel.TabIndex = 5;
            this.ConfigPanel.Text = "Config";
            // 
            // ConfigApply
            // 
            this.ConfigApply.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigApply.Location = new System.Drawing.Point(782, 26);
            this.ConfigApply.Name = "ConfigApply";
            this.ConfigApply.Size = new System.Drawing.Size(63, 22);
            this.ConfigApply.TabIndex = 4;
            this.ConfigApply.Text = "Apply";
            this.ConfigApply.UseVisualStyleBackColor = true;
            this.ConfigApply.Click += new System.EventHandler(this.ConfigApply_Click);
            // 
            // ConfigDownloadRepo
            // 
            this.ConfigDownloadRepo.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigDownloadRepo.Location = new System.Drawing.Point(782, 110);
            this.ConfigDownloadRepo.Name = "ConfigDownloadRepo";
            this.ConfigDownloadRepo.Size = new System.Drawing.Size(63, 22);
            this.ConfigDownloadRepo.TabIndex = 8;
            this.ConfigDownloadRepo.Text = "DL Repo";
            this.ConfigDownloadRepo.UseVisualStyleBackColor = true;
            this.ConfigDownloadRepo.Click += new System.EventHandler(this.ConfigDownloadRepo_Click);
            // 
            // ConfigUpload
            // 
            this.ConfigUpload.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigUpload.Location = new System.Drawing.Point(782, 138);
            this.ConfigUpload.Name = "ConfigUpload";
            this.ConfigUpload.Size = new System.Drawing.Size(63, 22);
            this.ConfigUpload.TabIndex = 7;
            this.ConfigUpload.Text = "Upload";
            this.ConfigUpload.UseVisualStyleBackColor = true;
            this.ConfigUpload.Click += new System.EventHandler(this.ConfigUpload_Click);
            // 
            // ConfigDownload
            // 
            this.ConfigDownload.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigDownload.Location = new System.Drawing.Point(782, 82);
            this.ConfigDownload.Name = "ConfigDownload";
            this.ConfigDownload.Size = new System.Drawing.Size(63, 22);
            this.ConfigDownload.TabIndex = 6;
            this.ConfigDownload.Text = "Download";
            this.ConfigDownload.UseVisualStyleBackColor = true;
            this.ConfigDownload.Click += new System.EventHandler(this.ConfigDownload_Click);
            // 
            // ConfigRefresh
            // 
            this.ConfigRefresh.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigRefresh.Location = new System.Drawing.Point(782, 54);
            this.ConfigRefresh.Name = "ConfigRefresh";
            this.ConfigRefresh.Size = new System.Drawing.Size(63, 22);
            this.ConfigRefresh.TabIndex = 5;
            this.ConfigRefresh.Text = "Refresh";
            this.ConfigRefresh.UseVisualStyleBackColor = true;
            this.ConfigRefresh.Click += new System.EventHandler(this.ConfigRefresh_Click);
            // 
            // ConfigPanels
            // 
            this.ConfigPanels.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigPanels.Controls.Add(this.ConfigConfigPanel);
            this.ConfigPanels.Controls.Add(this.DatabaseConfigPanel);
            this.ConfigPanels.Controls.Add(this.GameConfigPanel);
            this.ConfigPanels.Controls.Add(this.JobsConfigPanel);
            this.ConfigPanels.Controls.Add(this.MapsConfigPanel);
            this.ConfigPanels.Controls.Add(this.AdminsPanel);
            this.ConfigPanels.Location = new System.Drawing.Point(-4, 0);
            this.ConfigPanels.Name = "ConfigPanels";
            this.ConfigPanels.SelectedIndex = 0;
            this.ConfigPanels.Size = new System.Drawing.Size(876, 370);
            this.ConfigPanels.TabIndex = 0;
            // 
            // ConfigConfigPanel
            // 
            this.ConfigConfigPanel.AutoScroll = true;
            this.ConfigConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ConfigConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.ConfigConfigPanel.Name = "ConfigConfigPanel";
            this.ConfigConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.ConfigConfigPanel.Size = new System.Drawing.Size(868, 344);
            this.ConfigConfigPanel.TabIndex = 0;
            this.ConfigConfigPanel.Text = "General";
            // 
            // DatabaseConfigPanel
            // 
            this.DatabaseConfigPanel.AutoScroll = true;
            this.DatabaseConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.DatabaseConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.DatabaseConfigPanel.Name = "DatabaseConfigPanel";
            this.DatabaseConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.DatabaseConfigPanel.Size = new System.Drawing.Size(868, 344);
            this.DatabaseConfigPanel.TabIndex = 1;
            this.DatabaseConfigPanel.Text = "Database";
            // 
            // GameConfigPanel
            // 
            this.GameConfigPanel.AutoScroll = true;
            this.GameConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.GameConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.GameConfigPanel.Name = "GameConfigPanel";
            this.GameConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.GameConfigPanel.Size = new System.Drawing.Size(868, 344);
            this.GameConfigPanel.TabIndex = 2;
            this.GameConfigPanel.Text = "Game";
            // 
            // JobsConfigPanel
            // 
            this.JobsConfigPanel.AutoScroll = true;
            this.JobsConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.JobsConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.JobsConfigPanel.Name = "JobsConfigPanel";
            this.JobsConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.JobsConfigPanel.Size = new System.Drawing.Size(868, 344);
            this.JobsConfigPanel.TabIndex = 3;
            this.JobsConfigPanel.Text = "Jobs";
            // 
            // MapsConfigPanel
            // 
            this.MapsConfigPanel.AutoScroll = true;
            this.MapsConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.MapsConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.MapsConfigPanel.Name = "MapsConfigPanel";
            this.MapsConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.MapsConfigPanel.Size = new System.Drawing.Size(868, 344);
            this.MapsConfigPanel.TabIndex = 4;
            this.MapsConfigPanel.Text = "Maps";
            // 
            // AdminsPanel
            // 
            this.AdminsPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.AdminsPanel.Controls.Add(this.NegativePermissionsTitle);
            this.AdminsPanel.Controls.Add(this.NegativePermissions);
            this.AdminsPanel.Controls.Add(this.ApplyAdminRankButton);
            this.AdminsPanel.Controls.Add(this.PermissionsListBox);
            this.AdminsPanel.Controls.Add(this.PermissionsTItle);
            this.AdminsPanel.Controls.Add(this.RemoveRankButton);
            this.AdminsPanel.Controls.Add(this.AddRankTextBox);
            this.AdminsPanel.Controls.Add(this.AddRankButton);
            this.AdminsPanel.Controls.Add(this.AdminRanksListBox);
            this.AdminsPanel.Controls.Add(this.RanksTitle);
            this.AdminsPanel.Controls.Add(this.DeadminButton);
            this.AdminsPanel.Controls.Add(this.AddminTextBox);
            this.AdminsPanel.Controls.Add(this.AddminButton);
            this.AdminsPanel.Controls.Add(this.AdminsListBox);
            this.AdminsPanel.Controls.Add(this.AdminsTitle);
            this.AdminsPanel.Location = new System.Drawing.Point(4, 22);
            this.AdminsPanel.Name = "AdminsPanel";
            this.AdminsPanel.Padding = new System.Windows.Forms.Padding(3);
            this.AdminsPanel.Size = new System.Drawing.Size(868, 344);
            this.AdminsPanel.TabIndex = 5;
            this.AdminsPanel.Text = "Admins";
            // 
            // NegativePermissionsTitle
            // 
            this.NegativePermissionsTitle.AutoSize = true;
            this.NegativePermissionsTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.NegativePermissionsTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.NegativePermissionsTitle.Location = new System.Drawing.Point(269, 151);
            this.NegativePermissionsTitle.Name = "NegativePermissionsTitle";
            this.NegativePermissionsTitle.Size = new System.Drawing.Size(192, 18);
            this.NegativePermissionsTitle.TabIndex = 31;
            this.NegativePermissionsTitle.Text = "Negative Permissions:";
            this.NegativePermissionsTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // NegativePermissions
            // 
            this.NegativePermissions.FormattingEnabled = true;
            this.NegativePermissions.HorizontalScrollbar = true;
            this.NegativePermissions.Location = new System.Drawing.Point(272, 172);
            this.NegativePermissions.Name = "NegativePermissions";
            this.NegativePermissions.Size = new System.Drawing.Size(240, 109);
            this.NegativePermissions.TabIndex = 30;
            // 
            // ApplyAdminRankButton
            // 
            this.ApplyAdminRankButton.Location = new System.Drawing.Point(272, 292);
            this.ApplyAdminRankButton.Name = "ApplyAdminRankButton";
            this.ApplyAdminRankButton.Size = new System.Drawing.Size(240, 46);
            this.ApplyAdminRankButton.TabIndex = 29;
            this.ApplyAdminRankButton.Text = "Apply Selected Rank to Selected Admin";
            this.ApplyAdminRankButton.UseVisualStyleBackColor = true;
            this.ApplyAdminRankButton.Click += new System.EventHandler(this.ApplyAdminRankButton_Click);
            // 
            // PermissionsListBox
            // 
            this.PermissionsListBox.FormattingEnabled = true;
            this.PermissionsListBox.HorizontalScrollbar = true;
            this.PermissionsListBox.Location = new System.Drawing.Point(272, 29);
            this.PermissionsListBox.Name = "PermissionsListBox";
            this.PermissionsListBox.Size = new System.Drawing.Size(240, 109);
            this.PermissionsListBox.TabIndex = 28;
            // 
            // PermissionsTItle
            // 
            this.PermissionsTItle.AutoSize = true;
            this.PermissionsTItle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.PermissionsTItle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.PermissionsTItle.Location = new System.Drawing.Point(269, 8);
            this.PermissionsTItle.Name = "PermissionsTItle";
            this.PermissionsTItle.Size = new System.Drawing.Size(113, 18);
            this.PermissionsTItle.TabIndex = 27;
            this.PermissionsTItle.Text = "Permissions:";
            this.PermissionsTItle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // RemoveRankButton
            // 
            this.RemoveRankButton.Location = new System.Drawing.Point(9, 292);
            this.RemoveRankButton.Name = "RemoveRankButton";
            this.RemoveRankButton.Size = new System.Drawing.Size(240, 20);
            this.RemoveRankButton.TabIndex = 26;
            this.RemoveRankButton.Text = "Remove Selected";
            this.RemoveRankButton.UseVisualStyleBackColor = true;
            this.RemoveRankButton.Click += new System.EventHandler(this.RemoveRankButton_Click);
            // 
            // AddRankTextBox
            // 
            this.AddRankTextBox.Location = new System.Drawing.Point(9, 318);
            this.AddRankTextBox.Name = "AddRankTextBox";
            this.AddRankTextBox.Size = new System.Drawing.Size(184, 20);
            this.AddRankTextBox.TabIndex = 25;
            // 
            // AddRankButton
            // 
            this.AddRankButton.Location = new System.Drawing.Point(199, 318);
            this.AddRankButton.Name = "AddRankButton";
            this.AddRankButton.Size = new System.Drawing.Size(50, 20);
            this.AddRankButton.TabIndex = 24;
            this.AddRankButton.Text = "Add";
            this.AddRankButton.UseVisualStyleBackColor = true;
            this.AddRankButton.Click += new System.EventHandler(this.AddRankButton_Click);
            // 
            // AdminRanksListBox
            // 
            this.AdminRanksListBox.FormattingEnabled = true;
            this.AdminRanksListBox.Location = new System.Drawing.Point(9, 30);
            this.AdminRanksListBox.Name = "AdminRanksListBox";
            this.AdminRanksListBox.Size = new System.Drawing.Size(240, 251);
            this.AdminRanksListBox.TabIndex = 23;
            // 
            // RanksTitle
            // 
            this.RanksTitle.AutoSize = true;
            this.RanksTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.RanksTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.RanksTitle.Location = new System.Drawing.Point(6, 8);
            this.RanksTitle.Name = "RanksTitle";
            this.RanksTitle.Size = new System.Drawing.Size(64, 18);
            this.RanksTitle.TabIndex = 22;
            this.RanksTitle.Text = "Ranks:";
            this.RanksTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // DeadminButton
            // 
            this.DeadminButton.Location = new System.Drawing.Point(536, 292);
            this.DeadminButton.Name = "DeadminButton";
            this.DeadminButton.Size = new System.Drawing.Size(240, 20);
            this.DeadminButton.TabIndex = 21;
            this.DeadminButton.Text = "Remove Selected";
            this.DeadminButton.UseVisualStyleBackColor = true;
            this.DeadminButton.Click += new System.EventHandler(this.DeadminButton_Click);
            // 
            // AddminTextBox
            // 
            this.AddminTextBox.Location = new System.Drawing.Point(536, 318);
            this.AddminTextBox.Name = "AddminTextBox";
            this.AddminTextBox.Size = new System.Drawing.Size(184, 20);
            this.AddminTextBox.TabIndex = 20;
            // 
            // AddminButton
            // 
            this.AddminButton.Location = new System.Drawing.Point(726, 318);
            this.AddminButton.Name = "AddminButton";
            this.AddminButton.Size = new System.Drawing.Size(50, 20);
            this.AddminButton.TabIndex = 19;
            this.AddminButton.Text = "Add";
            this.AddminButton.UseVisualStyleBackColor = true;
            this.AddminButton.Click += new System.EventHandler(this.AddminButton_Click);
            // 
            // AdminsListBox
            // 
            this.AdminsListBox.FormattingEnabled = true;
            this.AdminsListBox.Location = new System.Drawing.Point(536, 30);
            this.AdminsListBox.Name = "AdminsListBox";
            this.AdminsListBox.Size = new System.Drawing.Size(240, 251);
            this.AdminsListBox.TabIndex = 13;
            // 
            // AdminsTitle
            // 
            this.AdminsTitle.AutoSize = true;
            this.AdminsTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.AdminsTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AdminsTitle.Location = new System.Drawing.Point(533, 8);
            this.AdminsTitle.Name = "AdminsTitle";
            this.AdminsTitle.Size = new System.Drawing.Size(75, 18);
            this.AdminsTitle.TabIndex = 12;
            this.AdminsTitle.Text = "Admins:";
            this.AdminsTitle.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ConfigDisabledLabel
            // 
            this.ConfigDisabledLabel.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigDisabledLabel.AutoSize = true;
            this.ConfigDisabledLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.ConfigDisabledLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.ConfigDisabledLabel.Location = new System.Drawing.Point(225, 160);
            this.ConfigDisabledLabel.Name = "ConfigDisabledLabel";
            this.ConfigDisabledLabel.Size = new System.Drawing.Size(428, 18);
            this.ConfigDisabledLabel.TabIndex = 14;
            this.ConfigDisabledLabel.Text = "Configuration is disabled until repository is set up!";
            this.ConfigDisabledLabel.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // RepoBGW
            // 
            this.RepoBGW.WorkerReportsProgress = true;
            this.RepoBGW.WorkerSupportsCancellation = true;
            // 
            // BYONDTimer
            // 
            this.BYONDTimer.Interval = 1000;
            this.BYONDTimer.Tick += new System.EventHandler(this.BYONDTimer_Tick);
            // 
            // ServerTimer
            // 
            this.ServerTimer.Interval = 10000;
            this.ServerTimer.Tick += new System.EventHandler(this.ServerTimer_Tick);
            // 
            // WorldStatusChecker
            // 
            this.WorldStatusChecker.WorkerReportsProgress = true;
            this.WorldStatusChecker.WorkerSupportsCancellation = true;
            this.WorldStatusChecker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.WorldStatusChecker_DoWork);
            // 
            // WorldStatusTimer
            // 
            this.WorldStatusTimer.Interval = 10000;
            this.WorldStatusTimer.Tick += new System.EventHandler(this.WorldStatusTimer_Tick);
            // 
            // FullUpdateWorker
            // 
            this.FullUpdateWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.FullUpdateWorker_DoWork);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ClientSize = new System.Drawing.Size(900, 415);
            this.Controls.Add(this.Panels);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Main";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "/tg/station 13 Server Control Panel";
            this.Panels.ResumeLayout(false);
            this.RepoPanel.ResumeLayout(false);
            this.RepoPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.TestmergeSelector)).EndInit();
            this.BYONDPanel.ResumeLayout(false);
            this.BYONDPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.MinorVersionNumeric)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.MajorVersionNumeric)).EndInit();
            this.ServerPanel.ResumeLayout(false);
            this.ServerPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.NudgePortSelector)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.PortSelector)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ServerTestmergeInput)).EndInit();
            this.ChatPanel.ResumeLayout(false);
            this.ChatPanel.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.ChatPortSelector)).EndInit();
            this.ChatProviderSelectorPanel.ResumeLayout(false);
            this.ChatProviderSelectorPanel.PerformLayout();
            this.ConfigPanel.ResumeLayout(false);
            this.ConfigPanel.PerformLayout();
            this.ConfigPanels.ResumeLayout(false);
            this.AdminsPanel.ResumeLayout(false);
            this.AdminsPanel.PerformLayout();
            this.ResumeLayout(false);

		}

		#endregion
		private System.Windows.Forms.TabControl Panels;
		private System.ComponentModel.BackgroundWorker RepoBGW;
		private System.Windows.Forms.TabPage BYONDPanel;
		private System.Windows.Forms.TabPage ServerPanel;
		private System.Windows.Forms.Button UpdateButton;
		private System.Windows.Forms.NumericUpDown MinorVersionNumeric;
		private System.Windows.Forms.NumericUpDown MajorVersionNumeric;
		private System.Windows.Forms.ProgressBar UpdateProgressBar;
		private System.Windows.Forms.Label MajorVersionLabel;
		private System.Windows.Forms.Label MinorVersionLabel;
		private System.Windows.Forms.Label VersionLabel;
		private System.Windows.Forms.Label VersionTitle;
		private System.Windows.Forms.Label StatusLabel;
		private System.Windows.Forms.Timer BYONDTimer;
		private System.Windows.Forms.Label StagedVersionLabel;
		private System.Windows.Forms.Label StagedVersionTitle;
		private System.Windows.Forms.TabPage ChatPanel;
		private System.Windows.Forms.TabPage ConfigPanel;
		private System.Windows.Forms.Label ServerStatusTitle;
		private System.Windows.Forms.Button compileButton;
		private System.Windows.Forms.Button initializeButton;
		private System.Windows.Forms.ProgressBar compilerProgressBar;
		private System.Windows.Forms.Label ServerStatusLabel;
		private System.Windows.Forms.Timer ServerTimer;
		private System.Windows.Forms.Label CompilerLabel;
		private System.Windows.Forms.Label CompilerStatusLabel;
		private System.ComponentModel.BackgroundWorker WorldStatusChecker;
		private System.Windows.Forms.Timer WorldStatusTimer;
		private System.Windows.Forms.CheckBox AutostartCheckbox;
		private System.Windows.Forms.Button ServerGRestartButton;
		private System.Windows.Forms.Button ServerGStopButton;
		private System.Windows.Forms.Button ServerRestartButton;
		private System.Windows.Forms.Button ServerStopButton;
		private System.Windows.Forms.Button ServerStartButton;
		private System.Windows.Forms.Label ServerPRLabel;
		private System.Windows.Forms.NumericUpDown ServerTestmergeInput;
		private System.Windows.Forms.Button TestmergeButton;
		private System.Windows.Forms.Button UpdateTestmergeButton;
		private System.Windows.Forms.Button UpdateMergeButton;
		private System.Windows.Forms.Button UpdateHardButton;
		private System.ComponentModel.BackgroundWorker FullUpdateWorker;
		private System.Windows.Forms.TabControl ConfigPanels;
		private System.Windows.Forms.TabPage ConfigConfigPanel;
		private System.Windows.Forms.Button ConfigRefresh;
		private System.Windows.Forms.Button ConfigApply;
		private System.Windows.Forms.Button ConfigDownload;
		private System.Windows.Forms.Button ConfigUpload;
		private System.Windows.Forms.Button ConfigDownloadRepo;
		private System.Windows.Forms.TabPage DatabaseConfigPanel;
		private System.Windows.Forms.TabPage GameConfigPanel;
		private System.Windows.Forms.Label PortLabel;
		private System.Windows.Forms.NumericUpDown PortSelector;
		private System.Windows.Forms.Label ProjectPathLabel;
		private System.Windows.Forms.TextBox projectNameText;
		private System.Windows.Forms.Button CompileCancelButton;
		private System.Windows.Forms.Label ServerPathLabel;
		private System.Windows.Forms.TextBox ServerPathTextbox;
		private System.Windows.Forms.Label LatestVersionLabel;
		private System.Windows.Forms.Label LatestVersionTitle;
		private System.Windows.Forms.TextBox ChatChannelsTextBox;
		private System.Windows.Forms.Label ChannelsTitle;
		private System.Windows.Forms.TextBox ChatAdminsTextBox;
		private System.Windows.Forms.Label ChatAdminsTitle;
		private System.Windows.Forms.Label ChatStatusLabel;
		private System.Windows.Forms.Label ChatStatusTitle;
		private System.Windows.Forms.CheckBox ChatEnabledCheckbox;
		private System.Windows.Forms.Panel ChatProviderSelectorPanel;
		private System.Windows.Forms.RadioButton DiscordProviderSwitch;
		private System.Windows.Forms.RadioButton IRCProviderSwitch;
		private System.Windows.Forms.Label ChatProviderTitle;
		private System.Windows.Forms.Button ChatReconnectButton;
		private System.Windows.Forms.Label AdminChannelTitle;
		private System.Windows.Forms.TextBox AdminChannelText;
		private System.Windows.Forms.Label AuthField2Title;
		private System.Windows.Forms.Label AuthField1Title;
		private System.Windows.Forms.TextBox AuthField2;
		private System.Windows.Forms.TextBox AuthField1;
		private System.Windows.Forms.Button ChatApplyButton;
		private System.Windows.Forms.NumericUpDown ChatPortSelector;
		private System.Windows.Forms.Label ChatPortTitle;
		private System.Windows.Forms.TextBox ChatServerText;
		private System.Windows.Forms.Label ChatServerTitle;
		private System.Windows.Forms.TextBox ChatNicknameText;
		private System.Windows.Forms.Label ChatNicknameTitle;
		private System.Windows.Forms.Button ChatRefreshButton;
		private System.Windows.Forms.TabPage JobsConfigPanel;
		private System.Windows.Forms.NumericUpDown NudgePortSelector;
		private System.Windows.Forms.Label NudgePortLabel;
		private System.Windows.Forms.TabPage MapsConfigPanel;
		private System.Windows.Forms.TabPage AdminsPanel;
		private System.Windows.Forms.TextBox AddminTextBox;
		private System.Windows.Forms.Button AddminButton;
		private System.Windows.Forms.ListBox AdminsListBox;
		private System.Windows.Forms.Label AdminsTitle;
		private System.Windows.Forms.Button DeadminButton;
		private System.Windows.Forms.ListBox AdminRanksListBox;
		private System.Windows.Forms.Label RanksTitle;
		private System.Windows.Forms.Button RemoveRankButton;
		private System.Windows.Forms.TextBox AddRankTextBox;
		private System.Windows.Forms.Button AddRankButton;
		private System.Windows.Forms.Button ApplyAdminRankButton;
		private System.Windows.Forms.CheckedListBox PermissionsListBox;
		private System.Windows.Forms.Label PermissionsTItle;
		private System.Windows.Forms.CheckedListBox NegativePermissions;
		private System.Windows.Forms.Label NegativePermissionsTitle;
		private System.Windows.Forms.Label ConfigDisabledLabel;
		private System.Windows.Forms.Button ResetTestmerge;
		private System.Windows.Forms.TabPage RepoPanel;
		private System.Windows.Forms.Button ResetRemote;
		private System.Windows.Forms.Button RecloneButton;
		private System.Windows.Forms.TextBox PythonPathText;
		private System.Windows.Forms.Label PythonPathLabel;
		private System.Windows.Forms.Button RepoGenChangelogButton;
		private System.Windows.Forms.NumericUpDown TestmergeSelector;
		private System.Windows.Forms.ListBox TestMergeListLabel;
		private System.Windows.Forms.Label CurrentRevisionLabel;
		private System.Windows.Forms.Button RepoApplyButton;
		private System.Windows.Forms.TextBox RepoBranchTextBox;
		private System.Windows.Forms.TextBox RepoRemoteTextBox;
		private System.Windows.Forms.Button HardReset;
		private System.Windows.Forms.Button UpdateRepoButton;
		private System.Windows.Forms.Button MergePRButton;
		private System.Windows.Forms.Label IdentityLabel;
		private System.Windows.Forms.Label TestMergeListTitle;
		private System.Windows.Forms.Label RemoteNameTitle;
		private System.Windows.Forms.Label BranchNameTitle;
		private System.Windows.Forms.Label CurrentRevisionTitle;
		private System.Windows.Forms.Button CloneRepositoryButton;
		private System.Windows.Forms.Label RepoProgressBarLabel;
		private System.Windows.Forms.ProgressBar RepoProgressBar;
		private System.Windows.Forms.ListBox BackupTagsList;
		private System.Windows.Forms.ComboBox SecuritySelector;
		private System.Windows.Forms.Label SecurityTitle;
		private System.Windows.Forms.Label VisibilityTitle;
		private System.Windows.Forms.ComboBox VisibilitySelector;
	}
}

