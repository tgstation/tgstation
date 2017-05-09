using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using TGServiceInterface;

namespace TGServerService
{
	//manages the dd window.
	//It's not possible to actually click it while starting it in CL mode, so in order to change visibility etc. It restarts the process when the round ends
	partial class TGStationServer : ITGDreamDaemon
	{

		const int DDHangStartTime = 60;
		const int DDBadStartTime = 10;
		const int DDRestartMaxRetries = 5;

		Process Proc;

		object watchdogLock = new object();
		Thread DDWatchdog;
		TGDreamDaemonStatus currentStatus;
		ushort currentPort = 0;

		object restartLock = new object();
		bool RestartInProgress = false;
		bool AwaitingShutdown = false;

		TGDreamDaemonSecurity StartingSecurity;
		TGDreamDaemonVisibility StartingVisiblity;

		//Only need 1 proc instance
		void InitDreamDaemon()
		{
			Proc = new Process();
			Proc.StartInfo.FileName = ByondDirectory + "/bin/dreamdaemon.exe";
			Proc.StartInfo.UseShellExecute = false;

			//autostart the server
			if (Properties.Settings.Default.DDAutoStart)
				//break this off so we don't hold up starting the service
				new Thread(new ThreadStart(InitStart));
		}

		//void wrapper for Start
		void InitStart()
		{
			Start();
		}

		//die now k thx
		void DisposeDreamDaemon()
		{
			if (DaemonStatus() == TGDreamDaemonStatus.Online)
			{
				SendCommand(SCWorldAnnounce + ";message=Server service stopped");
				Thread.Sleep(1000);
			}
			Stop();
		}

		//public api
		public TGDreamDaemonStatus DaemonStatus()
		{
			lock (watchdogLock)
			{
				return currentStatus;
			}
		}

		//public api
		public void RequestRestart()
		{
			SendCommand(SCHardReboot);
		}

		//public api
		public void RequestStop()
		{
			lock (watchdogLock)
			{
				AwaitingShutdown = true;
			}
			SendCommand(SCGracefulShutdown);
		}

		//public api
		public string Stop()
		{
			Thread t;
			lock (watchdogLock)
			{
				t = DDWatchdog;
				DDWatchdog = null;
			}
			if (t != null && t.IsAlive)
			{
				t.Abort();
				t.Join();
				return null;
			}
			else
				return "Server not running";
		}

		//public api
		public void SetPort(ushort new_port)
		{
			lock (watchdogLock)
			{
				Properties.Settings.Default.ServerPort = new_port;
				RequestRestart();
			}
		}

		//public api
		public string Restart()
		{
			if (DaemonStatus() == TGDreamDaemonStatus.Offline)
				return Start();
			if (!Monitor.TryEnter(restartLock))
				return "Restart already in progress";
			try
			{
				SendMessage("DD: Hard restart triggered");
				RestartInProgress = true;
				Stop();
				var res = Start();
				return res;
			}
			finally
			{
				RestartInProgress = false;
				Monitor.Exit(restartLock);
			}
		}

		//loop that keeps the server running
		void Watchdog()
		{
			try
			{
				lock (restartLock)
				{
					if (!RestartInProgress)
						SendMessage("DD: Server started, watchdog active...");
					else
						RestartInProgress = false;
				}
				var retries = DDRestartMaxRetries;
				while (true)
				{
					var starttime = DateTime.Now;
					Proc.WaitForExit();

					lock (watchdogLock)
					{
						currentStatus = TGDreamDaemonStatus.HardRebooting;
						currentPort = 0;
						Proc.Close();

						if (AwaitingShutdown)
							return;

						if ((DateTime.Now - starttime).Seconds < DDBadStartTime)
						{
							if (retries == 0)
							{
								SendMessage("DD: DEFCON 0: Watchdog unable to restart server!");
								TGServerService.ActiveService.EventLog.WriteEntry("Watchdog failed to restart server! Shutting down!", EventLogEntryType.Error);
								return;
							}

							SendMessage(String.Format("DD: DEFCON {0}: Watchdog server startup failed!", retries));

							--retries;
						}
						else
						{
							retries = DDRestartMaxRetries;
							SendMessage("DD: DreamDaemon crashed or exited! Rebooting...");
						}
					}

					var res = StartImpl(true);
					if (res != null)
						throw new Exception("Hard restart failed: " + res);
				}
			}
			catch(ThreadAbortException)
			{
				//No Mr bond, I expect you to die
				try
				{
					Proc.Kill();
					Proc.Close();
				}
				catch
				{ }
			}
			catch (Exception e)
			{
				SendMessage("DD: Watchdog thread crashed!");
				TGServerService.ActiveService.EventLog.WriteEntry("Watch dog thread crashed! Exception: " + e.ToString(), EventLogEntryType.Error);
			}
			finally
			{
				lock (watchdogLock)
				{
					currentStatus = TGDreamDaemonStatus.Offline;
					currentPort = 0;
					AwaitingShutdown = false;
					if (!RestartInProgress)
						SendMessage("DD: Watchdog exiting...");
				}
			}
		}

		//public api
		public string CanStart()
		{
			lock (watchdogLock)
			{
				if (GetVersion(false) == null)
					return "Byond is not installed!";
				var DMB = GameDirLive + "/" + Properties.Settings.Default.ProjectName + ".dmb";
				if (!File.Exists(DMB))
					return String.Format("Unable to find {0}!", DMB);
				return null;
			}
		}

		//public api
		public string Start()
		{
			if (CurrentStatus() == TGByondStatus.Staged)
			{
				//IMPORTANT: SLEEP FOR A MOMENT OR WONDOWS WON'T RELEASE THE FUCKING BYOND DLL HANDLES!!!! REEEEEEE
				Thread.Sleep(3000);
				ApplyStagedUpdate();
			}
			lock (watchdogLock)
			{
				if (currentStatus != TGDreamDaemonStatus.Offline)
					return "Server already running";
				currentStatus = TGDreamDaemonStatus.HardRebooting;
				currentPort = 0;
			}
			var res = CanStart();
			if (res != null)
				return res;
			return StartImpl(false);
		}

		//translate the configured security level into a byond param
		string SecurityWord(bool starting = false)
		{
			var level = starting ? StartingSecurity : (TGDreamDaemonSecurity)Properties.Settings.Default.ServerSecurity;
			switch (level)
			{
				case TGDreamDaemonSecurity.Safe:
					return "safe";
				case TGDreamDaemonSecurity.Trusted:
					return "trusted";
				case TGDreamDaemonSecurity.Ultrasafe:
					return "ultrasafe";
				default:
					throw new Exception(String.Format("Bad DreamDaemon security level: {0}", level));
			}
		}

		//same thing with visibility
		string VisibilityWord(bool starting = false)
		{
			var level = starting ? StartingVisiblity : (TGDreamDaemonVisibility)Properties.Settings.Default.ServerVisiblity;
			switch (level)
			{
				case TGDreamDaemonVisibility.Invisible:
					return "invisible";
				case TGDreamDaemonVisibility.Private:
					return "private";
				case TGDreamDaemonVisibility.Public:
					return "public";
				default:
					throw new Exception(String.Format("Bad DreamDaemon visibility level: {0}", level));
			}
		}

		//used by Start and Watchdog to start a DD instance
		string StartImpl(bool watchdog)
		{
			try
			{
				var res = CanStart();
				if (res != null)
					return res;

				lock (watchdogLock)
				{
					var Config = Properties.Settings.Default;
					var DMB = GameDirLive + "/" + Config.ProjectName + ".dmb";

					GenCommsKey();
					StartingVisiblity = (TGDreamDaemonVisibility)Config.ServerVisiblity;
					StartingSecurity = (TGDreamDaemonSecurity)Config.ServerSecurity;
					Proc.StartInfo.Arguments = String.Format("{0} -port {1} -close -verbose -params server_service={4} -{2} -{3}", DMB, Config.ServerPort, SecurityWord(), VisibilityWord(), serviceCommsKey);
					Proc.Start();

					if (!Proc.WaitForInputIdle(DDHangStartTime * 1000))
					{
						Proc.Kill();
						Proc.Close();
						currentStatus = TGDreamDaemonStatus.Offline;
						currentPort = 0;
						return String.Format("Server start is taking more than {0}s! Aborting!", DDHangStartTime);
					}
					currentPort = Config.ServerPort;
					currentStatus = TGDreamDaemonStatus.Online;
					if (!watchdog)
					{
						DDWatchdog = new Thread(new ThreadStart(Watchdog));
						DDWatchdog.Start();
					}
					return null;
				}
			}
			catch (Exception e)
			{
				currentStatus = TGDreamDaemonStatus.Offline;
				return e.ToString();
			}
		}

		//public api
		public void SetVisibility(TGDreamDaemonVisibility NewVis)
		{
			Properties.Settings.Default.ServerVisiblity = (int)NewVis;
			RequestRestart();
		}

		//public api
		public void SetSecurityLevel(TGDreamDaemonSecurity level)
		{
			Properties.Settings.Default.ServerSecurity = (int)level;
			RequestRestart();
		}

		//public api
		public bool Autostart()
		{
			return Properties.Settings.Default.DDAutoStart;
		}

		//public api
		public void SetAutostart(bool on)
		{
			Properties.Settings.Default.DDAutoStart = on;
		}

		public string StatusString(bool includeMetaInfo = true)
		{
			var visSecStr = " (Vis: {0}, Sec: {1})";
			string res;
			var ds = DaemonStatus();
			switch (ds)
			{
				case TGDreamDaemonStatus.Offline:
					res = "OFFLINE";
					break;
				case TGDreamDaemonStatus.HardRebooting:
					res = "REBOOTING";
					break;
				case TGDreamDaemonStatus.Online:
					lock (watchdogLock)
					{
						visSecStr = String.Format(visSecStr, VisibilityWord(true), SecurityWord(true));
					}
					res = SendCommand(SCIRCCheck) + visSecStr;
					break;
				default:
					res = "NULL AND ERRORS" + String.Format(visSecStr, VisibilityWord(), SecurityWord());
					break;
			}
			if (includeMetaInfo)
				return res +String.Format(visSecStr, VisibilityWord(ds == TGDreamDaemonStatus.Online), SecurityWord(ds == TGDreamDaemonStatus.Online));
			return res;
		}

		public ushort Port()
		{
			return Properties.Settings.Default.ServerPort;
		}
	}
}
