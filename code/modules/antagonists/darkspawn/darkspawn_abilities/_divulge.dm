//A channeled ability that turns the darkspawn into their main form.
/datum/action/innate/darkspawn/divulge
	name = "Divulge"
	id = "divulge"
	desc = "Sheds your human disguise. This is obvious and so should be done in a secluded area. You cannot reverse this."
	button_icon_state = "divulge"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	blacklisted = TRUE

/datum/action/innate/darkspawn/divulge/Activate()
	set waitfor = FALSE
	var/mob/living/carbon/human/user = usr
	var/turf/spot = get_turf(user)
	if(spot.get_lumcount() > DARKSPAWN_DIM_LIGHT)
		to_chat(user, "<span class='warning'>You are only able to divulge in darkness!</span>")
		return
	if(alert(user, "You are ready to divulge. Are you sure?", name, "Yes", "No") == "No")
		return
	in_use = TRUE
	user.visible_message("<b>[user]</b> flaps their wings.", "<span class='velvet'>You begin creating a psychic barrier around yourself...</span>")
	if(!do_after(user, 30, target = user))
		in_use = FALSE
		return
	var/image/alert_overlay = image('icons/mob/actions/actions_darkspawn.dmi', "divulge")
	notify_ghosts("Darkspawn [user.real_name] has begun divulging at [get_area(user)]! ", source = user, ghost_sound = 'sound/magic/devour_will_victim.ogg', alert_overlay = alert_overlay, action = NOTIFY_ORBIT)
	user.visible_message("<span class='warning'>A vortex of violet energies surrounds [user]!</span>", "<span class='velvet'>Your barrier will keep you shielded to a point..</span>")
	user.visible_message("<span class='danger'>[user] slowly rises into the air, their belongings falling away, and begins to shimmer...</span>", \
						"<span class='velvet big'><b>You begin the removal of your human disguise. You will be completely vulnerable during this time.</b></span>")
	user.setDir(SOUTH)
	for(var/obj/item/I in user)
		user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		new/obj/structure/psionic_barrier(T, 500)
	for(var/stage in 1 to 3)
		switch(stage)
			if(1)
				user.visible_message("<span class='userdanger'>Vibrations pass through the air. [user]'s eyes begin to glow a deep violet.</span>", \
									"<span class='velvet'>Psi floods into your consciousness. You feel your mind growing more powerful... <i>expanding.</i></span>")
				playsound(user, 'sound/magic/divulge_01.ogg', 30, 0)
			if(2)
				user.visible_message("<span class='userdanger'>Gravity fluctuates. Psychic tendrils extend outward and feel blindly around the area.</span>", \
									"<span class='velvet'>Gravity around you fluctuates. You tentatively reach out, feel with your mind.</span>")
				user.Shake(0, 3, 750) //50 loops in a second times 15 seconds = 750 loops
				playsound(user, 'sound/magic/divulge_02.ogg', 40, 0)
			if(3)
				user.visible_message("<span class='userdanger'>Sigils form along [user]'s body. \His skin blackens as \he glows a blinding purple.</span>", \
									"<span class='velvet'>Your body begins to warp. Sigils etch themselves upon your flesh.</span>")
				animate(user, color = list(rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0), rgb(0, 0, 0)), time = 150) //Produces a slow skin-blackening effect
				playsound(user, 'sound/magic/divulge_03.ogg', 50, 0)
		if(!do_after(user, 150, target = user))
			user.visible_message("<span class='warning'>[user] falls to the ground!</span>", "<span class='userdanger'>Your transformation was interrupted!</span>")
			animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 10)
			in_use = FALSE
			return
	playsound(user, 'sound/magic/divulge_ending.ogg', 50, 0)
	user.visible_message("<span class='userdanger'>[user] rises into the air, crackling with power!</span>", "<span class='velvet bold'>Your mind...! can't--- THINK--</span>")
	animate(user, pixel_y = user.pixel_y + 8, time = 60)
	sleep(45)
	user.Shake(5, 5, 110)
	for(var/i in 1 to 20)
		to_chat(user, "<span class='velvet bold'>[pick("I- I- I-", "Mind-", "Sigils-", "Can't think-", "<i>POWER-</i>","<i>TAKE-</i>", "M-M-MOOORE-")]</span>")
		sleep(1.1) //Spooky flavor message spam
	user.visible_message("<span class='userdanger'>A tremendous shockwave emanates from [user]!</span>", "<span class='velvet big'><b>YOU ARE FREE!!</b></span>")
	playsound(user, 'sound/magic/divulge_end.ogg', 50, 0)
	animate(user, color = initial(user.color), pixel_y = initial(user.pixel_y), time = 30)
	for(var/mob/living/L in view(7, user))
		if(L == user)
			continue
		L.flash_act(1, 1)
		L.Knockdown(50)
	var/processed_message = "<span class='velvet'><b>\[Mindlink\] [user.real_name] has removed their human disguise and is now DARKSPAWN_NAME.</b></span>"
	darkspawn.divulge()
	processed_message = replacetext(processed_message, "DARKSPAWN_NAME", "[user.real_name]")
	for(var/mob/M in GLOB.player_list)
		if(M.stat == DEAD)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [processed_message]")
		else if(isdarkspawn(M))
			to_chat(M, processed_message)
