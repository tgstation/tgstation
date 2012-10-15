/obj/item/weapon/mousetrap/examine()
	set src in oview(12)
	..()
	if(armed)
		usr << "\red It looks like it's armed."

/obj/item/weapon/mousetrap/proc/triggered(mob/target as mob, var/type = "feet")
	if(!armed)
		return
	var/datum/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_organ(pick("l_leg", "r_leg"))
					H.Weaken(3)
			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.get_organ(type)
					H.Stun(3)
		if(affecting)
			if(affecting.take_damage(1, 0))
				H.UpdateDamageIcon()
			H.updatehealth()
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		src.visible_message("\red <b>SPLAT!</b>")
		M.splat()
	playsound(target.loc, 'sound/effects/snap.ogg', 50, 1)
	icon_state = "mousetrap"
	armed = 0
/*
	else if (ismouse(target))
		target.adjustBruteLoss(100)
*/

/obj/item/weapon/mousetrap/attack_self(mob/living/user as mob)
	if(!armed)
		icon_state = "mousetraparmed"
		user << "\blue You arm the mousetrap."
	else
		icon_state = "mousetrap"
		if(( (user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50)))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>", 1)
			return
		user << "\blue You disarm the mousetrap."
	armed = !armed
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)

/obj/item/weapon/mousetrap/attack_hand(mob/living/user as mob)
	if(armed)
		if(( (user.getBrainLoss() >= 60 || CLUMSY in user.mutations)) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			src.triggered(user, which_hand)
			user << "\red <B>You accidentally trigger the mousetrap!</B>"
			for(var/mob/O in viewers(user, null))
				if(O == user)
					continue
				O.show_message("\red <B>[user] accidentally sets off the mousetrap, breaking their fingers.</B>", 1)
			return
	..()

/obj/item/weapon/mousetrap/HasEntered(AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				src.triggered(H)
				H << "\red <B>You accidentally step on the mousetrap!</B>"
				for(var/mob/O in viewers(H, null))
					if(O == H)
						continue
					O.show_message("\red <B>[H] accidentally steps on the mousetrap.</B>", 1)
		if(ismouse(AM))
			triggered(AM)
	..()

/obj/item/weapon/mousetrap/hitby(A as mob|obj)
	if(!armed)
		return ..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>The mousetrap is triggered by [A].</B>", 1)
	src.triggered(null)
