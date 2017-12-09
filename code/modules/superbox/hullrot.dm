// ----------------------------------------------------------------------------
// Push-to-talk stat panel and key handling

/mob/living
	var/list/hullrot_stats = list()
	var/hullrot_ptt
	var/hullrot_ptt_freq

/mob/living/Stat()
	..()
	if (client && statpanel("Radio"))
		var/list/keys_used = list()

		for (var/obj/item/device/radio/R in view(1))
			if (!istype(R, /obj/item/device/radio/intercom) && !(R in src))
				continue  // can't talk into a non-intercom you're not holding
			if (!R.on || R.wires.is_cut(WIRE_TX) || (istype(R, /obj/item/device/radio/headset) && !R.listening))
				stat(null, "\the [R] (OFF)")
				continue  // can't talk into a disabled radio

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

	for (var/obj/item/device/radio/R in view(1))
		if (!istype(R, /obj/item/device/radio/intercom) && !(R in src))
			continue  // can't talk into a non-intercom you're not holding
		if (!R.on || R.wires.is_cut(WIRE_TX) || (istype(R, /obj/item/device/radio/headset) && !R.listening))
			continue  // can't talk into a disabled radio

		if (!.)
			. = R.frequency

		if (hullrot_ptt == "[REF(R)]:Tuner")
			return R.frequency
		for (var/channel in R.channels)
			if (R.channels[channel] && hullrot_ptt == "[REF(R)]:[channel]")
				return GLOB.radiochannels[channel]

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
