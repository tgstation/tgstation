//////////////////////////////////////////////////////////////////
/////GitHub pull request announcer bot for IRC////////////////////
/////Made by VistaPOWA for the /tg/station 13 code project.///////
/////This software is licensed under GPL3.////////////////////////
/////Prequisites: Meebey's SmartIrc4Net library (incl, under GPL)/
/////             StarkSoft Proxy library (incl, under GPL)///////
/////Usage: Edit the config.txt file to match the settings////////
/////of your server's. Start the executable. Set up a Github hook/
/////if you hadn't before to send IRC notifications to the////////
/////channel of your choosing. Leave it running.//////////////////
/////IT IS PREFERABLE IF YOU RAN THIS LOCALLY. YOUR SERVER'S//////
/////API/COMMS KEY WILL BE SENT PLAINTEXT! ENSURE THAT THE API////
/////KEY IS NOT PUBLICALLY AVAILABLE! IF LEAKED, CHANGE IT.///////
/////Support available @ Rizon's #coderbus, ask for VistaPOWA.////
//////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Meebey.SmartIrc4net;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace sendkeys_ss13
{
    public class Program
    {
        //default values
        public static string serverIP = "127.0.0.1";
        public static int serverPort = 11111;
        public static string commskey = "this_is_a_test_key";
        public static string Github_bot_name = "testbot_github";
        public static string IRC_bot_name = "testbot";
        public static string IRC_server = "test.net";
        public static int IRC_port = 11111;
        public static string IRC_channel = "#channel";

        public static string[] merge_archive;
        public static bool mergeflag = false;

        public static IrcClient irc = new IrcClient();

        public static int IRCReconnectAttempt = 0;
        public static void Main(string[]args) 
        {
            ReadConf();
            irc.OnChannelMessage += new IrcEventHandler(OnChannelMessage);
            irc.SupportNonRfc = true;
            try
            {
                irc.Connect(IRC_server, IRC_port);
                IRCReconnectAttempt = 0;
            }
            catch (Exception)
            {
                IRCReconnectAttempt++;
                if (IRCReconnectAttempt <= 3)
                {
                    Console.WriteLine("IRC server is unavaible at the moment. Reconnect attempt {0}...", IRCReconnectAttempt);
                    System.Threading.Thread.Sleep(3000); //Reconnecting after 5 seconds.
                    Main(args);
                }
                else
                {
                    Console.WriteLine("IRC server unreachable. Please check your configuration file.");
                    Console.ReadLine();
                    return;
                }
            }
            Console.WriteLine("Connected to IRC");
            irc.Login(IRC_bot_name, IRC_bot_name);
            Console.WriteLine("Logged in");
            irc.RfcJoin(IRC_channel);
            Console.WriteLine("Joining {0}", IRC_channel);
            irc.Listen();
        }

        public static void ReadConf()
        {
            if (File.Exists("config.txt"))
            {
                StreamReader reader = new StreamReader("config.txt");
                string[] line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    Match match1 = Regex.Match(line[2], @"(\d{1,3}.?){4}"); //rudimentary IP validation
                    if (match1.Success)
                    {
                        serverIP = line[2];
                        Console.WriteLine("Read IP: " + serverIP);
                    }
                    else 
                    { 
                        Console.WriteLine("IP cannot be validated."); 
                        return; 
                    }
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    Match match2 = Regex.Match(line[2], @"\d{1,5}"); //rudimentary port validation
                    if (match2.Success && (Convert.ToInt32(line[2]) < 65535))
                    {
                        serverPort = Convert.ToInt32(line[2]);
                        Console.WriteLine("Read port: " + serverPort);
                    }
                    else 
                    {
                        Console.WriteLine("Port cannot be validated.");
                        return; 
                    }
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    commskey = line[2];
                    Console.WriteLine("Commskey read.");
                }
                else 
                { 
                    Console.WriteLine("No Commskey!"); 
                    return; 
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    Github_bot_name = line[2];
                    Console.WriteLine("Read Github bot name: " + Github_bot_name);
                }
                else 
                { 
                    Console.WriteLine("No botname found."); 
                    return; 
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    IRC_bot_name = line[2];
                    Console.WriteLine("Read IRC bot name: " + Github_bot_name);
                }
                else 
                { 
                    Console.WriteLine("No botname found."); 
                    return; 
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    Match match3 = Regex.Match(line[2], @"(.+)\:(\d{1,5})"); //rudimentary port validation
                    if (match3.Success)
                    {
                        IRC_server = Convert.ToString(match3.Groups[1]);
                        Int32.TryParse(Convert.ToString(match3.Groups[2]), out IRC_port);
                        Console.WriteLine("Read IRC server: " + IRC_server + ":" + Convert.ToString(IRC_port));
                    }
                    else
                    {
                        Console.WriteLine("Server:port invalid.");
                        return;
                    }
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    IRC_channel = line[2];
                    Console.WriteLine("Read channel: " + IRC_channel);
                }
                else 
                { 
                    Console.WriteLine("No channel found."); 
                    return; 
                }
                reader.Close();
            }
            else 
            {
                Console.WriteLine("Config file doesn't exist, using defaults"); 
                return; 
            }
        }

        public static void OnChannelMessage(object sender, IrcEventArgs e) 
        {
            if (e.Data.Nick == Github_bot_name)
            {
                    string[] msg = e.Data.Message.Split(' ');
                    for (int i = 0; i < msg.Length; i++)
                    {
                        msg[i] = Regex.Replace(msg[i], @"[\x02\x1F\x0F\x16]|\x03(\d\d?(,\d\d?)?)?", String.Empty); //Sanitizing color codes
                        msg[i] = Regex.Replace(msg[i], @"[\\\&\=\;\<\>]", " "); //Filtering out some iffy characters
                    }
                    FormMessage(msg);
            }
        }

        private static void FormMessage(string[] msg, bool ShortenedURL = false)
        {
            using (StreamWriter output = new StreamWriter("output.txt"))
            {
                if (msg[2] == "closed")
                {
                    merge_archive = msg;
                    mergeflag = true;
                    output.Close();
                }
                else if ((msg[2] == "opened" || mergeflag) && msg[1] != "meant:") //Either we open a new PR or a PR was closed in the last message. Also protection from Whibyl's correction thingy!
                {
                    if (msg[2] == "pushed")
                    {
                        msg = merge_archive; //We copy the "close" message and replace "close" with merge! The players won't know what him 'em!
                        msg[2] = "merged";
                    }
                    mergeflag = false;
                    merge_archive = null;
                    string URL = msg[msg.Length - 1];
                    if(!ShortenedURL)
                        URL = ShortenURL(URL);
                    msg[5] = "<a href=" + URL + ">" + msg[5] + "</a>";
                    msg[0] = ""; //Repo name
                    msg[msg.Length - 1] = ""; //The URL itself
                    msg[msg.Length - 2] = ""; //Branch info
                    byte[] PACKETS = CreatePacket(msg);
                    PACKETS[1] = 0x83;
                    int len = 0;
                    for (int i = 1; i < msg.Length - 1; i++)
                    {
                        len += msg[i].Length + 1; //The length of the word and the space following it.
                        Console.Write(msg[i] + " ");
                    }
                    len -= 1; //Compensating for the lack of space at the end.
                    len += 14 + commskey.Length + 6; //Argument names + Commskey length + 6 null bytes
                    PACKETS[3] = (byte)len;
                    StringBuilder test = new StringBuilder();
                    for (int i = 0; i < PACKETS.Length; i++)
                    {
                        test.Append(Convert.ToString(PACKETS[i]));
                    }
                    output.WriteLine(Convert.ToString(test));
                    SendPacket(output, PACKETS);
                }
                else
                {
                    mergeflag = false;
                    merge_archive = null;
                    output.Close();
                }
            }
        }

        public static int ServerReconnectAttempt = 0;
        private static void SendPacket(StreamWriter output, byte[] PACKETS)
        {
            Socket server = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPEndPoint ip = new IPEndPoint(IPAddress.Parse(serverIP), serverPort);
            try
            {
                server.Connect(ip);
                server.Send(PACKETS);
                Console.WriteLine("- sent ;)");
                output.Close();
                Console.WriteLine();
            }
            catch (Exception)
            {
                ServerReconnectAttempt++;
                if(ServerReconnectAttempt <= 5)
                {
                    Console.WriteLine("Server is not available at the moment. Reconnect attempt {0}...", ServerReconnectAttempt);
                    System.Threading.Thread.Sleep(5000); //Reconnecting after 5 seconds.
                    SendPacket(output, PACKETS);
                }
                else
                {
                    output.Close();
                    Console.WriteLine("Server appears to be down for good. Press ENTER when you have restarted the server to continue.");
                    Console.ReadLine();
                    ServerReconnectAttempt = 0;
                    SendPacket(output, PACKETS);
                }
            }
        }

        public static int GitReconnectAttempt = 0;
        private static string ShortenURL(string URL) //derived from GitIoSharp by dimapasko
        {
            WebRequest request = WebRequest.Create("http://git.io");
            request.ContentType = "application/x-www-form-urlencoded";
            request.Method = "POST";
            byte[] packet = Encoding.ASCII.GetBytes("url=" + URL);
            request.ContentLength = packet.Length;
            try
            {
                using (Stream stream = request.GetRequestStream())
                {
                    stream.Write(packet, 0, packet.Length);
                    GitReconnectAttempt = 0;
                }
            }
            catch (Exception)
            {
                GitReconnectAttempt++;
                if (GitReconnectAttempt <= 3)
                {
                    Console.WriteLine("Git.IO is not available at the moment. Reconnect attempt {0}...", GitReconnectAttempt);
                    System.Threading.Thread.Sleep(3000); //Attempt to reconnect after 3 seconds.
                    ShortenURL(URL);
                }
                else
                {
                    Console.WriteLine("Git.IO is down. Returning long URL.");
                    GitReconnectAttempt = 0; //Reset counter
                    return URL;
                }
            }
            
            HttpWebResponse response = (HttpWebResponse)request.GetResponse();
            return Convert.ToString(new Uri(response.Headers[HttpResponseHeader.Location]));
        }

        private static byte[] CreatePacket(string[] msg)
        {
            StringBuilder packet = new StringBuilder();
            packet.Append((char)'\x00', 8); //packet[1] is 0x83, packet[3] contain length
            packet.Append("?announce=");
            for (int i = 1; i < msg.Length - 1; i++)
            {
                if(i == msg.Length - 2)
                    packet.Append(msg[i]);
                else 
                    packet.Append(msg[i] + " ");
            }
            packet.Append("&key=");
            packet.Append(commskey);
            packet.Append((char)'\x00');
            return Encoding.ASCII.GetBytes(packet.ToString()); 
        } 
    }
}
