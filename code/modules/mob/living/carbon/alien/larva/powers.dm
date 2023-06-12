/datum/action/cooldown/alien/hide
	name = "Hide"
	desc = "Allows you to hide beneath tables and certain objects."
	button_icon_state = "alien_hide"
	plasma_cost = 0
	/// The layer we are on while hiding
	var/hide_layer = ABOVE_NORMAL_TURF_LAYER

/datum/action/cooldown/alien/hide/Activate(atom/target)
	if(owner.layer == hide_layer)
		owner.layer = initial(owner.layer)
		owner.visible_message(
			span_notice("[owner] slowly peeks up from the ground..."),
			span_noticealien("You stop hiding."),
		)

	else
		owner.layer = hide_layer
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

/datum/action/cooldown/alien/larva_evolve/IsAvailable(feedback = FALSE)
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
		return FALSE

	return TRUE

/datum/action/cooldown/alien/larva_evolve/Activate(atom/target)
	var/mob/living/carbon/alien/larva/larva = owner
	var/static/list/caste_options
	if(!caste_options)
		caste_options = list()

		// This can probably be genericized in the future.
		var/mob/hunter_path = /mob/living/carbon/alien/adult/hunter
		var/datum/radial_menu_choice/hunter = new()
		hunter.name = "Hunter"
		hunter.image  = image(icon = initial(hunter_path.icon), icon_state = initial(hunter_path.icon_state))
		hunter.info = span_info("Hunters are the most agile caste, tasked with hunting for hosts. \
			They are faster than a human and can even pounce, but are not much tougher than a drone.")

		caste_options["Hunter"] = hunter

		var/mob/sentinel_path = /mob/living/carbon/alien/adult/sentinel
		var/datum/radial_menu_choice/sentinel = new()
		sentinel.name = "Sentinel"
		sentinel.image  = image(icon = initial(sentinel_path.icon), icon_state = initial(sentinel_path.icon_state))
		sentinel.info = span_info("Sentinels are tasked with protecting the hive. \
			With their ranged spit, invisibility, and high health, they make formidable guardians \
			and acceptable secondhand hunters.")

		caste_options["Sentinel"] = sentinel

		var/mob/drone_path = /mob/living/carbon/alien/adult/drone
		var/datum/radial_menu_choice/drone = new()
		drone.name = "Drone"
		drone.image  = image(icon = initial(drone_path.icon), icon_state = initial(drone_path.icon_state))
		drone.info = span_info("Drones are the weakest and slowest of the castes, \
			but can grow into a praetorian and then queen if no queen exists, \
			and are vital to maintaining a hive with their resin secretion abilities.")

		caste_options["Drone"] = drone

	var/alien_caste = show_radial_menu(owner, owner, caste_options, radius = 38, require_near = TRUE, tooltips = TRUE)
	if(QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE) || isnull(alien_caste))
		return

	var/mob/living/carbon/alien/adult/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/adult/hunter(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/adult/sentinel(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/adult/drone(larva.loc)
		else
			CRASH("Alien evolve was given an invalid / incorrect alien cast type. Got: [alien_caste]")

	larva.alien_evolve(new_xeno)
	return TRUE
