/obj/item/device/assembly/mousetrap
	name = "mousetrap"
	desc = "A handy little spring-loaded trap for catching pesty rodents."
	icon_state = "mousetrap"
	m_amt = 100
	w_amt = 10
	origin_tech = "combat=1"
	var/armed = 0


	examine()
		..()
		if(armed)
			usr << "It looks like it's armed."

	update_icon()
		if(armed)
			icon_state = "mousetraparmed"
		else
			icon_state = "mousetrap"
		if(holder)
			holder.update_icon()

	proc/triggered(mob/target as mob, var/type = "feet")
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
			visible_message("\red <b>SPLAT!</b>")
			M.splat()
		playsound(target.loc, 'sound/effects/snap.ogg', 50, 1)
		armed = 0
		update_icon()
		pulse(0)


	attack_self(mob/living/user as mob)
		if(!armed)
			user << "<span class='notice'>You arm [src].</span>"
		else
			if(((user.getBrainLoss() >= 60 || (CLUMSY in user.mutations)) && prob(50)))
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


	attack_hand(mob/living/user as mob)
		if(armed)
			if(((user.getBrainLoss() >= 60 || CLUMSY in user.mutations)) && prob(50))
				var/which_hand = "l_hand"
				if(!user.hand)
					which_hand = "r_hand"
				triggered(user, which_hand)
				user.visible_message("<span class='warning'>[user] accidentally sets off [src], breaking their fingers.</span>", \
									 "<span class='warning'>You accidentally trigger [src]!</span>")
				return
		..()


	HasEntered(AM as mob|obj)
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


	on_found(mob/finder as mob)
		if(armed)
			finder.visible_message("<span class='warning'>[finder] accidentally sets off [src], breaking their fingers.</span>", \
								   "<span class='warning'>You accidentally trigger [src]!</span>")
			triggered(finder, finder.hand ? "l_hand" : "r_hand")
			return 1	//end the search!
		return 0


	hitby(A as mob|obj)
		if(!armed)
			return ..()
		visible_message("<span class='warning'>[src] is triggered by [A].</span>")
		triggered(null)


/obj/item/device/assembly/mousetrap/armed
	icon_state = "mousetraparmed"
	armed = 1