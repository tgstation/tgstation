// ----------------------------------------------------------------------------
// Push-to-talk stat panel and key handling

/mob/living
	var/list/hullrot_stats
	var/hullrot_ptt
	var/hullrot_ptt_freq
	var/hullrot_cache

/mob/living/Stat()
	..()
	if (client && SShullrot.can_fire)
		statpanel("Radio")  // process on the regular even if it's invisible
		var/list/keys_used = list()

		var/turf/T = get_turf(src)
		for (var/obj/item/device/radio/R in view(1))
			if (!istype(R, /obj/item/device/radio/intercom) && !(R in src))
				continue  // can't talk into a non-intercom you're not holding
			if (!R.on || R.wires.is_cut(WIRE_TX) || (istype(R, /obj/item/device/radio/headset) && !R.listening))
				stat(null, "\the [R] (off)")
				continue  // can't talk into a disabled radio
			if (R.subspace_transmission && !R.independent && !SShullrot.subspace_groups["[T.z]"])
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
				hullrot_stats[hullrot_ptt].name = "Active - hold V to talk"
		else
			hullrot_ptt = null
		if (hullrot_ptt_freq && hullrot_ptt_freq != hullrot_stats[hullrot_ptt].freq)
			hullrot_ptt_freq = hullrot_stats[hullrot_ptt].freq
			SShullrot.set_ptt(client, hullrot_ptt_freq)

/mob/living/proc/get_ptt_frequency()
	if (incapacitated(ignore_grab = TRUE))
		return

	var/obj/effect/statclick/radio/current = hullrot_stats[hullrot_ptt]
	return current && current.freq

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
	if (M.client && M.hullrot_ptt_freq && M.hullrot_ptt_freq != freq)
		M.hullrot_ptt_freq = freq
		SShullrot.set_ptt(M.client, freq)

/mob/living/key_down(_key, client/user)
	switch(_key)
		if("V")
			hullrot_ptt_freq = get_ptt_frequency()
			SShullrot.set_ptt(user, hullrot_ptt_freq)
		else
			return ..()

/mob/living/key_up(_key, client/user)
	switch(_key)
		if("V")
			hullrot_ptt_freq = null
			SShullrot.set_ptt(user, null)
		else
			return ..()

// ----------------------------------------------------------------------------
// Location-based can-hear and can-speak checks

/mob/living/proc/hullrot_update()
	if (!SShullrot.can_fire)
		return

	var/can_speak = can_speak() && (stat == CONSCIOUS || stat == SOFT_CRIT)
	var/can_hear = can_hear()
	if (!can_speak && !can_hear)
		return

	var/turf/T = get_turf(src)
	if (hullrot_cache["z"] != T.z)
		hullrot_cache["z"] = T.z
		SShullrot.set_z(client, T.z)

	var/speak_range = hullrot_ptt_freq ? 1 : 7
	var/hearers = get_hearers_in_view(7, src)
	if (can_speak)
		var/list/local_with = list()
		for(var/mob/living/L in hearers)
			if (L.client && L != src && get_dist(src, L) <= speak_range)
				local_with += L.ckey
		var/new_local = list2params(local_with)
		if (hullrot_cache["local_with"] != new_local)
			hullrot_cache["local_with"] = new_local
			SShullrot.set_local_with(client, local_with)

	var/list/hot_freqs = list()
	var/list/hear_freqs = list()
	for(var/obj/item/device/radio/R in hearers)
		if (get_dist(src, R) > R.canhear_range || !R.on)
			continue
		if (R.subspace_transmission && !R.independent && !SShullrot.subspace_groups["[T.z]"])
			continue

		if (can_speak && R.broadcasting && !R.wires.is_cut(WIRE_TX) && get_dist(src, R) <= speak_range)
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

/mob/living/Login()
	..()
	hullrot_stats = list()
	hullrot_cache = list()
	hullrot_update()

/mob/living/Move()
	. = ..()
	if(. && client)
		hullrot_update()

/obj/item/device/radio/equipped(mob/living/user, slot)
	..()
	if (isliving(user) && user.client)
		user.hullrot_update()

/obj/item/device/radio/dropped(mob/living/user)
	..()
	if (isliving(user) && user.client)
		user.hullrot_update()

/obj/item/device/radio/proc/hullrot_check_all_hearers()
	for (var/mob/living/M in get_hearers_in_view(canhear_range, src))
		if (M.client)
			M.hullrot_update()

/obj/item/device/radio/Initialize()
	..()
	hullrot_check_all_hearers()

/obj/item/device/radio/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if (action in list("frequency", "listen", "broadcast", "channel", "subspace"))
		hullrot_check_all_hearers()

/obj/item/device/radio/emp_act()
	. = ..()
	hullrot_check_all_hearers()
	addtimer(CALLBACK(src, .proc/hullrot_check_all_hearers), 201)  // un-EMP delay + 1

/mob/living/afterShuttleMove()
	. = ..()
	if (. && client)
		INVOKE_ASYNC(src, .proc/hullrot_update)

/mob/living/carbon/human/update_stat()
	var/previous = stat
	. = ..()
	if (client && stat != previous)
		hullrot_update()

/mob/dead/Login()
	..()
	SShullrot.set_ghost(client)
