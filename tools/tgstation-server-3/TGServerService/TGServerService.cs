using System;
using System.IO;
using System.ServiceModel;
using System.ServiceProcess;
using System.Threading;
using TGServiceInterface;

namespace TGServerService
{
	public partial class TGServerService : ServiceBase
	{
		public static TGServerService ActiveService;	//So everyone else can write to our eventlog

		ServiceHost host;	//the WCF host
		
		//I'm entirely not sure what this is for
		//but you should seriously not add anything here
		//Use OnStart instead
		public TGServerService()
		{
			InitializeComponent();
		}

		//when babby is formed
		protected override void OnStart(string[] args)
		{
			ActiveService = this;
			try
			{
				var Config = Properties.Settings.Default;
				if (!Directory.Exists(Config.ServerDirectory))
				{
					EventLog.WriteEntry("Creating server directory: " + Config.ServerDirectory);
					Directory.CreateDirectory(Config.ServerDirectory);
				}
				Environment.CurrentDirectory = Config.ServerDirectory;

				host = new ServiceHost(typeof(TGStationServer), new Uri[] { new Uri("net.pipe://localhost") })
				{
					CloseTimeout = new TimeSpan(0, 0, 5)
				}; //construction runs here

				AddEndpoint<ITGRepository>();
				AddEndpoint<ITGByond>();
				AddEndpoint<ITGCompiler>();
				AddEndpoint<ITGDreamDaemon>();
				AddEndpoint<ITGStatusCheck>();
				AddEndpoint<ITGIRC>();
				AddEndpoint<ITGConfig>();
				AddEndpoint<ITGServerUpdater>();

				host.Open();	//...or maybe here, doesn't really matter
			}
			catch
			{
				ActiveService = null;
				throw;
			}
		}

		//shorthand for adding the WCF endpoint
		void AddEndpoint<T>()
		{
			var typetype = typeof(T);
			host.AddServiceEndpoint(typetype, new NetNamedPipeBinding(), Server.MasterPipeName + "/" + typetype.Name);
		}

		//when we is kill
		protected override void OnStop()
		{
			try
			{
				host.Close();	//where TGStationServer.Dispose() is called
				host = null;
			}
			finally
			{
				Properties.Settings.Default.Save();
				ActiveService = null;
			}
		}
	}
}
