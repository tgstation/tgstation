//Turns the darkspawn into a progenitor.
/datum/action/innate/darkspawn/sacrament
	name = "Sacrament"
	id = "sacrament"
	desc = "Ascends into a progenitor. Unless someone else has performed the Sacrament, you must have drained 15 lucidity for this to work, and purchased all passive upgrades."
	button_icon_state = "sacrament"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	blacklisted = TRUE //baseline
	var/datum/looping_sound/sacrament/soundloop

/datum/action/innate/darkspawn/sacrament/Activate()
	if(darkspawn.sacrament_complete)
		darkspawn.sacrament()
		return
	if(!darkspawn || darkspawn.lucidity_drained < 20)
		to_chat(usr, "<span class='warning'>You do not have enough drained lucidity! ([darkspawn.lucidity_drained] / 20)</span>")
		return
	var/list/unpurchased_upgrades = list()
	for(var/V in subtypesof(/datum/darkspawn_upgrade))
		var/datum/darkspawn_upgrade/D = V
		if(!darkspawn.has_upgrade(initial(D.id)))
			unpurchased_upgrades += initial(D.name)
	if(unpurchased_upgrades.len)
		var/upgrade_string = unpurchased_upgrades.Join(", ")
		to_chat(usr, "<span class='warning'>You have not purchased all passive upgrades! You are missing:</span> <span class='danger'>[upgrade_string].</span>")
		return
	if(alert(usr, "The Sacrament is ready! Are you prepared?", name, "Yes", "No") == "No")
		return
	in_use = TRUE
	var/mob/living/carbon/human/user = usr
	user.visible_message("<span class='warning'>[user]'s sigils flare as energy swirls around them...</span>", "<span class='velvet'>You begin creating a psychic barrier around yourself...</span>")
	playsound(user, 'sound/magic/sacrament_begin.ogg', 50, FALSE)
	if(!do_after(user, 30, target = user))
		in_use = FALSE
		return
	var/image/alert_overlay = image('icons/mob/actions/actions_darkspawn.dmi', "sacrament")
	notify_ghosts("Darkspawn [user.real_name] has begun the Sacrament at [get_area(user)]! ", source = user, ghost_sound = 'sound/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message("<span class='warning'>A vortex of violet energies surrounds [user]!</span>", "<span class='velvet'>Your barrier will protect you.</span>")
	user.visible_message("<span class='danger'>[user] suddenly jolts into the air, pulsing with screaming violet light.</span>", \
						"<span class='velvet big'><b>You begin the Sacrament.</b></span>")
	soundloop = new(GLOB.player_list, TRUE, TRUE)
	for(var/turf/T in RANGE_TURFS(2, user))
		new/obj/structure/psionic_barrier(T, 340)
	for(var/stage in 1 to 2)
		soundloop.stage = stage
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>[user]'s sigils howl out light. Their limbs twist and move, glowing cracks forming across their chitin.</span>", \
									"<span class='velvet'>Power... <i>power...</i> flooding through you, the dreams and thoughts of those you've touched whispering in your ears...</span>")
				for(var/mob/M in GLOB.player_list)
					M.playsound_local(M, 'sound/magic/sacrament_01.ogg', 20, FALSE, pressure_affected = FALSE)
					if(M != user)
						to_chat(M, "<span class='warning'>What is that sound...?</span>")
			if(2)
				user.visible_message("<span class='userdanger'>[user] begins to... <i>grow.</i>.</span>", \
									"<span class='velvet'>Yes! <font size=3>Yes! You feel the weak mortal shell coming apart!</font></span>")
				for(var/mob/M in GLOB.player_list)
					M.playsound_local(M, 'sound/magic/sacrament_02.ogg', 20, FALSE, pressure_affected = FALSE)
				animate(user, transform = matrix() * 2, time = 150)
		if(!do_after(user, 150, target = user))
			user.visible_message("<span class='warning'>[user] falls to the ground!</span>", "<span class='userdanger'>Your transformation was interrupted!</span>")
			animate(user, transform = matrix(), pixel_y = initial(user.pixel_y), time = 30)
			in_use = FALSE
			QDEL_NULL(soundloop)
			return
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M, 'sound/magic/sacrament_ending.ogg', 75, FALSE, pressure_affected = FALSE)
	soundloop.stage = 3
	user.visible_message("<span class='userdanger'>[user] rises into the air, crackling with power!</span>", "<span class='velvet bold'>AND THE WEAK WILL KNOW <i>FEAR--</i></span>")
	for(var/turf/T in range(7, owner))
		if(prob(25))
			addtimer(CALLBACK(src, .proc/unleashed_psi, T), rand(1, 40))
	addtimer(CALLBACK(src, .proc/shatter_lights), 35)
	QDEL_IN(soundloop, 39)
	animate(user, pixel_y = user.pixel_y + 20, time = 40)
	addtimer(CALLBACK(darkspawn, /datum/antagonist/darkspawn/.proc/sacrament), 40)

/datum/action/innate/darkspawn/sacrament/proc/unleashed_psi(turf/T)
	playsound(T, 'sound/magic/divulge_end.ogg', 25, FALSE)
	new/obj/effect/temp_visual/revenant/cracks(T)

/datum/action/innate/darkspawn/sacrament/proc/shatter_lights()
	if(darkspawn.sacrament_complete)
		return
	for(var/obj/machinery/light/light in SSmachines.processing)
		light.break_light_tube()
