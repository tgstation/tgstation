/mob/living/carbon/monkey/New()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src
	if(name == "monkey")
		name = text("monkey ([rand(1, 1000)])")
	real_name = name

	if (!(dna))
		if(gender == NEUTER)
			gender = pick(MALE, FEMALE)
		dna = new /datum/dna( null )
		dna.uni_identity = "00600200A00E0110148FC01300B009"
		dna.struc_enzymes = "43359156756131E13763334D1C369012032164D4FE4CD61544B6C03F251B6C60A42821D26BA3B0FD6"
		dna.unique_enzymes = md5(name)
				//////////blah
		var/gendervar
		if (gender == "male")
			gendervar = add_zero2(num2hex((rand(1,2049)),1), 3)
		else
			gendervar = add_zero2(num2hex((rand(2051,4094)),1), 3)
		dna.uni_identity += gendervar
		dna.uni_identity += "12C"
		dna.uni_identity += "4E2"
		dna.b_type = "A+"
		dna.original_name = real_name

	new /datum/organ/external/chest(src)
	new /datum/organ/external/groin(src)
	new /datum/organ/external/head(src)
	new /datum/organ/external/l_arm(src)
	new /datum/organ/external/r_arm(src)
	new /datum/organ/external/r_leg(src)
	new /datum/organ/external/l_leg(src)

	var/datum/organ/external/part = new /datum/organ/external/l_hand(src)
	part.parent = organs["l_arm"]
	part = new /datum/organ/external/l_foot(src)
	part.parent = organs["l_leg"]
	part = new /datum/organ/external/r_hand(src)
	part.parent = organs["r_arm"]
	part = new /datum/organ/external/r_foot(src)
	part.parent = organs["r_leg"]

	spawn (1)
		if(!stand_icon)
			stand_icon = new /icon('monkey.dmi', "monkey1")
		if(!lying_icon)
			lying_icon = new /icon('monkey.dmi', "monkey0")
		icon = stand_icon
		update_clothing()
		src << "\blue Your icons have been generated!"

	..()
	return

/mob/living/carbon/monkey/movement_delay()
	var/tally = 0
	if(reagents)
		if(reagents.has_reagent("hyperzine")) return -1

		if(reagents.has_reagent("nuka_cola")) return -1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) tally += (health_deficiency / 25)

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
	return tally

/mob/living/carbon/monkey/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			/*if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & FAT)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return*/

			tmob.LAssailant = src
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/monkey/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)
	if ((href_list["item"] && !( usr.stat ) && !( usr.restrained() ) && in_range(src, usr) ))
		var/obj/effect/equip_e/monkey/O = new /obj/effect/equip_e/monkey(  )
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

/mob/living/carbon/monkey/meteorhit(obj/O as obj)
	for(var/mob/M in viewers(src, null))
		M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/shielded = 0
		bruteloss += 30
		if ((O.icon_state == "flaming" && !( shielded )))
			adjustFireLoss(40)
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	return

//mob/living/carbon/monkey/bullet_act(var/obj/item/projectile/Proj)taken care of in living

/mob/living/carbon/monkey/hand_p(mob/M as mob)
	if ((M.a_intent == "hurt" && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
		if ((prob(75) && health > 0))
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			var/damage = rand(1, 5)
			if (mutations & HULK) damage += 10
			bruteloss += damage
			updatehealth()

			for(var/datum/disease/D in M.viruses)
				if(istype(D, /datum/disease/jungle_fever))
					contract_disease(D,1,0)
		else
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
	return

/mob/living/carbon/monkey/attack_paw(mob/M as mob)
	..()

	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if ((M.a_intent == "hurt" && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
			if ((prob(75) && health > 0))
				playsound(loc, 'bite.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has bit [name]!</B>", 1)
				var/damage = rand(1, 5)
				bruteloss += damage
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
				for(var/datum/disease/D in M.viruses)
					if(istype(D, /datum/disease/jungle_fever))
						contract_disease(D,1,0)
				react_to_attack(M)
			else
				for(var/mob/O in viewers(src, null))
					O.show_message("\red <B>[M.name] has attempted to bite [name]!</B>", 1)
	return

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	if(M.gloves)
		if(M.gloves.cell)
			if(M.a_intent == "hurt")
				if(M.gloves.cell.charge >= 2500)
					M.gloves.cell.charge -= 2500
					Weaken(5)
					if (stuttering < 5)
						stuttering = 5
					Stun(5)

					for(var/mob/O in viewers(src, null))
						if (O.client)
							O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
					return
				else
					M << "\red Not enough charge! "
					return

	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (M.a_intent == "hurt")
			var/attack_verb
			switch(M.mutantrace)
				if("lizard")
					attack_verb = "scratch"
				if("plant")
					attack_verb = "slash"
				else
					attack_verb = "punch"

			if(M.type == /mob/living/carbon/human/tajaran)
				attack_verb = "slash"

			if ((prob(75) && health > 0))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has [attack_verb]ed [name]!</B>", M), 1)

				var/damage = rand(5, 10)
				if(M.type != /mob/living/carbon/human/tajaran)
					playsound(loc, "punch", 25, 1, -1)
				else if(M.type == /mob/living/carbon/human/tajaran)
					damage += 10
					playsound(loc, 'slice.ogg', 25, 1, -1)
				if (prob(40))
					damage = rand(10, 15)
					if (paralysis < 5)
						Paralyse(rand(10, 15))
						spawn( 0 )
							for(var/mob/O in viewers(src, null))
								if ((O.client && !( O.blinded )))
									O.show_message(text("\red <B>[] has knocked out [name]!</B>", M), 1)
							return
				bruteloss += damage
				updatehealth()
				react_to_attack(M)
			else
				if(M.type != /mob/living/carbon/human/tajaran)
					playsound(loc, 'punchmiss.ogg', 25, 1, -1)
				else if(M.type == /mob/living/carbon/human/tajaran)
					playsound(loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to [attack_verb] [name]!</B>", M), 1)
				react_to_attack(M)
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
				grabbed_by += G
				G.synch()

				LAssailant = M

				playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red [] has grabbed [name] passively!", M), 1)

				if(prob(1)) react_to_attack(M)
			else
				if (!( paralysis ))
					if (prob(25))
						Paralyse(2)
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has pushed down [name]!</B>", M), 1)
						react_to_attack(M)
					else
						drop_item()
						playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							if ((O.client && !( O.blinded )))
								O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
						react_to_attack(M)
	return

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
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

		if ("hurt")
			if ((prob(95) && health > 0))
				playsound(loc, 'slice.ogg', 25, 1, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if (paralysis < 15)
						Paralyse(rand(10, 15))
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has wounded [name]!</B>", M), 1)
				else
					for(var/mob/O in viewers(src, null))
						if ((O.client && !( O.blinded )))
							O.show_message(text("\red <B>[] has slashed [name]!</B>", M), 1)
				bruteloss += damage
				updatehealth()
				react_to_attack(M)
			else
				playsound(loc, 'slashmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has attempted to lunge at [name]!</B>", M), 1)

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
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [name] passively!", M), 1)

		if ("disarm")
			playsound(loc, 'pierce.ogg', 25, 1, -1)
			var/damage = 5
			if(prob(95))
				Weaken(rand(10,15))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled down [name]!</B>", M), 1)
			else
				drop_item()
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has disarmed [name]!</B>", M), 1)
			bruteloss += damage
			react_to_attack(M)
			updatehealth()
	return



/mob/living/carbon/monkey/attack_metroid(mob/living/carbon/metroid/M as mob)
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

		bruteloss += damage

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

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()
		react_to_attack(M)

	return

/mob/living/carbon/monkey/Stat()
	..()
	statpanel("Status")
	stat(null, text("Intent: []", a_intent))
	stat(null, text("Move Mode: []", m_intent))
	if(client && mind)
		if (client.statpanel == "Status")
			if (mind.special_role == "Changeling" && changeling)
				stat("Chemical Storage", changeling.chem_charges)
				stat("Genetic Damage Time", changeling.geneticdamage)
	return



/mob/living/carbon/monkey/var/icon/stand_icon = null
/mob/living/carbon/monkey/var/icon/lying_icon = null
/mob/living/carbon/monkey/update_clothing()
	if(buckled)
		if(istype(buckled, /obj/structure/stool/bed/chair))
			lying = 0
		else
			lying = 1

	if(!stand_icon || !lying_icon)
		update_body()

	if(update_icon) // Skie
		..()
		overlays = null

	if (lying)
		icon = lying_icon

	else
		icon = stand_icon

	if(client && client.admin_invis)
		invisibility = 100
	else
		invisibility = 0

	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			overlays += image("icon" = 'monkey.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = layer)
			wear_mask.screen_loc = ui_mask

	if (r_hand)
		if(update_icon)
			overlays += image("icon" = 'items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = layer)
		r_hand.screen_loc = ui_rhand

	if (l_hand)
		if(update_icon)
			overlays += image("icon" = 'items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = layer)
		l_hand.screen_loc = ui_lhand

	if (back)
		var/t1 = back.icon_state //apparently tables make me upset and cause my dreams to shatter
		overlays += image("icon" = 'back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = layer)
		back.screen_loc = ui_back

	if (handcuffed && update_icon)
		pulling = null
		if (!( lying ))
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff1", "layer" = layer)
		else
			overlays += image("icon" = 'monkey.dmi', "icon_state" = "handcuff2", "layer" = layer)

	if (client)
		client.screen -= contents
		client.screen += contents
		client.screen -= hud_used.m_ints
		client.screen -= hud_used.mov_int
		if (i_select)
			if (intent)
				client.screen += hud_used.m_ints

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT//What

			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS, FUCKING SHIT//the fuck

			else
				m_select.screen_loc = null
	if(targeted_by && target_locked)
		overlays += target_locked
	else if(targeted_by)
		target_locked = new /obj/effect/target_locked(src)
		overlays += target_locked
	else if(!targeted_by && target_locked)
		del(target_locked)
	for(var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn( 0 )
				show_inv(M)
				return
	return

/mob/living/carbon/monkey/proc/update_body()

	stand_icon = new /icon('monkey.dmi', "torso_s")
	lying_icon = new /icon('monkey.dmi', "torso_l")

	stand_icon.Blend(new /icon('monkey.dmi', "chest_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('monkey.dmi', "chest_l"), ICON_OVERLAY)

	var/datum/organ/external/head = organs["head"]
	if(!head.destroyed)
		stand_icon.Blend(new /icon('monkey.dmi', "head_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('monkey.dmi', "head_l"), ICON_OVERLAY)

	for(var/name in organs)
		var/datum/organ/external/part = organs[name]
		if(!istype(part, /datum/organ/external/groin) \
			&& !istype(part, /datum/organ/external/chest) \
			&& !istype(part, /datum/organ/external/head) \
			&& !part.destroyed)
			stand_icon.Blend(new /icon('monkey.dmi', "[part.icon_name]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('monkey.dmi', "[part.icon_name]_l"), ICON_OVERLAY)

	stand_icon.Blend(new /icon('monkey.dmi', "groin_s"), ICON_OVERLAY)
	lying_icon.Blend(new /icon('monkey.dmi', "groin_l"), ICON_OVERLAY)

/mob/living/carbon/monkey/Move()
	if ((!( buckled ) || buckled.loc != loc))
		buckled = null
	if (buckled)
		return
	if (restrained())
		pulling = null
	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				return 0
	if ((t7 && pulling && get_dist(src, pulling) <= 1))
		if (pulling.anchored)
			pulling = null
		var/T = loc
		. = ..()
		if (!( isturf(pulling.loc) ))
			pulling = null
			return
		if (!( restrained() ))
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((ismob(pulling) && (get_dist(src, pulling) > 1 || diag)))
				if (istype(pulling, type))
					var/mob/M = pulling
					var/mob/t = M.pulling
					M.pulling = null
					step(pulling, get_dir(pulling.loc, T))
					M.pulling = t
			else
				if (pulling)
					if (istype(pulling, /obj/structure/window))
						if(pulling:ini_dir == NORTHWEST || pulling:ini_dir == NORTHEAST || pulling:ini_dir == SOUTHWEST || pulling:ini_dir == SOUTHEAST)
							for(var/obj/structure/window/win in get_step(pulling,get_dir(pulling.loc, T)))
								pulling = null
				if (pulling)
					step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( contents.Find(s_active) )))
		s_active.close(src)

	for(var/mob/living/carbon/metroid/M in view(1,src))
		M.UpdateFeed(src)
	return

/mob/living/carbon/monkey/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/chealth = health
	var/rval = ..()
	if(chealth > health)
		// we were damaged!
		react_to_attack(user)

	return rval

/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return

/mob/living/carbon/monkey/var/co2overloadtime = null
/mob/living/carbon/monkey/var/temperature_resistance = T0C+75

/mob/living/carbon/monkey/emp_act(severity)
	if(wear_id) wear_id.emp_act(severity)
	..()

/mob/living/carbon/monkey/ex_act(severity)
	flick("flash", flash)
	switch(severity)
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(200)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(2.0)
			if (stat != 2)
				bruteloss += 60
				adjustFireLoss(60)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			if (prob(50))
				Paralyse(10)
		else
	return

/mob/living/carbon/monkey/blob_act()
	if (stat != 2)
		adjustFireLoss(60)
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
	if (prob(50))
		Paralyse(10)


/obj/effect/equip_e/monkey/process()
	if (item)
		item.add_fingerprint(source)
	if (!( item ))
		switch(place)
			if("head")
				if (!( target.wear_mask ))
					del(src)
					return
			if("l_hand")
				if (!( target.l_hand ))
					del(src)
					return
			if("r_hand")
				if (!( target.r_hand ))
					del(src)
					return
			if("back")
				if (!( target.back ))
					del(src)
					return
			if("handcuff")
				if (!( target.handcuffed ))
					del(src)
					return
			if("internal")
				if ((!( (istype(target.wear_mask, /obj/item/clothing/mask) && istype(target.back, /obj/item/weapon/tank) && !( target.internal )) ) && !( target.internal )))
					del(src)
					return

	if (item)
		for(var/mob/O in viewers(target, null))
			if ((O.client && !( O.blinded )))
				O.show_message(text("\red <B>[] is trying to put a [] on []</B>", source, item, target), 1)
	else
		var/message = null
		switch(place)
			if("mask")
				if(istype(target.wear_mask, /obj/item/clothing)&&!target.wear_mask:canremove)
					message = text("\red <B>[] fails to take off \a [] from []'s body!</B>", source, target.wear_mask, target)
				else
					message = text("\red <B>[] is trying to take off \a [] from []'s head!</B>", source, target.wear_mask, target)
			if("l_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s left hand!</B>", source, target.l_hand, target)
			if("r_hand")
				message = text("\red <B>[] is trying to take off a [] from []'s right hand!</B>", source, target.r_hand, target)
			if("back")
				message = text("\red <B>[] is trying to take off a [] from []'s back!</B>", source, target.back, target)
			if("handcuff")
				message = text("\red <B>[] is trying to unhandcuff []!</B>", source, target)
			if("internal")
				if (target.internal)
					message = text("\red <B>[] is trying to remove []'s internals</B>", source, target)
				else
					message = text("\red <B>[] is trying to set on []'s internals.</B>", source, target)
			else
		for(var/mob/M in viewers(target, null))
			M.show_message(message, 1)
	spawn( 30 )
		done()
		return
	return

/obj/effect/equip_e/monkey/done()
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
				var/obj/item/W = target.wear_mask
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
		if("l_hand")
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
		if("r_hand")
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
					item.layer = 20
					target.r_hand = item
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
					source.drop_item()
					target.handcuffed = item
					item.loc = target
		if("internal")
			if (target.internal)
				target.internal.add_fingerprint(source)
				target.internal = null
			else
				if (target.internal)
					target.internal = null
				if (!( istype(target.wear_mask, /obj/item/clothing/mask) ))
					return
				else
					if (istype(target.back, /obj/item/weapon/tank))
						target.internal = target.back
						target.internal.add_fingerprint(source)
						for(var/mob/M in viewers(target, 1))
							if ((M.client && !( M.blinded )))
								M.show_message(text("[] is now running on internals.", target), 1)
		else
	source.update_clothing()
	target.update_clothing()
	del(src)
	return

/mob/living/carbon/monkey/IsAdvancedToolUser()//Unless its monkey mode monkeys cant use advanced tools
	if(!ticker)	return 0
	if(!ticker.mode.name == "monkey")	return 0
	return 1

/mob/living/carbon/monkey/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/used_weapon = null)
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1

	if(blocked >= 2)	return 0

	var/datum/organ/external/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = get_organ(check_zone(def_zone))
	if(!organ || organ.destroyed)	return 0
	if(blocked)
		damage = (damage/(blocked+1))

	switch(damagetype)
		if(BRUTE)
			organ.take_damage(damage, 0, sharp, used_weapon)
		if(BURN)
			organ.take_damage(0, damage, sharp, used_weapon)

	if(used_weapon)
		organ.add_wound(used_weapon, damage)

	UpdateDamageIcon()
	updatehealth()
	update_clothing()
	return 1

/*/mob/living/carbon/monkey/UpdateDamageIcon()
	del(body_standing)
	body_standing = list()
	del(body_lying)
	body_lying = list()

	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(!O.destroyed)
			O.update_icon()
			var/icon/DI = new /icon('dam_human.dmi', O.damage_state)			// the damage icon for whole human
			DI.Blend(new /icon('dam_mask.dmi', O.icon_name), ICON_MULTIPLY)		// mask with this organ's pixels
		//		world << "[O.icon_name] [O.damage_state] \icon[DI]"
			body_standing += DI
			DI = new /icon('dam_human.dmi', "[O.damage_state]-2")				// repeat for lying icons
			DI.Blend(new /icon('dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)
		//		world << "[O.r_name]2 [O.d_i_state]-2 \icon[DI]"
			body_lying += DI*/

/mob/living/carbon/monkey/proc/HealDamage(zone, brute, burn)
	var/datum/organ/external/E = get_organ(zone)
	if(istype(E, /datum/organ/external))
		if (E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0
	return

/mob/living/carbon/monkey/proc/get_damaged_organs(var/brute, var/burn)
	var/list/datum/organ/external/parts = list()
	for(var/name in organs)
		var/datum/organ/external/organ = organs[name]
		if((brute && organ.brute_dam) || (burn && organ.burn_dam))
			parts += organ
	return parts

/mob/living/carbon/monkey/proc/get_damageable_organs()
	var/list/datum/organ/external/parts = list()
	for(var/name in organs)
		var/datum/organ/external/organ = organs[name]
		if(organ.brute_dam + organ.burn_dam < organ.max_damage)
			parts += organ
	return parts

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/monkey/heal_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damaged_organs(brute,burn)
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.heal_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/carbon/monkey/take_organ_damage(var/brute, var/burn)
	var/list/datum/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/datum/organ/external/picked = pick(parts)
	picked.take_damage(brute,burn)
	updatehealth()
	UpdateDamageIcon()

// heal MANY external organs, in random order
/mob/living/carbon/monkey/heal_overall_damage(var/brute, var/burn)
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
/mob/living/carbon/monkey/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	var/list/datum/organ/external/parts = get_damageable_organs()

	while(parts.len && (brute>0 || burn>0) )
		var/datum/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		picked.take_damage(brute,burn, 0, used_weapon)

		brute -= (picked.brute_dam-brute_was)
		burn -= (picked.burn_dam-burn_was)

		parts -= picked
	updatehealth()
	UpdateDamageIcon()
