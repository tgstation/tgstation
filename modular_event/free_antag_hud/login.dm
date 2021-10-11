/mob/living/Login()
	. = ..()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		hud.add_hud_to(src) //enable antag/team huds by default

/mob/dead/observer/Login()
	. = ..()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		hud.add_hud_to(src)
