//A channeled ability that turns the darkspawn into their main form.
/datum/action/innate/darkspawn/divulge
	name = "Divulge"
	id = "divulge"
	desc = "Sheds your human disguise. This is obvious and so should be done in a secluded area. You cannot reverse this."
	button_icon_state = "divulge"
	check_flags = AB_CHECK_INCAPACITATED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	blacklisted = TRUE

/datum/action/innate/darkspawn/divulge/Activate()
	set waitfor = FALSE
	var/mob/living/carbon/human/user = usr
	var/turf/spot = get_turf(user)
	if(!ishuman(user))
		to_chat(user, span_warning("You need to be human-er to do that!"))
		return
	if(isethereal(user))
		user.set_light(0)
	if(spot.get_lumcount() > DARKSPAWN_DIM_LIGHT)
		to_chat(user, span_warning("You are only able to divulge in darkness!"))
		return
	var/answer = tgui_alert(user, "You are ready to divulge. Are you sure?", "Divulge", list("Yes", "No"))
	if(answer == "No")
		return
	in_use = TRUE
	if(istype(user.dna.species, /datum/species/pod))
		to_chat(user, span_notice("Your disguise is stabilized by the divulgance..."))
		user.reagents.add_reagent(/datum/reagent/medicine/salbutamol,20)
	if(istype(user.dna.species, /datum/species/plasmaman))
		to_chat(user, span_notice("Your bones harden to protect you from the atmosphere..."))
		user.set_species(/datum/species/skeleton)
	user.visible_message("<b>[user]</b> flaps their wings.", span_velvet("You begin creating a psychic barrier around yourself..."))
	if(!do_after(user, 3 SECONDS, user))
		in_use = FALSE
		return
	var/image/alert_overlay = image('massmeta/icons/mob/actions/actions_darkspawn.dmi', "divulge")
	notify_ghosts("Darkspawn [user.real_name] has begun divulging at [get_area(user)]! ", source = user, ghost_sound = 'massmeta/sounds/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message(span_warning("A vortex of violet energies surrounds [user]!"), span_velvet("Your barrier will keep you shielded to a point.."))
	user.visible_message(span_danger("[user] slowly rises into the air, their belongings falling away, and begins to shimmer..."), \
						"<span class='velvet big'><b>You begin the removal of your human disguise. You will be completely vulnerable during this time.</b></span>")
	user.setDir(SOUTH)
	for(var/obj/item/I in user)
		user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		new/obj/structure/psionic_barrier(T, 500)
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				user.visible_message(span_userdanger("Vibrations pass through the air. [user]'s eyes begin to glow a deep violet."), \
									span_velvet("Psi floods into your consciousness. You feel your mind growing more powerful... <i>expanding.</i>"))
				playsound(user, 'massmeta/sounds/magic/divulge_01.ogg', 30, 0)
			if(2)
				user.visible_message(span_userdanger("Gravity fluctuates. Psychic tendrils extend outward and feel blindly around the area."), \
									span_velvet("Gravity around you fluctuates. You tentatively reach out, feel with your mind."))
				user.Shake(0, 3, 750) //50 loops in a second times 15 seconds = 750 loops
				playsound(user, 'massmeta/sounds/magic/divulge_02.ogg', 40, 0)
			if(3)
				user.visible_message(span_userdanger("Sigils form along [user]'s body. \His skin blackens as \he glows a blinding purple."), \
									span_velvet("Your body begins to warp. Sigils etch themselves upon your flesh."))
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 15 SECONDS) //Produces a slow skin-blackening effect
				playsound(user, 'massmeta/sounds/magic/divulge_03.ogg', 50, 0)
		if(!do_after(user, 15 SECONDS, user))
			user.visible_message(span_warning("[user] falls to the ground!"), span_userdanger("Your transformation was interrupted!"))
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 1 SECONDS)
			in_use = FALSE
			return
	playsound(user, 'massmeta/sounds/magic/divulge_ending.ogg', 50, 0)
	user.visible_message(span_userdanger("[user] rises into the air, crackling with power!"), "<span class='velvet bold'>Your mind...! can't--- THINK--</span>")
	animate(user, pixel_y = user.pixel_y + 8, time = 6 SECONDS)
	sleep(4.5 SECONDS)
	user.Shake(5, 5, 11 SECONDS)
	for(var/i in 1 to 20)
		to_chat(user, "<span class='velvet bold'>[pick("I- I- I-", "Mind-", "Sigils-", "Can't think-", "<i>POWER-</i>","<i>TAKE-</i>", "M-M-MOOORE-")]</span>")
		sleep(0.11 SECONDS) //Spooky flavor message spam
	user.visible_message(span_userdanger("A tremendous shockwave emanates from [user]!"), "<span class='velvet big'><b>YOU ARE FREE!!</b></span>")
	playsound(user, 'massmeta/sounds/magic/divulge_end.ogg', 50, 0)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 3 SECONDS)
	for(var/mob/living/L in view(7, user))
		if(L == user)
			continue
		L.flash_act(1, 1)
		L.Knockdown(5 SECONDS)
	var/old_name = user.real_name
	darkspawn.divulge()
	var/processed_message = span_velvet("<b>\[Mindlink\] [old_name] has removed their human disguise and is now [user.real_name].</b>")
	for(var/T in GLOB.alive_mob_list)
		var/mob/M = T
		if(is_darkspawn_or_veil(M))
			to_chat(M, processed_message)
	for(var/T in GLOB.dead_mob_list)
		var/mob/M = T
		to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [processed_message]")
