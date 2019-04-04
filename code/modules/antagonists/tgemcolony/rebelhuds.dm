/datum/antagonist/crystalgem/proc/update_cg_icons_added(var/mob/living/carbon/human/gem)
	var/datum/atom_hud/antag/cghud = GLOB.huds[ANTAG_HUD_CG]
	cghud.join_hud(gem)
	set_antag_hud(gem,"crystalgem")

/datum/antagonist/crystalgem/proc/update_cg_icons_removed(var/mob/living/carbon/human/gem)
	var/datum/atom_hud/antag/cghud = GLOB.huds[ANTAG_HUD_CG]
	cghud.leave_hud(gem)
	set_antag_hud(gem, null)

/datum/antagonist/crystalgem
	name = "Crystal Gem"
	roundend_category = "crystal gems" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Crystal Gem"
	//job_rank = ROLE_CRYSTALGEM

/datum/antagonist/crystalgem/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_cg_icons_added(M)
	objectives += "Protect the Earth and the life that lives here."
	objectives += "Destroy all kindergarten equipment and capture or exile all Homeworld gems"
	owner.announce_objectives()
	owner.current.log_message("has joined the crystal gems!", LOG_ATTACK, color="red")

/datum/antagonist/crystalgem/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	update_cg_icons_removed(M)
	objectives -= "Protect the Earth and the life that lives here."
	objectives -= "Destroy all kindergarten equipment and capture or exile all Homeworld gems"
	owner.current.log_message("has left the crystal gems!", LOG_ATTACK, color="red")

/datum/antagonist/crystalgem/roundend_report()
	var/list/parts = list()

	parts += printplayer(owner)

	//check for kindergarten equipment.
	var/foundinjector = FALSE
	for(var/obj/machinery/geminjector/FM in world)
		if(SSmapping.level_trait(FM.z,ZTRAIT_STATION))
			foundinjector = TRUE
	//check for humans.
	var/foundhumans = FALSE
	for(var/obj/effect/mob_spawn/human/tribal/FM in world)
		if(SSmapping.level_trait(FM.z,ZTRAIT_STATION))
			foundhumans = TRUE
	for(var/mob/living/carbon/human/FM in world)
		var/mob/living/carbon/human/thismob = FM
		if(thismob.dna.species.id == "human")
			if(SSmapping.level_trait(thismob.z,ZTRAIT_STATION))
				foundhumans = TRUE
	//objective time!
	if(foundhumans)
		parts += "<B>Objective</B>: Protect the Earth and the life that lives here. <span class='greentext'>Success!</span>"
	else
		parts += "<B>Objective</B>: Protect the Earth and the life that lives here. <span class='redtext'>Fail.</span>"
	if(!foundinjector)
		parts += "<B>Objective</B>: Destroy all kindergarten equipment.<span class='greentext'>Success!</span>"
	else
		parts += "<B>Objective</B>: Destroy all kindergarten equipment.<span class='redtext'>Fail.</span>"

	return parts.Join("<br>")