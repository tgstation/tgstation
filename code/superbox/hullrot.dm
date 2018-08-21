// ----------------------------------------------------------------------------
// Push-to-talk stat panel and key handling

/mob/living
	var/list/hullrot_stats
	var/hullrot_ptt
	var/hullrot_cache
	var/image/hullrot_bubble
	var/hullrot_needs_update = FALSE

/mob/living/Stat()
	..()
	if (client && SShullrot.can_fire && hullrot_radio_allowed())
		statpanel("Radio")  // process on the regular even if it's invisible
		var/list/keys_used = list()

		var/turf/T = get_turf(src)
		for (var/obj/item/radio/R in view(1))
			if (!istype(R, /obj/item/radio/intercom) && !(R in src))
				continue  // can't talk into a non-intercom you're not holding
			if (!R.on || R.wires.is_cut(WIRE_TX) || (istype(R, /obj/item/radio/headset) && !R.listening))
				stat(null, "\the [R] (off)")
				continue  // can't talk into a disabled radio
			if (R.subspace_transmission && !R.independent && (!SShullrot.subspace_groups || !SShullrot.subspace_groups["[T.z]"]))
				stat(null, "\the [R] (not responding)")
				continue  // can't talk into headsets while comms are down

			stat(null, "\the [R]")
			hullrot_stat(keys_used, R, "Tuner", R.frequency)
			for (var/channel in R.channels)
				if (R.channels[channel])
					hullrot_stat(keys_used, R, channel, GLOB.radiochannels[channel])

		hullrot_stats &= keys_used
		if (keys_used.len)
			if (!(hullrot_ptt in keys_used))
				hullrot_ptt = keys_used[1]
				var/obj/S = hullrot_stats[hullrot_ptt]
				S.name = "Active - hold V to talk"
		else
			hullrot_ptt = null

		if (client.keys_held["V"])
			ptt_tick()

/mob/living/proc/ptt_tick()
	var/ptt_freq
	if (hullrot_radio_allowed() && !incapacitated(ignore_grab = TRUE))
		var/obj/effect/statclick/radio/current = hullrot_ptt && hullrot_stats[hullrot_ptt]
		ptt_freq = current && current.freq

	if (hullrot_cache["ptt_freq"] != ptt_freq)
		hullrot_cache["ptt_freq"] = ptt_freq
		SShullrot.set_ptt(client, ptt_freq)

/mob/living/proc/hullrot_stat(keys_used, radio, channel, frequency)
	var/key = "[REF(radio)]:[channel]"
	if (hullrot_ptt == null)
		hullrot_ptt = key
	keys_used += key

	var/obj/effect/statclick/radio/O = hullrot_stats[key]
	if (!O)
		hullrot_stats[key] = O = new /obj/effect/statclick/radio(null, "Available", src)
		O.key = key
	O.freq = frequency
	O.name = (hullrot_ptt == key) ? "Active - hold V to talk" : "Available"
	stat(channel, O)

/obj/effect/statclick/radio
	var/key
	var/freq

/obj/effect/statclick/radio/Click()
	var/mob/living/M = usr
	M.hullrot_ptt = key
	if (M.client.keys_held["V"])
		M.ptt_tick()

/mob/living/key_down(_key, client/user)
	switch(_key)
		if("V")
			ptt_tick()
			hullrot_update()
		else
			return ..()

/mob/living/key_up(_key, client/user)
	switch(_key)
		if("V")
			if (hullrot_cache["ptt_freq"] != null)
				hullrot_cache["ptt_freq"] = null
				SShullrot.set_ptt(user, null)
				hullrot_update()
		else
			return ..()

// ----------------------------------------------------------------------------
// Admin ghost stat panel

/obj/effect/statclick/dead_radio
	var/enabled = FALSE

/obj/effect/statclick/dead_radio/Click()
	var/mob/dead/M = usr
	enabled = !enabled
	name = "[enabled ? "Enabled" : "Disabled"] (click to toggle)"
	if (M.client && check_rights_for(M.client, R_ADMIN))
		SShullrot.set_ghost_ears(M.client, enabled)

/client
	var/obj/effect/statclick/dead_radio/hullrot_hear_all

/mob/dead/Stat()
	..()
	if (client && check_rights_for(client, R_ADMIN) && SShullrot.can_fire && statpanel("Radio"))
		if (!client.hullrot_hear_all)
			client.hullrot_hear_all = new(null, "Disabled (click to toggle)")
		stat("Ghost Ears", client.hullrot_hear_all)

// ----------------------------------------------------------------------------
// Location-based can-hear and can-speak checks

/mob/living/proc/hullrot_update()
	hullrot_needs_update = FALSE
	if (!SShullrot.can_fire || !client)
		return

	// Mob-level speaking and hearing
	var/can_speak = (can_speak() && (stat == CONSCIOUS || stat == SOFT_CRIT)) || 0
	var/can_hear = (can_hear() && (stat == CONSCIOUS || stat == SOFT_CRIT)) || 0
	if (hullrot_cache["can_speak"] != can_speak || hullrot_cache["can_hear"] != can_hear)
		hullrot_cache["can_speak"] = can_speak
		hullrot_cache["can_hear"] = can_hear
		SShullrot.set_mob_flags(client, can_speak, can_hear)
	if (!can_speak && !can_hear)
		return

	// Languages
	var/datum/language_holder/langs = get_language_holder()
	var/list/language_names = list()
	for (var/L in langs.languages)
		language_names += "[L]"
	var/stringified = list2params(language_names)
	if (hullrot_cache["lang_known"] != stringified)
		hullrot_cache["lang_known"] = stringified
		SShullrot.set_languages(client, language_names)

	var/default_name = "[get_default_language()]"
	if (hullrot_cache["lang_speaking"] != default_name)
		hullrot_cache["lang_speaking"] = default_name
		SShullrot.set_spoken_language(client, default_name)

	// Position
	var/turf/T = get_turf(src)
	if (hullrot_cache["z"] != T.z)
		hullrot_cache["z"] = T.z
		SShullrot.set_z(client, T.z)

	// Local hearers
	var/speak_range = (client.keys_held["V"] || stat == SOFT_CRIT) ? 1 : 7
	var/audio_source = hullrot_audio_source()
	var/hearers = get_hearers_in_view(7, audio_source)
	if (can_speak)
		var/list/local_with = list()
		for (var/mob/L in hearers)
			if (L.client && L != src && get_dist(audio_source, L) <= speak_range)
				local_with += L.ckey
		for (var/obj/machinery/holopad/H in hearers)
			if (get_dist(audio_source, H) <= speak_range)
				for (var/mob/living/L in H.masters)
					if (L.client && L != src)
						local_with += L.ckey

		var/new_local = list2params(local_with)
		if (hullrot_cache["local_with"] != new_local)
			// make sure that we propagate changes to others as well
			var/previous = params2list(hullrot_cache["local_with"])
			for(var/other_ckey in (previous - local_with) + (local_with - previous))
				var/client/C = GLOB.directory[other_ckey]
				var/mob/living/speaker = C && C.mob
				if (istype(speaker))
					speaker.hullrot_needs_update = TRUE

			hullrot_cache["local_with"] = new_local
			SShullrot.set_local_with(client, local_with)

	// Certain mobs can speak locally but not over the radio
	if (!hullrot_radio_allowed())
		can_speak = FALSE

	// Hot and heard radio frequencies
	var/list/hot_freqs = list()
	var/list/hear_freqs = list()
	for(var/obj/item/radio/R in hearers)
		if (get_dist(audio_source, R) > R.canhear_range || !R.on)
			continue
		if (R.subspace_transmission && !R.independent && (!SShullrot.subspace_groups || !SShullrot.subspace_groups["[T.z]"]))
			continue

		if (can_speak && R.broadcasting && !R.wires.is_cut(WIRE_TX) && get_dist(audio_source, R) <= speak_range)
			hot_freqs |= R.frequency

		if (can_hear && R.listening && !R.wires.is_cut(WIRE_RX) && R.can_receive(R.frequency, list(R.z)))
			hear_freqs |= R.frequency
			for (var/channel in R.channels)
				if (R.channels[channel])
					hear_freqs |= GLOB.radiochannels[channel]

	var/new_hot = list2params(hot_freqs)
	var/new_hear = list2params(hear_freqs)
	if (hullrot_cache["hot"] != new_hot)
		hullrot_cache["hot"] = new_hot
		SShullrot.set_hot_freqs(client, hot_freqs)
	if (hullrot_cache["hear"] != new_hear)
		hullrot_cache["hear"] = new_hear
		SShullrot.set_hear_freqs(client, hear_freqs)

/mob/living/proc/hullrot_reset()
	hullrot_stats = list()
	hullrot_cache = list()
	hullrot_update()

/mob/living/Login()
	..()
	hullrot_reset()

/mob/living/Move()
	. = ..()
	if(. && client)
		hullrot_needs_update = TRUE

/obj/item/radio/equipped(mob/living/user, slot)
	..()
	if (isliving(user) && user.client)
		user.hullrot_update()

/obj/item/radio/dropped(mob/living/user)
	..()
	if (isliving(user) && user.client)
		user.hullrot_update()

/obj/proc/hullrot_check_all_hearers(range = 7)
	for (var/mob/living/M in get_hearers_in_view(range, src))
		M.hullrot_needs_update = TRUE

/obj/item/radio/Initialize()
	. = ..()
	hullrot_check_all_hearers(canhear_range)

/obj/item/radio/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (action in list("frequency", "listen", "broadcast", "channel", "subspace"))
		hullrot_check_all_hearers(canhear_range)

/obj/item/radio/emp_act()
	. = ..()
	hullrot_check_all_hearers(canhear_range)
	addtimer(CALLBACK(src, .proc/hullrot_check_all_hearers, canhear_range), 201)  // un-EMP delay + 1

/mob/living/afterShuttleMove()
	. = ..()
	if (. && client)
		hullrot_needs_update = TRUE

/mob/living/carbon/human/update_stat()
	var/previous = stat
	. = ..()
	if (client && stat != previous)
		hullrot_update()

/mob/dead/Login()
	..()
	SShullrot.set_ghost(client)

/obj/machinery/door/open()
	. = ..()
	if(.)
		hullrot_check_all_hearers()

/obj/machinery/door/close()
	. = ..()
	if(.)
		hullrot_check_all_hearers()

// ----------------------------------------------------------------------------
// AI restriction and holopad handling

/mob/living/proc/hullrot_radio_allowed()
	return TRUE

/mob/living/silicon/ai/hullrot_radio_allowed()
	return FALSE

/mob/living/silicon/robot/hullrot_radio_allowed()
	return mainframe == null

/mob/living/proc/hullrot_audio_source()
	var/mob/camera/aiEye/remote/holo/holoEye = remote_control
	if (istype(holoEye))
		return holoEye.origin
	return src

/mob/living/silicon/ai/hullrot_audio_source()
	var/obj/machinery/holopad/T = current
	if (istype(T) && T.masters[src])
		return T
	if (istype(loc, /obj/item/aicard))
		return loc
	return src

// ----------------------------------------------------------------------------
// Message composition

/mob/living/proc/hullrot_compose(atom/movable/speaker, datum/language/message_language, radio_freq, list/spans, message_mode)
	// Intended to mimic compose_mesage() from saycode
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	var/spanpart2 = "<span class='name'>"
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	var/endspanpart = "</span>"

	//Message
	var/datum/language/D = GLOB.language_datum_instances[message_language]
	var/verbpart = D.get_spoken_verb()
	if (verbpart == "says")
		verbpart = "speaks"

	var/langpart = ""
	if(!has_language(message_language))
		langpart = " in an unknown language"

	var/messagepart = " <span class='message'>[verbpart][langpart].</span></span>"

	var/languageicon = ""
	if(istype(D) && D.display_icon(src))
		languageicon = "[D.get_icon()] "

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, null, radio_freq)][endspanpart][messagepart]"
