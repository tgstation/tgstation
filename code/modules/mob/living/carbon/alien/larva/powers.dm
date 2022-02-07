/obj/effect/proc_holder/alien/hide
	name = "Hide"
	desc = "Allows aliens to hide beneath tables or certain items. Toggled on or off."
	plasma_cost = 0

	action_icon_state = "alien_hide"

/obj/effect/proc_holder/alien/hide/fire(mob/living/carbon/alien/user)
	if(user.stat != CONSCIOUS)
		return

	if (user.layer != ABOVE_NORMAL_TURF_LAYER)
		user.layer = ABOVE_NORMAL_TURF_LAYER
		user.visible_message(span_name("[user] scurries to the ground!"), \
						span_noticealien("You are now hiding."))
	else
		user.layer = MOB_LAYER
		user.visible_message(span_notice("[user] slowly peeks up from the ground..."), \
					span_noticealien("You stop hiding."))
	return 1


/obj/effect/proc_holder/alien/larva_evolve
	name = "Evolve"
	desc = "Evolve into a higher alien caste."
	plasma_cost = 0

	action_icon_state = "alien_evolve_larva"

/obj/effect/proc_holder/alien/larva_evolve/fire(mob/living/carbon/alien/user)
	if(!islarva(user))
		return
	var/mob/living/carbon/alien/larva/larva = user

	if(larva.handcuffed || larva.legcuffed) // Cuffing larvas ? Eh ?
		to_chat(user, span_warning("You cannot evolve when you are cuffed!"))
		return

	if(larva.amount_grown < larva.max_grown)
		to_chat(user, span_warning("You are not fully grown!"))
		return

	to_chat(larva, span_name("You are growing into a beautiful alien! It is time to choose a caste."))
	to_chat(larva, span_info("There are three to choose from:"))
	to_chat(larva, span_name("Hunters</span> <span class='info'>are the most agile caste, tasked with hunting for hosts. They are faster than a human and can even pounce, but are not much tougher than a drone."))
	to_chat(larva, span_name("Sentinels</span> <span class='info'>are tasked with protecting the hive. With their ranged spit, invisibility, and high health, they make formidable guardians and acceptable secondhand hunters."))
	to_chat(larva, span_name("Drones</span> <span class='info'>are the weakest and slowest of the castes, but can grow into a praetorian and then queen if no queen exists, and are vital to maintaining a hive with their resin secretion abilities."))
	var/alien_caste = tgui_input_list(larva, "Please choose which alien caste you shall belong to.",,list("Hunter","Sentinel","Drone"))

	if(larva.movement_type & VENTCRAWLING)
		to_chat(user, span_warning("You cannot evolve while ventcrawling!"))
		return

	if(user.incapacitated()) //something happened to us while we were choosing.
		return

	var/mob/living/carbon/alien/humanoid/new_xeno
	switch(alien_caste)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(larva.loc)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(larva.loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(larva.loc)

	larva.alien_evolve(new_xeno)
	return

