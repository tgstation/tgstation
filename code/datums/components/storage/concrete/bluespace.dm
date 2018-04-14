/datum/component/storage/concrete/bluespace
	var/dumping_range = 8
	var/dumping_sound = 'sound/items/pshoom.ogg'
	var/alt_sound = 'sound/items/pshoom_2.ogg'

/datum/component/storage/concrete/bluespace/dump_content_at(atom/dest, mob/M)
	var/atom/A = parent
	if(A.Adjacent(M))
		var/atom/dumping_location = dest.get_dumping_location()
		if(get_dist(M, dumping_location) < dumping_range)
			if(dumping_location.storage_contents_dump_act(src, M))
				if(alt_sound && prob(1))
					playsound(src, alt_sound, 40, 1)
				else
					playsound(src, dumping_sound, 40, 1)
				M.Beam(dumping_location, icon_state="rped_upgrade", time=5)
				return TRUE
		to_chat(M, "The [A.name] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	return FALSE

