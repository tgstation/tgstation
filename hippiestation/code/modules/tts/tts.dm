/client/proc/play_tts()
	set category = "Fun"
	set name = "Play TTS"
	if(!check_rights(R_SOUNDS))
		return
	var/input = stripped_input(usr, "Please enter a message to send to the server", "Text to Speech", "")
	if(input)
		if(!text_to_speech_output(input))
			to_chat(src, "<span class='boldwarning'>Text-to-speech is not enabled.</span>")

/proc/text_to_speech_output(msg)
	var/ttsurl = CONFIG_GET(string/tts_api)
	if(!ttsurl)
		return FALSE
	if(msg)
		var/mesg = url_encode(msg)
		for(var/m in GLOB.player_list)
			var/mob/M = m
			var/client/C = M.client
			if((C.prefs.toggles & SOUND_MIDI) && C.chatOutput && !C.chatOutput.broken && C.chatOutput.loaded)
				to_chat(M, "<audio autoplay><source src=\"[ttsurl][mesg]\" type=\"audio/mpeg\"></audio>")
		return TRUE