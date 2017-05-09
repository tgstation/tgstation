using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using TGServiceInterface;

namespace TGControlPanel
{
	static class Program
	{
		[STAThread]
		static void Main(string [] args)
		{
			try
			{
				var res = Server.VerifyConnection();
				if (res != null)
				{
					MessageBox.Show("Unable to connect to service! Error: " + res);
					return;
				}
				Application.EnableVisualStyles();
				Application.SetCompatibleTextRenderingDefault(false);
				Application.Run(new Main());
				return;
			}
			catch (Exception e)
			{
				MessageBox.Show("An unhandled exception occurred. This usually means we lost connection to the service. Error" + e.ToString());
				return;
			}
			finally
			{
				Properties.Settings.Default.Save();
			}
		}

		public static string TextPrompt(string caption, string text)
		{
			Form prompt = new Form()
			{
				Width = 500,
				Height = 150,
				FormBorderStyle = FormBorderStyle.FixedDialog,
				Text = caption,
				StartPosition = FormStartPosition.CenterScreen
			};
			Label textLabel = new Label() { Left = 50, Top = 20, Text = text, AutoSize = true };
			TextBox textBox = new TextBox() { Left = 50, Top = 50, Width = 400 };
			Button confirmation = new Button() { Text = "Ok", Left = 350, Width = 100, Top = 70, DialogResult = DialogResult.OK };
			confirmation.Click += (sender, e) => { prompt.Close(); };
			prompt.Controls.Add(textBox);
			prompt.Controls.Add(confirmation);
			prompt.Controls.Add(textLabel);
			prompt.AcceptButton = confirmation;

			return prompt.ShowDialog() == DialogResult.OK ? textBox.Text : null;
		}
	}
}
