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
            this.RepoPushButton = new System.Windows.Forms.Button();
            this.RepoCommitButton = new System.Windows.Forms.Button();
            this.RepoGenChangelogButton = new System.Windows.Forms.Button();
            this.CommitterPasswordTextBox = new System.Windows.Forms.TextBox();
            this.CommitterLoginTextBox = new System.Windows.Forms.TextBox();
            this.CommitterPasswordTitle = new System.Windows.Forms.Label();
            this.CommiterLoginTitle = new System.Windows.Forms.Label();
            this.TestmergeSelector = new System.Windows.Forms.NumericUpDown();
            this.TestMergeListLabel = new System.Windows.Forms.TextBox();
            this.CurrentRevisionLabel = new System.Windows.Forms.Label();
            this.RepoEmailTextBox = new System.Windows.Forms.TextBox();
            this.RepoCommitterNameTextBox = new System.Windows.Forms.TextBox();
            this.RepoApplyButton = new System.Windows.Forms.Button();
            this.RepoBranchTextBox = new System.Windows.Forms.TextBox();
            this.RepoRemoteTextBox = new System.Windows.Forms.TextBox();
            this.HardReset = new System.Windows.Forms.Button();
            this.UpdateRepoButton = new System.Windows.Forms.Button();
            this.MergePRButton = new System.Windows.Forms.Button();
            this.CommitterEmailTitle = new System.Windows.Forms.Label();
            this.CommiterNameTitle = new System.Windows.Forms.Label();
            this.IdentityLabel = new System.Windows.Forms.Label();
            this.TestMergeListTitle = new System.Windows.Forms.Label();
            this.RemoteNameTitle = new System.Windows.Forms.Label();
            this.BranchNameTitle = new System.Windows.Forms.Label();
            this.CurrentRevisionTitle = new System.Windows.Forms.Label();
            this.CloneRepositoryButton = new System.Windows.Forms.Button();
            this.RepoProgressBarLabel = new System.Windows.Forms.Label();
            this.RepoProgressBar = new System.Windows.Forms.ProgressBar();
            this.BYONDPanel = new System.Windows.Forms.TabPage();
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
            this.PortLabel = new System.Windows.Forms.Label();
            this.PortSelector = new System.Windows.Forms.NumericUpDown();
            this.label1 = new System.Windows.Forms.Label();
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
            this.tabPage3 = new System.Windows.Forms.TabPage();
            this.IRCPanel = new System.Windows.Forms.TabPage();
            this.ConfigPanel = new System.Windows.Forms.TabPage();
            this.ConfigDownloadRepo = new System.Windows.Forms.Button();
            this.ConfigUpload = new System.Windows.Forms.Button();
            this.ConfigDownload = new System.Windows.Forms.Button();
            this.ConfigRefresh = new System.Windows.Forms.Button();
            this.ConfigApply = new System.Windows.Forms.Button();
            this.ConfigPanels = new System.Windows.Forms.TabControl();
            this.ConfigConfigPanel = new System.Windows.Forms.TabPage();
            this.DatabaseConfigPanel = new System.Windows.Forms.TabPage();
            this.GameConfigPanel = new System.Windows.Forms.TabPage();
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
            ((System.ComponentModel.ISupportInitialize)(this.PortSelector)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.ServerTestmergeInput)).BeginInit();
            this.ConfigPanel.SuspendLayout();
            this.ConfigPanels.SuspendLayout();
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
            this.Panels.Controls.Add(this.tabPage3);
            this.Panels.Controls.Add(this.IRCPanel);
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
            this.RepoPanel.Controls.Add(this.RepoPushButton);
            this.RepoPanel.Controls.Add(this.RepoCommitButton);
            this.RepoPanel.Controls.Add(this.RepoGenChangelogButton);
            this.RepoPanel.Controls.Add(this.CommitterPasswordTextBox);
            this.RepoPanel.Controls.Add(this.CommitterLoginTextBox);
            this.RepoPanel.Controls.Add(this.CommitterPasswordTitle);
            this.RepoPanel.Controls.Add(this.CommiterLoginTitle);
            this.RepoPanel.Controls.Add(this.TestmergeSelector);
            this.RepoPanel.Controls.Add(this.TestMergeListLabel);
            this.RepoPanel.Controls.Add(this.CurrentRevisionLabel);
            this.RepoPanel.Controls.Add(this.RepoEmailTextBox);
            this.RepoPanel.Controls.Add(this.RepoCommitterNameTextBox);
            this.RepoPanel.Controls.Add(this.RepoApplyButton);
            this.RepoPanel.Controls.Add(this.RepoBranchTextBox);
            this.RepoPanel.Controls.Add(this.RepoRemoteTextBox);
            this.RepoPanel.Controls.Add(this.HardReset);
            this.RepoPanel.Controls.Add(this.UpdateRepoButton);
            this.RepoPanel.Controls.Add(this.MergePRButton);
            this.RepoPanel.Controls.Add(this.CommitterEmailTitle);
            this.RepoPanel.Controls.Add(this.CommiterNameTitle);
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
            // RepoPushButton
            // 
            this.RepoPushButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoPushButton.Location = new System.Drawing.Point(722, 212);
            this.RepoPushButton.Name = "RepoPushButton";
            this.RepoPushButton.Size = new System.Drawing.Size(140, 29);
            this.RepoPushButton.TabIndex = 29;
            this.RepoPushButton.Text = "Push";
            this.RepoPushButton.UseVisualStyleBackColor = true;
            this.RepoPushButton.Visible = false;
            this.RepoPushButton.Click += new System.EventHandler(this.RepoPushButton_Click);
            // 
            // RepoCommitButton
            // 
            this.RepoCommitButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoCommitButton.Location = new System.Drawing.Point(722, 177);
            this.RepoCommitButton.Name = "RepoCommitButton";
            this.RepoCommitButton.Size = new System.Drawing.Size(140, 29);
            this.RepoCommitButton.TabIndex = 28;
            this.RepoCommitButton.Text = "Commit";
            this.RepoCommitButton.UseVisualStyleBackColor = true;
            this.RepoCommitButton.Visible = false;
            this.RepoCommitButton.Click += new System.EventHandler(this.RepoCommitButton_Click);
            // 
            // RepoGenChangelogButton
            // 
            this.RepoGenChangelogButton.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.RepoGenChangelogButton.Location = new System.Drawing.Point(722, 142);
            this.RepoGenChangelogButton.Name = "RepoGenChangelogButton";
            this.RepoGenChangelogButton.Size = new System.Drawing.Size(140, 29);
            this.RepoGenChangelogButton.TabIndex = 27;
            this.RepoGenChangelogButton.Text = "Generate Changelog";
            this.RepoGenChangelogButton.UseVisualStyleBackColor = true;
            this.RepoGenChangelogButton.Visible = false;
            this.RepoGenChangelogButton.Click += new System.EventHandler(this.RepoGenChangelogButton_Click);
            // 
            // CommitterPasswordTextBox
            // 
            this.CommitterPasswordTextBox.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommitterPasswordTextBox.Location = new System.Drawing.Point(122, 256);
            this.CommitterPasswordTextBox.Name = "CommitterPasswordTextBox";
            this.CommitterPasswordTextBox.Size = new System.Drawing.Size(535, 20);
            this.CommitterPasswordTextBox.TabIndex = 26;
            this.CommitterPasswordTextBox.Text = "hunter2butseriouslyyoubetterfuckingrenamethis";
            this.CommitterPasswordTextBox.UseSystemPasswordChar = true;
            this.CommitterPasswordTextBox.Visible = false;
            // 
            // CommitterLoginTextBox
            // 
            this.CommitterLoginTextBox.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommitterLoginTextBox.Location = new System.Drawing.Point(122, 227);
            this.CommitterLoginTextBox.Name = "CommitterLoginTextBox";
            this.CommitterLoginTextBox.Size = new System.Drawing.Size(535, 20);
            this.CommitterLoginTextBox.TabIndex = 25;
            this.CommitterLoginTextBox.Visible = false;
            // 
            // CommitterPasswordTitle
            // 
            this.CommitterPasswordTitle.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommitterPasswordTitle.AutoSize = true;
            this.CommitterPasswordTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CommitterPasswordTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CommitterPasswordTitle.Location = new System.Drawing.Point(6, 258);
            this.CommitterPasswordTitle.Name = "CommitterPasswordTitle";
            this.CommitterPasswordTitle.Size = new System.Drawing.Size(92, 18);
            this.CommitterPasswordTitle.TabIndex = 24;
            this.CommitterPasswordTitle.Text = "Password:";
            this.CommitterPasswordTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.CommitterPasswordTitle.Visible = false;
            // 
            // CommiterLoginTitle
            // 
            this.CommiterLoginTitle.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommiterLoginTitle.AutoSize = true;
            this.CommiterLoginTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CommiterLoginTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CommiterLoginTitle.Location = new System.Drawing.Point(6, 227);
            this.CommiterLoginTitle.Name = "CommiterLoginTitle";
            this.CommiterLoginTitle.Size = new System.Drawing.Size(59, 18);
            this.CommiterLoginTitle.TabIndex = 23;
            this.CommiterLoginTitle.Text = "Login:";
            this.CommiterLoginTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.CommiterLoginTitle.Visible = false;
            // 
            // TestmergeSelector
            // 
            this.TestmergeSelector.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.TestmergeSelector.Location = new System.Drawing.Point(722, 116);
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
            this.TestMergeListLabel.Location = new System.Drawing.Point(122, 286);
            this.TestMergeListLabel.Multiline = true;
            this.TestMergeListLabel.Name = "TestMergeListLabel";
            this.TestMergeListLabel.ReadOnly = true;
            this.TestMergeListLabel.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.TestMergeListLabel.Size = new System.Drawing.Size(535, 74);
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
            // RepoEmailTextBox
            // 
            this.RepoEmailTextBox.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.RepoEmailTextBox.Location = new System.Drawing.Point(122, 197);
            this.RepoEmailTextBox.Name = "RepoEmailTextBox";
            this.RepoEmailTextBox.Size = new System.Drawing.Size(535, 20);
            this.RepoEmailTextBox.TabIndex = 19;
            this.RepoEmailTextBox.Visible = false;
            // 
            // RepoCommitterNameTextBox
            // 
            this.RepoCommitterNameTextBox.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.RepoCommitterNameTextBox.Location = new System.Drawing.Point(122, 168);
            this.RepoCommitterNameTextBox.Name = "RepoCommitterNameTextBox";
            this.RepoCommitterNameTextBox.Size = new System.Drawing.Size(535, 20);
            this.RepoCommitterNameTextBox.TabIndex = 18;
            this.RepoCommitterNameTextBox.Visible = false;
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
            this.RepoBranchTextBox.Location = new System.Drawing.Point(122, 89);
            this.RepoBranchTextBox.Name = "RepoBranchTextBox";
            this.RepoBranchTextBox.Size = new System.Drawing.Size(535, 20);
            this.RepoBranchTextBox.TabIndex = 15;
            this.RepoBranchTextBox.Visible = false;
            // 
            // RepoRemoteTextBox
            // 
            this.RepoRemoteTextBox.Location = new System.Drawing.Point(122, 57);
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
            this.HardReset.Text = "Reset To Remote";
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
            this.MergePRButton.Location = new System.Drawing.Point(722, 81);
            this.MergePRButton.Name = "MergePRButton";
            this.MergePRButton.Size = new System.Drawing.Size(140, 29);
            this.MergePRButton.TabIndex = 11;
            this.MergePRButton.Text = "Merge Pull Request";
            this.MergePRButton.UseVisualStyleBackColor = true;
            this.MergePRButton.Visible = false;
            this.MergePRButton.Click += new System.EventHandler(this.TestMergeButton_Click);
            // 
            // CommitterEmailTitle
            // 
            this.CommitterEmailTitle.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommitterEmailTitle.AutoSize = true;
            this.CommitterEmailTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CommitterEmailTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CommitterEmailTitle.Location = new System.Drawing.Point(6, 199);
            this.CommitterEmailTitle.Name = "CommitterEmailTitle";
            this.CommitterEmailTitle.Size = new System.Drawing.Size(67, 18);
            this.CommitterEmailTitle.TabIndex = 10;
            this.CommitterEmailTitle.Text = "E-mail:";
            this.CommitterEmailTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.CommitterEmailTitle.Visible = false;
            // 
            // CommiterNameTitle
            // 
            this.CommiterNameTitle.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.CommiterNameTitle.AutoSize = true;
            this.CommiterNameTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.CommiterNameTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.CommiterNameTitle.Location = new System.Drawing.Point(6, 170);
            this.CommiterNameTitle.Name = "CommiterNameTitle";
            this.CommiterNameTitle.Size = new System.Drawing.Size(62, 18);
            this.CommiterNameTitle.TabIndex = 9;
            this.CommiterNameTitle.Text = "Name:";
            this.CommiterNameTitle.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.CommiterNameTitle.Visible = false;
            // 
            // IdentityLabel
            // 
            this.IdentityLabel.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.IdentityLabel.AutoSize = true;
            this.IdentityLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.IdentityLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.IdentityLabel.Location = new System.Drawing.Point(6, 142);
            this.IdentityLabel.Name = "IdentityLabel";
            this.IdentityLabel.Size = new System.Drawing.Size(257, 18);
            this.IdentityLabel.TabIndex = 8;
            this.IdentityLabel.Text = "Changelog Committer Identity";
            this.IdentityLabel.TextAlign = System.Drawing.ContentAlignment.MiddleLeft;
            this.IdentityLabel.Visible = false;
            // 
            // TestMergeListTitle
            // 
            this.TestMergeListTitle.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.TestMergeListTitle.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TestMergeListTitle.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.TestMergeListTitle.Location = new System.Drawing.Point(6, 286);
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
            this.RemoteNameTitle.Location = new System.Drawing.Point(6, 57);
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
            this.BranchNameTitle.Location = new System.Drawing.Point(6, 89);
            this.BranchNameTitle.Name = "BranchNameTitle";
            this.BranchNameTitle.Size = new System.Drawing.Size(110, 18);
            this.BranchNameTitle.TabIndex = 4;
            this.BranchNameTitle.Text = "Branch/SHA:";
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
            // StagedVersionLabel
            // 
            this.StagedVersionLabel.AutoSize = true;
            this.StagedVersionLabel.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.StagedVersionLabel.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.StagedVersionLabel.Location = new System.Drawing.Point(425, 112);
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
            this.StagedVersionTitle.Location = new System.Drawing.Point(214, 112);
            this.StagedVersionTitle.Name = "StagedVersionTitle";
            this.StagedVersionTitle.Size = new System.Drawing.Size(202, 18);
            this.StagedVersionTitle.TabIndex = 10;
            this.StagedVersionTitle.Text = "Current staged version:";
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
            this.VersionLabel.Location = new System.Drawing.Point(425, 74);
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
            this.VersionTitle.Location = new System.Drawing.Point(214, 74);
            this.VersionTitle.Name = "VersionTitle";
            this.VersionTitle.Size = new System.Drawing.Size(205, 18);
            this.VersionTitle.TabIndex = 7;
            this.VersionTitle.Text = "Current BYOND version:";
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
            this.ServerPanel.Controls.Add(this.PortLabel);
            this.ServerPanel.Controls.Add(this.PortSelector);
            this.ServerPanel.Controls.Add(this.label1);
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
            // PortLabel
            // 
            this.PortLabel.Anchor = System.Windows.Forms.AnchorStyles.Left;
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
            this.PortSelector.Anchor = System.Windows.Forms.AnchorStyles.Left;
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
            // label1
            // 
            this.label1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Verdana", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.label1.Location = new System.Drawing.Point(734, 102);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(49, 18);
            this.label1.TabIndex = 26;
            this.label1.Text = "PR#:";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // ServerTestmergeInput
            // 
            this.ServerTestmergeInput.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.ServerTestmergeInput.Location = new System.Drawing.Point(782, 101);
            this.ServerTestmergeInput.Maximum = new decimal(new int[] {
            1000000,
            0,
            0,
            0});
            this.ServerTestmergeInput.Name = "ServerTestmergeInput";
            this.ServerTestmergeInput.Size = new System.Drawing.Size(80, 20);
            this.ServerTestmergeInput.TabIndex = 25;
            // 
            // TestmergeButton
            // 
            this.TestmergeButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.TestmergeButton.Location = new System.Drawing.Point(586, 95);
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
            this.UpdateTestmergeButton.Location = new System.Drawing.Point(438, 95);
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
            this.UpdateMergeButton.Location = new System.Drawing.Point(290, 95);
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
            this.UpdateHardButton.Location = new System.Drawing.Point(142, 95);
            this.UpdateHardButton.Name = "UpdateHardButton";
            this.UpdateHardButton.Size = new System.Drawing.Size(142, 28);
            this.UpdateHardButton.TabIndex = 21;
            this.UpdateHardButton.Text = "Update (Reset Testmerge)";
            this.UpdateHardButton.UseVisualStyleBackColor = true;
            this.UpdateHardButton.Click += new System.EventHandler(this.UpdateHardButton_Click);
            // 
            // ServerGRestartButton
            // 
            this.ServerGRestartButton.Anchor = System.Windows.Forms.AnchorStyles.Top;
            this.ServerGRestartButton.Location = new System.Drawing.Point(621, 54);
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
            this.ServerGStopButton.Location = new System.Drawing.Point(497, 54);
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
            this.ServerRestartButton.Location = new System.Drawing.Point(373, 54);
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
            this.ServerStopButton.Location = new System.Drawing.Point(249, 54);
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
            this.ServerStartButton.Location = new System.Drawing.Point(125, 54);
            this.ServerStartButton.Name = "ServerStartButton";
            this.ServerStartButton.Size = new System.Drawing.Size(118, 28);
            this.ServerStartButton.TabIndex = 16;
            this.ServerStartButton.Text = "Start";
            this.ServerStartButton.UseVisualStyleBackColor = true;
            this.ServerStartButton.Click += new System.EventHandler(this.ServerStartButton_Click);
            // 
            // AutostartCheckbox
            // 
            this.AutostartCheckbox.AutoSize = true;
            this.AutostartCheckbox.Font = new System.Drawing.Font("Verdana", 12F);
            this.AutostartCheckbox.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(248)))), ((int)(((byte)(248)))), ((int)(((byte)(242)))));
            this.AutostartCheckbox.Location = new System.Drawing.Point(18, 101);
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
            this.CompilerStatusLabel.Location = new System.Drawing.Point(360, 271);
            this.CompilerStatusLabel.Name = "CompilerStatusLabel";
            this.CompilerStatusLabel.Size = new System.Drawing.Size(122, 28);
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
            this.compilerProgressBar.Size = new System.Drawing.Size(650, 31);
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
            // tabPage3
            // 
            this.tabPage3.Location = new System.Drawing.Point(4, 22);
            this.tabPage3.Name = "tabPage3";
            this.tabPage3.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage3.Size = new System.Drawing.Size(868, 366);
            this.tabPage3.TabIndex = 3;
            this.tabPage3.Text = "Logs";
            this.tabPage3.UseVisualStyleBackColor = true;
            // 
            // IRCPanel
            // 
            this.IRCPanel.Location = new System.Drawing.Point(4, 22);
            this.IRCPanel.Name = "IRCPanel";
            this.IRCPanel.Padding = new System.Windows.Forms.Padding(3);
            this.IRCPanel.Size = new System.Drawing.Size(868, 366);
            this.IRCPanel.TabIndex = 4;
            this.IRCPanel.Text = "IRC";
            this.IRCPanel.UseVisualStyleBackColor = true;
            // 
            // ConfigPanel
            // 
            this.ConfigPanel.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(39)))), ((int)(((byte)(40)))), ((int)(((byte)(34)))));
            this.ConfigPanel.Controls.Add(this.ConfigDownloadRepo);
            this.ConfigPanel.Controls.Add(this.ConfigUpload);
            this.ConfigPanel.Controls.Add(this.ConfigDownload);
            this.ConfigPanel.Controls.Add(this.ConfigRefresh);
            this.ConfigPanel.Controls.Add(this.ConfigApply);
            this.ConfigPanel.Controls.Add(this.ConfigPanels);
            this.ConfigPanel.Location = new System.Drawing.Point(4, 22);
            this.ConfigPanel.Name = "ConfigPanel";
            this.ConfigPanel.Padding = new System.Windows.Forms.Padding(3);
            this.ConfigPanel.Size = new System.Drawing.Size(868, 366);
            this.ConfigPanel.TabIndex = 5;
            this.ConfigPanel.Text = "Config";
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
            // ConfigPanels
            // 
            this.ConfigPanels.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.ConfigPanels.Controls.Add(this.ConfigConfigPanel);
            this.ConfigPanels.Controls.Add(this.DatabaseConfigPanel);
            this.ConfigPanels.Controls.Add(this.GameConfigPanel);
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
            this.WorldStatusTimer.Interval = 5000;
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
            ((System.ComponentModel.ISupportInitialize)(this.PortSelector)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.ServerTestmergeInput)).EndInit();
            this.ConfigPanel.ResumeLayout(false);
            this.ConfigPanels.ResumeLayout(false);
            this.ResumeLayout(false);

		}

		#endregion
		private System.Windows.Forms.TabControl Panels;
		private System.Windows.Forms.TabPage RepoPanel;
		private System.Windows.Forms.Label RepoProgressBarLabel;
		private System.Windows.Forms.ProgressBar RepoProgressBar;
		private System.Windows.Forms.Button CloneRepositoryButton;
		private System.ComponentModel.BackgroundWorker RepoBGW;
		private System.Windows.Forms.Label CurrentRevisionLabel;
		private System.Windows.Forms.TextBox RepoEmailTextBox;
		private System.Windows.Forms.TextBox RepoCommitterNameTextBox;
		private System.Windows.Forms.Button RepoApplyButton;
		private System.Windows.Forms.TextBox RepoBranchTextBox;
		private System.Windows.Forms.TextBox RepoRemoteTextBox;
		private System.Windows.Forms.Button HardReset;
		private System.Windows.Forms.Button UpdateRepoButton;
		private System.Windows.Forms.Button MergePRButton;
		private System.Windows.Forms.Label CommitterEmailTitle;
		private System.Windows.Forms.Label CommiterNameTitle;
		private System.Windows.Forms.Label IdentityLabel;
		private System.Windows.Forms.Label TestMergeListTitle;
		private System.Windows.Forms.Label RemoteNameTitle;
		private System.Windows.Forms.Label BranchNameTitle;
		private System.Windows.Forms.Label CurrentRevisionTitle;
		private System.Windows.Forms.TabPage BYONDPanel;
		private System.Windows.Forms.TabPage ServerPanel;
		private System.Windows.Forms.TabPage tabPage3;
		private System.Windows.Forms.TextBox TestMergeListLabel;
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
		private System.Windows.Forms.TabPage IRCPanel;
		private System.Windows.Forms.TabPage ConfigPanel;
		private System.Windows.Forms.NumericUpDown TestmergeSelector;
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
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.NumericUpDown ServerTestmergeInput;
		private System.Windows.Forms.Button TestmergeButton;
		private System.Windows.Forms.Button UpdateTestmergeButton;
		private System.Windows.Forms.Button UpdateMergeButton;
		private System.Windows.Forms.Button UpdateHardButton;
		private System.ComponentModel.BackgroundWorker FullUpdateWorker;
		private System.Windows.Forms.TextBox CommitterPasswordTextBox;
		private System.Windows.Forms.TextBox CommitterLoginTextBox;
		private System.Windows.Forms.Label CommitterPasswordTitle;
		private System.Windows.Forms.Label CommiterLoginTitle;
		private System.Windows.Forms.Button RepoPushButton;
		private System.Windows.Forms.Button RepoCommitButton;
		private System.Windows.Forms.Button RepoGenChangelogButton;
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
	}
}

