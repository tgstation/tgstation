namespace AddToChangelog
{
    partial class MainForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.authorBox = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.dateBox = new System.Windows.Forms.MaskedTextBox();
            this.dropdownBox = new System.Windows.Forms.ComboBox();
            this.getButton = new System.Windows.Forms.Button();
            this.addButton = new System.Windows.Forms.Button();
            this.resultsBox = new System.Windows.Forms.TextBox();
            this.addLineButton = new System.Windows.Forms.Button();
            this.addLineBox = new System.Windows.Forms.TextBox();
            this.listBox = new System.Windows.Forms.TextBox();
            this.saveButton = new System.Windows.Forms.Button();
            this.editBox = new System.Windows.Forms.TextBox();
            this.reloadButton = new System.Windows.Forms.Button();
            this.pictureBox = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(20, 46);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(33, 13);
            this.label1.TabIndex = 10;
            this.label1.Text = "Date:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(20, 21);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(41, 13);
            this.label2.TabIndex = 11;
            this.label2.Text = "Author:";
            // 
            // authorBox
            // 
            this.authorBox.Location = new System.Drawing.Point(67, 18);
            this.authorBox.Name = "authorBox";
            this.authorBox.Size = new System.Drawing.Size(154, 20);
            this.authorBox.TabIndex = 1;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(330, 21);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(68, 13);
            this.label3.TabIndex = 12;
            this.label3.Text = "Add change:";
            // 
            // dateBox
            // 
            this.dateBox.Location = new System.Drawing.Point(67, 43);
            this.dateBox.Mask = "00/00/0000";
            this.dateBox.Name = "dateBox";
            this.dateBox.Size = new System.Drawing.Size(79, 20);
            this.dateBox.TabIndex = 2;
            this.dateBox.ValidatingType = typeof(System.DateTime);
            // 
            // dropdownBox
            // 
            this.dropdownBox.DisplayMember = "\"";
            this.dropdownBox.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.dropdownBox.FormattingEnabled = true;
            this.dropdownBox.Items.AddRange(new object[] {
            "Added feature",
            "Removed feature",
            "Bugfix",
            "Work in progress",
            "Tweak",
            "Experimental feature",
            "Added icon",
            "Removed icon",
            "Added sound",
            "Removed sound"});
            this.dropdownBox.Location = new System.Drawing.Point(856, 17);
            this.dropdownBox.MaxDropDownItems = 10;
            this.dropdownBox.Name = "dropdownBox";
            this.dropdownBox.Size = new System.Drawing.Size(121, 21);
            this.dropdownBox.TabIndex = 7;
            this.dropdownBox.SelectedIndexChanged += new System.EventHandler(this.dropdownBox_SelectedIndexChanged);
            // 
            // getButton
            // 
            this.getButton.Location = new System.Drawing.Point(17, 70);
            this.getButton.Name = "getButton";
            this.getButton.Size = new System.Drawing.Size(69, 21);
            this.getButton.TabIndex = 3;
            this.getButton.Text = "Get HTML";
            this.getButton.UseVisualStyleBackColor = true;
            this.getButton.Click += new System.EventHandler(this.getButton_Click);
            // 
            // addButton
            // 
            this.addButton.Location = new System.Drawing.Point(92, 70);
            this.addButton.Name = "addButton";
            this.addButton.Size = new System.Drawing.Size(69, 21);
            this.addButton.TabIndex = 4;
            this.addButton.Text = "Lazy Add";
            this.addButton.UseVisualStyleBackColor = true;
            this.addButton.Click += new System.EventHandler(this.addButton_Click);
            // 
            // resultsBox
            // 
            this.resultsBox.Location = new System.Drawing.Point(11, 101);
            this.resultsBox.Multiline = true;
            this.resultsBox.Name = "resultsBox";
            this.resultsBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.resultsBox.Size = new System.Drawing.Size(318, 356);
            this.resultsBox.TabIndex = 10;
            // 
            // addLineButton
            // 
            this.addLineButton.Location = new System.Drawing.Point(983, 17);
            this.addLineButton.Name = "addLineButton";
            this.addLineButton.Size = new System.Drawing.Size(21, 21);
            this.addLineButton.TabIndex = 8;
            this.addLineButton.Text = "+";
            this.addLineButton.UseVisualStyleBackColor = true;
            this.addLineButton.Click += new System.EventHandler(this.addLineButton_Click);
            // 
            // addLineBox
            // 
            this.addLineBox.Location = new System.Drawing.Point(404, 18);
            this.addLineBox.Name = "addLineBox";
            this.addLineBox.Size = new System.Drawing.Size(415, 20);
            this.addLineBox.TabIndex = 6;
            // 
            // listBox
            // 
            this.listBox.Location = new System.Drawing.Point(335, 46);
            this.listBox.Multiline = true;
            this.listBox.Name = "listBox";
            this.listBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.listBox.Size = new System.Drawing.Size(669, 49);
            this.listBox.TabIndex = 9;
            // 
            // saveButton
            // 
            this.saveButton.Location = new System.Drawing.Point(260, 70);
            this.saveButton.Name = "saveButton";
            this.saveButton.Size = new System.Drawing.Size(69, 21);
            this.saveButton.TabIndex = 5;
            this.saveButton.Text = "Save";
            this.saveButton.UseVisualStyleBackColor = true;
            this.saveButton.Click += new System.EventHandler(this.saveButton_Click);
            // 
            // editBox
            // 
            this.editBox.Location = new System.Drawing.Point(335, 101);
            this.editBox.MaxLength = 9999999;
            this.editBox.Multiline = true;
            this.editBox.Name = "editBox";
            this.editBox.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.editBox.Size = new System.Drawing.Size(669, 356);
            this.editBox.TabIndex = 13;
            // 
            // reloadButton
            // 
            this.reloadButton.Location = new System.Drawing.Point(185, 70);
            this.reloadButton.Name = "reloadButton";
            this.reloadButton.Size = new System.Drawing.Size(69, 21);
            this.reloadButton.TabIndex = 14;
            this.reloadButton.Text = "Reload";
            this.reloadButton.UseVisualStyleBackColor = true;
            this.reloadButton.Click += new System.EventHandler(this.reloadButton_Click);
            // 
            // pictureBox
            // 
            this.pictureBox.Location = new System.Drawing.Point(834, 20);
            this.pictureBox.Name = "pictureBox";
            this.pictureBox.Size = new System.Drawing.Size(16, 16);
            this.pictureBox.TabIndex = 15;
            this.pictureBox.TabStop = false;
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ControlLightLight;
            this.ClientSize = new System.Drawing.Size(1016, 469);
            this.Controls.Add(this.pictureBox);
            this.Controls.Add(this.reloadButton);
            this.Controls.Add(this.editBox);
            this.Controls.Add(this.saveButton);
            this.Controls.Add(this.listBox);
            this.Controls.Add(this.addLineBox);
            this.Controls.Add(this.addLineButton);
            this.Controls.Add(this.resultsBox);
            this.Controls.Add(this.addButton);
            this.Controls.Add(this.getButton);
            this.Controls.Add(this.dropdownBox);
            this.Controls.Add(this.dateBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.authorBox);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "MainForm";
            this.Text = "Add To Changelog";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.Shown += new System.EventHandler(this.MainForm_Shown);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox authorBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.MaskedTextBox dateBox;
        private System.Windows.Forms.ComboBox dropdownBox;
        private System.Windows.Forms.Button getButton;
        private System.Windows.Forms.Button addButton;
        private System.Windows.Forms.TextBox resultsBox;
        private System.Windows.Forms.Button addLineButton;
        private System.Windows.Forms.TextBox addLineBox;
        private System.Windows.Forms.TextBox listBox;
        private System.Windows.Forms.Button saveButton;
        private System.Windows.Forms.TextBox editBox;
        private System.Windows.Forms.Button reloadButton;
        private System.Windows.Forms.PictureBox pictureBox;
    }
}

