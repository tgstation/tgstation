/mob/living/carbon/monkey/New()
	spawn(1)
		var/datum/reagents/R = new/datum/reagents(1000)
		reagents = R
		R.my_atom = src
		if (!(src.dna))
			if(src.gender == NEUTER)
				src.gender = pick(MALE, FEMALE)
			src.dna = new /datum/dna( null )
			src.dna.uni_identity = "00600200A00E0110148FC01300B009"
			src.dna.struc_enzymes = "0983E840344C39F4B059D5145FC5785DC6406A4BB8"
			src.dna.unique_enzymes = md5(src.name)
					//////////blah
			var/gendervar
			if (src.gender == "male")
				gendervar = add_zero2(num2hex((rand(1,2049)),1), 3)
			else
				gendervar = add_zero2(num2hex((rand(2051,4094)),1), 3)
			src.dna.uni_identity += gendervar
			src.dna.uni_identity += "12C"
			src.dna.uni_identity += "4E2"

		if(src.name == "monkey") src.name = text("monkey ([rand(1, 1000)])")

		src.real_name = src.name
		return
	..()
	return

/mob/living/carbon/monkey/movement_delay()
	var/tally = 0
	if(src.reagents)
		if(src.reagents.has_reagent("hyperzine")) return -1

	var/health_deficiency = (100 - src.health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (src.bodytemperature < 283.222)
		tally += (283.222 - src.bodytemperature) / 10 * 1.75
	return tally

/mob/living/carbon/monkey/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					src.now_pushing = 0
					return
		src.now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( src.now_pushing ))
			src.now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/window/win in get_step(AM,t))
							return
				step(AM, t)
			src.now_pushing = null
		return
	return

/mob/living/carbon/monkey/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		src.machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && !( usr.restrained() ) && in_range(src, usr) ))
		var/obj/equip_e/monkey/O = new /obj/equip_e/monkey(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = src.loc
		O.place = href_list["item"]
		src.requests += O
		spawn( 0 )
			O.process()
			return
	..()
	return

/mob/living/carbon/monkey/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		var/shielded = 0
		for(var/obj/item/device/shield/S in src)
			if (S.active)
				shielded = 1
			else
		src.bruteloss += 30
		if ((O.icon_state == "flaming" && !( shielded )))
			src.fireloss += 40
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	return

/mob/living/carbon/monkey/bullet_act(flag)

	if (flag == PROJECTILE_BULLET)
		if (src.stat != 2)
			src.bruteloss += 60
			src.updatehealth()
			src.weakened = 10
	else if (flag == PROJECTILE_TASER)
		if (prob(75))
			src.stunned = 15
		else
			src.weakened = 15
	else if (flag == PROJECTILE_DART)
		src.weakened += 5
		src.toxloss += 10
	else if(flag == PROJECTILE_LASER)
		if (src.stat != 2)
			src.bruteloss += 20
			src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			if (prob(25))
				src.stunned = 1
	else if(flag == PROJECTILE_PULSE)
		if (src.stat != 2)
			src.bruteloss += 40
			src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			if (prob(25))
				src.stunned = min(src.stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		src.toxloss += 3
		src.radiation += 100
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		src.stuttering += 5
		src.drowsyness += 5
	return

/mob/living/carbon/monkey/hand_p(mob/M as mob)
	if ((M.a_intent == "hurt" && !( istype(src.wear_mask, /obj/item/clothing/mask/muzzle) )))
		if ((prob(75) && src.health > 0))
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			var/damage = rand(1, 5)
			if (src.mutations & 8) damage += 10
			src.bruteloss += damage
			src.updatehealth()
		else
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
	return

/mob/living/carbon/monkey/attack_paw(mob/M as mob)
	..()

	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		if (src.paralysis >= 3) src.paralysis -= 3
		if (src.stunned >= 3) src.stunned -= 3
		if (src.weakened >= 3) src.weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message("\blue [M.name] shakes [src.name] trying to wake him up!", 1)
	else
		if ((M.a_intent == "hurt" && !( istype(src.wear_mask, /obj/item/clothing/mask/muzzle) )))
			if ((prob(75) && src.health > 0))
				playsound(src.loc, 'bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has bit [src.name]!</B>", 1)
				var/damage = rand(1, 5)
				src.bruteloss += damage
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has attempted to bite [src.name]!</B>", 1)
	return

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	if ((M:gloves && M:gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M:gloves.uses > 0)
			M:gloves.uses--
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
			M:gloves.elecgen = 0
			M << "\red Not enough charge! "
			return

	if (M.a_intent == "help")
		src.sleeping = 0
		src.resting = 0
		if (src.paralysis >= 3) src.paralysis -= 3
		if (src.stunned >= 3) src.stunned -= 3
		if (src.weakened >= 3) src.weakened -= 3
		playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\blue [] shakes [src.name] trying to wake him up!", M), 1)
	else
		if (M.a_intent == "hurt")
			if ((prob(75) && src.health > 0))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched [src.name]!</B>", M), 1)

				playsound(src.loc, "punch", 25, 1, -1)
				var/damage = rand(5, 10)
				if (prob(40))
					damage = rand(10, 15)
					if (src.paralysis < 5)
						src.paralysis = rand(10, 15)
						spawn( 0 )
							for(var/mob/O in viewers(src, null))
								if ((O.client && !( O.blinded )))
									O.show_message(text("\red <B>[] has knocked out [src.name]!</B>", M), 1)
							return
				src.bruteloss += damage
				src.updatehealth()
			else
				playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch [src.name]!</B>", M), 1)
		else
			if (M.a_intent == "grab")
				if (M == src)
					return
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
					O.show_message(text("\red [] has grabbed [src.name] passively!", M), 1)
			else
				if (!( src.paralysis ))
					if (prob(25))
						src.paralysis = 2
						playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has pushed down [src.name]!</B>", M), 1)
					else
						drop_item()
						playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has disarmed [src.name]!</B>", M), 1)
	return

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	switch(M.a_intent)
		if ("help")
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M] caresses [src] with its scythe like arm."), 1)

		if ("hurt")
			if ((prob(95) && src.health > 0))
				playsound(src.loc, 'slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if (src.paralysis < 15)
						src.paralysis = rand(10, 15)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has wounded [src.name]!</B>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has slashed [src.name]!</B>", M), 1)
				src.bruteloss += damage
				src.updatehealth()
			else
				playsound(src.loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to lunge at [src.name]!</B>", M), 1)

		if ("grab")
			if (M == src)
				return
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
				O.show_message(text("\red [] has grabbed [src.name] passively!", M), 1)

		if ("disarm")
			playsound(src.loc, 'pierce.ogg', 25, 1, -1)
			var/damage = 5
			if(prob(95))
				src.weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled down [src.name]!</B>", M), 1)
			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has disarmed [src.name]!</B>", M), 1)
			src.bruteloss += damage
			src.updatehealth()
	return

/mob/living/carbon/monkey/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", src.a_intent))
	stat(null, text("Move Mode: []", src.m_intent))
	if(client && mind)
		if (src.client.statpanel == "Status")
			if (src.mind.special_role == "Changeling")
				stat("Chemical Storage", src.chem_charges)
	return

/mob/living/carbon/monkey/update_clothing()
	if(src.buckled)
		if(istype(src.buckled, /obj/stool/bed))
			src.lying = 1
		else
			src.lying = 0

	if(src.update_icon) // Skie
		..()
		for(var/i in src.overlays)
			src.overlays -= i

		if (!( src.lying ))
			src.icon_state = "monkey1"
		else
			src.icon_state = "monkey0"

	if (src.wear_mask)
		if (istype(src.wear_mask, /obj/item/clothing/mask) && src.update_icon)
			var/t1 = src.wear_mask.item_state
			if (!( t1 ))
				t1 = src.wear_mask.icon_state
			src.overlays += image("icon" = 'monkey.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = src.layer)
		src.wear_mask.screen_loc = ui_mask

	if (src.r_hand)
		if(src.update_icon)
			src.overlays += image("icon" = 'items_righthand.dmi', "icon_state" = src.r_hand.item_state ? src.r_hand.item_state : src.r_hand.icon_state, "layer" = src.layer)
		src.r_hand.screen_loc = ui_rhand

	if (src.l_hand)
		if(src.update_icon)
			src.overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = src.l_hand.item_state ? src.l_hand.item_state : src.l_hand.icon_state, "layer" = src.layer)
		src.l_hand.screen_loc = ui_lhand

	if (src.back)
		if(src.update_icon)
			if (!( src.lying ))
				src.overlays += image("icon" = 'monkey.dmi', "icon_state" = "back", "layer" = src.layer)
			else
				src.overlays += image("icon" = 'monkey.dmi', "icon_state" = "back2", "layer" = src.layer)
		src.back.screen_loc = ui_back

	if (src.handcuffed && src.update_icon)
		src.pulling = null
		if (!( src.lying ))
			src.overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff1", "layer" = src.layer)
		else
			src.overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff2", "layer" = src.layer)

	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents
		src.client.screen -= src.hud_used.m_ints
		src.client.screen -= src.hud_used.mov_int
		if (src.i_select)
			if (src.intent)
				src.client.screen += src.hud_used.m_ints

				var/list/L = dd_text2list(src.intent, ",")
				L[1] += ":-11"
				src.i_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT

			else
				src.i_select.screen_loc = null
		if (src.m_select)
			if (src.m_int)
				src.client.screen += src.hud_used.mov_int

				var/list/L = dd_text2list(src.m_int, ",")
				L[1] += ":-11"
				src.m_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT

			else
				src.m_select.screen_loc = null
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn( 0 )
				src.show_inv(M)
				return
	return

/mob/living/carbon/monkey/Move()
	if ((!( src.buckled ) || src.buckled.loc != src.loc))
		src.buckled = null
	if (src.buckled)
		return
	if (src.restrained())
		src.pulling = null
	var/t7 = 1
	if (src.restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				return 0
	if ((t7 && src.pulling && get_dist(src, src.pulling) <= 1))
		if (src.pulling.anchored)
			src.pulling = null
		var/T = src.loc
		. = ..()
		if (!( isturf(src.pulling.loc) ))
			src.pulling = null
			return
		if (!( src.restrained() ))
			var/diag = get_dir(src, src.pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((ismob(src.pulling) && (get_dist(src, src.pulling) > 1 || diag)))
				if (istype(src.pulling, src.type))
					var/mob/M = src.pulling
					var/mob/t = M.pulling
					M.pulling = null
					step(src.pulling, get_dir(src.pulling.loc, T))
					M.pulling = t
			else
				if (src.pulling)
					if (istype(src.pulling, /obj/window))
						if(src.pulling:ini_dir == NORTHWEST || src.pulling:ini_dir == NORTHEAST || src.pulling:ini_dir == SOUTHWEST || src.pulling:ini_dir == SOUTHEAST)
							for(var/obj/window/win in get_step(src.pulling,get_dir(src.pulling.loc, T)))
								src.pulling = null
				if (src.pulling)
					step(src.pulling, get_dir(src.pulling.loc, T))
	else
		src.pulling = null
		. = ..()
	if ((src.s_active && !( src.contents.Find(src.s_active) )))
		src.s_active.close(src)
	return

/mob/living/carbon/monkey/verb/removeinternal()
	src.internal = null
	return

/mob/living/carbon/monkey/var/co2overloadtime = null
/mob/living/carbon/monkey/var/temperature_resistance = T0C+75

/mob/living/carbon/monkey/ex_act(severity)
	flick("flash", src.flash)
	switch(severity)
		if(1.0)
			if (src.stat != 2)
				src.bruteloss += 200
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		if(2.0)
			if (src.stat != 2)
				src.bruteloss += 60
				src.fireloss += 60
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
		if(3.0)
			if (src.stat != 2)
				src.bruteloss += 30
				src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
			if (prob(50))
				src.paralysis += 10
		else
	return

/mob/living/carbon/monkey/blob_act()
	if (src.stat != 2)
		src.fireloss += 60
		src.health = 100 - src.oxyloss - src.toxloss - src.fireloss - src.bruteloss
	if (prob(50))
		src.paralysis += 10

/obj/equip_e/monkey/process()
	if (src.item)
		src.item.add_fingerprint(src.source)
	if (!( src.item ))
		switch(src.place)
			if("head")
				if (!( src.target.wear_mask ))
					del(src)
					return
			if("l_hand")
				if (!( src.target.l_hand ))
					del(src)
					return
			if("r_hand")
				if (!( src.target.r_hand ))
					del(src)
					return
			if("back")
				if (!( src.target.back ))
					del(src)
					return
			if("handcuff")
				if (!( src.target.handcuffed ))
					del(src)
					return
			if("internal")
				if ((!( (istype(src.target.wear_mask, /obj/item/clothing/mask) && istype(src.target.back, /obj/item/weapon/tank) && !( src.target.internal )) ) && !( src.target.internal )))
					del(src)
					return

	if (src.item)
		for(var/mob/O in viewers(src.target, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] is trying to put a [] on []</B>", src.source, src.item, src.target), 1)
	else
		var/message = null
		switch(src.place)
			if("l_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s left hand!</B>", src.source, src.target.l_hand, src.target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s right hand!</B>", src.source, src.target.r_hand, src.target)
			if("back")
				message = text("\red <B>[] is trying to take off a [] from []'s back!</B>", src.source, src.target.back, src.target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", src.source, src.target)
			if("internal")
				if (src.target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", src.source, src.target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", src.source, src.target)
			else
		for(var/mob/M in viewers(src.target, null))
			M.show_message(message, 1)
	spawn( 30 )
		src.done()
		return
	return

/obj/equip_e/monkey/done()
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
		if("l_hand")
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
		if("r_hand")
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
					src.source.drop_item()
					src.target.handcuffed = src.item
					src.item.loc = src.target
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
						src.target.internal.add_fingerprint(src.source)
						for(var/mob/M in viewers(src.target, 1))
							if ((M.client && !( M.blinded )))
								M.show_message(text("[] is now running on internals.", src.target), 1)
		else
	src.source.update_clothing()
	src.target.update_clothing()
	del(src)
	return