/obj/effect/anomaly
	/// If TRUE, the anomaly is contained to its impact_area.
	var/contained = FALSE

/obj/effect/anomaly/proc/scan_anomaly(mob/user, obj/item/scanner)
	if(!aSignal)
		return FALSE
	playsound(get_turf(user), 'sound/machines/ping.ogg', vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	to_chat(user, span_boldnotice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
	return TRUE

/obj/effect/anomaly/stabilize(anchor, has_core)
	. = ..()
	contained = TRUE

/obj/effect/anomaly/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(contained)
		if(impact_area != get_area(newloc))
			return FALSE
		else if(impact_area != get_area(src)) // if we somehow escaped ANYWAYS, let's just go poof
			qdel(src)
			return FALSE
	return ..()
