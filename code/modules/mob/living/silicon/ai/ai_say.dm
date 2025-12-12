//the following 2 procs are staying here because its for AI and its shells (also AI controlled)
/mob/living/silicon/compose_track_href(atom/movable/speaker, namepart)
	if(!HAS_TRAIT(src, TRAIT_CAN_GET_AI_TRACKING_MESSAGE))
		return ""
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='byond://?src=[REF(src)];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	if(!HAS_TRAIT(src, TRAIT_CAN_GET_AI_TRACKING_MESSAGE))
		return ""
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	// AIs cannot speak if silent AI is on.
	// Unless forced is set, as that's probably stating laws or something.
	if(!forced && CONFIG_GET(flag/silent_ai))
		to_chat(src, span_danger("The ability for AIs to speak is currently disabled via server config."))
		return FALSE

	return ..()

/mob/living/silicon/ai/radio(message, list/message_mods = list(), list/spans, language)
	if(incapacitated)
		return FALSE
	if(!radio_enabled) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		to_chat(src, span_danger("Your radio transmitter is offline!"))
		return FALSE
	. = ..()
	if(.)
		return .
	if(message_mods[MODE_HEADSET])
		if(radio)
			radio.talk_into(src, message, , spans, language, message_mods)
		return NOPASS
	else if(message_mods[RADIO_EXTENSION] in GLOB.default_radio_channels)
		if(radio)
			radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
			return NOPASS
	return FALSE

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, list/spans = list(), language, list/message_mods = list())
	message = trim(message)

	if (!message)
		return

	var/obj/machinery/holopad/active_pad = current
	// Only continue if there is a hologram and its master is the user.
	if(!istype(active_pad) || !active_pad.masters[src])
		to_chat(src, span_alert("No holopad connected."))
		return

	var/obj/effect/overlay/holo_pad_hologram/ai_holo = active_pad.masters[src]
	var/turf/pad_turf = get_turf(active_pad)
	var/pad_loc = pad_turf ? AREACOORD(pad_turf) : "(UNKNOWN)"

	log_sayverb_talk(message, message_mods, tag = "HOLOPAD in [pad_loc]")
	ai_holo.say(message, spans = spans, sanitize = FALSE, language = language, message_mods = message_mods)


// Make sure that the code compiles with AI_VOX undefined
#ifdef AI_VOX
#define VOX_DELAY 600
/mob/living/silicon/ai
	/// The currently selected VOX Announcer voice.
	var/vox_type = VOX_NORMAL
	/// The list of available VOX Announcer voices to choose from.
	var/list/vox_voices = list(VOX_NORMAL, VOX_HL, VOX_BMS, VOX_MIL)

/// Returns a list of vox sounds based on the sound_type passed in
/mob/living/silicon/ai/proc/get_vox_sounds(vox_type)
	switch(vox_type)
		if(VOX_NORMAL)
			return GLOB.vox_sounds
		if(VOX_HL)
			return GLOB.vox_sounds_hl
		if(VOX_BMS)
			return GLOB.vox_sounds_bms
		if(VOX_MIL)
			return GLOB.vox_sounds_mil
	return GLOB.vox_sounds

/mob/living/silicon/ai/verb/switch_vox()
	set name = "Switch Vox Voice"
	set desc = "Switch your VOX announcement voice!"
	set category = "AI Commands"

	if(incapacitated)
		return
	var/selection = tgui_input_list(src, "Please select a new VOX voice:", "VOX VOICE", vox_voices)
	if(selection == null)
		return
	vox_type = selection

	to_chat(src, "Vox voice set to [vox_type]")

/mob/living/silicon/ai/verb/announcement_help()

	set name = "Announcement Help"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = "AI Commands"

	if(incapacitated)
		return

	var/dat = {"
	<font class='bad'>WARNING:</font> Misuse of the announcement system will get you job banned.<BR><BR>
	Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<BR>
	<UL><LI>You can also click on the word to PREVIEW it.</LI>
	<LI>You can only say 30 words for every announcement.</LI>
	<LI>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</LI>
	<LI>Numbers are in word format, e.g. eight, sixty, etc </LI>
	<LI>Sound effects begin with an 's' before the actual word, e.g. scensor</LI>
	<LI>Use Ctrl+F to see if a word exists in the list.</LI></UL><HR>
	"}

	var/index = 0
	for(var/word in get_vox_sounds(vox_type))
		index++
		dat += "<A href='byond://?src=[REF(src)];say_word=[word]'>[capitalize(word)]</A>"
		if(index != length(get_vox_sounds(vox_type)))
			dat += " / "

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(dat)
	popup.open()


/mob/living/silicon/ai/proc/announcement()
	var/static/announcing_vox = 0 // Stores the time of the last announcement
	if(announcing_vox > world.time)
		to_chat(src, span_notice("Please wait [DisplayTimeText(announcing_vox - world.time)]."))
		return

	var/message = tgui_input_text(
		src,
		"WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'",
		"Announcement",
		src.last_announcement,
		max_length = MAX_MESSAGE_LEN,
	)

	if(!message || announcing_vox > world.time)
		return

	last_announcement = message

	if(incapacitated)
		return

	if(control_disabled)
		to_chat(src, span_warning("Wireless interface disabled, unable to interact with announcement PA."))
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(words.len > 30)
		words.len = 30

	for(var/word in words)
		word = LOWER_TEXT(trim(word))
		if(!word)
			words -= word
			continue
		if(!get_vox_sounds(vox_type)[word])
			incorrect_words += word

	if(incorrect_words.len)
		to_chat(src, span_notice("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	announcing_vox = world.time + VOX_DELAY

	log_message("made a vocal announcement with the following message: [message].", LOG_GAME)
	log_talk(message, LOG_SAY, tag="VOX Announcement")

	var/list/players = list()
	var/turf/ai_turf = get_turf(src)
	for(var/mob/player_mob as anything in GLOB.player_list)
		var/turf/player_turf = get_turf(player_mob)
		if(is_valid_z_level(ai_turf, player_turf))
			players += player_mob
	minor_announce(capitalize(message), "[name] announces:", players = players, should_play_sound = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(does_target_have_vox_off)))

	for(var/word in words)
		play_vox_word(word, ai_turf, null)


/proc/play_vox_word(word, ai_turf, mob/only_listener)

	word = LOWER_TEXT(word)

	// Get AI for the vox Type
	var/turf/ai_turf_as_turf = ai_turf
	if(!istype(ai_turf_as_turf))
		return //and prolly throw an error because wtf
	var/mob/living/silicon/ai/the_AI = null
	for(var/mob/living/silicon/ai/found_AI in ai_turf_as_turf.contents)
		if(istype(found_AI))
			the_AI = found_AI

	var/vox_volume_modifier = 1
	var/sound_file
	if(the_AI.get_vox_sounds(the_AI.vox_type)[word])
		sound_file = the_AI.get_vox_sounds(the_AI.vox_type)[word]
		// If the vox stuff are disabled, or we failed getting the word from the list, just early return.
		if(!sound_file)
			return FALSE
		switch(the_AI.vox_type)
			if(VOX_MIL)
				vox_volume_modifier = 0.50
			if(VOX_HL)
				vox_volume_modifier = 0.40 // No, my poor ears...

	// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/player_mob as anything in GLOB.player_list)
				var/pref_volume = safe_read_pref(player_mob.client, /datum/preference/numeric/volume/sound_ai_vox)
				pref_volume *= vox_volume_modifier
				if(!player_mob.can_hear() || !pref_volume)
					continue

				var/turf/player_turf = get_turf(player_mob)
				if(!is_valid_z_level(ai_turf, player_turf))
					continue

				var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX, volume = pref_volume)
				voice.status = SOUND_STREAM
				SEND_SOUND(player_mob, voice)
		else
			var/pref_volume = safe_read_pref(only_listener.client, /datum/preference/numeric/volume/sound_ai_vox)
			var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX, volume = pref_volume)
			voice.status = SOUND_STREAM
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE

/proc/does_target_have_vox_off(mob/target)
	return !safe_read_pref(target.client, /datum/preference/numeric/volume/sound_ai_vox)

#undef VOX_DELAY
#endif
