/client/proc/kill_turf_chems()
	set name = "Del all turf chemicals"
	set category = "Special Verbs"
	set desc = "Mass deletes all currently existing chem piles in case of serious destruction"
	message_admins("[key_name(src)] deleted all turfchems.")
	log_game("[key_name(src)] deleted all turfchems")
	if(GLOB.chempiles)
		for(var/I in GLOB.chempiles)
			qdel(I)
			CHECK_TICK