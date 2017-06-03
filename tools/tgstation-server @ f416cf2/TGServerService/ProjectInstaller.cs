using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace ServerService
{
	[RunInstaller(true)]
	public partial class ProjectInstaller : Installer
	{
		public ProjectInstaller()
		{
			InitializeComponent();
			serviceInstaller1.BeforeUninstall += ServiceInstaller1_BeforeUninstall;
		}

		private void ServiceInstaller1_BeforeUninstall(object sender, InstallEventArgs e)
		{
		}

		private void ServiceInstaller1_AfterInstall(object sender, InstallEventArgs e)
		{
			using (ServiceController sc = new ServiceController(serviceInstaller1.ServiceName))
			{
				sc.Start();
			}
		}
	}
}
