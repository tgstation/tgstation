
/mob/living/carbon/human/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if (!dna)
		dna = new /datum/dna( null )

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

	organs["chest"] = chest
	organs["groin"] = groin
	organs["head"] = head
	organs["l_arm"] = l_arm
	organs["r_arm"] = r_arm
	organs["l_hand"] = l_hand
	organs["r_hand"] = r_hand
	organs["l_leg"] = l_leg
	organs["r_leg"] = r_leg
	organs["l_foot"] = l_foot
	organs["r_foot"] = r_foot

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"
	else
		gender = MALE
		g = "m"

	spawn (1)
		if(!stand_icon)
			stand_icon = new /icon('human.dmi', "body_[g]_s")
		if(!lying_icon)
			lying_icon = new /icon('human.dmi', "body_[g]_l")
		icon = stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"

	..()

	organStructure = new /obj/organstructure/human(src)

/mob/living/carbon/human/cyborg
	New()
		..()
		if(organStructure) //hacky, but it's not supposed to be in for a long time anyway
			del(organStructure)
		organStructure = new /obj/organstructure/cyber(src)

/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM
		if(tmob.a_intent == "help" && a_intent == "help" && tmob.canmove && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			for(var/mob/living/carbon/metroid/Metroid in view(1,tmob))
				if(Metroid.Victim == tmob)
					Metroid.UpdateFeed()

			return
		if(istype(equipped(), /obj/item/weapon/melee/baton)) // add any other item paths you think are necessary
			if(loc:sd_lumcount < 3 || blinded)
				var/obj/item/weapon/W = equipped()
				if (world.time > lastDblClick+2)
					lastDblClick = world.time
					if((prob(40)) || (prob(95) && mutations & CLOWN))
						//src << "\red You accidentally stun yourself with the [W.name]."
						visible_message("\red [src] accidentally stun \himself with the [W.name].", \
							"\red You accidentally stun yourself with the [W.name].")
						weakened = max(12, weakened)
					else
						visible_message("\red[src] accidentally bumps into [tmob] with the [W.name].", \
							"\red You accidentally bumps into [tmob] with the [W.name].")
						tmob.weakened = max(4, tmob.weakened)
						tmob.stunned = max(4, tmob.stunned)
					playsound(loc, 'Egloves.ogg', 50, 1, -1)
					W:charges--
					now_pushing = 0
					return
		if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
			if(prob(40) && !(mutations & FAT))
				visible_message("\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>", \
					"\red <B>You fail to push [tmob]'s fat ass out of the way.</B>")
				now_pushing = 0
				return

		tmob.LAssailant = src

	now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1

			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = 0
		return
	return

/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(reagents.has_reagent("hyperzine")) return -1

	if(reagents.has_reagent("nuka_cola")) return -1

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(shoes)
		tally += shoes.slowdown

	if(mutations & FAT)
		tally += 1.5
	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	return tally

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	if(ticker && ticker.mode && ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
	if(emergency_shuttle)
		if(emergency_shuttle.online && emergency_shuttle.location < 2)
			var/timeleft = emergency_shuttle.timeleft()
			if (timeleft)
				stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)
		if (mind)
			if (mind.special_role == "Changeling")
				stat("Chemical Storage", chem_charges)
		if (istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_initialized)
			stat("Energy Charge", round(wear_suit:cell:charge/100))

/mob/living/carbon/human/bullet_act(flag, A as obj, var/datum/organ/external/def_zone)
	var/shielded = 0
	var/list/armor
	//Preparing the var for grabbing the armor information, can't grab the values yet because we don't know what kind of bullet was used. --NEO

	if(prob(50))
		for(var/mob/living/carbon/metroid/M in view(1,src))
			if(M.Victim == src)
				M.bullet_act(flag, A) // the bullet hits them, not src!
				return


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
			if(paralysis <= 120)	paralysis = 120
			updatehealth()

	var/datum/organ/external/affecting
	if(!def_zone)
		var/organ = organs[ran_zone("chest")]
		if (istype(organ, /datum/organ/external))
			affecting = organ
	else
		affecting = organs["[def_zone]"]

	if(!affecting)
		return
	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = r_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (safe)
			return safe.bullet_act(flag, A)


	switch(flag)
		if(PROJECTILE_BULLET)
			armor = getarmor(affecting, "bullet")
			var/d = 51
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"]/2))
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
				/*
			else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(90))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5*/
			if (istype(r_hand, /obj/item/weapon/shield/riot))
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
				if (istype(l_hand, /obj/item/weapon/shield/riot))
					if (prob(90))
						show_message("\red Your shield absorbs the blow!", 4)
						return
					else
						if (prob(40))
							show_message("\red Your shield only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5
			if (stat != 2)
				affecting.take_damage(d, 0)
				UpdateDamageIcon()
				updatehealth()
				if (prob(50))
					if(weakened <= 5)	weakened = 5
			return
		if(PROJECTILE_BULLETBURST)
			armor = getarmor(affecting, "bullet")
			var/d = 18
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"]/2))
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
				/*
			else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(90))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5*/
			if (istype(r_hand, /obj/item/weapon/shield/riot))
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
				if (istype(l_hand, /obj/item/weapon/shield/riot))
					if (prob(90))
						show_message("\red Your shield absorbs the blow!", 4)
						return
					else
						if (prob(40))
							show_message("\red Your shield only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5
			if (stat != 2)
				affecting.take_damage(d, 0)
				UpdateDamageIcon()
				updatehealth()
				if (prob(50))
					if(weakened <= 2)	weakened = 2
			return
		if(PROJECTILE_TASER)
			armor = getarmor(affecting, "taser")
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(70))
						show_message("\red Your armor absorbs the hit!", 4)
						return*/
			if (prob(75) && stunned <= 10)
				stunned = 10
			else
				weakened = 10
			if (stuttering < 10)
				stuttering = 10
		if(PROJECTILE_DART)
			armor = getarmor(affecting, "bio")
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			if (istype(l_hand, /obj/item/weapon/shield/riot)||istype(r_hand, /obj/item/weapon/shield/riot))
				if (prob(50))
					show_message("\red Your shield absorbs the hit!", 4)
			else
				weakened += 5
				toxloss += 10
		if(PROJECTILE_LASER)
			armor = getarmor(affecting, "laser")
			var/d = 20
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"])/2)
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(70))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 2*/

			if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
			if (prob(25)) stunned++

			if (stat != 2)
				affecting.take_damage(0, d)
				UpdateDamageIcon()
				updatehealth()
				if (prob(25))
					stunned = 1
		if(PROJECTILE_SHOCK)
			armor = getarmor(affecting, "laser")
			var/d = 20
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"])/2)
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(70))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 2*/

			if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
			if (prob(25)) stunned++

			if (stat != 2)
				affecting.take_damage(0, d)
				UpdateDamageIcon()
				updatehealth()
				if (prob(25))
					stunned = 10
				else
					weakened = 10
		if(PROJECTILE_PULSE)
			armor = getarmor(affecting, "laser")
			var/d = 40
			if (prob(armor["armor"]/2))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"])/2)
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(50))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(50))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(50))
								d = d / 2
							d = d / 2*/
			if (stat != 2)
				affecting.take_damage(0, d)
				UpdateDamageIcon()
				updatehealth()
				if (prob(50))
					stunned = min(stunned, 5)
		if(PROJECTILE_BOLT)
			armor = getarmor(affecting, "rad")
			if (prob(getarmor(affecting, "bio")))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			toxloss += 3
			radiation += 100
			updatehealth()
			stuttering += 5
			drowsyness += 5
		if(PROJECTILE_WEAKBULLET)
			armor = getarmor(affecting, "bullet")
			var/d = 14
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"]/2))
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(90))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5*/
			if (istype(r_hand, /obj/item/weapon/shield/riot))
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
				if (istype(l_hand, /obj/item/weapon/shield/riot))
					if (prob(90))
						show_message("\red Your shield absorbs the blow!", 4)
						return
					else
						if (prob(40))
							show_message("\red Your shield only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5
			if (stat != 2)
				affecting.take_damage(d, 0)
				UpdateDamageIcon()
				updatehealth()
				if(weakened <= 5)	weakened = 5
			return
		if(PROJECTILE_WEAKBULLETBURST)
			armor = getarmor(affecting, "bullet")
			var/d = 7
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"]/2))
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(90))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5*/
			if (istype(r_hand, /obj/item/weapon/shield/riot))
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
				if (istype(l_hand, /obj/item/weapon/shield/riot))
					if (prob(90))
						show_message("\red Your shield absorbs the blow!", 4)
						return
					else
						if (prob(40))
							show_message("\red Your shield only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5
			if (stat != 2)
				affecting.take_damage(d, 0)
				UpdateDamageIcon()
				updatehealth()
				if(weakened <= 2)	weakened = 2
			return
		if(PROJECTILE_WEAKERBULLETBURST)
			armor = getarmor(affecting, "bullet")
			var/d = 4
			if (prob(armor["armor"]))
				show_message("\red Your [armor["clothes"]] absorbs the hit!", 4)
				return
			else
				if (prob(armor["armor"]/2))
					show_message("\red Your [armor["clothes"]] only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
			/*else
				if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
					if (prob(90))
						show_message("\red Your armor absorbs the blow!", 4)
						return
					else
						if (prob(90))
							show_message("\red Your armor only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5*/
			if (istype(r_hand, /obj/item/weapon/shield/riot))
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
				if (istype(l_hand, /obj/item/weapon/shield/riot))
					if (prob(90))
						show_message("\red Your shield absorbs the blow!", 4)
						return
					else
						if (prob(40))
							show_message("\red Your shield only softens the blow!", 4)
							if (prob(60))
								d = d / 2
							d = d / 5
			if (stat != 2)
				affecting.take_damage(d, 0)
				UpdateDamageIcon()
				updatehealth()
				if(weakened <= 2)	weakened = 2
			return
	return

/mob/living/carbon/human/emp_act(severity)
	if(wear_suit) wear_suit.emp_act(severity)
	if(w_uniform) w_uniform.emp_act(severity)
	if(shoes) shoes.emp_act(severity)
	if(belt) belt.emp_act(severity)
	if(gloves) gloves.emp_act(severity)
	if(glasses) glasses.emp_act(severity)
	if(head) head.emp_act(severity)
	if(ears) ears.emp_act(severity)
	if(wear_id) wear_id.emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	if(s_store) s_store.emp_act(severity)
	if(h_store) h_store.emp_act(severity)
	..()

/mob/living/carbon/human/ex_act(severity)
	flick("flash", flash)

// /obj/item/clothing/suit/bomb_suit( src )
// /obj/item/clothing/head/bomb_hood( src )

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		gibs(loc, viruses)
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
			if (!prob(getarmor(null, "bomb")))
				gib(1)
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)
			//return
//				var/atom/target = get_edge_target_turf(user, get_dir(src, get_step_away(user, src)))
				//user.throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60
			if (prob(50) && !shielded)
				paralysis += 10

	for(var/organ in organs)
		var/datum/organ/external/temp = organs[text("[]", organ)]
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

	UpdateDamageIcon()


/mob/living/carbon/human/blob_act()
	if (stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (stat != 2)
		damage = rand(30,40)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The magma splashes on you!")

	var/list/zones = list("head","chest","chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")

	var/zone = pick(zones)

	var/datum/organ/external/temp = organs["[zone]"]

	switch(zone)
		if ("head")
			if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (weakened < 10)
					weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The magma has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("chest")
			if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & UPPER_TORSO)) && prob(85)))
				show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (weakened < 5)
						weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The magma has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (stunned < 5)
						stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The magma has stunned []!</B>", src), 1)
				if(stat != 2)	stat = 1
			temp.take_damage(damage)
		if ("groin")
			if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
				show_message("\red You have been protected from a hit to the lower chest.")
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

	UpdateDamageIcon()
	return

/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		W = s_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		wear_suit = null
	else if (W == w_uniform)
		W = r_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = l_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = wear_id
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = belt
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		w_uniform = null
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		W = h_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		head = null
	else if (W == ears)
		ears = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_mask)
		if(internal)
			if (internals)
				internals.icon_state = "internal0"
			internal = null
		wear_mask = null
	else if (W == wear_id)
		wear_id = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == s_store)
		s_store = null
	else if (W == h_store)
		h_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

	update_clothing()

/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("mask")
			if (wear_mask)
				if (emptyHand)
					wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if (back)
				if (emptyHand)
					back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.flags & ONBACK ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)

/*		if("headset")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			w_radio = W
			W.equipped(src, text) */
		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			if (mutations & FAT && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (gloves)
				if (emptyHand)
					gloves.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/gloves) ))
				return
			u_equip(W)
			gloves = W
			W.equipped(src, text)
		if("shoes")
			if (shoes)
				if (emptyHand)
					shoes.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/shoes) ))
				return
			u_equip(W)
			shoes = W
			W.equipped(src, text)
		if("belt")
			if (belt)
				if (emptyHand)
					belt.DblClick()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			u_equip(W)
			belt = W
			W.equipped(src, text)
		if("eyes")
			if (glasses)
				if (emptyHand)
					glasses.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/glasses) ))
				return
			u_equip(W)
			glasses = W
			W.equipped(src, text)
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (( istype(W, /obj/item/weapon/paper) ))
				u_equip(W)
				head = W
			else if (!( istype(W, /obj/item/clothing/head) ))
				return
			u_equip(W)
			head = W
			if(istype(W,/obj/item/clothing/head/kitty))
				W.update_icon(src)
			W.equipped(src, text)
		if("ears")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ))
				return
			u_equip(W)
			ears = W
			W.equipped(src, text)
		if("i_clothing")
			if (w_uniform)
				if (emptyHand)
					w_uniform.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/under) ))
				return
			if (mutations & FAT && !(W.flags & ONESIZEFITSALL))
				src << "\red You're too fat to wear the [W.name]!"
				return
			u_equip(W)
			w_uniform = W
			W.equipped(src, text)
		if("id")
			if (wear_id)
				if (emptyHand)
					wear_id.DblClick()
				return
			if (!w_uniform)
				return
			if (!istype(W, /obj/item/weapon/card/id) && !istype(W, /obj/item/device/pda) )
				return
			u_equip(W)
			wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			l_store = W
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			r_store = W
		if("suit storage")
			if (s_store)
				if (emptyHand)
					s_store.DblClick()
				return
			var/confirm
			if (wear_suit)
				if(!wear_suit.allowed)
					usr << "You somehow have a suit with no defined allowed items for suit storage, stop that."
					return
				if (istype(W, /obj/item/device/pda) || istype(W, /obj/item/weapon/pen))
					confirm = 1
				if (is_type_in_list(W, wear_suit.allowed))
					confirm = 1
			if (!confirm) return
			else
				u_equip(W)
				s_store = W

		if("hat storage")
			if (h_store)
				if (emptyHand)
					h_store.DblClick()
				return
			var/confirm
			if (head)
				if (istype(W, /obj/item/weapon/pen))
					confirm = 1
				if (istype(head) && is_type_in_list(W, head.allowed)) // NOTE: head is /obj/item/clothing/head/ and parer hat is not /obj/item/clothing/ and does not have "allowed" --rastaf0
					confirm = 1
			if (!confirm) return
			else
				u_equip(W)
				h_store = W

	update_clothing()

	return

/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/dam_zone = pick("chest", "chest", "chest", "head", "groin")
		if (istype(organs[dam_zone], /datum/organ/external))
			var/datum/organ/external/temp = organs[dam_zone]
			if (istype(O, /obj/immovablerod))
				temp.take_damage(101, 0)
			else
				temp.take_damage((istype(O, /obj/meteor/small) ? 10 : 25), 30)
			UpdateDamageIcon()
		updatehealth()
	return

/mob/living/carbon/human/Move(a, b, flag)

	if (buckled)
		return

	if (restrained())
		pulling = null


	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
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


						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						if (istype(pulling, /obj/window))
							if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
								for(var/obj/window/win in get_step(pulling,get_dir(pulling.loc, T)))
									pulling = null
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	for(var/mob/living/carbon/metroid/M in view(1,src))
		M.UpdateFeed(src)

	return

/mob/living/carbon/human/update_clothing()
	..()

	if (monkeyizing)
		return

	overlays = null

	// lol
	var/fat = ""
	if (mutations & FAT)
		fat = "fat"

	if (mutations & HULK)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "hulk[fat][!lying ? "_s" : "_l"]")

	if (mutations & COLD_RESISTANCE)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "fire[fat][!lying ? "_s" : "_l"]")

	if (mutations & PORTALS)
		overlays += image("icon" = 'genetics.dmi', "icon_state" = "telekinesishead[fat][!lying ? "_s" : "_l"]")

	if (mutantrace)
		switch(mutantrace)
			if("lizard","golem","metroid")
				overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat][!lying ? "_s" : "_l"]")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
			if("plant")
				if(stat != 2) //if not dead, that is
					overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace][fat]_[gender][!lying ? "_s" : "_l"]")
				else
					overlays += image("icon" = 'genetics.dmi', "icon_state" = "[mutantrace]_d")
				if(face_standing)
					del(face_standing)
				if(face_lying)
					del(face_lying)
				if(stand_icon)
					del(stand_icon)
				if(lying_icon)
					del(lying_icon)
	else
		if(!face_standing || !face_lying)
			update_face()
		if(!stand_icon || !lying_icon)
			update_body()

	if(buckled)
		if(istype(buckled, /obj/stool/bed))
			lying = 1
		else
			lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (!w_uniform)
		for (var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			if (thing)
				u_equip(thing)
				if (client)
					client.screen -= thing

				if (thing)
					thing.loc = loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)


	//if (zone_sel)
	//	zone_sel.overlays = null
	//	zone_sel.overlays += body_standing
	//	zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", zone_sel.selecting))

	if (lying)
		icon = lying_icon

		overlays += body_lying

		if (face_lying)
			overlays += face_lying
	else
		icon = stand_icon

		overlays += body_standing

		if (face_standing)
			overlays += face_standing

	// Uniform
	if (w_uniform)
		if (mutations & FAT && !(w_uniform.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [w_uniform.name]!"
			var/obj/item/clothing/c = w_uniform
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)
		w_uniform.screen_loc = ui_iclothing
		if (istype(w_uniform, /obj/item/clothing/under))
			var/t1 = w_uniform.color
			if (!t1)
				t1 = icon_state
			if (mutations & FAT)
				overlays += image("icon" = 'uniform_fat.dmi', "icon_state" = "[t1][!lying ? "_s" : "_l"]", "layer" = MOB_LAYER)
			else
				overlays += image("icon" = 'uniform.dmi', "icon_state" = text("[][]",t1, (!(lying) ? "_s" : "_l")), "layer" = MOB_LAYER)
			if (w_uniform.blood_DNA)
				var/icon/stain_icon = icon('blood.dmi', "uniformblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (wear_id)
		overlays += image("icon" = 'mob.dmi', "icon_state" = "id[!lying ? null : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int


	//Screenlocs for these slots are handled by the huds other_update()
	//because theyre located on the 'other' inventory bar.

	// Gloves
	if (gloves)
		var/t1 = gloves.item_state
		if (!t1)
			t1 = gloves.icon_state
		overlays += image("icon" = 'hands.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (gloves.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	else if (blood_DNA)
		var/icon/stain_icon = icon('blood.dmi', "bloodyhands[!lying ? "" : "2"]")
		overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	// Glasses
	if (glasses)
		var/t1 = glasses.icon_state
		overlays += image("icon" = 'eyes.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Ears
	if (ears)
		var/t1 = ears.icon_state
		overlays += image("icon" = 'ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
	// Shoes
	if (shoes)
		var/t1 = shoes.icon_state
		overlays += image("icon" = 'feet.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (shoes.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "shoesblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)	// Radio
/*	if (w_radio)
		overlays += image("icon" = 'ears.dmi', "icon_state" = "headset[!lying ? "" : "2"]", "layer" = MOB_LAYER) */

	if (s_store)
		var/t1 = s_store.item_state
		if (!t1)
			t1 = s_store.icon_state
		overlays += image("icon" = 'belt_mirror.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		s_store.screen_loc = ui_sstore1

	if (h_store)
		h_store.screen_loc = ui_hstore1

	if(client) hud_used.other_update() //Update the screenloc of the items on the 'other' inventory bar
											   //to hide / show them.

	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			overlays += image("icon" = 'mask.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(wear_mask, /obj/item/clothing/mask/cigarette))
				if (wear_mask.blood_DNA)
					var/icon/stain_icon = icon('blood.dmi', "maskblood[!lying ? "" : "2"]")
					overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_mask.screen_loc = ui_mask


	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null


	if (wear_suit)
		if (mutations & FAT && !(wear_suit.flags & ONESIZEFITSALL))
			src << "\red You burst out of the [wear_suit.name]!"
			var/obj/item/clothing/c = wear_suit
			u_equip(c)
			if(client)
				client.screen -= c
			if(c)
				c:loc = loc
				c:dropped(src)
				c:layer = initial(c:layer)
		if (istype(wear_suit, /obj/item/clothing/suit))
			var/t1 = wear_suit.icon_state
			overlays += image("icon" = 'suit.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (wear_suit)
			if (wear_suit.blood_DNA)
				var/icon/stain_icon = null
				if (istype(wear_suit, /obj/item/clothing/suit/armor/vest || /obj/item/clothing/suit/wcoat || /obj/item/clothing/suit/armor/a_i_a_ptank))
					stain_icon = icon('blood.dmi', "armorblood[!lying ? "" : "2"]")
				else if (istype(wear_suit, /obj/item/clothing/suit/det_suit || /obj/item/clothing/suit/labcoat))
					stain_icon = icon('blood.dmi', "coatblood[!lying ? "" : "2"]")
				else
					stain_icon = icon('blood.dmi', "suitblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
			wear_suit.screen_loc = ui_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h

	// Head
	if (head)
		var/t1 = head.icon_state
		var/icon/head_icon = icon('head.dmi', text("[][]", t1, (!( lying ) ? null : "2")))
		if(istype(head,/obj/item/clothing/head/kitty))
			head_icon = (( lying ) ? head:mob2 : head:mob)
		overlays += image("icon" = head_icon, "layer" = MOB_LAYER)
		if (head.blood_DNA)
			var/icon/stain_icon = icon('blood.dmi', "helmetblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		head.screen_loc = ui_head

	// Belt
	if (belt)
		var/t1 = belt.item_state
		if (!t1)
			t1 = belt.icon_state
		overlays += image("icon" = 'belt.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		belt.screen_loc = ui_belt

	if ((wear_mask && !(wear_mask.see_face)) || (head && !(head.see_face))) // can't see the face
		if (wear_id)
			if (istype(wear_id, /obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/id = wear_id
				if (id.registered)
					name = id.registered
				else
					name = "Unknown"
			else if (istype(wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = wear_id
				if (pda.owner)
					name = pda.owner
				else
					name = "Unknown"
		else
			name = "Unknown"
	else
		if (wear_id)
			if (istype(wear_id, /obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/id = wear_id
				if (id.registered != real_name)
					name = "[real_name] (as [id.registered])"


			else if (istype(wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = wear_id
				if (pda.owner)
					if (pda.owner != real_name)
						name = "[real_name] (as [pda.owner])"
		else
			name = real_name

	if (wear_id)
		wear_id.screen_loc = ui_id

	if (l_store)
		l_store.screen_loc = ui_storage1

	if (r_store)
		r_store.screen_loc = ui_storage2

	if (back)
		var/t1 = back.icon_state
		overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		back.screen_loc = ui_back

	if (handcuffed)
		pulling = null
		if (!lying)
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff1", "layer" = MOB_LAYER)
		else
			overlays += image("icon" = 'mob.dmi', "icon_state" = "handcuff2", "layer" = MOB_LAYER)

	if (client)
		client.screen -= contents
		client.screen += contents

	if (r_hand)
		overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = MOB_LAYER+1)

		r_hand.screen_loc = ui_rhand

	if (l_hand)
		overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = MOB_LAYER+1)

		l_hand.screen_loc = ui_lhand

	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if(istype(wear_suit, /obj/item/clothing/suit/space/space_ninja)&&wear_suit:s_active)
		shielded = 3

	switch(shielded)
		if(1)
			overlays += image("icon" = 'effects.dmi', "icon_state" = "shield", "layer" = MOB_LAYER+1)
		if(2)
			invisibility = 2
			//New stealth. Hopefully doesn't lag too much. /N
			if(istype(loc, /turf))//If they are standing on a turf.
				AddCamoOverlay(loc)//Overlay camo.
		if(3)
			if(istype(loc, /turf))
			//Ninjas may flick into view once in a while if they are stealthed.
				if(prob(90))
					NinjaStealthActive(loc)
				else
					NinjaStealthMalf()
		else
			invisibility = 0

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return

	last_b_state = stat

/mob/living/carbon/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			if (istype(wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			/*else if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return*/
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						UpdateDamageIcon()
					else
						UpdateDamage()
				updatehealth()

				for(var/datum/disease/D in M.viruses)
					if(istype(D, /datum/disease/jungle_fever))
						var/mob/living/carbon/human/H = src
						src = null
						src = H.monkeyize()
						contract_disease(D,1,0)

	return

/mob/living/carbon/human/attack_paw(mob/M as mob)
	..()
	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			if (istype(wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/armor))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			/*else if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return*/
			else
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")
				if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						UpdateDamageIcon()
					else
						UpdateDamage()
				updatehealth()

				for(var/datum/disease/D in M.viruses)
					if(istype(D, /datum/disease/jungle_fever))
						var/mob/living/carbon/human/H = src
						src = null
						src = H.monkeyize()
						contract_disease(D,1,0)
	return

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)

		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)
		if ("grab")
			//This will be changed to skin, where we can skin a dead human corpse//Actually, that sounds kind of impractical./N
			if (M == src)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("hurt")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30) // How much damage aliens do to humans? Increasing -- TLE
									  // I've decreased the chance of humans being protected by uniforms. Now aliens can actually damage them.
			var/datum/organ/external/affecting = organs["chest"]
			var/t = M.zone_sel.selecting
			if ((t in list( "eyes", "mouth" )))
				t = "head"
			var/def_zone = ran_zone(t)
			if (organs[def_zone])
				affecting = organs[def_zone]
			if ((istype(affecting, /datum/organ/external) && prob(95)))
				playsound(loc, 'slice.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
				if (def_zone == "head")
					if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(5)))
						if (prob(20))
							affecting.take_damage(damage, 0)
						else
							show_message("\red You have been protected from a hit to the head.")
						return
					if (damage >= 25)
						if (weakened < 10)
							weakened = rand(10, 15)
						for(var/mob/O in viewers(M, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has wounded []!</B>", M, src), 1, "\red You hear someone fall.", 2)
					affecting.take_damage(damage)
				else
					if (def_zone == "chest")
						if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(10)))
							show_message("\blue You have been protected from a hit to the chest.")
							return
						if (damage >= 25)
							if (prob(50))
								if (weakened < 5)
									weakened = 5
								playsound(loc, 'slashmiss.ogg', 50, 1, -1)
								for(var/mob/O in viewers(src, null))
									if ((O.client && !( O.blinded )))
										O.show_message(text("\red <B>[] has tackled down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
							else
								if (stunned < 5)
									stunned = 5
								for(var/mob/O in viewers(src, null))
									if ((O.client && !( O.blinded )))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
							if(stat != 2)	stat = 1
						affecting.take_damage(damage)
					else
						if (def_zone == "groin")
							if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(1)))
								show_message("\blue You have been protected from a hit to the lower chest.")
								return
							if (damage >= 25)
								if (prob(50))
									if (weakened < 3)
										weakened = 3
									for(var/mob/O in viewers(src, null))
										if ((O.client && !( O.blinded )))
											O.show_message(text("\red <B>[] has tackled down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (stunned < 3)
										stunned = 3
									for(var/mob/O in viewers(src, null))
										if ((O.client && !( O.blinded )))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(stat != 2)	stat = 1
							affecting.take_damage(damage)
						else
							affecting.take_damage(damage)
				UpdateDamageIcon()
				updatehealth()
			else
				playsound(loc, 'slashmiss.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M] has lunged at [src] but missed!</B>"), 1)
		if ("disarm")
			var/damage = 5
			var/datum/organ/external/affecting = organs["chest"]
			var/t = M.zone_sel.selecting
			if ((t in list( "eyes", "mouth" )))
				t = "head"
			var/def_zone = ran_zone(t)
			if (organs[def_zone])
				affecting = organs[def_zone]
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/randn = rand(1, 100)
			if (randn <= 90)
				playsound(loc, 'pierce.ogg', 25, 1, -1)
				if (weakened < 15)
					weakened = rand(10, 15)
				affecting.take_damage(damage)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled down []!</B>", M, src), 1)
			else
				if (randn <= 99)
					playsound(loc, 'slash.ogg', 25, 1, -1)
					drop_item()
					affecting.take_damage(damage)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] disarmed []!</B>", M, src), 1)
				else
					playsound(loc, 'slashmiss.ogg', 50, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has tried to disarm []!</B>", M, src), 1)
	return


/mob/living/carbon/human/attack_metroid(mob/living/carbon/metroid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>The [M.name] has [pick("bit","slashed")] []!</B>", src), 1)

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/metroid/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)


		var/dam_zone = pick("head", "chest", "l_hand", "r_hand", "l_leg", "r_leg", "groin")


		if (dam_zone == "chest")
			if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(10)))
				if(prob(20))
					show_message("\blue You have been protected from a hit to the chest.")
					return



		if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
			var/datum/organ/external/temp = organs[text("[]", dam_zone)]
			if (temp.take_damage(damage, 0))
				UpdateDamageIcon()
			else
				UpdateDamage()


		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>The [M.name] has shocked []!</B>", src), 1)

				if (weakened < power)
					weakened = power
				if (stuttering < power)
					stuttering = power
				if (stunned < power)
					stunned = power

				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					fireloss += M.powerlevel * rand(6,10)


		updatehealth()

	return

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (weakened < 5)
				weakened = 5
			if (stuttering < 5)
				stuttering = 5
			if (stunned < 5)
				stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		if (health > 0)
			help_shake_act(M)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((head && head.flags & 4) || (wear_mask && !( wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = loc
				O.place = "CPR"
				requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				if (w_uniform)
					w_uniform.add_fingerprint(M)
				var/damage = 0
				if(organStructure && organStructure.arms)
					damage = rand(organStructure.arms.minDamage,organStructure.arms.maxDamage)
				else
					damage = rand(1, 9) //oh boy
				var/datum/organ/external/affecting = organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (organs[text("[]", def_zone)])
					affecting = organs[text("[]", def_zone)]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					if (M.mutations & HULK)
						damage += 5
						spawn(0)
							paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
					M.attack_log += text("<font color='red'>[world.time] - has punched [src.name] ([src.ckey])</font>")
					src.attack_log += text("<font color='orange'>[world.time] - has been punched by [M.name] ([M.ckey])</font>")

					M.attack_log += text("<font color='red'>[world.time] - has punched [src.name] ([src.ckey])</font>")
					src.attack_log += text("<font color='orange'>[world.time] - has been punched by [M.name] ([M.ckey])</font>")


					if (def_zone == "head")
						if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (weakened < 10)
								weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (weakened < 5)
										weakened = 5
									playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (stunned < 5)
										stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(stat != 2)	stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (weakened < 3)
											weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (stunned < 3)
											stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(stat != 2)	stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					UpdateDamageIcon()

					updatehealth()
				else
					playsound(loc, 'punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( lying ) && !(M.gloves && M.gloves.elecgen == 1))
					if (w_uniform)
						w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						weakened = 2
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							drop_item()
							playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(loc, 'punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/proc/update_body()
	if(stand_icon)
		del(stand_icon)
	if(lying_icon)
		del(lying_icon)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	stand_icon = new /icon('human.dmi', "blank")
	lying_icon = new /icon('human.dmi', "blank")

	var/husk = (mutations & HUSK)
	var/obese = (mutations & FAT)

	if (husk)
		stand_icon.Blend(new /icon('human.dmi', "husk_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "husk_l"), ICON_OVERLAY)
	else if(obese)
		stand_icon.Blend(new /icon('human.dmi', "fatbody_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "fatbody_l"), ICON_OVERLAY)
	else
		stand_icon.Blend(new /icon('human.dmi', "chest_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "chest_[g]_l"), ICON_OVERLAY)

		for (var/part in list("head", "arm_left", "arm_right", "hand_left", "hand_right", "leg_left", "leg_right", "foot_left", "foot_right"))
			stand_icon.Blend(new /icon('human.dmi', "[part]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('human.dmi', "[part]_l"), ICON_OVERLAY)

		stand_icon.Blend(new /icon('human.dmi', "groin_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('human.dmi', "groin_[g]_l"), ICON_OVERLAY)

	// Skin tone
	if (s_tone >= 0)
		stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
	else
		stand_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)
		lying_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	if (underwear > 0)
		if(!obese)
			stand_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('human.dmi', "underwear[underwear]_[g]_l"), ICON_OVERLAY)

/mob/living/carbon/human/proc/update_face()
	del(face_standing)
	del(face_lying)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	var/icon/hair_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[hair_icon_state]_s")
	var/icon/hair_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[hair_icon_state]_l")
	hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
	hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "[face_icon_state]_s")
	var/icon/facial_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "[face_icon_state]_l")
	facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'human_face.dmi', "icon_state" = "mouth_[g]_l")

	eyes_s.Blend(hair_s, ICON_OVERLAY)
	eyes_l.Blend(hair_l, ICON_OVERLAY)
	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)
	eyes_s.Blend(facial_s, ICON_OVERLAY)
	eyes_l.Blend(facial_l, ICON_OVERLAY)

	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_lying.icon = eyes_l

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
	if (item)
		item.add_fingerprint(source)
	if (!item)
		switch(place)
			if("mask")
				if (!( target.wear_mask ))
					//SN src = null
					del(src)
					return
/*			if("headset")
				if (!( target.w_radio ))
					//SN src = null
					del(src)
					return */
			if("l_hand")
				if (!( target.l_hand ))
					//SN src = null
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					//SN src = null
					del(src)
					return
			if("suit")
				if (!( target.wear_suit ))
					//SN src = null
					del(src)
					return
			if("uniform")
				if (!( target.w_uniform ))
					//SN src = null
					del(src)
					return
			if("back")
				if (!( target.back ))
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
				if (!( target.handcuffed ))
					//SN src = null
					del(src)
					return
			if("id")
				if ((!( target.wear_id ) || !( target.w_uniform )))
					//SN src = null
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					//SN src = null
					del(src)
					return

	var/list/L = list( "syringe", "pill", "drink", "dnainjector", "fuel")
	if ((item && !( L.Find(place) )))
		for(var/mob/O in viewers(target, null))
			O.show_message(text("\red <B>[] is trying to put \a [] on []</B>", source, item, target), 1)
	else
		if (place == "syringe")
			for(var/mob/O in viewers(target, null))
				O.show_message(text("\red <B>[] is trying to inject []!</B>", source, target), 1)
		else
			if (place == "pill")
				for(var/mob/O in viewers(target, null))
					O.show_message(text("\red <B>[] is trying to force [] to swallow []!</B>", source, target, item), 1)
			else
				if(place == "fuel")
					for(var/mob/O in viewers(target, null))
						O.show_message(text("\red [source] is trying to force [target] to eat the [item:content]!"), 1)
				else
					if (place == "drink")
						for(var/mob/O in viewers(target, null))
							O.show_message(text("\red <B>[] is trying to force [] to swallow a gulp of []!</B>", source, target, item), 1)
					else
						if (place == "dnainjector")
							for(var/mob/O in viewers(target, null))
								O.show_message(text("\red <B>[] is trying to inject [] with the []!</B>", source, target, item), 1)
						else
							var/message = null
							switch(place)
								if("mask")
									if(istype(target.wear_mask, /obj/item/clothing)&&!target.wear_mask:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_mask, target)
									else
										message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
/*								if("headset")
									message = text("\red <B>[] is trying to take off \a [] from []'s face!</B>", source, target.w_radio, target) */
								if("l_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s left hand!</B>", source, target.l_hand, target)
								if("r_hand")
									message = text("\red <B>[] is trying to take off \a [] from []'s right hand!</B>", source, target.r_hand, target)
								if("gloves")
									if(istype(target.gloves, /obj/item/clothing)&&!target.gloves:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.gloves, target)
									else
										message = text("\red <B>[] is trying to take off the [] from []'s hands!</B>", source, target.gloves, target)
								if("eyes")
									if(istype(target.glasses, /obj/item/clothing)&&!target.glasses:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.glasses, target)
									else
										message = text("\red <B>[] is trying to take off the [] from []'s eyes!</B>", source, target.glasses, target)
								if("ears")
									if(istype(target.ears, /obj/item/clothing)&&!target.ears:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.ears, target)
									else
										message = text("\red <B>[] is trying to take off the [] from []'s ears!</B>", source, target.ears, target)
								if("head")
									if(istype(target.head, /obj/item/clothing)&&!target.head:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.head, target)
									else
										message = text("\red <B>[] is trying to take off the [] from []'s head!</B>", source, target.head, target)
								if("shoes")
									if(istype(target.shoes, /obj/item/clothing)&&!target.shoes:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.shoes, target)
									else
										message = text("\red <B>[] is trying to take off the [] from []'s feet!</B>", source, target.shoes, target)
								if("belt")
									message = text("\red <B>[] is trying to take off the [] from []'s belt!</B>", source, target.belt, target)
								if("suit")
									if(istype(target.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))//Exception for suicide vests.
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
									else if(istype(target.wear_suit, /obj/item/clothing)&&!target.wear_suit:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
									else
										message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.wear_suit, target)
								if("back")
									message = text("\red <B>[] is trying to take off \a [] from []'s back!</B>", source, target.back, target)
								if("handcuff")
									message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
								if("uniform")
									if(istype(target.w_uniform, /obj/item/clothing)&&!target.w_uniform:canremove)
										message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
									else
										message = text("\red <B>[] is trying to take off \a [] from []'s body!</B>", source, target.w_uniform, target)
								if("s_store")
									message = text("\red <B>[] is trying to take off \a [] from []'s suit!</B>", source, target.s_store, target)
								if("h_store")
									message = text("\red <B>[] is trying to empty []'s hat!</B>", source, target)
								if("pockets")
									for(var/obj/item/weapon/mousetrap/MT in  list(target.l_store, target.r_store))
										if(MT.armed)
											for(var/mob/O in viewers(target, null))
												if(O == source)
													O.show_message(text("\red <B>You reach into the [target]'s pockets, but there was a live mousetrap in there!</B>"), 1)
												else
													O.show_message(text("\red <B>[source] reaches into [target]'s pockets and sets off a hidden mousetrap!</B>"), 1)
											target.u_equip(MT)
											if (target.client)
												target.client.screen -= MT
											MT.loc = source.loc
											MT.triggered(source, source.hand ? "l_hand" : "r_hand")
											MT.layer = OBJ_LAYER
											return
									message = text("\red <B>[] is trying to empty []'s pockets!!</B>", source, target)
								if("CPR")
									if (target.cpr_time >= world.time + 3)
										//SN src = null
										del(src)
										return
									message = text("\red <B>[] is trying perform CPR on []!</B>", source, target)
								if("id")
									message = text("\red <B>[] is trying to take off [] from []'s uniform!</B>", source, target.wear_id, target)
								if("internal")
									if (target.internal)
										message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
									else
										message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
								else
							for(var/mob/M in viewers(target, null))
								M.show_message(message, 1)
	spawn( 40 )
		done()
		return
	return

/*
This proc equips stuff (or does something else) when removing stuff manually from the character window when you click and drag.
It works in conjuction with the process() above.
This proc works for humans only. Aliens stripping humans and the like will all use this proc. Stripping monkeys or somesuch will use their version of this proc.
The first if statement for "mask" and such refers to items that are already equipped and un-equipping them.
The else statement is for equipping stuff to empty slots.
!canremove refers to variable of /obj/item/clothing which either allows or disallows that item to be removed.
It can still be worn/put on as normal.
*/
/obj/equip_e/human/done()
	if(!source || !target)						return
	if(source.loc != s_loc)						return
	if(target.loc != t_loc)						return
	if(LinkBlocked(s_loc,t_loc))				return
	if(item && source.equipped() != item)	return
	if ((source.restrained() || source.stat))	return
	switch(place)
		if("mask")
			if (target.wear_mask)
				if(istype(target.wear_mask, /obj/item/clothing)&& !target.wear_mask:canremove)
					return
				var/obj/item/clothing/W = target.wear_mask
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/mask))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_mask = item
					item.loc = target
/*		if("headset")
			if (target.w_radio)
				var/obj/item/W = target.w_radio
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_radio = item
					item.loc = target*/
		if("gloves")
			if (target.gloves)
				if(istype(target.gloves, /obj/item/clothing)&& !target.gloves:canremove)
					return
				var/obj/item/clothing/W = target.gloves
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/gloves))
					source.drop_item()
					loc = target
					item.layer = 20
					target.gloves = item
					item.loc = target
		if("eyes")
			if (target.glasses)
				if(istype(target.glasses, /obj/item/clothing)&& !target.glasses:canremove)
					return
				var/obj/item/W = target.glasses
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/glasses))
					source.drop_item()
					loc = target
					item.layer = 20
					target.glasses = item
					item.loc = target
		if("belt")
			if (target.belt)
				var/obj/item/W = target.belt
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj) && item.flags & 128 && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.belt = item
					item.loc = target
		if("s_store")
			if (target.s_store)
				var/obj/item/W = target.s_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj) && target.wear_suit)
					var/confirm
					for(var/i=1, i<=target.wear_suit.allowed.len, i++)
		//				world << "[target.wear_suit.allowed[i]] and [W.type]"
						if (findtext("[item.type]","[target.wear_suit.allowed[i]]") || istype(item, /obj/item/device/pda) || istype(item, /obj/item/weapon/pen))
							confirm = 1
							break
					if (!confirm) return
					else
						source.drop_item()
						loc = target
						item.layer = 20
						target.s_store = item
						item.loc = target
		if("head")
			if (target.head)
				if(istype(target.head, /obj/item/clothing)&& !target.head:canremove)
					return
				var/obj/item/W = target.head
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/head))
					source.drop_item()
					loc = target
					item.layer = 20
					target.head = item
					item.loc = target
		if("ears")
			if (target.ears)
				if(istype(target.ears, /obj/item/clothing)&& !target.ears:canremove)
					return
				var/obj/item/W = target.ears
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/ears))
					source.drop_item()
					loc = target
					item.layer = 20
					target.ears = item
					item.loc = target
				else if (istype(item, /obj/item/device/radio/headset))
					source.drop_item()
					loc = target
					item.layer = 20
					target.ears = item
					item.loc = target
		if("shoes")
			if (target.shoes)
				if(istype(target.shoes, /obj/item/clothing)&& !target.shoes:canremove)
					return
				var/obj/item/W = target.shoes
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/shoes))
					source.drop_item()
					loc = target
					item.layer = 20
					target.shoes = item
					item.loc = target
		if("l_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.l_hand)
				var/obj/item/W = target.l_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					item.layer = 20
					target.l_hand = item
					item.loc = target
					item.add_fingerprint(target)
		if("r_hand")
			if (istype(target, /obj/item/clothing/suit/straight_jacket))
				//SN src = null
				del(src)
				return
			if (target.r_hand)
				var/obj/item/W = target.r_hand
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item))
					source.drop_item()
					loc = target
					if (item)
						item.layer = 20
						target.r_hand = item
						item.loc = target
						item.add_fingerprint(target)
		if("uniform")
			if (target.w_uniform)
				if(istype(target.w_uniform, /obj/item/clothing)&& !target.w_uniform:canremove)
					return
				var/obj/item/W = target.w_uniform
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
				W = target.l_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.r_store
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
				W = target.wear_id
				if (W)
					target.u_equip(W)
					if (target.client)
						target.client.screen -= W
					if (W)
						W.loc = target.loc
						W.dropped(target)
						W.layer = initial(W.layer)
			else
				if (istype(item, /obj/item/clothing/under))
					source.drop_item()
					loc = target
					item.layer = 20
					target.w_uniform = item
					item.loc = target
		if("suit")
			if (target.wear_suit)
				if(istype(target.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))//triggers suicide vest if someone else tries to take it off/N
					var/obj/item/clothing/suit/armor/a_i_a_ptank/A = target.wear_suit//mostly a copy from death.dm code.
					bombers += "[target.key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
					if(A.status && prob(90))
						A.part4.ignite()
						return
				if(istype(target.wear_suit, /obj/item/clothing)&& !target.wear_suit:canremove)
					if(!istype(target.wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))	return//Can remove the suicide vest if it didn't trigger.
				var/obj/item/W = target.wear_suit
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/clothing/suit))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_suit = item
					item.loc = target
		if("id")
			if (target.wear_id)
				var/obj/item/W = target.wear_id
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (((istype(item, /obj/item/weapon/card/id)||istype(item, /obj/item/device/pda)) && target.w_uniform))
					source.drop_item()
					loc = target
					item.layer = 20
					target.wear_id = item
					item.loc = target
		if("back")
			if (target.back)
				var/obj/item/W = target.back
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if ((istype(item, /obj/item) && item.flags & 1))
					source.drop_item()
					loc = target
					item.layer = 20
					target.back = item
					item.loc = target
		if("h_store")
			if (target.h_store)
				var/obj/item/W = target.h_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
		if("handcuff")
			if (target.handcuffed)
				var/obj/item/W = target.handcuffed
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			else
				if (istype(item, /obj/item/weapon/handcuffs))
					target.drop_from_slot(target.r_hand)
					target.drop_from_slot(target.l_hand)
					source.drop_item()
					target.handcuffed = item
					item.loc = target
		if("CPR")
			if (target.cpr_time >= world.time + 30)
				//SN src = null
				del(src)
				return
			if ((target.health >= -99.0 && target.health < 0))
				target.cpr_time = world.time
				var/suff = min(target.oxyloss, 7)
				target.oxyloss -= suff
				target.updatehealth()
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] performs CPR on []!", source, target), 1)
				target << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
				source << "\red Repeat every 7 seconds AT LEAST."
		if("fuel")
			var/obj/item/weapon/fuel/S = item
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
			for(var/mob/O in viewers(source, null))
				O.show_message(text("\red [source] forced [target] to eat the [a]!"), 1)
			S.injest(target)
		if("dnainjector")
			var/obj/item/weapon/dnainjector/S = item
			if(item)
				item.add_fingerprint(source)
				item:inject(target, null)
				if (!( istype(S, /obj/item/weapon/dnainjector) ))
					//SN src = null
					del(src)
					return
				if (S.s_time >= world.time + 30)
					//SN src = null
					del(src)
					return
				S.s_time = world.time
				for(var/mob/O in viewers(source, null))
					O.show_message(text("\red [] injects [] with the DNA Injector!", source, target), 1)
		if("pockets")
			if (target.l_store)
				var/obj/item/W = target.l_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
			if (target.r_store)
				var/obj/item/W = target.r_store
				target.u_equip(W)
				if (target.client)
					target.client.screen -= W
				if (W)
					W.loc = target.loc
					W.dropped(target)
					W.layer = initial(W.layer)
				W.add_fingerprint(source)
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
				if (target.internals)
					target.internals.icon_state = "internal0"
			else
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
					else if (istype(target.s_store, /obj/item/weapon/tank))
						target.internal = target.s_store
					else if (istype(target.belt, /obj/item/weapon/tank))
						target.internal = target.belt
					if (target.internal)
						for(var/mob/M in viewers(target, 1))
							M.show_message(text("[] is now running on internals.", target), 1)
						target.internal.add_fingerprint(source)
						if (target.internals)
							target.internals.icon_state = "internal1"
		else
	if(source)
		source.update_clothing()
	if(target)
		target.update_clothing()
	//SN src = null
	del(src)
	return

/mob/living/carbon/human/proc/TakeDamage(zone, brute, burn)
	var/datum/organ/external/E = organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.take_damage(brute, burn))
			UpdateDamageIcon()
		else
			UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)

	var/datum/organ/external/E = organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
		else
			UpdateDamage()
	else
		return 0
	return

/mob/living/carbon/human/proc/UpdateDamage()

	bruteloss = 0
	fireloss = 0
	var/datum/organ/external/O
	for(var/t in organs)
		O = organs[t]
		if (istype(O, /datum/organ/external))
			bruteloss += O.brute_dam
			fireloss += O.burn_dam
	return

// new damage icon system
// now constructs damage icon for each organ from mask * damage field

/mob/living/carbon/human/proc/UpdateDamageIcon()
	del(body_standing)
	body_standing = list()
	del(body_lying)
	body_lying = list()
	bruteloss = 0
	fireloss = 0
	var/datum/organ/external/O
	for(var/t in organs)
		O = organs[t]
		if (istype(O, /datum/organ/external))
			bruteloss += O.brute_dam
			fireloss += O.burn_dam

			var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels

	//		world << "[O.icon_name] [O.damage_state] \icon[DI]"

			body_standing += DI

			DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
			DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)

	//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"

			body_lying += DI

			//body_standing += new /icon( 'dam_zones.dmi', text("[]", O.d_i_state) )
			//body_lying += new /icon( 'dam_zones.dmi', text("[]2", O.d_i_state) )

/mob/living/carbon/human/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(ears ? ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform ? w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR><B>Suit Storage:</B> <A href='?src=\ref[src];item=s_store'>[(s_store ? s_store : "Nothing")]</A>
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[src];item=h_store'>Empty Hat</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

// called when something steps onto a human
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.assignment
		else
			. = pda.ownjob
	else if (istype(id))
		. = id.assignment
	else
		return if_no_id
	if (!.)
		. = if_no_job
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		if (pda.id)
			. = pda.id.registered
		else
			. = pda.owner
	else if (istype(id))
		. = id.registered
	else
		return if_no_id
	return

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_visible_name(var/if_no_id = "Unknown")
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if (istype(pda))
		. = pda.owner
	else if (istype(id))
		. = id.registered
	else
		return if_no_id
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	var/obj/item/weapon/card/id/id = wear_id
	var/obj/item/device/pda/pda = wear_id
	if (istype(pda) && pda.id)
		id = pda.id
	if (istype(id))
		return id

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/safety = 0)
	if(!safety)
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			siemens_coeff = G.siemens_coefficient
	return ..(shock_damage,source,siemens_coeff)


/mob/living/carbon/human/proc/get_damaged_organs(var/brute, var/burn)
	var/list/datum/organ/external/parts = list()
	for(var/organ_name in organs)
		var/datum/organ/external/organ = organs[organ_name]
		if((brute && organ.brute_dam) || (burn && organ.burn_dam))
			parts += organ
	return parts

/mob/living/carbon/human/proc/get_damageable_organs()
	var/list/datum/organ/external/parts = list()
	for(var/organ_name in organs)
		var/datum/organ/external/organ = organs[organ_name]
		if(organ.brute_dam + organ.burn_dam < organ.max_damage)
			parts += organ
	return parts

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/human/heal_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.heal_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/human/take_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.take_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)

	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damageable_organs()

	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		picked.take_damage(brute,burn)

		brute -= (picked.brute_dam-brute_was)
		burn -= (picked.burn_dam-burn_was)

		parts -= picked
	updatehealth()
	UpdateDamageIcon()

/mob/living/carbon/human/proc/getarmor(var/datum/organ/external/def_zone, var/type)
	var/armorval = 0
	var/organnum = 0


	if(istype(def_zone))
		return checkarmor(def_zone, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value. --NEO

	else
		//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
		for(var/organ_name in organs)
			var/datum/organ/external/organ = organs[organ_name]
			if (istype(organ))
				var/list/organarmor = checkarmor(organ, type)
				armorval += organarmor["armor"]
				organnum++
				//world << "Debug text: full body armor check in progress, [organ.name] is best protected against [type] damage by [organarmor["clothes"]], with a value of [organarmor["armor"]]"
		//world << "Debug text: full body armor check complete, average of [armorval/organnum] protection against [type] damage."
		return armorval/organnum

	return 0

/mob/living/carbon/human/proc/checkarmor(var/datum/organ/external/def_zone, var/type)
	if (!type)
		return
	var/obj/item/clothing/best
	var/armorval = 0

	//I don't really like the way this is coded, but I can't think of a better way to check what they're actually wearing as opposed to something they're holding. --NEO

	if(head && istype(head,/obj/item/clothing))
		if(def_zone.body_part & head.body_parts_covered)
			if(head.armor[type] > armorval)
				armorval = head.armor[type]
				best = head

	if(wear_mask && istype(wear_mask,/obj/item/clothing))
		if(def_zone.body_part & wear_mask.body_parts_covered)
			if(wear_mask.armor[type] > armorval)
				armorval = wear_mask.armor[type]
				best = wear_mask

	if(wear_suit && istype(wear_suit,/obj/item/clothing))
		if(def_zone.body_part & wear_suit.body_parts_covered)
			if(wear_suit.armor[type] > armorval)
				armorval = wear_suit.armor[type]
				best = wear_suit

	if(w_uniform && istype(w_uniform,/obj/item/clothing))
		if(def_zone.body_part & w_uniform.body_parts_covered)
			if(w_uniform.armor[type] > armorval)
				armorval = w_uniform.armor[type]
				best = w_uniform

	if(shoes && istype(shoes,/obj/item/clothing))
		if(def_zone.body_part & shoes.body_parts_covered)
			if(shoes.armor[type] > armorval)
				armorval = shoes.armor[type]
				best = shoes

	if(gloves && istype(gloves,/obj/item/clothing))
		if(def_zone.body_part & gloves.body_parts_covered)
			if(gloves.armor[type] > armorval)
				armorval = gloves.armor[type]
				best = gloves

	var/list/result = list(clothes = best, armor = armorval)
	return result


/mob/living/carbon/human/Topic(href, href_list)
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/equip_e/human/O = new /obj/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		requests += O
		spawn( 0 )
			O.process()
			return
	..()
	return