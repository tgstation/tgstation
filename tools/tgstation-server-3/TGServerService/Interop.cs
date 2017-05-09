using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Web.Security;
using TGServiceInterface;

namespace TGServerService
{
	//handles talking between the world and us
	partial class TGStationServer
	{
		QueuedLock topicLock = new QueuedLock();
		Socket topicSender = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp) { SendTimeout = 5000, ReceiveTimeout = 5000 };

		const int CommsKeyLen = 64;
		string serviceCommsKey; //regenerated every DD restart

		Thread NudgeThread;
		object NudgeLock = new object();

		//See code/modules/server_tools/server_tools.dm for command switch
		const string SCHardReboot = "hard_reboot";  //requests that dreamdaemon restarts when the round ends
		const string SCGracefulShutdown = "graceful_shutdown";  //requests that dreamdaemon stops when the round ends
		const string SCWorldAnnounce = "world_announce";	//sends param 'message' to the world
		const string SCIRCCheck = "irc_check";  //returns game stats
		const string SCIRCStatus = "irc_status";	//returns admin stats
		const string SCNameCheck = "namecheck";	//returns keywords lookup
		const string SCAdminPM = "adminmsg";	//pms a target ckey
		const string SCAdminWho = "adminwho";	//lists admins

		//raw command string sent here via world.ExportService
		void HandleCommand(string cmd)
		{
			var splits = new List<string>(cmd.Split(' '));

			switch (splits[0])
			{
				case "irc":
					splits.RemoveAt(0);
					SendMessage("GAME: " + String.Join(" ", splits));
					break;
				case "killme":
					Restart();
					break;
				case "send2irc":
					splits.RemoveAt(0);
					SendMessage("RELAY: " + String.Join(" ", splits), true);
					break;
			}
		}
		
		string SendCommand(string cmd)
		{
			lock (watchdogLock)
			{
				if (currentStatus != TGDreamDaemonStatus.Online)
					return "Error: Server Offline!";
				return SendTopic(String.Format("serviceCommsKey={0};command={1}", serviceCommsKey, cmd), currentPort);
			}
		}

		string SendPM(string targetCkey, string sender, string message)
		{
			return SendCommand(String.Format("{3};target={0};sender={1};message={2}", targetCkey, sender, message, SCAdminPM));
		}

		string NameCheck(string targetCkey, string sender)
		{
			return SendCommand(String.Format("{2};target={0};sender={1}", targetCkey, sender, SCNameCheck));
		}

		//Fuckery to diddle byond with the right packet to accept our girth
		string SendTopic(string topicdata, ushort port, bool retry = false)
		{
			if (!retry)
				topicLock.Enter();
			try
			{
				if (!topicSender.Connected)
					topicSender.Connect(IPAddress.Loopback, port);

				StringBuilder stringPacket = new StringBuilder();
				stringPacket.Append((char)'\x00', 8);
				stringPacket.Append('?' + topicdata);
				stringPacket.Append((char)'\x00');
				string fullString = stringPacket.ToString();
				var packet = Encoding.ASCII.GetBytes(fullString);
				packet[1] = 0x83;
				packet[3] = (byte)(packet.Length - 4);

				topicSender.Send(packet);

				string returnedString = "NULL";
				try
				{
					var returnedData = new byte[512];
					topicSender.Receive(returnedData);
					var raw_string = Encoding.ASCII.GetString(returnedData);
					if (raw_string.Length > 6)
						returnedString = raw_string.Substring(5, raw_string.Length - 6);
				}
				catch {
					returnedString = "Topic recieve error!";
				}

				TGServerService.ActiveService.EventLog.WriteEntry("Topic: \"" + topicdata + "\" Returned: " + returnedString);
				return returnedString;
			}
			catch
			{
				if (topicSender.Connected)
					topicSender.Disconnect(true);
				if (!retry)
					return SendTopic(topicdata, port, true);
				else
				{
					TGServerService.ActiveService.EventLog.WriteEntry("Failed to send topic: " + topicdata, EventLogEntryType.Error);
					return "Topic delivery failed!";
				}
			}
			finally
			{
				if(!retry)
					topicLock.Exit();
			}
		}

		//Every time we make a new DD process we generate a new comms key for security
		//It's in world.params['server_service']
		void GenCommsKey()
		{
			var charsToRemove = new string[] { "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "-", "+", "=", "[", "{", "]", "}", ";", ":", "<", ">", "|", ".", "/", "?" };
			serviceCommsKey = String.Empty;
			do {
				var tmp = Membership.GeneratePassword(CommsKeyLen, 0);
				foreach (var c in charsToRemove)
					tmp = tmp.Replace(c, String.Empty);
				serviceCommsKey += tmp;
			} while (serviceCommsKey.Length < CommsKeyLen);
			serviceCommsKey = serviceCommsKey.Substring(0, CommsKeyLen);
			TGServerService.ActiveService.EventLog.WriteEntry("Service Comms Key set to: " + serviceCommsKey);
		}

		//Start listening for nudges on the configured port
		void InitInterop()
		{
			lock (NudgeLock)
			{
				if(NudgeThread != null)
				{
					NudgeThread.Abort();
					NudgeThread.Join();
				}
				NudgeThread = new Thread(new ThreadStart(NudgeHandler)) { IsBackground = true };
				NudgeThread.Start();
			}
		}

		void NudgeHandler()
		{
			try
			{
				var np = NudgePort(out string error);
				if (error != null)
					//I guess we'll come back some other time
					return;

				var listener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
				listener.Bind(new IPEndPoint(IPAddress.Any, np));
				listener.Listen(5);

				// Start listening for connections.  
				while (true)
				{
					// Program is suspended while waiting for an incoming connection.  
					Socket handler = listener.Accept();
					
					var bytes = new byte[1024];
					int bytesRec = handler.Receive(bytes);
					// Show the data on the console.  
					HandleCommand(Encoding.ASCII.GetString(bytes, 0, bytesRec));
					
					handler.Shutdown(SocketShutdown.Both);
					handler.Close();
				}

			}
			catch (ThreadAbortException)
			{
				return;
			}
			catch (Exception e)
			{
				TGServerService.ActiveService.EventLog.WriteEntry("Nudge handler thread crashed: " + e.ToString(), EventLogEntryType.Error);
			}
		}
	}
}
