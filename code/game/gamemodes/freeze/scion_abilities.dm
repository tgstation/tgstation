/obj/effect/proc_holder/spell/proc/check_frosty(/ob/living/carbon/human/H)
	. = 0
	if(!H||!istype(H))
		return



/obj/effect/proc_holder/spell/aoe_turf/spread_frost
	name = "Spread Frost"
	desc = "Forms a slowly-spreading layer of frost on the ground beneath your feet."
	panel = "Scion Abilities"
	charge_max = 100
	clothes_req = 0
	range = 0
	action_icon_state = "frost"

/obj/effect/proc_holder/spell/aoe_turf/spread_frost/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	for(var/turf/T in targets)
		if(locate(/obj/structure/alien/weeds/frost/node) in T.contents)
			user << "<span class='warning'>There is already thick frost here!</span>"
			return 0
		new /obj/structure/alien/weeds/frost/node(T)
	user.visible_message("<span class='notice'>[user] has formed some thick frost!</span>")
	return 1

/obj/effect/proc_holder/spell/targeted/chilling_grasp
	name = "Chilling Grasp"
	desc = "Allows you to turn a conscious, non-braindead, non-catatonic human to a pawn of the legion. This takes some time to cast and requires that the target is not wearing a jumpsuit."
	panel = "Scion Abilities"
	charge_max = 0
	clothes_req = 0
	range = 1 //Adjacent to user
	action_icon_state = "chill"
	var/turning = 0


/obj/effect/proc_holder/spell/targeted/chilling_grasp/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	listclearnulls(ticker.mode.frost_scions)
	if(!(user.mind in ticker.mode.frost_scions))
		return
	/*
	if(user.dna.species.id != "shadowling")
		if(ticker.mode.thralls.len >= 5)
			user << "<span class='warning'>With your telepathic abilities suppressed, your human form will not allow you to enthrall any others. Hatch first.</span>"
			charge_counter = charge_max
			return
	*/
	for(var/mob/living/carbon/human/target in targets)
		if(!in_range(usr, target))
			user << "<span class='warning'>You need to be closer to turn [target].</span>"
			charge_counter = charge_max
			return
		if(!target.key || !target.mind)
			user << "<span class='warning'>The target has no mind.</span>"
			charge_counter = charge_max
			return
		if(target.stat)
			user << "<span class='warning'>The target must be conscious.</span>"
			charge_counter = charge_max
			return
		if(is_frosty(target))
			user << "<span class='warning'>You can not turn allies.</span>"
			charge_counter = charge_max
			return
		if(!ishuman(target))
			user << "<span class='warning'>You can only turn humans.</span>"
			charge_counter = charge_max
			return
		if(turning)
			user << "<span class='warning'>You are already turning someone!</span>"
			charge_counter = charge_max
			return
		if(!target.client)
			user << "<span class='warning'>[target]'s mind is vacant of activity.</span>"
			return
		turning = 1
		user << "<span class='danger'>This target is valid. You begin the turning.</span>"
		target << "<span class='userdanger'>[user] places \his hand on your chest. You begin to feel cooler.</span>"
		//TODO: rewrite text to match flavor
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					user << "<span class='notice'>You begin preparing yourself for the turning.</span>"
					user.visible_message("<span class='warning'>Tendrils of frost begin running up [user]'s arm.</span>")
				if(2)
					user << "<span class='notice'>You begin the turning of [target].</span>"
					user.visible_message("<span class='danger'>[user] leans over [target], their eyes glowing a deep crimson, and stares into their face.</span>")
					target << "<span class='boldannounce'>Your whole body begins to feel cold, radiating from your chest. You fall to the floor as your heart begins to slow.</span>"
					target.Weaken(12)
					sleep(20)
					if(isloyal(target))
						user << "<span class='notice'>They are enslaved by Nanotrasen. You begin to freeze the nanobot implant - this will take some time.</span>"
						user.visible_message("<span class='danger'>[user] halts for a moment, then begins passing its hand over [target]'s body.</span>")
						target << "<span class='boldannounce'>You feel your loyalties begin to weaken!</span>"
						sleep(150) //15 seconds - not spawn() so the turning takes longer
						user << "<span class='notice'>The nanobots composing the loyalty implant have been frozen solid. Now to continue.</span>"
						user.visible_message("<span class='danger'>[user] halts their hand and places it back on [target]'s chest.</span>")
						for(var/obj/item/weapon/implant/loyalty/L in target)
							if(L && L.implanted)
								qdel(L)
								target << "<span class='boldannounce'>Your unwavering loyalty to Nanotrasen unexpectedly falters, dims, dies.</span>"
				if(3)
					user << "<span class='notice'>[target]'s internal temperature is minimal. You begin freezing each of [target]'s cells.</span>"
					user.visible_message("<span class='danger'>[user]'s eyes turn completely white.</span>")
					target << "<span class='boldannounce'>Your entire body is numb. You feel nothing but [user]'s hand on your chest, even colder than you.</span>"
			if(!do_mob(user, target, 100)) //around 30 seconds total for turning, 45 for someone with a loyalty implant
				user << "<span class='warning'>The turning has been interrupted - [target] is once again heating \himself internally.</span>"
				target << "<span class='userdanger'>You suddenly feel your heratbeat speeding up as you start to warm yourself again.</span>"
				turning = 0
				return 0

		turning = 0
		usr << "<span class='notice'>You have turned <b>[target]</b>!</span>"
		target.visible_message("<span class='big'>[target] looks to have been frozen solid!</span>", \
							   "<span class='warning'>Your heart stops.</b></span>")
		target.setOxyLoss(0) //In case the scion was choking them out
		ticker.mode.make_pawn(target.mind)
		target.mind.special_role = "FrostPawn"
		return 1

/obj/effect/proc_holder/spell/targeted/scion_transform
