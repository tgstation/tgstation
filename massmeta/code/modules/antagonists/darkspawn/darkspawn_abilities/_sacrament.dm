//Turns the darkspawn into a progenitor.
/datum/action/innate/darkspawn/sacrament
	name = "Sacrament"
	id = "sacrament"
	desc = "Ascends into a progenitor. Unless someone else has performed the Sacrament, you must have drained lucidity from 15-30 (check your objective) different people for this to work, and purchased all passive upgrades."
	button_icon_state = "sacrament"
	check_flags = AB_CHECK_INCAPACITATED | AB_CHECK_CONSCIOUS
	blacklisted = TRUE //baseline
	var/datum/looping_sound/sacrament/soundloop

/datum/action/innate/darkspawn/sacrament/Activate()
	if(GLOB.sacrament_done)
		darkspawn.sacrament()
		return
	if(!darkspawn || darkspawn.lucidity_drained < GLOB.required_succs)
		to_chat(usr, span_warning("You do not have enough unique lucidity! ([darkspawn.lucidity_drained] / [GLOB.required_succs])"))
		return
	var/list/unpurchased_upgrades = list()
	for(var/V in subtypesof(/datum/darkspawn_upgrade))
		var/datum/darkspawn_upgrade/D = V
		if(!darkspawn.has_upgrade(initial(D.id)))
			unpurchased_upgrades += initial(D.name)
	if(unpurchased_upgrades.len)
		var/upgrade_string = unpurchased_upgrades.Join(", ")
		to_chat(usr, "[span_warning("You have not purchased all passive upgrades! You are missing:")] [span_danger("[upgrade_string].")]")
		return
	if(alert(usr, "The Sacrament is ready! Are you prepared?", name, "Yes", "No") == "No")
		return
	in_use = TRUE
	var/mob/living/carbon/human/user = usr
	user.visible_message(span_warning("[user]'s sigils flare as energy swirls around them..."), span_velvet("You begin creating a psychic barrier around yourself..."))
	playsound(user, 'massmeta/sounds/magic/sacrament_begin.ogg', 50, FALSE)
	if(!do_after(user, 3 SECONDS, user))
		in_use = FALSE
		return
	var/image/alert_overlay = image('massmeta/icons/mob/actions/actions_darkspawn.dmi', "sacrament")
	notify_ghosts("Darkspawn [user.real_name] has begun the Sacrament at [get_area(user)]! ", source = user, ghost_sound = 'massmeta/sounds/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message(span_warning("A vortex of violet energies surrounds [user]!"), span_velvet("Your barrier will protect you."))
	user.visible_message(span_danger("[user] suddenly jolts into the air, pulsing with screaming violet light."), \
						"<span class='velvet big'><b>You begin the Sacrament.</b></span>")
	soundloop = new(GLOB.player_list, TRUE, TRUE)
	for(var/turf/T in RANGE_TURFS(2, user))
		new/obj/structure/psionic_barrier(T, 340)
	for(var/stage in 1 to 2)
		soundloop.stage = stage
		switch(stage)
			if(1)
				user.visible_message(span_userdanger("[user]'s sigils howl out light. Their limbs twist and move, glowing cracks forming across their chitin."), \
									span_velvet("Power... <i>power...</i> flooding through you, the dreams and thoughts of those you've touched whispering in your ears..."))
				for(var/mob/M in GLOB.player_list)
					M.playsound_local(M, 'massmeta/sounds/magic/sacrament_01.ogg', 20, FALSE, pressure_affected = FALSE)
					if(M != user)
						to_chat(M, span_warning("What is that sound...?"))
			if(2)
				user.visible_message(span_userdanger("[user] begins to... <i>grow.</i>."), \
									span_velvet("Yes! <font size=3>Yes! You feel the weak mortal shell coming apart!</font>"))
				for(var/mob/M in GLOB.player_list)
					M.playsound_local(M, 'massmeta/sounds/magic/sacrament_02.ogg', 20, FALSE, pressure_affected = FALSE)
				animate(user, transform = matrix() * 2, time = 15 SECONDS)
		if(!do_after(user, 15 SECONDS, user))
			user.visible_message(span_warning("[user] falls to the ground!"), span_userdanger("Your transformation was interrupted!"))
			animate(user, transform = matrix(), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
			in_use = FALSE
			QDEL_NULL(soundloop)
			return
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M, 'massmeta/sounds/magic/sacrament_ending.ogg', 75, FALSE, pressure_affected = FALSE)
	soundloop.stage = 3
	user.visible_message(span_userdanger("[user] rises into the air, crackling with power!"), "<span class='velvet bold'>AND THE WEAK WILL KNOW <i>FEAR--</i></span>")
	for(var/turf/T in range(7, owner))
		if(prob(25))
			addtimer(CALLBACK(src, .proc/unleashed_psi, T), rand(0.1, 4) SECONDS)
	addtimer(CALLBACK(src, .proc/shatter_lights), 3.5 SECONDS)
	QDEL_IN(soundloop, 39)
	animate(user, pixel_y = user.pixel_y + 20, time = 4 SECONDS)
	addtimer(CALLBACK(darkspawn, /datum/antagonist/darkspawn/.proc/sacrament), 4 SECONDS)

/datum/action/innate/darkspawn/sacrament/proc/unleashed_psi(turf/T)
	playsound(T, 'massmeta/sounds/magic/divulge_end.ogg', 25, FALSE)
	new/obj/effect/temp_visual/revenant/cracks(T)

/datum/action/innate/darkspawn/sacrament/proc/shatter_lights()
	if(GLOB.sacrament_done)
		return
	for(var/obj/machinery/light/light in SSmachines.processing)
		light.break_light_tube()
