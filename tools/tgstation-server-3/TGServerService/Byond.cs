using System;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Threading;
using TGServiceInterface;

namespace TGServerService
{
	partial class TGStationServer : ITGByond
	{
		const string ByondDirectory = "BYOND";
		const string StagingDirectory = "BYOND_staged";
		const string StagingDirectoryInner = "BYOND_staged/byond";
		const string RevisionDownloadPath = "BYONDRevision.zip";
		const string VersionFile = "/byond_version.dat";
		const string ByondRevisionsURL = "https://secure.byond.com/download/build/{0}/{0}.{1}_byond.zip";

		const string ByondConfigDir = "/BYOND/cfg";
		const string ByondDDConfig = "/daemon.txt";
		const string ByondNoPromptTrustedMode = "trusted-check 0";

		TGByondStatus updateStat = TGByondStatus.Idle;
		object ByondLock = new object();
		string lastError;

		Thread RevisionStaging;

		//Just cleanup
		void InitByond()
		{
			//linger not
			if (File.Exists(RevisionDownloadPath))
				File.Delete(RevisionDownloadPath);
			Program.DeleteDirectory(StagingDirectory);
		}

		//Kill the thread and cleanup again
		void DisposeByond()
		{
			lock (ByondLock)
			{
				if (RevisionStaging != null)
					RevisionStaging.Abort();
				InitByond();
			}
		}

		//requires ByondLock to be locked
		bool BusyCheckNoLock()
		{
			switch (updateStat)
			{
				default:
				case TGByondStatus.Starting:
				case TGByondStatus.Downloading:
				case TGByondStatus.Staging:
				case TGByondStatus.Updating:
					return true;
				case TGByondStatus.Idle:
				case TGByondStatus.Staged:
					return false;
			}
		}

		//public api
		public TGByondStatus CurrentStatus()
		{
			lock (ByondLock)
			{
				return updateStat;
			}
		}

		//public api
		public string GetError()
		{
			lock (ByondLock)
			{
				var error = lastError;
				lastError = null;
				return error;
			}
		}

		//public api
		public string GetVersion(bool staged)
		{
			lock (ByondLock)
			{
				string DirToUse = staged ? StagingDirectoryInner : ByondDirectory;
				if (Directory.Exists(DirToUse)) {
					string file = DirToUse + VersionFile;
					if(File.Exists(file))
						return File.ReadAllText(file);
				}
				return null;
			}
		}

		//literally just for passing 2 ints to the thread function
		class VersionInfo
		{
			public int major, minor;
		}

		//does the downloading and unzipping
		//calls ApplyStagedUpdate() after if the server isn't running
		public void UpdateToVersionImpl(object param)
		{
			lock (ByondLock) { 
				if (updateStat != TGByondStatus.Starting)
					return;
				updateStat = TGByondStatus.Downloading;
			}

			try
			{
				//remove leftovers
				if (File.Exists(RevisionDownloadPath))
					File.Delete(RevisionDownloadPath);
				Program.DeleteDirectory(StagingDirectory);

				var client = new WebClient();
				var vi = (VersionInfo)param;
				SendMessage(String.Format("BYOND: Updating to version {0}.{1}...", vi.major, vi.minor));

				//DOWNLOADING

				try
				{
					client.DownloadFile(String.Format(ByondRevisionsURL, vi.major, vi.minor), RevisionDownloadPath);
				}
				catch
				{
					SendMessage("BYOND: Update download failed. Does the specified version exist?");
					lastError = String.Format("Download of BYOND version {0}.{1} failed! Does it exist?", vi.major, vi.minor);
					TGServerService.ActiveService.EventLog.WriteEntry(String.Format("Failed to update BYOND to version {0}.{1}!", vi.major, vi.minor), EventLogEntryType.Warning);
					lock (ByondLock)
					{
						updateStat = TGByondStatus.Idle;
					}
					return;
				}

				lock (ByondLock)
				{
					updateStat = TGByondStatus.Staging;
				}

				//STAGING
				
				ZipFile.ExtractToDirectory(RevisionDownloadPath, StagingDirectory);
				lock (ByondLock)
				{
					File.WriteAllText(StagingDirectoryInner + VersionFile, String.Format("{0}.{1}", vi.major, vi.minor));
				}
				File.Delete(RevisionDownloadPath);

				lock (ByondLock)
				{
					updateStat = TGByondStatus.Staged;
				}

				switch (DaemonStatus())
				{
					case TGDreamDaemonStatus.Offline:
						if(ApplyStagedUpdate())
							lastError = null;
						else
							lastError = "Failed to apply update!";
						break;
					default:
						RequestRestart();
						lastError = "Update staged. Awaiting server restart...";
						SendMessage(String.Format("BYOND: Staging complete. Awaiting server restart...", vi.major, vi.minor));
						TGServerService.ActiveService.EventLog.WriteEntry(String.Format("BYOND update {0}.{1} staged", vi.major, vi.minor));
						break;
				}
			}
			catch (ThreadAbortException)
			{
				return;
			}
			catch (Exception e)
			{
				TGServerService.ActiveService.EventLog.WriteEntry("Revision staging errror: " + e.ToString(), EventLogEntryType.Error);
				lock (ByondLock)
				{
					updateStat = TGByondStatus.Idle;
					lastError = e.ToString();
					RevisionStaging = null;
				}
			}
		}
		//public api for kicking off the update thread
		public bool UpdateToVersion(int ma, int mi)
		{
			lock (ByondLock)
			{
				if (!BusyCheckNoLock())
				{
					updateStat = TGByondStatus.Starting;
					RevisionStaging = new Thread(new ParameterizedThreadStart(UpdateToVersionImpl))
					{
						IsBackground = true //don't slow me down
					};
					RevisionStaging.Start(new VersionInfo { major = ma, minor = mi });
					return true;
				}
				return false; 
			}
		}
		//tries to apply the staged update
		public bool ApplyStagedUpdate()
		{
			lock (CompilerLock)
			{
				if (compilerCurrentStatus == TGCompilerStatus.Compiling)
					return false;
				lock (ByondLock)
				{

					if (updateStat != TGByondStatus.Staged)
						return false;
					updateStat = TGByondStatus.Updating;
				}
				try
				{
					//IMPORTANT: SET THE BYOND CONFIG TO NOT PROMPT FOR TRUSTED MODE REEE
					var dir = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments) + ByondConfigDir;
					Directory.CreateDirectory(dir);
					File.WriteAllText(dir + ByondDDConfig, ByondNoPromptTrustedMode);

					Program.DeleteDirectory(ByondDirectory);
					Directory.Move(StagingDirectoryInner, ByondDirectory);
					Program.DeleteDirectory(StagingDirectory);
					lastError = null;
					SendMessage("BYOND: Update completed!");
					return true;
				}
				catch (Exception e)
				{
					lastError = e.ToString();
					SendMessage("BYOND: Update failed!");
					return false;
				}
				finally
				{
					lock(ByondLock) {
						updateStat = TGByondStatus.Idle;
					}
				}
			}
		}
	}
}
