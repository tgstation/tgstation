/mob/living/carbon/Login()
	..()
	if(disabilities & AGNOSIA)
		for(var/v in GLOB.active_agnosia_appearances)
			if(!v)
				continue
			var/datum/atom_hud/alternate_appearance/AA = v
			AA.onNewMob(src)