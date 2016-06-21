## DECTALK SERVER ##

The Dectalk server ( written using the .NET speech synthesis libraries ) is a local-running webserver that generates and stores speech from text and a selected voice.

The server receives two kinds of requests:

 - A HTTP URL query on the root, with two parameters, tts and voice. tts is the text to generate sound for, and voice is the optionally selected voice to use - see the .NET library documentation for more information about which voices are available. This request, when executed successfully, gives a HTTP response in text/plain where the body is the url of the server with a text-formatted GUID. This GUID corresponds to the generated WAV of the text on the server.

 - A HTTP get on a GUID under the root. This guid must correspond to a generated WAV on the server, or no response will be given. If the guid is connected to a WAV, the WAV will be streamed back as audio/mpeg in the response body.

To set up the server, open the DecTalk_Server.exe.config file and ensure that the address and port values are set correctly - you will be using these in your DM code. You can then run the DecTalk_Server.exe, which will start a process that listens for requests.

To generate a WAV on the server for later access, connect to http://[your-address]:[your-port]/, or, if port was configured to 0 in the exe.config, just http://[your-address]/. You need to add two HTTP query parameters to the URL in the typical style - ?tts=your+text&voice=your+voice.

This will leave your final url looking something like

	http://localhost/?tts=look+ma&voice=little+billy

Which will give a response of something like

	http://localhost/744a55de-ed45-4a53-acd1-1c9756529995

When you want to get the sound, just connect to the given URL and the WAV will be streamed back.

### Installation ###

Open and build the solution file found in tools/DecTalk_Server/DecTalk_Server - NuGet will restore any missing packages. Once you have your .exe and corresponding .exe.config (make sure they have the same name), configure your settings and start up the server.

### Long-running use ###

Due to the storage of WAV files for use by multiple clients, the server will slowly use more and more memory over time as requests are made and stored. Therefore, it is recommended to shut down the server between periods of use, which allows the reallocation of memory.