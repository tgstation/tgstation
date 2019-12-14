/datum/job/proc/austation_after_spawn(mob/living/carbon/human/H, mob/M) // because /tg/'s version is empty and the childs don't call ..()
	if(!H || !M)
		return FALSE
	if(is_banned_from(M.ckey, CATBAN))
		H.set_species(/datum/species/human/felinid) // can't escape hell
