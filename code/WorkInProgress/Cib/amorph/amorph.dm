/mob/living/carbon/amorph
	name = "amorph"
	real_name = "amorph"
	voice_name = "amorph"
	icon = 'icons/mob/amorph.dmi'
	icon_state = ""


	var/species = "Amorph"
	age = 30.0

	var/used_skillpoints = 0
	var/skill_specialization = null
	var/list/skills = null

	var/obj/item/l_ear = null

	// might use this later to recolor armorphs with icon.SwapColor
	var/slime_color = null

	var/examine_text = ""


/mob/living/carbon/amorph/New()

	..()

	// Amorphs don't have a blood vessel, but they can have reagents in their body
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	// Amorphs have no DNA(they're more like carbon-based machines)

	// Amorphs don't have organs
	..()

/mob/living/carbon/amorph/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM

//BubbleWrap - Should stop you pushing a restrained person out of the way

		if(istype(tmob, /mob/living/carbon/human))

			for(var/mob/M in range(tmob, 1))
				if( ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restrained, you cannot push past"
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						src << "\red [tmob] is restraining [M], you cannot push past"
					now_pushing = 0
					return

		//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		if((tmob.a_intent == "help" || tmob.restrained()) && (a_intent == "help" || src.restrained()) && tmob.canmove && canmove) // mutual brohugs all around!
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			for(var/mob/living/carbon/metroid/Metroid in view(1,tmob))
				if(Metroid.Victim == tmob)
					Metroid.UpdateFeed()
			return

		if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
			if(prob(99))
				now_pushing = 0
				return
		if(tmob.nopush)
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
				if (istype(AM, /obj/structure/window))
					if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
				step(AM, t)
			now_pushing = 0
		return
	return

/mob/living/carbon/amorph/movement_delay()
	var/tally = 2 // amorphs are a bit slower than humans
	var/mob/M = pulling

	if(reagents.has_reagent("hyperzine")) return -1

	if(reagents.has_reagent("nuka_cola")) return -1

	if(analgesic) return -1

	if (istype(loc, /turf/space)) return -1 // It's hard to be slowed down in space by... anything

	var/health_deficiency = traumatic_shock
	if(health_deficiency >= 40) tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70) tally += hungry/300

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75
		if (stuttering < 10)
			stuttering = 10

	if(shock_stage >= 10) tally += 3

	if(tally < 0)
		tally = 0

	if(istype(M) && M.lying) //Pulling lying down people is slower
		tally += 3

	if(mRun in mutations)
		tally = 0

	return tally

/mob/living/carbon/amorph/Stat()
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
			if (mind.special_role == "Changeling" && changeling)
				stat("Chemical Storage", changeling.chem_charges)
				stat("Genetic Damage Time", changeling.geneticdamage)

/mob/living/carbon/amorph/ex_act(severity)
	flick("flash", flash)

	var/shielded = 0
	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			if (!prob(getarmor(null, "bomb")))
				gib()
				return
			else
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, 200, 4)

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/1.5
				f_loss = f_loss/1.5

		if(3.0)
			b_loss += 30
			if (!prob(getarmor(null, "bomb")))
				b_loss = b_loss/2
			if (prob(50) && !shielded)
				Paralyse(10)

	src.bruteloss += b_loss
	src.fireloss  += f_loss

	UpdateDamageIcon()


/mob/living/carbon/amorph/blob_act()
	if(stat == 2)	return
	show_message("\red The blob attacks you!")
	src.bruteloss += rand(30,40)
	UpdateDamageIcon()
	return

/mob/living/carbon/amorph/u_equip(obj/item/W as obj)
	// These are the only slots an amorph has
	if (W == l_ear)
		l_ear = null
	else if (W == r_hand)
		r_hand = null

	update_clothing()

/mob/living/carbon/amorph/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)
		if("l_ear")
			if (l_ear)
				if (emptyHand)
					l_ear.DblClick()
				return
			else if(emptyHand)
				return
			if (!( istype(W, /obj/item/clothing/ears) ) && !( istype(W, /obj/item/device/radio/headset) ) && W.w_class != 1)
				return
			u_equip(W)
			l_ear = W
			W.equipped(src, text)

	update_clothing()

	return

/mob/living/carbon/amorph/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		if (istype(O, /obj/effect/immovablerod))
			src.bruteloss += 101
		else
			src.bruteloss += 25
			UpdateDamageIcon()
		updatehealth()
	return

/mob/living/carbon/amorph/Move(a, b, flag)

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
						if (M.lying && (prob(M.getBruteLoss() / 6)))
							var/turf/location = M.loc
							if (istype(location, /turf/simulated))
								location.add_blood(M)
								if(ishuman(M))
									var/mob/living/carbon/H = M
									var/blood_volume = round(H:vessel.get_reagent_amount("blood"))
									if(blood_volume > 0)
										H:vessel.remove_reagent("blood",1)
							if(prob(5))
								M.adjustBruteLoss(1)
								visible_message("\red \The [M]'s wounds open more from being dragged!")
						if(M.pull_damage())
							if(prob(25))
								M.adjustBruteLoss(2)
								visible_message("\red \The [M]'s wounds worsen terribly from being dragged!")
								var/turf/location = M.loc
								if (istype(location, /turf/simulated))
									location.add_blood(M)
									if(ishuman(M))
										var/mob/living/carbon/H = M
										var/blood_volume = round(H:vessel.get_reagent_amount("blood"))
										if(blood_volume > 0)
											H:vessel.remove_reagent("blood",1)

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
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)

	for(var/mob/living/carbon/metroid/M in view(1,src))
		M.UpdateFeed(src)
	return

/mob/living/carbon/amorph/proc/misc_clothing_updates()
	// Temporary proc to shove stuff in that was put into update_clothing()
	// for questionable reasons

	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4
			else
				m_select.screen_loc = null

	// Probably a lazy way to make sure all items are on the screen exactly once
	if (client)
		client.screen -= contents
		client.screen += contents

/mob/living/carbon/amorph/rebuild_appearance()
	// Lazy method: Just rebuild everything.
	// This can be called when the mob is created, but on other occasions, rebuild_body_overlays(),
	// rebuild_clothing_overlays() etc. should be called individually.

	misc_clothing_updates() // silly stuff

/mob/living/carbon/amorph/update_body_appearance()
	// Should be called whenever something about the body appearance itself changes.

	misc_clothing_updates() // silly stuff

	if(lying)
		icon_state = "lying"
	else
		icon_state = "standing"

/mob/living/carbon/amorph/update_lying()
	// Should be called whenever something about the lying status of the mob might have changed.

	if(lying)
		icon_state = "lying"
	else
		icon_state = "standing"

/mob/living/carbon/amorph/hand_p(mob/M as mob)
	// not even sure what this is meant to do
	return

/mob/living/carbon/amorph/restrained()
	if (handcuffed)
		return 0 // handcuffs don't work on amorphs
	return 0

/mob/living/carbon/amorph/var/co2overloadtime = null
/mob/living/carbon/amorph/var/temperature_resistance = T0C+75

/mob/living/carbon/amorph/show_inv(mob/user as mob)
	// TODO: add a window for extracting stuff from an amorph's mouth

// called when something steps onto an amorph
// this could be made more general, but for now just handle mulebot
/mob/living/carbon/amorph/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB))
		MB.RunOver(src)

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/amorph/proc/get_assignment(var/if_no_id = "No id", var/if_no_job = "No job")
	// TODO: get the ID from the amorph's contents
	return

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/amorph/proc/get_authentification_name(var/if_no_id = "Unknown")
	// TODO: get the ID from the amorph's contents
	return

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/amorph/proc/get_visible_name()
	// amorphs can't wear clothes or anything, so always return face_name
	return get_face_name()

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/amorph/proc/get_face_name()
	// there might later be ways for amorphs to change the appearance of their face
	return "[real_name]"


//gets ID card object from special clothes slot or null.
/mob/living/carbon/amorph/proc/get_idcard()
	// TODO: get the ID from the amorph's contents


// heal the amorph
/mob/living/carbon/amorph/heal_overall_damage(var/brute, var/burn)
	bruteloss -= brute
	fireloss -= burn
	bruteloss = max(bruteloss, 0)
	fireloss  = max(fireloss, 0)

	updatehealth()
	UpdateDamageIcon()

// damage MANY external organs, in random order
/mob/living/carbon/amorph/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	bruteloss += brute
	fireloss += burn

	updatehealth()
	UpdateDamageIcon()

/mob/living/carbon/amorph/Topic(href, href_list)
	if (href_list["refresh"])
		if((machine)&&(in_range(src, usr)))
			show_inv(machine)

	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		machine = null
		src << browse(null, t1)

	if ((href_list["item"] && !( usr.stat ) && usr.canmove && !( usr.restrained() ) && in_range(src, usr) && ticker)) //if game hasn't started, can't make an equip_e
		var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human(  )
		O.source = usr
		O.target = src
		O.item = usr.equipped()
		O.s_loc = usr.loc
		O.t_loc = loc
		O.place = href_list["item"]
		if(href_list["loc"])
			O.internalloc = href_list["loc"]
		requests += O
		spawn( 0 )
			O.process()
			return

	if (href_list["criminal"])
		if(istype(usr, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
				var/perpname = "wot"
				var/modified = 0

				/*if(wear_id)
					if(istype(wear_id,/obj/item/weapon/card/id))
						perpname = wear_id:registered_name
					else if(istype(wear_id,/obj/item/device/pda))
						var/obj/item/device/pda/tempPda = wear_id
						perpname = tempPda.owner
				else*/
				perpname = src.name

				for (var/datum/data/record/E in data_core.general)
					if (E.fields["name"] == perpname)
						for (var/datum/data/record/R in data_core.security)
							if (R.fields["id"] == E.fields["id"])

								var/setcriminal = input(usr, "Specify a new criminal status for this person.", "Security HUD", R.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Parolled", "Released", "Cancel")

								if(istype(H.glasses, /obj/item/clothing/glasses/hud/security) || istype(H.glasses, /obj/item/clothing/glasses/sunglasses/sechud))
									if(setcriminal != "Cancel")
										R.fields["criminal"] = setcriminal
										modified = 1

										spawn()
											H.handle_regular_hud_updates()

				if(!modified)
					usr << "\red Unable to locate a data core entry for this person."
	..()
	return


///eyecheck()
///Returns a number between -1 to 2
/mob/living/carbon/amorph/eyecheck()
	return 1


/mob/living/carbon/amorph/IsAdvancedToolUser()
	return 1//Amorphs can use guns and such


/mob/living/carbon/amorph/updatehealth()
	if(src.nodamage)
		src.health = 100
		src.stat = 0
		return
	src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss() - src.getCloneLoss() -src.halloss
	return

/mob/living/carbon/amorph/abiotic(var/full_body = 0)
	return 0

/mob/living/carbon/amorph/abiotic2(var/full_body2 = 0)
	return 0

/mob/living/carbon/amorph/getBruteLoss()
	return src.bruteloss

/mob/living/carbon/amorph/adjustBruteLoss(var/amount, var/used_weapon = null)
	src.bruteloss += amount
	if(bruteloss < 0) bruteloss = 0

/mob/living/carbon/amorph/getFireLoss()
	return src.fireloss

/mob/living/carbon/amorph/adjustFireLoss(var/amount,var/used_weapon = null)
	src.fireloss += amount
	if(fireloss < 0) fireloss = 0

/mob/living/carbon/amorph/get_visible_gender()
	return gender
