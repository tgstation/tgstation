/datum/action/innate/umbrage/psi_web
	name = "Psi Web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "umbrage_psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = 1
	psi_cost = 5

/datum/action/innate/umbrage/psi_web/Activate()
	usr << "<span class='velvet_bold'>You retreat inwards and touch the Mindlink...</span>"
	var/datum/umbrage/U = get_umbrage()
	if(!U)
		return
	U.ui_interact(usr)
	return 1

/datum/action/innate/umbrage/tutorial
	name = "Tutorial"
	desc = "Need more information on being an umbrage? This in-game tutorial can help you with any questions."
	button_icon_state = "umbrage_tutorial"
	check_flags = 0
	blacklisted = 1
	psi_cost = 0

/datum/action/innate/umbrage/tutorial/Activate()
	switch(alert(usr, "Basic or in-depth tutorial?", "Umbrage Tutorial", "Basic", "Advanced", "Cancel"))
		if("Basic")
			//basic_tutorial(usr)
		if("Advanced")
			//advanced_tutorial(usr)

#warn Do the tutorials at some point

/datum/action/innate/umbrage/divulge
	name = "Divulge"
	desc = "Cast off your human disguise and become a proper umbrage. This takes about a full minute, and you can be interrupted by performing any actions."
	button_icon_state = "umbrage_divulge"
	blacklisted = 1
	check_flags = AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS

/datum/action/innate/umbrage/divulge/IsAvailable()
	if(active)
		return
	return ..()

/datum/action/innate/umbrage/divulge/Activate()
	if(alert(usr, "Are you sure? You cannot change back into a human!", name, "Yes", "No") == "No")
		return
	usr << "<span class='warning'>If this attempt fails, you may not try again for another minute.</span>"
	active = 1
	spawn(600) //1-minute cooldown on all attempts, regardless of success or failure
		active = 0
	var/mob/living/carbon/human/user = usr
	user.visible_message("<b>[user]</b> flaps their wings.", "<span class='velvet'>You begin creating a psychic barrier around yourself...</span>")
	if(!do_after(user, 30, target = user))
		return
	var/image/alert_overlay = image('icons/mob/actions.dmi', "umbrage_divulge")
	notify_ghosts("Umbrage [user.real_name] has begun Divulging at [get_area(user)]! ", source = user, ghost_sound = 'sound/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message("<span class='warning'>A vortex of violet energies surrounds [user]!</span>", "<span class='velvet'>Your barrier will keep you shielded... to a degree.</span>")
	user.visible_message("<span class='danger'>[user] slowly rises into the air, their belongings falling away, and begins to shimmer...</span>", \
						"<span class='velvet_large'><b>You begin the removal of your human disguise. You will be completely vulnerable during this time.</b></span>")
	for(var/obj/item/I in user)
		user.unEquip(I)
	for(var/turf/T in orange(1, user))
		new/obj/structure/psionic_barrier(T)
	new/obj/structure/fluff/psionic_vortex(get_turf(user))
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Vibrations pass through the air. [user]'s eyes begin to glow a deep violet.</span>", \
									"<span class='velvet'>Psi floods into your consciousness. You feel your mind growing more powerful... <i>expanding.</i></span>")
				playsound(user, 'sound/magic/divulge_01.ogg', 70, 0)
			if(2)
				user.visible_message("<span class='userdanger'>Gravity fluctuates. Psychic tendrils extend outward and feel blindly around the area.</span>", \
									"<span class='velvet'>Gravity around you fluctuates. You tentatively reach out, feel with your mind.</span>")
				for(var/atom/A in view(3, user))
					spawn(rand(10, 40))
						if(prob(25))
							user.Beam(A, icon_state="b_beam", time = rand(30, 100))
				playsound(user, 'sound/magic/divulge_02.ogg', 80, 0)
			if(3)
				user.visible_message("<span class='userdanger'>Sigils form along [user]'s body. \His skin blackens as \he glows a blinding purple.</span>", \
									"<span class='velvet'>Your body begins to warp. Sigils etch themselves upon your flesh.</span>")
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 200) //Produces a slow skin-blackening effect
				playsound(user, 'sound/magic/divulge_03.ogg', 90, 0)
		if(!do_after(user, 150, target = user))
			user.visible_message("<span class='warning'>[user] falls to the ground!</span>", "<span class='userdanger'>Your transformation was interrupted!</span>")
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 10)
			return
	playsound(user, 'sound/magic/divulge_ending.ogg', 100, 0)
	user.visible_message("<span class='userdanger'>[user] rises into the air, crackling with power!</span>", "<span class='velvet_bold'>Your mind...! can't--- THINK--</span>")
	animate(user, pixel_y = user.pixel_y + 5, time = 60)
	sleep(45)
	for(var/i in 1 to 20)
		user << "<span class='velvet_bold'>[pick("I- I- I-", "Mind-", "Sigils-", "Can't think-", "<i>POWER-</i>", "W-EE--EEE-", "<i>TAKE-</i>", "M-M-MOOORE-")]</span>"
		sleep(1.1) //Spooky flavor message spam
	user.visible_message("<span class='userdanger'>A tremendous shockwave emanates from [user]!</span>", "<span class='velvet_large'><b>YOU ARE FREE!!</b></span>")
	playsound(user, 'sound/magic/divulge_end.ogg', 100, 0)
	user.fully_heal()
	user.underwear = "Nude"
	user.undershirt = "Nude"
	user.socks = "Nude"
	user.set_species(/datum/species/umbrage)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 10)
	for(var/mob/living/L in view(7, user))
		if(L == user)
			continue
		L.flash_act(1, 1)
		L.Weaken(5)
	var/umbrage_name = pick(umbrage_names)
	var/processed_message = "<span class='velvet'><b>\[Mindlink\] [user.real_name] has removed their human disguise and is now [umbrage_name].</b></span>"
	for(var/datum/mind/M in ticker.mode.umbrages_and_veils)
		M.current << processed_message
	for(var/mob/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		M << "[link] [processed_message]"
	Remove(user) //Take the action away
	user.real_name = umbrage_name
	user.name = umbrage_name
	sleep(50)
	user << "<span class='velvet_bold'>Your mind has expanded. The Psi Web is now available. Avoid the light. Keep to the shadows. Your time will come.</span>"
	var/datum/umbrage/U = get_umbrage()
	U.give_ability("Psi Web")
	U.give_ability("Devour Will")
