/obj/item/device/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	materials = list(MAT_METAL=100)
	origin_tech = "combat=1;materials=2;engineering=1"
	attachable = 1
	var/armed = 0


/obj/item/device/assembly/mousetrap/examine(mob/user)
	..()
	if(armed)
		to_chat(user, "The mousetrap is armed!")
	else
		to_chat(user, "The mousetrap is not armed.")

/obj/item/device/assembly/mousetrap/activate()
	if(..())
		armed = !armed
		if(!armed)
			if(ishuman(usr))
				var/mob/living/carbon/human/user = usr
				if((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY && prob(50))
					to_chat(user, "<span class='warning'>Your hand slips, setting off the trigger!</span>")
					pulse(0)
		update_icon()
		if(usr)
			playsound(usr.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)

/obj/item/device/assembly/mousetrap/describe()
	return "The pressure switch is [armed?"primed":"safe"]."

/obj/item/device/assembly/mousetrap/update_icon()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	if(holder)
		holder.update_icon()

/obj/item/device/assembly/mousetrap/proc/triggered(mob/target, type = "feet")
	if(!armed)
		return
	var/obj/item/bodypart/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(PIERCEIMMUNE in H.dna.species.species_traits)
			playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
			armed = 0
			update_icon()
			pulse(0)
			return 0
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_bodypart(pick("l_leg", "r_leg"))
					H.Weaken(3)
			if("l_hand", "r_hand")
				if(!H.gloves)
					affecting = H.get_bodypart(type)
					H.Stun(3)
		if(affecting)
			if(affecting.receive_damage(1, 0))
				H.update_damage_overlays()
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("<span class='boldannounce'>SPLAT!</span>")
		M.splat()
	playsound(src.loc, 'sound/effects/snap.ogg', 50, 1)
	armed = 0
	update_icon()
	pulse(0)


/obj/item/device/assembly/mousetrap/attack_self(mob/living/carbon/human/user)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if(((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY) && prob(50))
			var/which_hand = "l_hand"
			if(!(user.active_hand_index % 2))
				which_hand = "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)


/obj/item/device/assembly/mousetrap/attack_hand(mob/living/carbon/human/user)
	if(armed)
		if(((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY) && prob(50))
			var/which_hand = "l_hand"
			if(!(user.active_hand_index % 2))
				which_hand = "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()


/obj/item/device/assembly/mousetrap/Crossed(atom/movable/AM as mob|obj)
	if(armed)
		if(ismob(AM))
			var/mob/MM = AM
			if(!(MM.movement_type & FLYING))
				if(ishuman(AM))
					var/mob/living/carbon/H = AM
					if(H.m_intent == MOVE_INTENT_RUN)
						triggered(H)
						H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
										  "<span class='warning'>You accidentally step on [src]</span>")
				else if(ismouse(MM))
					triggered(MM)
		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			triggered(AM)
	..()


/obj/item/device/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, (finder.active_hand_index % 2 == 0) ? "r_hand" : "l_hand")
		return 1	//end the search!
	return 0


/obj/item/device/assembly/mousetrap/hitby(A as mob|obj)
	if(!armed)
		return ..()
	visible_message("<span class='warning'>[src] is triggered by [A].</span>")
	triggered(null)


/obj/item/device/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1
