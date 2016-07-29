<<<<<<< HEAD
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
		user << "It looks like it's armed."

/obj/item/device/assembly/mousetrap/activate()
	if(..())
		armed = !armed
		if(!armed)
			if(ishuman(usr))
				var/mob/living/carbon/human/user = usr
				if((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY && prob(50))
					user << "<span class='warning'>Your hand slips, setting off the trigger!</span>"
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
		if(PIERCEIMMUNE in H.dna.species.specflags)
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
			if(affecting.take_damage(1, 0))
				H.update_damage_overlays(0)
			H.updatehealth()
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
		user << "<span class='notice'>You arm [src].</span>"
	else
		if(((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
		user << "<span class='notice'>You disarm [src].</span>"
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)


/obj/item/device/assembly/mousetrap/attack_hand(mob/living/carbon/human/user)
	if(armed)
		if(((user.getBrainLoss() >= 60) || user.disabilities & CLUMSY) && prob(50))
			var/which_hand = "l_hand"
			if(!user.hand)
				which_hand = "r_hand"
			triggered(user, which_hand)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()


/obj/item/device/assembly/mousetrap/Crossed(atom/movable/AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								  "<span class='warning'>You accidentally step on [src]</span>")
		else if(isanimal(AM))
			var/mob/living/simple_animal/SA = AM
			if(!SA.flying)
				triggered(AM)
		else if(AM.density) // For mousetrap grenades, set off by anything heavy
			triggered(AM)
	..()


/obj/item/device/assembly/mousetrap/on_found(mob/finder)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")
		triggered(finder, finder.hand ? "l_hand" : "r_hand")
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
=======
/obj/item/device/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	starting_materials = list(MAT_IRON = 100)
	w_type = RECYK_METAL
	origin_tech = "combat=1"
	var/armed = 0
	wires = WIRE_PULSE

/obj/item/device/assembly/mousetrap/examine(mob/user)
	..()
	if(armed)
		to_chat(user, "<span class='warning'>It looks like it's armed.</span>")

/obj/item/device/assembly/mousetrap/update_icon()
	if(armed)
		icon_state = "mousetraparmed"
	else
		icon_state = "mousetrap"
	if(holder)
		holder.update_icon()

/obj/item/device/assembly/mousetrap/proc/triggered(mob/target as mob, var/type = "feet")
	if(!armed)
		return
	var/datum/organ/external/affecting = null
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		switch(type)
			if("feet")
				if(!H.shoes)
					affecting = H.get_organ(pick(LIMB_LEFT_LEG, LIMB_RIGHT_LEG))
					H.Weaken(3)
			if(LIMB_LEFT_HAND, LIMB_RIGHT_HAND)
				if(!H.gloves)
					affecting = H.get_organ(type)
					H.Stun(3)
		if(affecting)
			if(affecting.take_damage(1, 0))
				H.UpdateDamageIcon()
			H.updatehealth()
	else if(ismouse(target))
		var/mob/living/simple_animal/mouse/M = target
		visible_message("<span class='danger'>SPLAT!</span>")
		M.splat()
	playsound(target.loc, 'sound/effects/snap.ogg', 50, 1)
	armed = 0
	update_icon()
	pulse(0)


/obj/item/device/assembly/mousetrap/attack_self(mob/living/user as mob)
	if(!armed)
		to_chat(user, "<span class='notice'>You arm [src].</span>")
	else
		if(((user.getBrainLoss() >= 60 || (M_CLUMSY in user.mutations)) && prob(50)))

			var/datum/organ/external/OE = user.get_active_hand_organ()

			triggered(user, OE.name)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You disarm [src].</span>")
	armed = !armed
	update_icon()
	playsound(user.loc, 'sound/weapons/handcuffs.ogg', 30, 1, -3)


/obj/item/device/assembly/mousetrap/attack_hand(mob/living/user as mob)
	if(armed)
		if(((user.getBrainLoss() >= 60 || M_CLUMSY in user.mutations)) && prob(50))
			var/datum/organ/external/OE = user.get_active_hand_organ()
			triggered(user, OE.name)
			user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
								 "<span class='warning'>You accidentally trigger [src]!</span>")
			return
	..()


/obj/item/device/assembly/mousetrap/Crossed(AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			var/mob/living/carbon/H = AM
			if(H.m_intent == "run")
				triggered(H)
				H.visible_message("<span class='warning'>[H] accidentally steps on [src].</span>", \
								  "<span class='warning'>You accidentally step on [src]</span>")
		if(ismouse(AM))
			triggered(AM)
	..()


/obj/item/device/assembly/mousetrap/on_found(mob/finder as mob)
	if(armed)
		finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
							   "<span class='warning'>You accidentally trigger [src]!</span>")

		var/datum/organ/external/OE = finder.get_active_hand_organ()
		triggered(finder, OE.name)
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


/obj/item/device/assembly/mousetrap/verb/hide_under()
	set src in oview(1)
	set name = "Hide"
	set category = "Object"

	if(usr.isUnconscious())
		return

	layer = TURF_LAYER+0.2
	to_chat(usr, "<span class='notice'>You hide [src].</span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
