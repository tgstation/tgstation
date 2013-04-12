using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.IO;
using System.Reflection;

namespace AddToChangelog
{
    public partial class MainForm : Form
    {

        public string changelogPath = "changelog.html";
        public string changelogMarker = "#ADDTOCHANGELOGMARKER#";
        public string longDateFormat = "d MMMM yyyy";
        public string shortDateFormat = "ddMMyyyy";

        public Dictionary<string, string> ItemList = new Dictionary<string, string>()
        {
            { "Added feature", "rscadd" },
            { "Removed feature", "rscdel" },
            { "Bugfix", "bugfix" },
            { "Work in progress", "wip" },
            { "Tweak", "tweak" },
            { "Experimental feature", "experiment" },
            { "Added icon", "imageadd" },
            { "Removed icon", "imagedel" },
            { "Added sound", "soundadd" },
            { "Removed sound", "sounddel" }
        };

        public Dictionary<string, Bitmap> ImageList = new Dictionary<string, Bitmap>();

        public MainForm()
        {
            InitializeComponent();
            this.dropdownBox.SelectedIndex = 0;
            this.dateBox.Text = DateTime.Now.ToString(shortDateFormat);
            this.listBox.Text = "# Enter your logs in the text box above and it'll be parsed into here. You can use 'Get HTML' to format it for the changelog. You can also use Lazy Add to automatically add the logs to the changelog, no effort needed (just remember to save)! Below is the changelog, you can edit and save it from here to easily fix mistakes. Save will save the changelog below, reload will undo any unsaved changes.";
        }

        public void SaveChangelog()
        {
            DialogResult dialogResult = MessageBox.Show("Are you sure?", "Confirm", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                try
                {
                    File.WriteAllText(changelogPath, editBox.Text);
                }
                catch
                {
                    MessageBox.Show("Could not find '" + changelogPath + "'. Please place me on the same folder as " + changelogPath + ".");
                }
            }
        }

        public void ScrollToMarker()
        {
            int selection = editBox.Text.IndexOf(changelogMarker);
            if (selection > 0)
            {
                // Hacky way to scroll the edit text box to the beginning of the changelog entries
                this.ActiveControl = editBox;
                this.Refresh();
                editBox.SelectionStart = editBox.Text.Length - 1;
                editBox.SelectionLength = 0;
                editBox.ScrollToCaret();
                editBox.SelectionStart = selection - 2;
                editBox.ScrollToCaret();
            }
        }

        // Load up the changelog

        public void ReadChangelog()
        {
            try
            {
                string changelog = File.ReadAllText(changelogPath);
                editBox.Text = changelog;
                ScrollToMarker();
            }
            catch (Exception e)
            {
                MessageBox.Show("Could not find '" + changelogPath + "'. Please place me on the same folder as " + changelogPath + "." + e);
            }
        }

        // Get the log notes

        public string GetHTMLLines()
        {
            StringReader stringReader = new StringReader(listBox.Text);
            string html = "";
            string aLine = "";

            do
            {
                aLine = stringReader.ReadLine();
                if (aLine != null)
                {
                    // remove < and >
                    if (aLine.StartsWith("<") && aLine.Contains(">"))
                    {
                        string tag = aLine.Substring(1, aLine.IndexOf(">") - 1); // extract the tag
                        aLine = aLine.Substring(aLine.IndexOf(">") + 1); // now remove the tag from the line
                        aLine = "\t\t<li class='" + tag + "'>" + aLine + "</li>\r\n"; // give html
                    }
                    else
                    {
                        aLine = "\t\t<li class='rscadd'>" + aLine + "</li>\r\n";
                    }

                    html += aLine;
                }

            } while (aLine != null);

            return html;
        }

        private void addLineButton_Click(object sender, EventArgs e)
        {
            if (addLineBox.Text == "")
            {
                return;
            }

            string textAdd = this.addLineBox.Text;
            string listItem = this.dropdownBox.SelectedItem.ToString();
            string itemClass = ItemList[listItem];

            if (itemClass == null)
            {
                return;
            }

            if (listBox.Text.StartsWith("#"))
            {
                listBox.Text = "";
            }

            listBox.Text += "<" + itemClass + ">" + textAdd + "\r\n";
            addLineBox.Text = "";

        }

        private void getButton_Click(object sender, EventArgs e)
        {
            if (listBox.Text != "")
            {
                DateTime dateTime;
                if (!DateTime.TryParse(dateBox.Text, out dateTime))
                {
                    MessageBox.Show("Invalid date time.");
                    return;
                }

                resultsBox.Text = "<div class='commit sansserif'>\r\n";
                resultsBox.Text += "\t<h2 class='date'>" + dateTime.ToString(longDateFormat) + "</h2>\r\n";
                resultsBox.Text += "\t<h3 class='author'>" + authorBox.Text + " updated:</h3>\r\n";
                resultsBox.Text += "\t<ul class='changes bgimages16'>\r\n";
                resultsBox.Text += GetHTMLLines();
                resultsBox.Text += "\t</ul>\r\n";
                resultsBox.Text += "</div>";
            }
        }

        // Automatically add to changelog

        private void addButton_Click(object sender, EventArgs e)
        {
            if (resultsBox.Text == "")
            {
                getButton_Click(this, EventArgs.Empty);
            }

            if (resultsBox.Text == "")
            {
                return;
            }

            string html = resultsBox.Text;

            string[] changelogFile = null;

            changelogFile = editBox.Text.Split('\n');

            if (changelogFile != null)
            {
                bool foundMarker = false;
                for (int i = 0; i < changelogFile.Length; i++)
                {
                    if (foundMarker == false)
                    {
                        string line = changelogFile[i];
                        if (line.Contains(changelogMarker))
                        {
                            line += "\r\n\r\n";
                            line += resultsBox.Text;
                            line += "\r\n";
                            changelogFile[i] = line;
                            foundMarker = true;
                            break;
                        }
                    }
                }

                if (foundMarker == false)
                {
                    MessageBox.Show("Could not find '#ADDTOCHANGELOGMARKER#' in '" + changelogPath + "'. Please place one above where the changelog entries start, inside a comment.");
                }
                else
                {
                    editBox.Text = String.Join("\n", changelogFile);
                    ScrollToMarker();
                }
  
            }
        }

        private void saveButton_Click(object sender, EventArgs e)
        {
            SaveChangelog();
        }

        private void reloadButton_Click(object sender, EventArgs e)
        {
            ReadChangelog();
        }

        private void MainForm_Shown(object sender, EventArgs e)
        {
            ReadChangelog();
        }

        private void dropdownBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Change the image to reflect the drop down box selection
            if (ImageList.Count > 0)
            {
                string value = ItemList[dropdownBox.SelectedItem.ToString()];
                pictureBox.Image = ImageList[value];
            }
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            // Get our embedded images. Use our dictionaries to help.
            foreach (string value in ItemList.Values)
            {
                Assembly myAssembly = Assembly.GetExecutingAssembly();
                Stream myStream = myAssembly.GetManifestResourceStream("AddToChangelog." + value + ".png");
                Bitmap image = new Bitmap(myStream);

                ImageList.Add(value, image);
            }

            pictureBox.Image = ImageList["rscadd"];
        }
    }
}
