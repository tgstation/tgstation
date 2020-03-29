/**
  *Text-to-speech subsystem
  *
  *Converts say() speech into a played sound
  *
  *Basically works by recieving a file from the say_tts proc,
  *then feeding it into a TTS generator.
  *The generator then spits out an .ogg and a .meta files
  *.ogg is file is then played and .meta is used to measure the length of the speech,
  *which determines the length of the timer for spam limiting and resets the HUD icon
  *After the sound is played both files are deleted and the cycle begins anew
  *
  *Each file has a userid which ensures that no file mixups occur
  *
  *The generator itself is an exe file and not a dll so it doesnt help cause OOM, since .dlls eat already limited BYOND memory space.
  *it also allows for multiple Dreamdaemons to make use of a single generator for TTS requests
  *Shutdown is handeled by the exe, which regularily checks for a DreamDaemon instance (as requested by MSO).
  *Since /tg/ servers run DD in pairs this makes sure that the TTS is active even if one DD instance shuts down,
  *while still handling normal shutdowns such as on a localhost.
  *start_engine() can be called even with an active .exe instance since the exe prevents further instances of itself
  */

#define GENERATOR_PATH    "tools\\tts_generator\\"	//TTS generator file location
#define DATA_PATH         GENERATOR_PATH + "data\\"	//Temp files location
#define STATUS_NEW        0
#define STATUS_GENERATING 1
#define STATUS_PLAYING    2

SUBSYSTEM_DEF(tts)
	name = "Text-to-Speech"
	wait = 2
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	/// List of items to process
	var/list/processing

/datum/controller/subsystem/tts/Initialize()
	LAZYINITLIST(processing)

	if (!CONFIG_GET(flag/enable_tts))
		can_fire = FALSE
	else
		start_engine()

	return ..()

/**
  *Launches the actual TTS generator
  */
/datum/controller/subsystem/tts/proc/start_engine()
	if (!CONFIG_GET(flag/enable_tts))
		return
	var/cmd = "cmd /c start \"tts_generator\" [GENERATOR_PATH]tts_generator.exe"
	shell(cmd)

/**
  *Kills the TTS generator
  *
  *Can only be called as a debug verb by admins
  */

/datum/controller/subsystem/tts/proc/stop_engine()
	var/cmd = "taskkill /F /IM \"tts_generator.exe\" /T"
	shell(cmd)
/**
  *Checks if something is currently being proccessed for this client
  */
/datum/controller/subsystem/tts/proc/check_processing(client/C)
	if (!C)
		return FALSE

	for (var/T in processing)
		var/datum/tts/tts_datum = T
		if (tts_datum.owner == C)
			return TRUE

	return FALSE

/datum/controller/subsystem/tts/fire(resumed = FALSE)
	if (!LAZYLEN(processing))
		return

	for (var/T in processing)	//we have something to process, let's make the files
		var/datum/tts/tts_datum = T
		switch(tts_datum.status)
			if (STATUS_NEW)
				var/uid = "[world.time]" + tts_datum.owner.ckey
				fdel(DATA_PATH + "[uid].request")
				fdel(DATA_PATH + "[uid].rlock")

				text2file("", DATA_PATH + "[uid].rlock")
				text2file("name=[uid]", DATA_PATH + "[uid].request")
				text2file("voice=[tts_datum.voice]", DATA_PATH + "[uid].request")
				text2file("text=[tts_datum.text]", DATA_PATH + "[uid].request")
				fdel(DATA_PATH + "[uid].rlock")

				tts_datum.filename = DATA_PATH + "[uid]"
				tts_datum.status = STATUS_GENERATING
				continue
			if (STATUS_GENERATING)
				// Check if this file is ready
				if (fexists(tts_datum.filename + ".ogg") && fexists(tts_datum.filename + ".meta"))
					play_tts(tts_datum)
				continue
			if (STATUS_PLAYING)
				// Delete the file when it's finished
				if (world.time > tts_datum.life)
					delete_files(tts_datum)
					LAZYREMOVE(processing, tts_datum)
				continue
/**
  *Deletes files once they've been played
  */
/datum/controller/subsystem/tts/proc/delete_files(datum/tts/T)
	if (!T)
		return
	if (!T.filename)
		return
	fdel(T.filename + ".ogg")
	fdel(T.filename + ".meta")

/datum/controller/subsystem/tts/proc/play_tts(datum/tts/TTS)
	if (!TTS.owner)
		message_admins("TTS request has no owner")	//I dunno how the fuck you managed to play a sound with no owner but don't
		return
	if (!TTS.owner.mob)
		message_admins("TTS request has no mob")
		return

	var/next_channel = open_sound_channel()

	TTS.status = STATUS_PLAYING

	var/turf/origin = get_turf(TTS.owner.mob)

	var/list/listeners = hearers(world.view, origin)
	/// Gets length of the created audio file using the .meta file
	var/audio_length = text2num(file2text(TTS.filename + ".meta"))
	audio_length = audio_length * 0.01
	if (!audio_length)
		audio_length = length(TTS.text)

	TTS.life = world.time + audio_length
	TTS.owner.tts_cooldown = world.time + audio_length

	addtimer(CALLBACK(TTS.owner.mob, /mob/living.proc/update_tts_hud), audio_length) //Resets the hud and spam protection

	for (var/M in listeners)
		var/mob/listener = M
		if (!listener.client)
			continue
		if (!(listener.client.prefs.toggles & SOUND_TTS))
			continue
		if (TTS.language && !listener.can_speak_language(TTS.language))
			continue

		listener.playsound_local(origin, TTS.filename + ".ogg", 100 * TTS.volume_mod, 0, channel=next_channel)	//play the file we made

/datum/tts
	///Who's saying things
	var/client/owner
	///what text are they saying
	var/text = ""
	///What voice is being used
	var/voice = ""
	///Filename of the sound
	var/filename = ""
	///Whether everyone can hear the sound
	var/is_global = FALSE
	///Curent status of the TTS generation
	var/status = STATUS_NEW
	///Time the sound plays
	var/life = 0
	///What language the text is in, Lizardspeak TTS can't be understood by people who don't speak lizard
	var/datum/language/language
	///Volume modifier for wispering, etc
	var/volume_mod = 1
/**
  *Adds a piece of text to the TTS subsystem
  *
  * Arguments:
  * * client/c - the client creating the message
  * * msg - The message that the client wants to be converted to TTS
  * * voice - The voice that should be used by the TTS generator
  * * is_global - Whether the sound should be globally played
  * * volume_mod - Modifies the volume level of the TTS sound
  * * datum/language/language - The IC language that the message is in
  */
/datum/tts/proc/say(client/C, msg, voice = "", is_global = FALSE, volume_mod = 1, datum/language/language)
	if (!C)
		return
	if (!msg)
		return
	owner = C
	text = msg
	src.voice = voice
	src.is_global = is_global	//Can be used to play global sounds like vox announcements
	src.volume_mod = volume_mod
	src.language = language

	LAZYADD(SStts.processing, src)

#undef GENERATOR_PATH
#undef STATUS_NEW
#undef STATUS_GENERATING
#undef STATUS_PLAYING
