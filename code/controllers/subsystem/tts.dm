#define GENERATOR_PATH    "tools\\tts_generator\\"
#define DATA_PATH         GENERATOR_PATH + "data\\"
#define STATUS_NEW        0
#define STATUS_GENERATING 1
#define STATUS_PLAYING    2

SUBSYSTEM_DEF(tts)
	name = "Text-to-Speech"
	wait = 2
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/processing // List of items to process

/datum/controller/subsystem/tts/Initialize()
	LAZYINITLIST(processing)

	if (!CONFIG_GET(flag/enable_tts))
		can_fire = FALSE
	else
		start_engine()

	return ..()

/datum/controller/subsystem/tts/proc/start_engine()
	if (!CONFIG_GET(flag/enable_tts))
		return
	var/cmd = "cmd /c start \"tts_generator\" [GENERATOR_PATH]tts_generator.exe"
	shell(cmd)

/datum/controller/subsystem/tts/proc/check_processing(client/C)
	if (!C)
		return FALSE

	for (var/datum/tts/T in processing)
		if (T.owner == C)
			return TRUE

	return FALSE

/datum/controller/subsystem/tts/fire(resumed = FALSE)
	if (!LAZYLEN(processing))
		return

	for (var/datum/tts/T in processing)
		switch(T.status)
			if (STATUS_NEW)
				var/uid = "[world.time]" + T.owner.ckey
				fdel(DATA_PATH + "[uid].request")
				fdel(DATA_PATH + "[uid].rlock")

				text2file("", DATA_PATH + "[uid].rlock")
				text2file("name=[uid]", DATA_PATH + "[uid].request")
				text2file("voice=[T.voice]", DATA_PATH + "[uid].request")
				text2file("text=[T.text]", DATA_PATH + "[uid].request")
				fdel(DATA_PATH + "[uid].rlock")

				T.filename = DATA_PATH + "[uid]"
				T.status = STATUS_GENERATING
				continue
			if (STATUS_GENERATING)
				/* Check if this file is ready */
				if (fexists(T.filename + ".ogg") && fexists(T.filename + ".meta"))
					play_tts(T)
				continue
			if (STATUS_PLAYING)
				/* Delete the file when it's finished */
				if (world.time > T.life)
					delete_files(T)
					LAZYREMOVE(processing, T)
				continue

/datum/controller/subsystem/tts/proc/delete_files(datum/tts/T)
	if (!T)
		return
	if (!T.filename)
		return
	fdel(T.filename + ".ogg")
	fdel(T.filename + ".meta")

/datum/controller/subsystem/tts/proc/play_tts(datum/tts/T)
	if (!T.owner)
		message_admins("TTS request has no owner")
		return
	if (!T.owner.mob)
		message_admins("TTS request has no mob")
		return

	var/next_channel = open_sound_channel()

	T.status = STATUS_PLAYING

	if (T.is_global)
		for (var/mob/M in GLOB.player_list)
			if (!M.client)
				continue
			if (!(M.client.prefs.toggles & SOUND_TTS))
				continue

			M.playsound_local(M.loc, T.filename + ".ogg", 100, 0, channel=next_channel)
	else
		var/turf/origin = T.owner.mob.loc

		var/list/listeners = GLOB.player_list
		listeners = listeners & hearers(world.view, origin)

		// get length of audio file
		var/audio_length = text2num(file2text(T.filename + ".meta"))
		audio_length = audio_length / 100
		if (!audio_length)
			audio_length = length(T.text)

		T.life = world.time + audio_length
		T.owner.tts_cooldown = world.time + audio_length

		addtimer(CALLBACK(T.owner.mob, /mob/living.proc/update_tts_hud), audio_length)

		for (var/mob/P in listeners)
			if (!P.client)
				continue
			if (!(P.client.prefs.toggles & SOUND_TTS))
				continue
			if (T.language)
				if (!P.can_speak_language(T.language))
					continue

			if (get_dist(P, origin) <= world.view)
				var/turf/Turf = get_turf(P)

				if (Turf && Turf.z == origin.z)
					P.playsound_local(origin, T.filename + ".ogg", 100 * T.volume_mod, 0, channel=next_channel)

/datum/tts
	var/client/owner
	var/text = ""
	var/voice = ""
	var/filename = ""
	var/is_global = FALSE
	var/status = STATUS_NEW
	var/life = 0
	var/datum/language/language
	var/volume_mod = 1

/datum/tts/proc/say(client/C, msg, voice = "", is_global = FALSE, volume_mod = 1, datum/language/language)
	if (!C)
		return
	if (!msg)
		return
	owner = C
	text = msg
	src.voice = voice
	src.is_global = is_global
	src.volume_mod = volume_mod
	src.language = language

	LAZYADD(SStts.processing, src)

#undef GENERATOR_PATH
#undef STATUS_NEW
#undef STATUS_GENERATING
#undef STATUS_PLAYING
