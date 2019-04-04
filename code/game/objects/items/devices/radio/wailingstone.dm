/obj/structure/wailingstone
	name = "Wailing Stone"
	desc = "Push down on the button to transmit. Cannot transmit and recieve at the same time. Feedback tends to overload and explode the device."
	icon = 'icons/obj/radio.dmi'
	icon_state = "wailingstone_listen"
	var/mode = 0 //0 == listen, 1 == speak.
	var/pressing = null
	density = TRUE
	flags_1 = HEAR_1
	var/feedbackcooldown = 0
	var/exploding = FALSE //so explosion isn't spammed.

/obj/structure/wailingstone/anchored
	anchored = TRUE

/obj/structure/wailingstone/proc/checkforpresser()
	var/foundpresser = FALSE
	for(var/mob/living/L in view(src,1))
		if(L == pressing)
			foundpresser = TRUE
	if(foundpresser == FALSE)
		if(mode == 1)
			src.visible_message("<span class='notice'>[pressing] releases [src]!</span>")
		mode = 0
		pressing = null
		icon_state = "wailingstone_listen"
	else
		addtimer(CALLBACK(src, .proc/checkforpresser), 5)

/obj/structure/wailingstone/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(mode == 0 && isliving(user))
		mode = 1
		pressing = user
		addtimer(CALLBACK(src, .proc/checkforpresser), 5)
		src.visible_message("<span class='notice'>[user] presses down on [src]!</span>")
		icon_state = "wailingstone_speak"
	else if(user == pressing)
		src.visible_message("<span class='notice'>[user] releases [src]!</span>")
		icon_state = "wailingstone_listen"
		mode = 0
		pressing = null

/obj/structure/wailingstone/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if (mode == 0)
		return  // not transmitting.
	if(istype(speaker,/obj/structure/wailingstone) && exploding == FALSE && feedbackcooldown < world.time && speaker in view(src,2)) //now you've fucked up.

		for(var/obj/structure/wailingstone/WS in world)
			if(WS.mode == 0 && WS.feedbackcooldown < world.time)
				for(var/mob/living/carbon/C in view(WS,8))
					if(C.can_hear())
						C.adjustEarDamage(10,20)
						to_chat(C,"<span class='userdanger'>[WS] lets out a horrible screeching noise!</span>")
				WS.feedbackcooldown = world.time+50
		if(prob(25))
			src.visible_message("<span class='userdanger'>[src] violently explodes from feedback!</span>")
			explosion(src.loc, 1, 2, 3, 8)
			exploding = TRUE
			return
		else
			feedbackcooldown = world.time+50
			return

	for(var/obj/structure/wailingstone/WS in world)
		if(WS.mode == 0 && WS.feedbackcooldown < world.time && !istype(speaker, /obj/structure/wailingstone))
			WS.say(message)