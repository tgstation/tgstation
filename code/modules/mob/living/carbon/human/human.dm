/mob/living/carbon/human/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if (!dna)
		dna = new /datum/dna( null )
	spawn (1)
		var/datum/organ/external/chest/chest = new /datum/organ/external/chest( src )
		chest.owner = src
		var/datum/organ/external/groin/groin = new /datum/organ/external/groin( src )
		groin.owner = src
		var/datum/organ/external/head/head = new /datum/organ/external/head( src )
		head.owner = src
		var/datum/organ/external/l_arm/l_arm = new /datum/organ/external/l_arm( src )
		l_arm.owner = src
		var/datum/organ/external/r_arm/r_arm = new /datum/organ/external/r_arm( src )
		r_arm.owner = src
		var/datum/organ/external/l_hand/l_hand = new /datum/organ/external/l_hand( src )
		l_hand.owner = src
		var/datum/organ/external/r_hand/r_hand = new /datum/organ/external/r_hand( src )
		r_hand.owner = src
		var/datum/organ/external/l_leg/l_leg = new /datum/organ/external/l_leg( src )
		l_leg.owner = src
		var/datum/organ/external/r_leg/r_leg = new /datum/organ/external/r_leg( src )
		r_leg.owner = src
		var/datum/organ/external/l_foot/l_foot = new /datum/organ/external/l_foot( src )
		l_foot.owner = src
		var/datum/organ/external/r_foot/r_foot = new /datum/organ/external/r_foot( src )
		r_foot.owner = src

		src.organs["chest"] = chest
		src.organs["groin"] = groin
		src.organs["head"] = head
		src.organs["l_arm"] = l_arm
		src.organs["r_arm"] = r_arm
		src.organs["l_hand"] = l_hand
		src.organs["r_hand"] = r_hand
		src.organs["l_leg"] = l_leg
		src.organs["r_leg"] = r_leg
		src.organs["l_foot"] = l_foot
		src.organs["r_foot"] = r_foot

		var/g = "m"
		if (src.gender == MALE)
			g = "m"
		else if (src.gender == FEMALE)
			g = "f"
		else
			src.gender = MALE
			g = "m"

		if(!src.stand_icon)
			src.stand_icon = new /icon('human.dmi', "body_[g]_s")
		if(!src.lying_icon)
			src.lying_icon = new /icon('human.dmi', "body_[g]_l")
		src.icon = src.stand_icon

		src << "\blue Your icons have been generated!"



		update_clothing()

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || src.now_pushing))
		return
	src.now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM
		if(tmob.a_intent == "help" && src.a_intent == "help" && tmob.canmove && src.canmove) // mutual brohugs all around!
			var/turf/oldloc = src.loc
			src.loc = tmob.loc
			tmob.loc = oldloc
			src.now_pushing = 0
			return
		if(istype(src.equipped(), /obj/item/weapon/baton)) // add any other item paths you think are necessary
			if(src.loc:sd_lumcount < 3 || src.blinded)
				var/obj/item/weapon/W = src.equipped()
				if (world.time > src.lastDblClick+2)
					src.lastDblClick = world.time
					if((prob(40)) || (prob(95) && src.mutations & 16))
						src << "\red You accidentally stun yourself with the [W.name]."
						src.weakened = max(12, src.weakened)
					else
						for(var/mob/M in viewers(src, null))
							if(M.client)
								M << "\red <B>[src] accidentally bumps into [tmob] with the [W.name]."
						tmob.weakened = max(4, tmob.weakened)
						tmob.stunned = max(4, tmob.stunned)
					playsound(src.loc, 'Egloves.ogg', 50, 1, -1)
					W:charges--
					return
		if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
			if(prob(40) && !(src.mutations & 32))
				for(var/mob/M in viewers(src, null))
					if(M.client)
						M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
				src.now_pushing = 0
				return
	src.now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			src.now_pushing = null
		return
	return

/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(src.reagents.has_reagent("hyperzine")) return -1

	var/health_deficiency = (100 - src.health)
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	if(src.wear_suit)
		switch(src.wear_suit.type)
			if(/obj/item/clothing/suit/straight_jacket)
				tally += 15
			if(/obj/item/clothing/suit/fire)	//	firesuits slow you down a bit
				tally += 1.3
			if(/obj/item/clothing/suit/fire/heavy)	//	firesuits slow you down a bit
				tally += 1.7
			if(/obj/item/clothing/suit/space)
				if(!istype(src.loc, /turf/space))		//	space suits slow you down a bit unless in space
					tally += 3

	if (istype(src.shoes, /obj/item/clothing/shoes))
		if (src.shoes.chained)
			tally += 15
		else
			tally += -1.0
	if(src.mutations & 32)
		tally += 1.5
	if (src.bodytemperature < 283.222)
		tally += (283.222 - src.bodytemperature) / 10 * 1.75

	return tally

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [src.a_intent]")
	stat(null, "Move Mode: [src.m_intent]")
//	if(ticker.mode.name == "AI malfunction")
//		if(ticker.mode:malf_mode_declared)
//			stat(null, "Time left: [ ticker.mode:AI_win_timeleft]")
	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (src.client.statpanel == "Status")
		if (src.internal)
			if (!src.internal.air_contents)
				del(src.internal)
			else
				stat("Internal Atmosphere Info", src.internal.name)
				stat("Tank Pressure", src.internal.air_contents.return_pressure())
				stat("Distribution Pressure", src.internal.distribute_pressure)


/mob/living/carbon/human/bullet_act(flag, A as obj)
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"
	if ((shielded && flag != "bullet"))
		if (!flag)
			src << "\blue Your shield was disturbed by a laser!"
			if(src.paralysis <= 120)	src.paralysis = 120
			src.updatehealth()
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(src.l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = src.l_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (istype(src.r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = src.r_hand
			if ((G.state == 3 && get_dir(src, A) == src.dir))
				safe = G.affecting
		if (safe)
			return safe.bullet_act(flag, A)
	if (flag == PROJECTILE_BULLET)
		var/d = 51
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
			if (prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
		else
			if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(90))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (istype(src.r_hand, /obj/item/weapon/shield/riot))
			if (prob(90))
				show_message("\red Your shield absorbs the blow!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your shield only softens the blow!", 4)
					if (prob(60))
						d = d / 2
					d = d / 5
		else
			if (istype(src.l_hand, /obj/item/weapon/shield/riot))
				if (prob(90))
					show_message("\red Your shield absorbs the blow!", 4)
					return
				else
					if (prob(40))
						show_message("\red Your shield only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (src.stat != 2)
			var/organ = src.organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				temp.take_damage(d, 0)
			src.UpdateDamageIcon()
			src.updatehealth()
			if (prob(50))
				if(src.weakened <= 5)	src.weakened = 5
		return
	else if (flag == PROJECTILE_TASER)
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
			if (prob(5))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		else
			if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the hit!", 4)
					return
		if (prob(75) && src.stunned <= 10)
			src.stunned = 10
		else
			src.weakened = 10
		if (src.stuttering < 10)
			src.stuttering = 10
	else if(flag == PROJECTILE_LASER)
		var/d = 20
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
			if (prob(40))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 2

		if (!src.eye_blurry) src.eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
		if (prob(25)) src.stunned++

		if (src.stat != 2)
			var/organ = src.organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				temp.take_damage(d, 0)
			src.UpdateDamageIcon()
			src.updatehealth()
			if (prob(25))
				src.stunned = 1
	else if(flag == PROJECTILE_PULSE)
		var/d = 40
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
			if (prob(20))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(20))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(50))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(50))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(50))
							d = d / 2
						d = d / 2
		if (src.stat != 2)
			var/organ = src.organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				temp.take_damage(d, 0)
			src.UpdateDamageIcon()
			src.updatehealth()
			if (prob(50))
				src.stunned = min(src.stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		src.toxloss += 3
		src.radiation += 100
		src.updatehealth()
		src.stuttering += 5
		src.drowsyness += 5
	else if(flag == PROJECTILE_WEAKBULLET)
		var/d = 14
		if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
			if (prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
		else
			if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(90))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (istype(src.r_hand, /obj/item/weapon/shield/riot))
			if (prob(90))
				show_message("\red Your shield absorbs the blow!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your shield only softens the blow!", 4)
					if (prob(60))
						d = d / 2
					d = d / 5
		else
			if (istype(src.l_hand, /obj/item/weapon/shield/riot))
				if (prob(90))
					show_message("\red Your shield absorbs the blow!", 4)
					return
				else
					if (prob(40))
						show_message("\red Your shield only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (src.stat != 2)
			var/organ = src.organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				temp.take_damage(d, 0)
			src.UpdateDamageIcon()
			src.updatehealth()
			if(src.weakened <= 5)	src.weakened = 5
		return
	return

/mob/living/carbon/human/ex_act(severity)
	flick("flash", src.flash)

	if (src.stat == 2 && src.client)
		src.gib(1)
		return

	else if (src.stat == 2 && !src.client)
		var/virus = src.virus
		gibs(src.loc, virus)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			src.gib(1)
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!istype(src.ears, /obj/item/clothing/ears/earmuffs))
				src.ear_damage += 30
				src.ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				src.paralysis += 10
			if (!istype(src.ears, /obj/item/clothing/ears/earmuffs))
				src.ear_damage += 15
				src.ear_deaf += 60

	for(var/organ in src.organs)
		var/datum/organ/external/temp = src.organs[text("[]", organ)]
		if (istype(temp, /datum/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, f_loss * 0.2)
				if("chest")
					temp.take_damage(b_loss * 0.4, f_loss * 0.4)
				if("groin")
					temp.take_damage(b_loss * 0.1, f_loss * 0.1)
				if("l_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("l_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)

	src.UpdateDamageIcon()

/mob/living/carbon/human/blob_act()
	if (src.stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (src.stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

		//src.paralysis += 1

	src.show_message("\red The blob attacks you!")

	var/list/zones = list("head","chest","chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")

	var/zone = pick(zones)

	var/datum/organ/external/temp = src.organs["[zone]"]

	switch(zone)
		if ("head")
			if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					src.show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (src.weakened < 10)
					src.weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The blob has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("chest")
			if ((((src.wear_suit && src.wear_suit.body_parts_covered & UPPER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & UPPER_TORSO)) && prob(85)))
				src.show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (src.weakened < 5)
						src.weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The blob has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (src.stunned < 5)
						src.stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The blob has stunned []!</B>", src), 1)
				if(src.stat != 2)	src.stat = 1
			temp.take_damage(damage)
		if ("groin")
			if ((((src.wear_suit && src.wear_suit.body_parts_covered & LOWER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
				src.show_message("\red You have been protected from a hit to the lower chest.")
				return
			else
				temp.take_damage(damage, 0)


		if("l_arm")
			temp.take_damage(damage, 0)
		if("r_arm")
			temp.take_damage(damage, 0)
		if("l_hand")
			temp.take_damage(damage, 0)
		if("r_hand")
			temp.take_damage(damage, 0)
		if("l_leg")
			temp.take_damage(damage, 0)
		if("r_leg")
			temp.take_damage(damage, 0)
		if("l_foot")
			temp.take_damage(damage, 0)
		if("r_foot")
			temp.take_damage(damage, 0)

	src.UpdateDamageIcon()
	return

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == src.wear_suit)
		src.wear_suit = null
	else if (W == src.w_uniform)
		W = src.r_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.l_store
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.wear_id
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = src.belt
		if (W)
			u_equip(W)
			if (src.client)
				src.client.screen -= W
			if (W)
				W.loc = src.loc
				W.dropped(src)
				W.layer = initial(W.layer)
		src.w_uniform = null
	else if (W == src.gloves)
		src.gloves = null
	else if (W == src.glasses)
		src.glasses = null
	else if (W == src.head)
		src.head = null
	else if (W == src.ears)
		src.ears = null
	else if (W == src.shoes)
		src.shoes = null
	else if (W == src.belt)
		src.belt = null
	else if (W == src.wear_mask)
		if(internal)
			if (src.internals)
				src.internals.icon_state = "internal0"
			internal = null
		src.wear_mask = null
	else if (W == src.wear_id)
		src.wear_id = null
	else if (W == src.r_store)
		src.r_store = null
	else if (W == src.l_store)
		src.l_store = null
	else if (W == src.back)
		src.back = null
	else if (W == src.handcuffed)
		src.handcuffed = null
	else if (W == src.r_hand)
		src.r_hand = null
	else if (W == src.l_hand)
		src.l_hand = null

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = src.equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("mask")
			if (src.wear_mask)
				if (emptyHand)
					src.wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			src.u_equip(W)
			src.wear_mask = W
			W.equipped(src, text)
		if("back")
			if (src.back)
				if (emptyHand)
					src.back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.flags & ONBACK ))
				return
			src.u_equip(W)
			src.back = W
			W.equipped(src, text)

/*		if("headset")
			if (src.ears)
				if (emptyHand)
					src.ears.DblClick()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			src.u_equip(W)
			src.w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (src.wear_suit)
				if (emptyHand)
					src.wear_suit.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			if (src.mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			src.u_equip(W)
			src.wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (src.gloves)
				if (emptyHand)
					src.gloves.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/gloves) ))
				return
			src.u_equip(W)
			src.gloves = W
			W.equipped(src, text)
		if("shoes")
			if (src.shoes)
				if (emptyHand)
					src.shoes.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/shoes) ))
				return
			src.u_equip(W)
			src.shoes = W
			W.equipped(src, text)
		if("belt")
			if (src.belt)
				if (emptyHand)
					src.belt.DblClick()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			src.u_equip(W)
			src.belt = W
			W.equipped(src, text)
		if("eyes")
			if (src.glasses)
				if (emptyHand)
					src.glasses.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/glasses) ))
				return
			src.u_equip(W)
			src.glasses = W
			W.equipped(src, text)
		if("head")
			if (src.head)
				if (emptyHand)
					src.head.DblClick()
				return
			if (( istype(W, /obj/item/weapon/paper) ))
				src.u_equip(W)
				src.head = W
			else if (!( istype(W, /obj/item/clothing/head) ))
				return
			src.u_equip(W)
			src.head = W
			W.equipped(src, text)
		if("ears")
			if (src.ears)
				if (emptyHand)
					src.ears.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ))
				return
			src.u_equip(W)
			src.ears = W
			W.equipped(src, text)
		if("i_clothing")
			if (src.w_uniform)
				if (emptyHand)
					src.w_uniform.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/under) ))
				return
			if (src.mutations & 32 && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			src.u_equip(W)
			src.w_uniform = W
			W.equipped(src, text)
		if("id")
			if (src.wear_id)
				if (emptyHand)
					src.wear_id.DblClick()
				return
			if (!src.w_uniform)
				return
			if (!( istype(W, /obj/item/weapon/card/id) ))
				return
			src.u_equip(W)
			src.wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (src.l_store)
				if (emptyHand)
					src.l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.l_store = W
		if("storage2")
			if (src.r_store)
				if (emptyHand)
					src.r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( src.w_uniform )))
				return
			src.u_equip(W)
			src.r_store = W

	update_clothing()

	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		var/dam_zone = pick("chest", "chest", "chest", "head", "groin")
		if (istype(src.organs[dam_zone], /datum/organ/external))
			var/datum/organ/external/temp = src.organs[dam_zone]
			temp.take_damage((istype(O, /obj/meteor/small) ? 10 : 25), 30)
			src.UpdateDamageIcon()
		src.updatehealth()
	return

/mob/living/carbon/human/Move(a, b, flag)

	if (src.buckled)
		return

	if (src.restrained())
		src.pulling = null

	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (src.pulling && ((get_dist(src, src.pulling) <= 1 || src.pulling.loc == src.loc) && (src.client && src.client.moving)))))
		var/turf/T = src.loc
		. = ..()

		if (src.pulling && src.pulling.loc)
			if(!( isturf(src.pulling.loc) ))
				src.pulling = null
				return
			else
				if(Debug)
					diary <<"src.pulling disappeared? at [__LINE__] in mob.dm - src.pulling = [src.pulling]"
					diary <<"REPORT THIS"

		/////
		if(src.pulling && src.pulling.anchored)
			src.pulling = null
			return

		if (!src.restrained())
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, src.pulling) > 1 || diag))
				if (ismob(src.pulling))
					var/mob/M = src.pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null

						//this is the gay blood on floor shit -- Added back -- Skie
						if (M.lying && (prob(M.bruteloss / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood(M)


						step(src.pulling, get_dir(src.pulling.loc, T))
						M.pulling = t
				else
					if (src.pulling)
						step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/living/carbon/human/update_clothing()
	..()

	if (src.monkeyizing)
		return

	src.overlays = null

	// lol
	var/fat = ""
	if (src.mutations & 32)
		fat = "fat"

	if (src.mutations & 8)
		src.overlays += image("icon" = 'genetics.dmi', "icon_state" = "hulk[fat][!src.lying ? "_s" : "_l"]")

	if (src.mutations & 2)
		src.overlays += image("icon" = 'genetics.dmi', "icon_state" = "fire[fat][!src.lying ? "_s" : "_l"]")

	if (src.mutations & 1)
		src.overlays += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead[fat][!src.lying ? "_s" : "_l"]")

	if (src.mutantrace)
		src.overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat][!src.lying ? "_s" : "_l"]")
		if(src.face_standing)
			del(src.face_standing)
		if(src.face_lying)
			del(src.face_lying)
		if(src.stand_icon)
			del(src.stand_icon)
		if(src.lying_icon)
			del(src.lying_icon)
	else
		if(!src.face_standing || !src.face_lying)
			src.update_face()
		if(!src.stand_icon || !src.lying_icon)
			src.update_body()

	if(src.buckled)
		if(istype(src.buckled, /obj/stool/bed))
			src.lying = 1
		else
			src.lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!src.w_uniform)
		for (var/obj/item/thing in list(src.r_store, src.l_store, src.wear_id, src.belt))
			if (thing)
				u_equip(thing)
				if (src.client)
					src.client.screen -= thing

				if (thing)
					thing.loc = src.loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)


	//if (src.zone_sel)
	//	src.zone_sel.overlays = null
	//	src.zone_sel.overlays += src.body_standing
	//	src.zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", src.zone_sel.selecting))

	if (src.lying)
		src.icon = src.lying_icon

		src.overlays += src.body_lying

		if (src.face_lying)
			src.overlays += src.face_lying
	else
		src.icon = src.stand_icon

		src.overlays += src.body_standing

		if (src.face_standing)
			src.overlays += src.face_standing

	// Uniform
	if (src.w_uniform)
		if (src.mutations & 32 && !(src.w_uniform.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [src.w_uniform.name]!"
			var/obj/item/clothing/c = src.w_uniform
			src.u_equip(c)
			if(src.client)
				src.client.screen -= c
			if(c)
				c:loc = src.loc
				c:dropped(src)
				c:layer = initial(c:layer)
		src.w_uniform.screen_loc = ui_iclothing
		if (istype(src.w_uniform, /obj/item/clothing/under))
			var/t1 = src.w_uniform.color
			if (!t1)
				t1 = src.icon_state
			if (src.mutations & 32)
				src.overlays += image("icon" = 'uniform_fat.dmi', "icon_state" = "[t1][!src.lying ? "_s" : "_l"]", "layer" = MOB_LAYER)
			else
				src.overlays += image("icon" = 'uniform.dmi', "icon_state" = text("[][]",t1, (!(src.lying) ? "_s" : "_l")), "layer" = MOB_LAYER)
			if (src.w_uniform.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "uniformblood[!src.lying ? "" : "2"]")
				src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (src.wear_id)
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = "id[!src.lying ? null : "2"]", "layer" = MOB_LAYER)

	if (src.client)
		src.client.screen -= src.hud_used.intents
		src.client.screen -= src.hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	if (src.gloves)
		var/t1 = src.gloves.item_state
		if (!t1)
			t1 = src.gloves.icon_state
		src.overlays += image("icon" = 'hands.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.gloves.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!src.lying ? "" : "2"]")
			src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	else if (src.blood_DNA)
		var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!src.lying ? "" : "2"]")
		src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	// Glasses
	if (src.glasses)
		var/t1 = src.glasses.icon_state
		src.overlays += image("icon" = 'eyes.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Ears
	if (src.ears)
		var/t1 = src.ears.icon_state
		src.overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Shoes
	if (src.shoes)
		var/t1 = src.shoes.icon_state
		src.overlays += image("icon" = 'feet.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.shoes.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "shoesblood[!src.lying ? "" : "2"]")
			src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)	// Radio
/*	if (src.w_radio)
		src.overlays += image("icon" = 'ears.dmi', "icon_state" = "headset[!src.lying ? "" : "2"]", "layer" = MOB_LAYER) */

	if(src.client) src.hud_used.other_update() //Update the screenloc of the items on the 'other' inventory bar
											   //to hide / show them.

	if (src.wear_mask)
		if (istype(src.wear_mask, /obj/item/clothing/mask))
			var/t1 = src.wear_mask.icon_state
			src.overlays += image("icon" = 'mask.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
				if (src.wear_mask.blood_DNA)
					var/icon/stain_icon = icon('blood.dmi', "maskblood[!src.lying ? "" : "2"]")
					src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			src.wear_mask.screen_loc = ui_mask


	if (src.client)
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.intents

				var/list/L = dd_text2list(src.intent, ",")
				L[1] += ":-11"
				src.i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int

				var/list/L = dd_text2list(src.m_int, ",")
				L[1] += ":-11"
				src.m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				src.m_select.screen_loc = null


	if (src.wear_suit)
		if (src.mutations & 32 && !(src.wear_suit.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [src.wear_suit.name]!"
			var/obj/item/clothing/c = src.wear_suit
			src.u_equip(c)
			if(src.client)
				src.client.screen -= c
			if(c)
				c:loc = src.loc
				c:dropped(src)
				c:layer = initial(c:layer)
		if (istype(src.wear_suit, /obj/item/clothing/suit))
			var/t1 = src.wear_suit.icon_state
			src.overlays += image("icon" = 'suit.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.wear_suit)
			if (src.wear_suit.blood_DNA)
				var/icon/stain_icon = null
				if (istype(src.wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/wcoat || /obj/item/clothing/suit/armor/a_i_a_ptank))
					stain_icon = icon('blood.dmi', "armorblood[!src.lying ? "" : "2"]")
				else if (istype(src.wear_suit, /obj/item/clothing/suit/det_suit || /obj/item/clothing/suit/labcoat))
					stain_icon = icon('blood.dmi', "coatblood[!src.lying ? "" : "2"]")
				else
					stain_icon = icon('blood.dmi', "suitblood[!src.lying ? "" : "2"]")
				src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			src.wear_suit.screen_loc = ui_oclothing
		if (istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (src.handcuffed)
				src.handcuffed.loc = src.loc
				src.handcuffed.layer = initial(src.handcuffed.layer)
				src.handcuffed = null
			if ((src.l_hand || src.r_hand))
				var/h = src.hand
				src.hand = 1
				drop_item()
				src.hand = 0
				drop_item()
				src.hand = h

	// Head
	if (src.head)
		var/t1 = src.head.icon_state
		var/icon/head_icon = icon('head.dmi', text("[][]", t1, (!( src.lying ) ? null : "2")))
		src.overlays += image("icon" = head_icon, "layer" = MOB_LAYER)
		if (src.head.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "helmetblood[!src.lying ? "" : "2"]")
			src.overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		src.head.screen_loc = ui_head

	// Belt
	if (src.belt)
		var/t1 = src.belt.item_state
		if (!t1)
			t1 = src.belt.icon_state
		src.overlays += image("icon" = 'belt.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.belt.screen_loc = ui_belt

	if ((src.wear_mask && !(src.wear_mask.see_face)) || (src.head && !(src.head.see_face))) // can't see the face
		if (src.wear_id && src.wear_id.registered)
			src.name = src.wear_id.registered
		else
			src.name = "Unknown"
	else
		if (src.wear_id && src.wear_id.registered != src.real_name)
			src.name = "[src.real_name] (as [src.wear_id.registered])"
		else
			src.name = src.real_name

	if (src.wear_id)
		src.wear_id.screen_loc = ui_id

	if (src.l_store)
		src.l_store.screen_loc = ui_storage1

	if (src.r_store)
		src.r_store.screen_loc = ui_storage2

	if (src.back)
		var/t1 = src.back.icon_state
		src.overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		src.back.screen_loc = ui_back

	if (src.handcuffed)
		src.pulling = null
		if (!src.lying)
			src.overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff1", "layer" = MOB_LAYER)
		else
			src.overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff2", "layer" = MOB_LAYER)

	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents

	if (src.r_hand)
		src.overlays += image("icon" = 'items_righthand.dmi', "icon_state" = src.r_hand.item_state ? src.r_hand.item_state : src.r_hand.icon_state, "layer" = MOB_LAYER+1)

		src.r_hand.screen_loc = ui_rhand

	if (src.l_hand)
		src.overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = src.l_hand.item_state ? src.l_hand.item_state : src.l_hand.icon_state, "layer" = MOB_LAYER+1)

		src.l_hand.screen_loc = ui_lhand



	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if (shielded == 2)
		src.invisibility = 2
	else
		src.invisibility = 0

	if (shielded)
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				src.show_inv(M)
				return

	src.last_b_state = src.stat

/mob/living/carbon/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(src.organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
				if(istype(M.virus, /datum/disease/jungle_fever))
					src.monkeyize()
	return

/mob/living/carbon/human/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		if (src.paralysis >= 3) src.paralysis -= 3
		if (src.stunned >= 3) src.stunned -= 3
		if (src.weakened >= 3) src.weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue [M.name] shakes [] trying to wake him up!", src), 1)
	else
		if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			if (istype(src.wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(src.wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(src.organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = src.organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						src.UpdateDamageIcon()
					else
						src.UpdateDamage()
				src.updatehealth()
				if(istype(M.virus, /datum/disease/jungle_fever))
					src.monkeyize()
	return

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if (M.a_intent == "help")
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue [M] caresses [src] with its sythe like arm."), 1)
	else
		//This will be changed to skin, where we can skin a dead human corpse
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			src.grabbed_by += G
			G.synch()
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt")
				if (src.w_uniform)
					src.w_uniform.add_fingerprint(M)
				var/damage = rand(15, 30) // How much damage aliens do to humans? Increasing -- TLE
				var/datum/organ/external/affecting = src.organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (src.organs[def_zone])
					affecting = src.organs[def_zone]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					playsound(src.loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
					if (def_zone == "head")
						if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								src.show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (src.weakened < 10)
								src.weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((src.wear_suit && src.wear_suit.body_parts_covered & UPPER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								src.show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (src.weakened < 5)
										src.weakened = 5
									playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (src.stunned < 5)
										src.stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(src.stat != 2)	src.stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((src.wear_suit && src.wear_suit.body_parts_covered & LOWER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									src.show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (src.weakened < 3)
											src.weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (src.stunned < 3)
											src.stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(src.stat != 2)	src.stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					src.UpdateDamageIcon()

					src.updatehealth()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M] has lunged at [src] but missed!</B>"), 1)
					return
			else
			//disarm
				if (!( src.lying ))
					if (src.w_uniform)
						src.w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						src.weakened = 2
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has knocked over []!</B>", M, src), 1)
					else
						if (randn <= 60)
							src.drop_item()
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has knocked the item out of []'s hand!</B>", M, src), 1)
						else
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has tried to knock the item out of []'s hand!</B>", M, src), 1)
	return

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (src.weakened < 5)
				src.weakened = 5
			if (src.stuttering < 5)
				src.stuttering = 5
			if (src.stunned < 5)
				src.stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		if (src.health > 0)
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			src.sleeping = 0
			src.resting = 0
			if (src.paralysis >= 3) src.paralysis -= 3
			if (src.stunned >= 3) src.stunned -= 3
			if (src.weakened >= 3) src.weakened -= 3
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((src.head && src.head.flags & 4) || (src.wear_mask && !( src.wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = src.loc
				O.place = "CPR"
				src.requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (src.w_uniform)
				src.w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			src.grabbed_by += G
			G.synch()
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				if (src.w_uniform)
					src.w_uniform.add_fingerprint(M)
				var/damage = rand(1, 9)
				var/datum/organ/external/affecting = src.organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (src.organs[text("[]", def_zone)])
					affecting = src.organs[text("[]", def_zone)]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					if (M.mutations & 8)
						damage += 5
						spawn(0)
							src.paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(src.loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

					if (def_zone == "head")
						if ((((src.head && src.head.body_parts_covered & HEAD) || (src.wear_mask && src.wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								src.show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (src.weakened < 10)
								src.weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((src.wear_suit && src.wear_suit.body_parts_covered & UPPER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								src.show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (src.weakened < 5)
										src.weakened = 5
									playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (src.stunned < 5)
										src.stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(src.stat != 2)	src.stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((src.wear_suit && src.wear_suit.body_parts_covered & LOWER_TORSO) || (src.w_uniform && src.w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									src.show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (src.weakened < 3)
											src.weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (src.stunned < 3)
											src.stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(src.stat != 2)	src.stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					src.UpdateDamageIcon()

					src.updatehealth()
				else
					playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( src.lying ) && !(M.gloves && M.gloves.elecgen == 1))
					if (src.w_uniform)
						src.w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						src.weakened = 2
						playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							src.drop_item()
							playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/mob/living/carbon/human/restrained()
	if (src.handcuffed)
		return 1
	if (istype(src.wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/proc/update_body()
	if(src.stand_icon)
		del(src.stand_icon)
	if(src.lying_icon)
		del(src.lying_icon)

	if (src.mutantrace)
		return

	var/g = "m"
	if (src.gender == MALE)
		g = "m"
	else if (src.gender == FEMALE)
		g = "f"

	src.stand_icon = new /icon('human.dmi', "blank")
	src.lying_icon = new /icon('human.dmi', "blank")

	var/husk = (src.mutations & 64)
	var/obese = (src.mutations & 32)

	if (husk)
		src.stand_icon.Blend(new /icon('human.dmi', "husk_s"), ICON_OVERLAY)
		src.lying_icon.Blend(new /icon('human.dmi', "husk_l"), ICON_OVERLAY)
	else if(obese)
		src.stand_icon.Blend(new /icon('human.dmi', "fatbody_s"), ICON_OVERLAY)
		src.lying_icon.Blend(new /icon('human.dmi', "fatbody_l"), ICON_OVERLAY)
	else
		src.stand_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)
		src.lying_icon.Blend(new /icon('human.dmi', "chest_[g]_l"), ICON_OVERLAY)

		for (var/part in list("head", "arm_left", "arm_right", "hand_left", "hand_right", "leg_left", "leg_right", "foot_left", "foot_right"))
			src.stand_icon.Blend(new /icon('human.dmi', "[part]_s"), ICON_OVERLAY)
			src.lying_icon.Blend(new /icon('human.dmi', "[part]_l"), ICON_OVERLAY)

		src.stand_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
		src.lying_icon.Blend(new /icon('human.dmi', "groin_[g]_l"), ICON_OVERLAY)

	// Skin tone
	if (src.s_tone >= 0)
		src.stand_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), ICON_ADD)
		src.lying_icon.Blend(rgb(src.s_tone, src.s_tone, src.s_tone), ICON_ADD)
	else
		src.stand_icon.Blend(rgb(-src.s_tone,  -src.s_tone,  -src.s_tone), ICON_SUBTRACT)
		src.lying_icon.Blend(rgb(-src.s_tone,  -src.s_tone,  -src.s_tone), ICON_SUBTRACT)

	if (src.underwear > 0)
		if(!obese)
			src.stand_icon.Blend(new /icon('human.dmi', "underwear[src.underwear]_[g]_s"), ICON_OVERLAY)
			src.lying_icon.Blend(new /icon('human.dmi', "underwear[src.underwear]_[g]_l"), ICON_OVERLAY)

/mob/living/carbon/human/proc/update_face()
	del(src.face_standing)
	del(src.face_lying)

	if (src.mutantrace)
		return

	var/g = "m"
	if (src.gender == MALE)
		g = "m"
	else if (src.gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(src.r_eyes, src.g_eyes, src.b_eyes), ICON_ADD)

	var/icon/hair_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[src.hair_icon_state]_s")
	var/icon/hair_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[src.hair_icon_state]_l")
	hair_s.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)
	hair_l.Blend(rgb(src.r_hair, src.g_hair, src.b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[src.face_icon_state]_s")
	var/icon/facial_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[src.face_icon_state]_l")
	facial_s.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)
	facial_l.Blend(rgb(src.r_facial, src.g_facial, src.b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_l")

	eyes_s.Blend(hair_s, ICON_OVERLAY)
	eyes_l.Blend(hair_l, ICON_OVERLAY)
	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)
	eyes_s.Blend(facial_s, ICON_OVERLAY)
	eyes_l.Blend(facial_l, ICON_OVERLAY)

	src.face_standing = new /image()
	src.face_lying = new /image()
	src.face_standing.icon = eyes_s
	src.face_lying.icon = eyes_l

	del(mouth_l)
	del(mouth_s)
	del(facial_l)
	del(facial_s)
	del(hair_l)
	del(hair_s)
	del(eyes_l)
	del(eyes_s)

/mob/living/carbon/human/var/co2overloadtime = null
/mob/living/carbon/human/var/temperature_resistance = T0C+75

/obj/equip_e/human/process()
	if (src.item)
		src.item.add_fingerprint(src.source)
	if (!src.item)
		switch(src.place)
			if("mask")
				if (!( src.target.wear_mask ))
					//SN src = null
					del(src)
					return
/*			if("headset")
				if (!( src.target.w_radio ))
					//SN src = null
					del(src)
					return */
			if("l_hand")
				if (!( src.target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( src.target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( src.target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( src.target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( src.target.back ))
					//SN src = null
					del(src)
					return
			if("syringe")
				return
			if("pill")
				return
			if("fuel")
				return
			if("drink")
				return
			if("dnainjector")
				return
			if("handcuff")
				if (!( src.target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( src.target.wear_id ) || !( src.target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(src.target.wear_mask, /obj/item/clothing/mask) && istype(src.target.back, /obj/item/weapon/tank) && !( src.target.internal )) ) && !( src.target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((src.item && !( L.Find(src.place) )))
		for(var/mob/O in viewers(src.target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", src.source, src.item, src.target), 1)
	else
		if (src.place == "syringe")
			for(var/mob/O in viewers(src.target, null))
				O.show_message(text("\red <B>[] is trying to inject []!</B>", src.source, src.target), 1)
		else
			if (src.place == "pill")
				for(var/mob/O in viewers(src.target, null))
					O.show_message(text("\red <B>[] is trying to force [] to swallow []!</B>", src.source, src.target, src.item), 1)
			else
				if(src.place == "fuel")
					for(var/mob/O in viewers(src.target, null))
						O.show_message(text("\red [src.source] is trying to force [src.target] to eat the [src.item:content]!"), 1)
				else
					if (src.place == "drink")
						for(var/mob/O in viewers(src.target, null))
							O.show_message(text("\red <B>[] is trying to force [] to swallow a gulp of []!</B>", src.source, src.target, src.item), 1)
					else
						if (src.place == "dnainjector")
							for(var/mob/O in viewers(src.target, null))
								O.show_message(text("\red <B>[] is trying to inject [] with the []!</B>", src.source, src.target, src.item), 1)
						else
							var/message = null
							switch(src.place)
								if("mask")
									message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", src.source, src.target.wear_mask, src.target)
/*								if("headset")
									message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", src.source, src.target.w_radio, src.target) */
								if("l_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", src.source, src.target.l_hand, src.target)
								if("r_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", src.source, src.target.r_hand, src.target)
								if("gloves")
									message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", src.source, src.target.gloves, src.target)
								if("eyes")
									message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", src.source, src.target.glasses, src.target)
								if("ears")
									message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", src.source, src.target.ears, src.target)
								if("head")
									message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", src.source, src.target.head, src.target)
								if("shoes")
									message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", src.source, src.target.shoes, src.target)
								if("belt")
									message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", src.source, src.target.belt, src.target)
								if("suit")
									message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", src.source, src.target.wear_suit, src.target)
								if("back")
									message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", src.source, src.target.back, src.target)
								if("handcuff")
									message = text("\red <B>[] is trying to unhandcuff []!</B>", src.source, src.target)
								if("uniform")
									message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", src.source, src.target.w_uniform, src.target)
								if("pockets")
									for(var/obj/item/weapon/mousetrap/MT in  list(src.target.l_store, src.target.r_store))
										if(MT.armed)
											for(var/mob/O in viewers(src.target, null))
												if(O == src.source)
													O.show_message(text("\red <B>You reach into the [src.target]'s pockets, but there was a live mousetrap in there!</B>"), 1)
												else
													O.show_message(text("\red <B>[src.source] reaches into [src.target]'s pockets and sets off a hidden mousetrap!</B>"), 1)
											src.target.u_equip(MT)
											if (src.target.client)
												src.target.client.screen -= MT
											MT.loc = src.source.loc
											MT.triggered(src.source, src.source.hand ? "l_hand" : "r_hand")
											MT.layer = OBJ_LAYER
											return
									message = text("\red <B>[] is trying to empty []'s pockets!!</B>", src.source, src.target)
								if("CPR")
									if (src.target.cpr_time >= world.time + 3)
										//SN src = null
										del(src)
										return
									message = text("\red <B>[] is trying perform CPR on []!</B>", src.source, src.target)
								if("id")
									message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", src.source, src.target.wear_id, src.target)
								if("internal")
									if (src.target.internal)
										message = text("\red <B>[] is trying to remove []'s internals</B>", src.source, src.target)
									else
										message = text("\red <B>[] is trying to set on []'s internals.</B>", src.source, src.target)
								else
							for(var/mob/M in viewers(src.target, null))
								M.show_message(message, 1)
	spawn( 40 )
		src.done()
		return
	return

/obj/equip_e/human/done()
	if(!src.source || !src.target)						return
	if(src.source.loc != src.s_loc)						return
	if(src.target.loc != src.t_loc)						return
	if(LinkBlocked(src.s_loc,src.t_loc))				return
	if(src.item && src.source.equipped() != src.item)	return
	if ((src.source.restrained() || src.source.stat))	return
	switch(src.place)
		if("mask")
			if (src.target.wear_mask)
				var/obj/item/W = src.target.wear_mask
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/mask))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_mask = src.item
					src.item.loc = src.target
/*		if("headset")
			if (src.target.w_radio)
				var/obj/item/W = src.target.w_radio
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
			else
				if (istype(src.item, /obj/item/device/radio/headset))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.w_radio = src.item
					src.item.loc = src.target*/
		if("gloves")
			if (src.target.gloves)
				var/obj/item/W = src.target.gloves
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/gloves))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.gloves = src.item
					src.item.loc = src.target
		if("eyes")
			if (src.target.glasses)
				var/obj/item/W = src.target.glasses
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/glasses))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.glasses = src.item
					src.item.loc = src.target
		if("belt")
			if (src.target.belt)
				var/obj/item/W = src.target.belt
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj) && src.item.flags & 128 && src.target.w_uniform))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.belt = src.item
					src.item.loc = src.target
		if("head")
			if (src.target.head)
				var/obj/item/W = src.target.head
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/head))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.head = src.item
					src.item.loc = src.target
		if("ears")
			if (src.target.ears)
				var/obj/item/W = src.target.ears
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/ears))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.ears = src.item
					src.item.loc = src.target
				else if (istype(src.item, /obj/item/device/radio/headset))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.ears = src.item
					src.item.loc = src.target
		if("shoes")
			if (src.target.shoes)
				var/obj/item/W = src.target.shoes
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/shoes))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.shoes = src.item
					src.item.loc = src.target
		if("l_hand")
			if (istype(src.target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (src.target.l_hand)
				var/obj/item/W = src.target.l_hand
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.l_hand = src.item
					src.item.loc = src.target
					src.item.add_fingerprint(src.target)
		if("r_hand")
			if (istype(src.target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (src.target.r_hand)
				var/obj/item/W = src.target.r_hand
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.r_hand = src.item
					src.item.loc = src.target
					src.item.add_fingerprint(src.target)
		if("uniform")
			if (src.target.w_uniform)
				var/obj/item/W = src.target.w_uniform
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
				W = src.target.l_store
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
				W = src.target.r_store
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
				W = src.target.wear_id
				if (W)
					src.target.u_equip(W)
					if (src.target.client)
						src.target.client.screen -= W
					if (W)
						W.loc = src.target.loc
						W.dropped(src.target)
						W.layer = initial(W.layer)
			else
				if (istype(src.item, /obj/item/clothing/under))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.w_uniform = src.item
					src.item.loc = src.target
		if("suit")
			if (src.target.wear_suit)
				var/obj/item/W = src.target.wear_suit
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/clothing/suit))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_suit = src.item
					src.item.loc = src.target
		if("id")
			if (src.target.wear_id)
				var/obj/item/W = src.target.wear_id
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj/item/weapon/card/id) && src.target.w_uniform))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.wear_id = src.item
					src.item.loc = src.target
		if("back")
			if (src.target.back)
				var/obj/item/W = src.target.back
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if ((istype(src.item, /obj/item) && src.item.flags & 1))
					src.source.drop_item()
					src.loc = src.target
					src.item.layer = 20
					src.target.back = src.item
					src.item.loc = src.target
		if("handcuff")
			if (src.target.handcuffed)
				var/obj/item/W = src.target.handcuffed
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			else
				if (istype(src.item, /obj/item/weapon/handcuffs))
					src.target.drop_from_slot(src.target.r_hand)
					src.target.drop_from_slot(src.target.l_hand)
					src.source.drop_item()
					src.target.handcuffed = src.item
					src.item.loc = src.target
		if("CPR")
			if (src.target.cpr_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			if ((src.target.health >= -75.0 && src.target.health < 0))
				src.target.cpr_time = world.time
				if (src.target.health >= -40.0)
					var/suff = min(src.target.oxyloss, 5)
					src.target.oxyloss -= suff
					src.target.updatehealth()
				if(target.reagents.get_reagent_amount("inaprovaline") < 10)
					target.reagents.add_reagent("inaprovaline", 10)
				for(var/mob/O in viewers(src.source, null))
					O.show_message(text("\red [] performs CPR on []!", src.source, src.target), 1)
				src.source << "\red Repeat every 7 seconds AT LEAST."
		if("fuel")
			var/obj/item/weapon/fuel/S = src.item
			if (!( istype(S, /obj/item/weapon/fuel) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			var/a = S.content
			for(var/mob/O in viewers(src.source, null))
				O.show_message(text("\red [src.source] forced [src.target] to eat the [a]!"), 1)
			S.injest(src.target)
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = src.item
			src.item.add_fingerprint(src.source)
			src.item:inject(src.target, null)
			if (!( istype(S, /obj/item/weapon/dnainjector) ))
				//SN src = null
				del(src)
				return
			if (S.s_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			S.s_time = world.time
			for(var/mob/O in viewers(src.source, null))
				O.show_message(text("\red [] injects [] with the DNA Injector!", src.source, src.target), 1)
		if("pockets")
			if (src.target.l_store)
				var/obj/item/W = src.target.l_store
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
			if (src.target.r_store)
				var/obj/item/W = src.target.r_store
				src.target.u_equip(W)
				if (src.target.client)
					src.target.client.screen -= W
				if (W)
					W.loc = src.target.loc
					W.dropped(src.target)
					W.layer = initial(W.layer)
				W.add_fingerprint(src.source)
		if("internal")
			if (src.target.internal)
				src.target.internal.add_fingerprint(src.source)
				src.target.internal = null
			else
				if (src.target.internal)
					src.target.internal = null
				if (!( istype(src.target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(src.target.back, /obj/item/weapon/tank))
						src.target.internal = src.target.back
						for(var/mob/M in viewers(src.target, 1))
							M.show_message(text("[] is now running on internals.", src.target), 1)
						src.target.internal.add_fingerprint(src.source)
		else
	if(src.source)
		src.source.update_clothing()
	if(src.target)
		src.target.update_clothing()
	//SN src = null
	del(src)
	return

/mob/living/carbon/human/proc/TakeDamage(zone, brute, burn)
	var/datum/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.take_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)

	var/datum/organ/external/E = src.organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			src.UpdateDamageIcon()
		else
			src.UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/UpdateDamage()

	var/list/L = list(  )
	for(var/t in src.organs)
		if (istype(src.organs[text("[]", t)], /datum/organ/external))
			L += src.organs[text("[]", t)]
	src.bruteloss = 0
	src.fireloss = 0
	for(var/datum/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/proc/UpdateDamageIcon()
	var/list/L = list(  )
	for (var/t in src.organs)
		if (istype(src.organs[t], /datum/organ/external))
			L += src.organs[t]

	del(src.body_standing)
	src.body_standing = list()
	del(src.body_lying)
	src.body_lying = list()

	src.bruteloss = 0
	src.fireloss = 0

	for (var/datum/organ/external/O in L)
		src.bruteloss += O.brute_dam
		src.fireloss += O.burn_dam

		var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
		DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels

//		world << "[O.icon_name] [O.damage_state] \icon[DI]"

		body_standing += DI

		DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
		DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)

//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"

		body_lying += DI

		//src.body_standing += new /icon( 'dam_zones.dmi', text("[]", O.d_i_state) )
		//src.body_lying += new /icon( 'dam_zones.dmi', text("[]2", O.d_i_state) )

/mob/living/carbon/human/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[src.name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(src.wear_mask ? src.wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(src.l_hand ? src.l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(src.r_hand ? src.r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(src.gloves ? src.gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(src.glasses ? src.glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(src.ears ? src.ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(src.head ? src.head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(src.shoes ? src.shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(src.belt ? src.belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(src.w_uniform ? src.w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(src.wear_suit ? src.wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(src.back ? src.back : "Nothing")]</A> [((istype(src.wear_mask, /obj/item/clothing/mask) && istype(src.back, /obj/item/weapon/tank) && !( src.internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(src.wear_id ? src.wear_id : "Nothing")]</A>
	<BR>[(src.handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(src.internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[src.name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[src.name];size=340x480"))
	onclose(user, "mob[src.name]")
	return

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)
