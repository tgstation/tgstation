/obj/effect/anomaly/proc/scan_anomaly(mob/user, obj/item/scanner)
	if(!aSignal)
		return FALSE
	playsound(get_turf(user), 'sound/machines/ping.ogg', vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	to_chat(user, span_boldnotice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
	return TRUE
