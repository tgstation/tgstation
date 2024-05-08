/obj/effect/anomaly
	/// If set, the anomaly will delete itself if it leaves this z-level.
	var/stay_on_z

/obj/effect/anomaly/proc/scan_anomaly(mob/user, obj/item/scanner)
	if(!aSignal)
		return FALSE
	playsound(get_turf(user), 'sound/machines/ping.ogg', vol = 30, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	to_chat(user, span_boldnotice("Analyzing... [src]'s unstable field is fluctuating along frequency [format_frequency(aSignal.frequency)], code [aSignal.code]."))
	return TRUE

/obj/effect/anomaly/stabilize(anchor, has_core)
	. = ..()
	var/turf/current_turf = get_turf(src)
	stay_on_z = current_turf.z

/obj/effect/anomaly/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(!isnull(stay_on_z) && !QDELETED(src) && new_turf?.z != stay_on_z)
		qdel(src)
