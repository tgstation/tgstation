/datum/admins/proc/hippie_makeVampire(datum/admins/sr) //no i won't rename it why would i do that
	if(sr.makeVampire())
		message_admins("[key_name(usr)] created a vampire.")
		log_admin("[key_name(usr)] created a vampire.")
	else
		message_admins("[key_name_admin(usr)] tried to create a vampire. Unfortunately, there were no candidates available.")
		log_admin("[key_name(usr)] failed to create a vampire.")
