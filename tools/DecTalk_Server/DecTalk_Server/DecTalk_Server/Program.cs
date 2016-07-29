using System;
using System.Net;
using System.IO;
using System.Text;
using NAudio.Wave;
using NAudio.Lame;
using System.Configuration;
using System.Threading.Tasks;
using System.Linq;
using System.Collections.Generic;
using System.Speech.Synthesis;

namespace DecTalk
{
    class Program
    {
        static string entirePath = null;

        private static Dictionary<Guid, Stream> storedStreams = new Dictionary<Guid, Stream>();

        public static Stream GetStream(Guid guid)
        {
            lock (storedStreams)
            {
                Stream returned;
                if (storedStreams.TryGetValue(guid, out returned))
                {
                    return returned;
                }
                return null;
            }
        }

        public static void AddStream(Guid guid, Stream stream)
        {
            lock (storedStreams)
            {
                storedStreams.Add(guid, stream);
            }
        }

        public static void RemoveStream(Guid guid)
        {
            lock (storedStreams)
            {
                storedStreams.Remove(guid);
            }
        }

        static void Main(string[] args)
        {
            HttpListener listener = null;
            var server = ConfigurationManager.AppSettings["server"];
            var port = ConfigurationManager.AppSettings["port"];


            if (port == "0") entirePath = "http://" + server + "/";
            else entirePath = "http://" + server + ":" + port + "/";


            listener = new HttpListener();
            listener.Prefixes.Add(entirePath);
           
            try
            {
                listener.Start();
                Console.WriteLine("Server Started");
                while (true)
                {
                    //Console.WriteLine("Awaiting Connection...");
                    HttpListenerContext context = listener.GetContext();
                    Task.Run(async () => await ProcessRequest(context));
                }
            }
            catch (HttpListenerException e)
            {
                Console.WriteLine("Error Code: " + e.ErrorCode);
                Console.WriteLine(e.Message);
                Console.ReadLine();

            }
        }

        public static async Task<Stream> WaveToMP3(Stream wavStream, int bitRate = 128)
        {


            Stream outStream = new MemoryStream();
            wavStream.Seek(0, SeekOrigin.Begin);
            try
            {
                RawSourceWaveStream rawReader = new RawSourceWaveStream(wavStream, new WaveFormat(22000, 1));
                var writer = new LameMP3FileWriter(outStream, rawReader.WaveFormat, bitRate);

                await rawReader.CopyToAsync(writer);
            } catch (Exception e)
            {
                Console.WriteLine("Exception:" + e.Message);
            }
            return outStream;
        }

        public static async Task ProcessRequest(HttpListenerContext context)
        {
            if (!String.IsNullOrEmpty(context.Request.QueryString["tts"]))
            {
                string msg = Convert.ToString(context.Request.QueryString["tts"]);
                string tts_voice = Convert.ToString(context.Request.QueryString["voice"]);
                Console.WriteLine("Incoming DecTalk: " + msg + "/ Voice: " + tts_voice);

                Stream voiceStream = new MemoryStream();


                SpeechSynthesizer _tts = new SpeechSynthesizer();
                List<string> voiceList = new List<string>();
                string usableVoice = "";
                foreach (InstalledVoice voice in _tts.GetInstalledVoices())
                {
                    //Console.WriteLine("Name : " + voice.VoiceInfo.Name + "/ ID : " + voice.VoiceInfo.Id);
                    if (voice.VoiceInfo.Name == tts_voice) {
                        usableVoice = voice.VoiceInfo.Name;
                        break;
                    }
                    else {
                        usableVoice = voice.VoiceInfo.Name;
                    }
                }
                try
                {
                    //_tts.SetOutputToDefaultAudioDevice();
                    //_tts.SetOutputToWaveFile("test.wav");
                    //_tts.SelectVoice("Microsoft Haruka Desktop");
                    _tts.SelectVoice(usableVoice);
                    _tts.SetOutputToWaveStream(voiceStream); //This writes to a waveStream at 22,000hz so we create the waveFormat later
                    //_tts.Rate = 2;
                    //_tts.Volume = 100;
                    _tts.Speak(msg);
                }
                catch (Exception e)
                {
                    Console.WriteLine("Exception : " + e.Message);
                }

                //We've written, so we have to go back to the top
                voiceStream.Seek(0, SeekOrigin.Begin);

                //Converts to MP3
                voiceStream = await WaveToMP3(voiceStream);

                //Resets to the top again
                voiceStream.Seek(0, SeekOrigin.Begin);

                //Generates a new file guid to keep the file in
                Guid fileGuid = Guid.NewGuid();

                AddStream(fileGuid, voiceStream);
                string streampath = entirePath + fileGuid.ToString();

                byte[] getBytes = Encoding.ASCII.GetBytes(streampath);
                System.IO.Stream output = context.Response.OutputStream;
                context.Response.ContentType = "text/plain";
                await output.WriteAsync(getBytes, 0, getBytes.Length);
                output.Close();
            }

            else
            {
                try
                {
                    //Gets the guid requested from the end of the url
                    Guid requested;
                    if (Guid.TryParse(context.Request.Url.Segments.Last(), out requested))
                    {
                        Stream stream = GetStream(requested);
                        if(stream != null) {
                            try
                            {
                                //Console.WriteLine("Requested : " + requested);
                                //Console.WriteLine("Stream Length: " + stream.Length);
                                System.IO.Stream output = context.Response.OutputStream;
                                context.Response.ContentType = "audio/mpeg";
                                await stream.CopyToAsync(output);
                                output.Close();
                                stream.Seek(0, SeekOrigin.Begin);
                            } catch (Exception e)
                            {
                                Console.WriteLine("Exception: " + e.Message);
                            }
                        }
                    }
                }
                catch (KeyNotFoundException e)
                {
                    Console.WriteLine("Key Not Located: " + context.Request.Url.LocalPath);

                }
            }
        }
    }
}