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

        public static IrcClient irc = new IrcClient();
        public static void Main(string[]args) 
        {
            ReadConf();
            irc.OnChannelMessage += new IrcEventHandler(OnChannelMessage);
            irc.SupportNonRfc = true;
            irc.Connect(IRC_server , IRC_port);
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
                    else { Console.WriteLine("IP cannot be validated."); return; }
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
                    else { Console.WriteLine("Port cannot be validated."); return; }
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    commskey = line[2];
                    Console.WriteLine("Commskey read.");
                }
                else { Console.WriteLine("No Commskey!"); return; }
                line = reader.ReadLine().Split(' ');
                if(line[2] != null)
                {
                    Github_bot_name = line[2];
                    Console.WriteLine("Read Github bot name: " + Github_bot_name);
                }
                else { Console.WriteLine("No botname found."); return; }
                line = reader.ReadLine().Split(' ');
                if(line[2] != null)
                {
                    IRC_bot_name = line[2];
                    Console.WriteLine("Read IRC bot name: " + Github_bot_name);
                }
                else { Console.WriteLine("No botname found."); return; }
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
                    else { Console.WriteLine("Server:port invalid."); return; }
                }
                line = reader.ReadLine().Split(' ');
                if (line[2] != null)
                {
                    IRC_channel = line[2];
                    Console.WriteLine("Read channel: " + IRC_channel);
                }
                else { Console.WriteLine("No channel found."); return; }
                reader.Close();
            }
            else { Console.WriteLine("Config file doesn't exist, using defaults"); return; }
        }
        public static void OnChannelMessage(object sender, IrcEventArgs e) 
        {
            if(e.Data.Nick == Github_bot_name)
            {
                StreamWriter output = new StreamWriter("output.txt");
                string[] msg = e.Data.Message.Split(' ');
                for (int i = 0; i < msg.Length; i++)
                {
                    msg[i] = Regex.Replace(msg[i], @"[\x02\x1F\x0F\x16]|\x03(\d\d?(,\d\d?)?)?", String.Empty); //Sanitizing color codes
                    msg[i] = Regex.Replace(msg[i], @"[\\\&\=\;]", " "); //Filtering out some iffy characters
                    Console.Write(msg[i] + " ");
                }
                Console.WriteLine();
                if (msg[2] == "opened")
                {
                    byte[] PACKETS = CreatePacket(msg);
                    PACKETS[1] = 0x83;
                    int len = 0;
                    for (int i = 0; i < msg.Length; i++)
                    {
                        len += msg[i].Length + 1;
                    }
                    len += 14 + commskey.Length + 6;
                    PACKETS[3] = (byte) len;
                                
                    StringBuilder test = new StringBuilder();
                    for (int i = 0; i < PACKETS.Length; i++)
                    {
                        test.Append(Convert.ToString(PACKETS[i]));
                    }
                    output.WriteLine(Convert.ToString(test));
                    Socket server = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
                    IPEndPoint ip = new IPEndPoint(IPAddress.Parse(serverIP), serverPort);

                    server.Connect(ip);
                    server.Send(PACKETS);
                    output.Close();
                }
            }
        }

        private static byte[] CreatePacket(string[] msg)
        {
            StringBuilder packet = new StringBuilder();
            packet.Append((char)'\x00');
            byte x83 = 0x83 ;
            packet.Append((char)x83);
            packet.Append((char)'\x00',6);
            packet.Append("?announce=");
            for (int i = 0; i < msg.Length; i++)
            {
                packet.Append(msg[i] + " ");
            }
            packet.Append("&key=");
            packet.Append(commskey);
            packet.Append((char)'\x00');
            return Encoding.ASCII.GetBytes(packet.ToString()); 
        } 
    }
}
