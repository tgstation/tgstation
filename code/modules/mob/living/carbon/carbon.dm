/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
		if((FAT in src.mutations) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("\red You hear something rumbling inside [src]'s stomach..."), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ("chest")
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						if(temp.take_damage(d, 0))
							H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("\red <B>[M] bursts out of [src]!</B>"), 2)
	. = ..()

/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return

	for(var/datum/disease/D in viruses)
		var/s_spread_type
		if(D.spread_type!=SPECIAL && D.spread_type!=AIRBORNE)
			s_spread_type = D.spread_type
			D.spread_type = CONTACT_HANDS
			M.contract_disease(D)
			D.spread_type = s_spread_type

	for(var/datum/disease/D in M.viruses)
		var/s_spread_type
		if(D.spread_type!=SPECIAL && D.spread_type!=AIRBORNE)
			s_spread_type = D.spread_type
			D.spread_type = CONTACT_HANDS
			contract_disease(D)
			D.spread_type = s_spread_type

	/*		// old code: doesn't support multiple viruses
	if(src.virus || M.virus)
		var/s_spread_type
		if(src.virus && src.virus.spread_type!=SPECIAL && src.virus.spread_type!=AIRBORNE)
			s_spread_type = src.virus.spread_type
			src.virus.spread_type = CONTACT_HANDS
			M.contract_disease(src.virus)
			src.virus.spread_type = s_spread_type

		if(M.virus && M.virus.spread_type!=SPECIAL && M.virus.spread_type!=AIRBORNE)
			s_spread_type = M.virus.spread_type
			M.virus.spread_type = CONTACT_GENERAL
			src.contract_disease(M.virus)
			M.virus.spread_type = s_spread_type
	*/
	return


/mob/living/carbon/attack_paw(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return


	for(var/datum/disease/D in viruses)
		var/s_spread_type
		if(D.spread_type!=SPECIAL && D.spread_type!=AIRBORNE)
			s_spread_type = D.spread_type
			D.spread_type = CONTACT_HANDS
			M.contract_disease(D)
			D.spread_type = s_spread_type

	for(var/datum/disease/D in M.viruses)
		var/s_spread_type
		if(D.spread_type!=SPECIAL && D.spread_type!=AIRBORNE)
			s_spread_type = D.spread_type
			D.spread_type = CONTACT_HANDS
			contract_disease(D)
			D.spread_type = s_spread_type

	/*

	if(src.virus || M.virus)
		var/s_spread_type
		if(src.virus && src.virus.spread_type!=SPECIAL && src.virus.spread_type!=AIRBORNE)
			s_spread_type = src.virus.spread_type
			src.virus.spread_type = CONTACT_HANDS
			M.contract_disease(src.virus)
			src.virus.spread_type = s_spread_type

		if(M.virus && M.virus.spread_type!=SPECIAL && M.virus.spread_type!=AIRBORNE)
			s_spread_type = M.virus.spread_type
			M.virus.spread_type = CONTACT_GENERAL
			src.contract_disease(M.virus)
			M.virus.spread_type = s_spread_type
	*/
	return

/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0
	src.take_overall_damage(0,shock_damage)
	//src.burn_skin(shock_damage)
	//src.adjustFireLoss(shock_damage) //burn_skin will do this for us
	//src.updatehealth()
	src.visible_message(
		"\red [src] was shocked by the [source]!", \
		"\red <B>You feel a powerful shock course through your body!</B>", \
		"\red You hear a heavy electrical crack." \
	)
//	if(src.stunned < shock_damage)	src.stunned = shock_damage
	Stun(10)//This should work for now, more is really silly and makes you lay there forever
//	if(src.weakened < 20*siemens_coeff)	src.weakened = 20*siemens_coeff
	Weaken(10)
	return shock_damage


/mob/living/carbon/proc/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/weapon/twohanded))
			if(item_in_hand:wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [item_in_hand.name]</span>"
				return
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "hand_active"
			hud_used.r_hand_hud_object.icon_state = "hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_active"
	/*if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH*/
	return

/mob/living/carbon/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

	if(selhand == "right" || selhand == "r")
		selhand = 0
	if(selhand == "left" || selhand == "l")
		selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health > 0)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("\blue [src] examines [].",src.gender==MALE?"himself":"herself"), \
				"\blue You check yourself for injuries." \
				)

			for(var/datum/organ/external/org in H.organs)
				var/status = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "bleeding"
				if(brutedamage > 40)
					status = "mangled"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"\blue ":"\red ",org.getDisplayName(),status),1)
			if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			src.sleeping = max(0,src.sleeping-5)
			if(src.sleeping == 0)
				src.resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"\blue [M] shakes [src] trying to wake [t_him] up!", \
				"\blue You shake [src] trying to wake [t_him] up!", \
				)

/mob/living/carbon/proc/eyecheck()
	return 0

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/proc/handle_ventcrawl() // -- TLE -- Merged by Carn

	if(!stat)
		if(!lying)

			var/obj/machinery/atmospherics/unary/vent_pump/vent_found
			for(var/obj/machinery/atmospherics/unary/vent_pump/v in range(1,src))
				if(!v.welded)
					vent_found = v
				else
					src << "\red That vent is welded."

			if(vent_found)
				if(vent_found.network&&vent_found.network.normal_members.len)
					var/list/vents[0]
					for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in vent_found.network.normal_members)
						if(temp_vent.loc == loc)
							continue
						if(temp_vent.welded)
							continue
						var/turf/T = get_turf(temp_vent)

						if(!T || T.z != loc.z)
							continue

						var/i = 1
						var/index = "[T.loc.name]\[[i]\]"
						while(index in vents)
							i++
							index = "[T.loc.name]\[[i]\]"
						vents[index] = temp_vent

					var/turf/startloc = loc
					var/obj/selection = input("Select a destination.", "Duct System") as null|anything in sortList(vents)
					if(!selection)	return
					if(loc==startloc)
						if(contents.len)
							for(var/obj/item/carried_item in contents)//If the monkey got on objects.
								if( !istype(carried_item, /obj/item/weapon/implant) && !istype(carried_item, /obj/item/clothing/mask/facehugger) )//If it's not an implant or a facehugger
									src << "\red You can't be carrying items or have items equipped when vent crawling!"
									return
						var/obj/machinery/atmospherics/unary/vent_pump/target_vent = vents[selection]
						if(target_vent)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("<B>[src] scrambles into the ventillation ducts!</B>"), 1)
							loc = target_vent

							var/travel_time = round(get_dist(loc, target_vent.loc) / 2)

							spawn(travel_time)

								if(!target_vent)	return
								for(var/mob/O in hearers(target_vent,null))
									O.show_message("You hear something squeezing through the ventilation ducts.",2)

								sleep(travel_time)

								if(!target_vent)	return
								if(target_vent.welded)			//the vent can be welded while alien scrolled through the list or travelled.
									target_vent = vent_found 	//travel back. No additional time required.
									src << "\red The vent you were heading to appears to be welded."
								loc = target_vent.loc

					else
						src << "You need to remain still while entering a vent."
				else
					src << "This vent is not connected to anything."

			else
				src << "You must be standing on or beside an air vent to enter it."

		else
			src << "You can't vent crawl while you're stunned!"

	else
		src << "You must be conscious to do this!"
	return


/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves(0)
	update_icons()	//apply the now updated overlays to the mob


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	var/obj/item/W = get_active_hand()
	if( !W )//Not holding anything
		if( client && (TK in mutations) )
			var/obj/item/tk_grab/O = new(src)
			put_in_active_hand(O)
			O.host = src
		return

	if( istype(W,/obj/item/tk_grab) )
		if(hand)	del(l_hand)
		else		del(r_hand)
		return

	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	src.throw_icon.icon_state = "act_throw_on"

/mob/living/carbon/proc/throw_item(atom/target)
	src.throw_mode_off()
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen) return

	var/atom/movable/item = src.get_active_hand()

	if(!item) return

	if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw() //throw the person instead of the grab
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")

				log_attack("<font color='red'>[usr.name] ([usr.ckey]) Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				log_admin("ATTACK: [usr.name] ([usr.ckey]) Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]")
				msg_admin_attack("ATTACK: [usr.name] ([usr.ckey]) Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]")

	if(!item) return //Grab processing has a chance of returning null

	u_equip(item)
	update_icons()
	if(src.client)
		src.client.screen -= item

	item.loc = src.loc

	if(istype(item, /obj/item))
		item:dropped(src) // let it know it's been dropped

	//actually throw it!
	if (item)
		item.layer = initial(item.layer)
		src.visible_message("\red [src] has thrown [item].")

		if(!src.lastarea)
			src.lastarea = get_area(src.loc)
		if((istype(src.loc, /turf/space)) || (src.lastarea.has_gravity == 0))
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/


		item.throw_at(target, item.throw_range, item.throw_speed)

/mob/living/carbon/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > CARBON_LIFEFORM_FIRE_RESISTANCE)
		adjustFireLoss(CARBON_LIFEFORM_FIRE_DAMAGE)
	..()
