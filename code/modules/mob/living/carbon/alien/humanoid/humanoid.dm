
//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien")
		src.name = text("alien ([rand(1, 1000)])")
	src.real_name = src.name
	spawn (1)
		if(!istype(src, /mob/living/carbon/alien/humanoid/queen))
			src.stand_icon = new /icon('alien.dmi', "alien_s")
			src.lying_icon = new /icon('alien.dmi', "alien_l")
		src.icon = src.stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"
	..()


//This is fine, works the same as a human
/mob/living/carbon/alien/humanoid/Bump(atom/movable/AM as mob|obj, yes)
	spawn( 0 )
		if ((!( yes ) || src.now_pushing))
			return
		src.now_pushing = 0
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!src.now_pushing)
			src.now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/window/win in get_step(AM,t))
							src.now_pushing = 0
							return
				step(AM, t)
			src.now_pushing = null
		return
	return

/mob/living/carbon/alien/humanoid/movement_delay()
	var/tally = 0
	if (istype(src, /mob/living/carbon/alien/humanoid/queen))
		tally += 5
	if (istype(src, /mob/living/carbon/alien/humanoid/drone))
		tally += 2
	if (istype(src, /mob/living/carbon/alien/humanoid/sentinel))
		tally += 1
	return tally

//This needs to be fixed
/mob/living/carbon/alien/humanoid/Stat()
	..()

	statpanel("Status")
	if (src.client && src.client.holder)
		stat(null, "([x], [y], [z])")

	stat(null, "Intent: [src.a_intent]")
	stat(null, "Move Mode: [src.m_intent]")

	if (src.client.statpanel == "Status")
		stat(null, "Plasma Stored: [src.toxloss]")

/mob/living/carbon/alien/humanoid/bullet_act(flag, A as obj)
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
			if(src.paralysis <= 12)	src.paralysis = 12
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
	switch(flag)//Did these people not know that switch is a function that exists? I swear, half of the code ignores switch completely.
		if(PROJECTILE_BULLET)
			var/d = 51
			if (src.stat != 2)
				src.bruteloss += d
				src.updatehealth()
				if (prob(50)&&weakened <= 5)
					src.weakened = 5
		if(PROJECTILE_TASER)
			if (prob(75) && src.stunned <= 10)
				src.stunned = 10
			else
				src.weakened = 10
		if(PROJECTILE_DART)//Nothing is supposed to happen, just making sure it's listed.

		if(PROJECTILE_LASER)
			var/d = 20
	//		if (!src.eye_blurry) src.eye_blurry = 4 //This stuff makes no sense but lasers need a buff./ It really doesn't make any sense. /N
			if (prob(25)) src.stunned++
			if (src.stat != 2)
				src.bruteloss += d
				src.updatehealth()
				if (prob(25))
					src.stunned = 1
		if(PROJECTILE_PULSE)
			var/d = 40

			if (src.stat != 2)
				src.bruteloss += d
				src.updatehealth()
				if (prob(50))
					src.stunned = min(src.stunned, 5)
		if(PROJECTILE_BOLT)
			src.toxloss += 3
			src.radiation += 100
			src.updatehealth()
			src.drowsyness += 5
	return

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(wear_suit) wear_suit.emp_act(severity)
	if(head) head.emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
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

			src.ear_damage += 30
			src.ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				src.paralysis += 1
			src.ear_damage += 15
			src.ear_deaf += 60

	src.bruteloss += b_loss
	src.fireloss += f_loss

	src.updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if (src.stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (src.stat != 2)
		damage = rand(30,40)

	if(shielded)
		damage /= 4


	src.show_message("\red The magma splashes on you!")

	src.fireloss += damage

	return

//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
	else if (W == head)
		head = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

/mob/living/carbon/alien/humanoid/db_click(text, t1)
	var/obj/item/W = src.equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)

//if emptyhand then wear the suit, no bedsheet clothes for the alien

		if("o_clothing")
			if (src.wear_suit)
				if (emptyHand)
					src.wear_suit.DblClick()
				return
			if (( istype(W, /obj/alien/skin_suit) ))
				src.u_equip(W)
				src.head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			src.u_equip(W)
			src.wear_suit = W
			W.equipped(src, text)
*/
		if("head")
			if (src.head)
				if (emptyHand)
					src.head.DblClick()
				return
			if (( istype(W, /obj/alien/head) ))
				src.u_equip(W)
				src.head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/head) ))
				return
			src.u_equip(W)
			src.head = W
			W.equipped(src, text)
*/
		if("storage1")
			if (src.l_store)
				if (emptyHand)
					src.l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			src.u_equip(W)
			src.l_store = W
		if("storage2")
			if (src.r_store)
				if (emptyHand)
					src.r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			src.u_equip(W)
			src.r_store = W
		else
	return

/mob/living/carbon/alien/humanoid/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (src.health > 0)
		src.bruteloss += (istype(O, /obj/meteor/small) ? 10 : 25)
		src.fireloss += 30

		src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/Move(a, b, flag)
	if (src.buckled)
		return 0

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
					diary <<"src.pulling disappeared? at __LINE__ in mob.dm - src.pulling = [src.pulling]"
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
	if ((src.s_active && !( s_active in src.contents ) ))
		src.s_active.close(src)
	return

/mob/living/carbon/alien/humanoid/update_clothing()
	..()

	if (src.monkeyizing)
		return

	src.overlays = null

	if(src.buckled)
		if(istype(src.buckled, /obj/stool/bed))
			src.lying = 1
		else
			src.lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (src.zone_sel)
		src.zone_sel.overlays = null
		src.zone_sel.overlays += src.body_standing
		src.zone_sel.overlays += image("icon" = 'zone_sel.dmi', "icon_state" = text("[]", src.zone_sel.selecting))

	if (src.lying)
		if(src.update_icon)
			src.icon = src.lying_icon

		src.overlays += src.body_lying

		if (src.face_lying)
			src.overlays += src.face_lying
	else
		if(src.update_icon)
			src.icon = src.stand_icon

		src.overlays += src.body_standing

		if (src.face_standing)
			src.overlays += src.face_standing

	// Uniform
	if (src.client)
		src.client.screen -= src.hud_used.other
		src.client.screen -= src.hud_used.intents
		src.client.screen -= src.hud_used.mov_int

	// ???
	if (src.client && src.other)
		src.client.screen += src.hud_used.other


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
		var/t1 = src.wear_suit.item_state
		if (!t1)
			t1 = src.wear_suit.icon_state
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.wear_suit.blood_DNA)
			if (istype(src.wear_suit, /obj/item/clothing/suit/armor))
				src.overlays += image("icon" = 'blood.dmi', "icon_state" = "armorblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
			else
				src.overlays += image("icon" = 'blood.dmi', "icon_state" = "suitblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
		src.wear_suit.screen_loc = ui_iclothing
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
		var/t1 = src.head.item_state
		if (!t1)
			t1 = src.head.icon_state
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = text("[][]", t1, (!( src.lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (src.head.blood_DNA)
			src.overlays += image("icon" = 'blood.dmi', "icon_state" = "helmetblood[!src.lying ? "" : "2"]", "layer" = MOB_LAYER)
		src.head.screen_loc = ui_oclothing

	if (src.l_store)
		src.l_store.screen_loc = ui_storage1

	if (src.r_store)
		src.r_store.screen_loc = ui_storage2

	if (src.client)
		src.client.screen -= src.contents
		src.client.screen += src.contents

	if (src.r_hand)
		src.overlays += image("icon" = 'items_righthand.dmi', "icon_state" = src.r_hand.item_state ? src.r_hand.item_state : src.r_hand.icon_state, "layer" = MOB_LAYER+1)

		src.r_hand.screen_loc = ui_id

	if (src.l_hand)
		src.overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = src.l_hand.item_state ? src.l_hand.item_state : src.l_hand.icon_state, "layer" = MOB_LAYER+1)

		src.l_hand.screen_loc = ui_belt



	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if (shielded == 2 || src.alien_invis)
		src.invisibility = 2
	else
		src.invisibility = 0

	if (shielded || src.alien_invis)
		src.overlays += image("icon" = 'mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				src.show_inv(M)
				return

	src.last_b_state = src.stat

/mob/living/carbon/alien/humanoid/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (src.health > 0)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			bruteloss  += rand(1, 3)

			src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!ismonkey(M))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	..()

	switch(M.a_intent)

		if ("help")
			src.help_shake_act(M)
		else
			if (istype(src.wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (src.health > 0)
				playsound(src.loc, 'bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
				src.bruteloss  += rand(1, 3)
				src.updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	if(M.gloves && M.gloves.elecgen == 1)//Stungloves. Any contact will stun the alien.
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (src.weakened < 5)
				src.weakened = 5
			if (src.stuttering < 5)
				src.stuttering = 5
			if (src.stunned < 5)
				src.stunned = 5
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall.", 2)

	switch(M.a_intent)

		if ("help")
			if (src.health > 0)
				src.help_shake_act(M)
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
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)

		if ("hurt")
			var/damage = rand(1, 9)
			if (prob(90))
				if (M.mutations & HULK)//HULK SMASH
					damage += 14
					spawn(0)
						src.paralysis += 5
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(src.loc, "punch", 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
				if (damage > 9||prob(5))//Regular humans have a very small chance of weakening an alien.
					if (src.weakened < 10)
						src.weakened = rand(1,5)
					for(var/mob/O in viewers(M, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
				src.bruteloss += damage
				src.updatehealth()
			else
				playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)

		if ("disarm")
			if (!src.lying)
				var/randn = rand(1, 100)
				if (randn <= 5)//Very small chance to push an alien down.
					src.weakened = 2
					playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
				else
					if (randn <= 50)
						src.drop_item()
						playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
					else
						playsound(src.loc, 'punchmiss.ogg', 25, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/

/mob/living/carbon/alien/humanoid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(src.loc, /turf) && istype(src.loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	..()

	switch(M.a_intent)

		if ("help")
			src.sleeping = 0
			src.resting = 0
			if (src.paralysis >= 3) src.paralysis -= 3
			if (src.stunned >= 3) src.stunned -= 3
			if (src.weakened >= 3) src.weakened -= 3
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\blue [M.name] nuzzles [] trying to wake it up!", src), 1)

		else
			if (src.health > 0)
				playsound(src.loc, 'bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				src.bruteloss += damage
				src.updatehealth()
			else
				M << "\green <B>[src.name] is too injured for that.</B>"
	return


/mob/living/carbon/alien/humanoid/restrained()
	if (src.handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[src.name]</FONT></B>
	<BR><HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(src.l_hand ? text("[]", src.l_hand) : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(src.r_hand ? text("[]", src.r_hand) : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(src.head ? text("[]", src.head) : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(src.wear_suit ? text("[]", src.wear_suit) : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[src.name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[src.name];size=340x480"))
	onclose(user, "mob[src.name]")
	return

/mob/living/carbon/alien/humanoid/updatehealth()
	if (src.nodamage == 0)
	//oxyloss is only used for suicide
	//toxloss isn't used for aliens, its actually used as alien powers!!
		src.health = 100 - src.oxyloss - src.fireloss - src.bruteloss
	else
		src.health = 100
		src.stat = 0

