/obj/structure/table/alt_attack_hand(mob/user)
	if(user && Adjacent(user) && !user.incapacitated())
		if(istype(user) && user.a_intent == INTENT_HARM)
			user.visible_message("<span class='warning'>[user] slams [user.p_their()] palms down on [src].</span>", "<span class='warning'>You slam your palms down on [src].</span>")
			playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
		else
			user.visible_message("<span class='notice'>[user] slaps [user.p_their()] hands on [src].</span>", "<span class='notice'>You slap your hands on [src].</span>")
			playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		user.do_attack_animation(src)
		return TRUE
