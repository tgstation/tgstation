/datum/action/cooldown/alien/hide
	name = "Hide"
	desc = "Allows aliens to hide beneath tables or certain items. Toggled on or off."
	button_icon_state = "alien_hide"
	plasma_cost = 0

/datum/action/cooldown/alien/hide/Activate(atom/target)
	if (owner.layer == ABOVE_NORMAL_TURF_LAYER)
		owner.layer = MOB_LAYER
		owner.visible_message(
			span_notice("[owner] slowly peeks up from the ground..."),
			span_noticealien("You stop hiding."),
		)
	else
		owner.layer = ABOVE_NORMAL_TURF_LAYER
		owner.visible_message(
			span_name("[owner] scurries to the ground!"),
			span_noticealien("You are now hiding."),
		)

	return TRUE


/datum/action/cooldown/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	button_icon_state = "alien_evolve_larva"
	plasma_cost = 0

/datum/action/cooldown/alien/larva_evolve/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	if(!islarva(owner))
		return FALSE

	var/mob/living/carbon/alien/larva/larva = owner

	if(larva.handcuffed || larva.legcuffed) // Cuffing larvas ? Eh ?
		return FALSE

	if(larva.amount_grown < larva.max_grown)
		return FALSE

	if(larva.movement_type & VENTCRAWLING)
		return

	return TRUE

/datum/action/cooldown/alien/larva_evolve/Activate(atom/target)
	var/mob/living/carbon/alien/larva/larva = owner

	var/hunter_info = span_info("are the most agile caste, tasked with hunting for hosts. \
		They are faster than a human and can even pounce, but are not much tougher than a drone.")

	var/sentinel_info = span_info("are tasked with protecting the hive. \
		With their ranged spit, invisibility, and high health, they make formidable guardians \
		and acceptable secondhand hunters.")

	var/drone_info = span_info("are the weakest and slowest of the castes, \
		but can grow into a praetorian and then queen if no queen exists, \
		and are vital to maintaining a hive with their resin secretion abilities.")

	to_chat(larva, span_name("You are growing into a beautiful alien! It is time to choose a caste."))
	to_chat(larva, span_info("There are three to choose from:"))
	to_chat(larva, "[span_name("Hunters")][hunter_info]")
	to_chat(larva, "[span_name("Sentinels")][sentinel_info]")
	to_chat(larva, "[span_name("Drones")][drone_info]")
	var/alien_caste = tgui_input_list(larva, "Please choose which alien caste you shall belong to.",,list("Hunter","Sentinel","Drone"))
	if(!QDELETED(src) || QDELETED(owner) || !IsAvailable() || !alien_caste)
		return

	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(larva.loc)
		else
			CRASH("Alien evolve was given an invalid / incorrect alien cast type. Got: [alien_caste]")

	larva.alien_evolve(new_xeno)
	return TRUE
