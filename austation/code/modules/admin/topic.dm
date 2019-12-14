/datum/admins/proc/austation_on_jobban(mob/M, list/joblist)
	if(joblist.len && (CATBAN in joblist) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.set_species(/datum/species/human/felinid, icon_update=1) // can't escape hell
