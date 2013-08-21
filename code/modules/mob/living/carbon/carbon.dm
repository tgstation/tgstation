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
					if (istype(organ, /datum/limb))
						var/datum/limb/temp = organ
						if(temp.take_damage(d, 0))
							H.update_damage_overlays(0)
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
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.loc = loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
	. = ..()

/mob/living/carbon/attack_hand(mob/user)
	if(!iscarbon(user)) return

	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			user.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in user.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

	if(lying || isslime(src))
		if(user.a_intent == "help")
			if(surgeries.len)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1
	return 0


/mob/living/carbon/attack_paw(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return


	for(var/datum/disease/D in viruses)

		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)

	for(var/datum/disease/D in M.viruses)

		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

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
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"
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
	else
		mode() // Activate held item

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= 0)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			visible_message( \
				"<span class='notice'>[src] examines \himself.", \
				"<span class='notice'>You check yourself for injuries.</span>")

			for(var/datum/limb/org in H.organs)
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
				src << "\t [status == "OK" ? "\blue" : "\red"] My [org.getDisplayName()] is [status]."
			if(dna && (dna.mutantrace == "skeleton") && !H.w_uniform && !H.wear_suit)
				H.play_xylophone()
		else
			if(ishuman(src))
				var/mob/living/carbon/human/H = src
				if(H.wear_suit)
					H.wear_suit.add_fingerprint(M)
				else if(H.w_uniform)
					H.w_uniform.add_fingerprint(M)

			if(lying)
				sleeping = max(0, sleeping - 5)
				if(sleeping == 0)
					resting = 0
				M.visible_message("<span class='notice'>[M] shakes [src] trying to get \him up!</span>", \
								"<span class='notice'>You shake [src] trying to get \him up!</span>")
			else
				M.visible_message("<span class='notice'>[M] hugs [src] to make \him feel better!</span>", \
								"<span class='notice'>You hug [src] to make \him feel better!</span>")

			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)


/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/proc/tintcheck()
	return 0

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
					if(!vents.len)
						src << "\red There are no available vents to travel to, they could be welded."
						return

					var/turf/startloc = loc
					var/obj/selection = input("Select a destination.", "Duct System") as null|anything in sortList(vents)
					if(!selection)	return
					if(loc==startloc)
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
								var/area/new_area = get_area(loc)
								if(new_area)
									new_area.Entered(src)

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
	var/obj/item/I = get_active_hand()
	if(!I)//Not holding anything
		if(client && (TK in mutations))
			var/obj/item/tk_grab/O = new(src)
			put_in_active_hand(O)
			O.host = src
			return

	if(istype(I, /obj/item/tk_grab))
		if(hand)	del(l_hand)
		else		del(r_hand)
		return

	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = 0
	throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = 1
	throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return
/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen) return

	var/atom/movable/item = src.get_active_hand()

	if(!item) return

	if(istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.throw() //throw the person instead of the grab
		del(G)			//We delete the grab, as it needs to stay around until it's returned.
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been thrown by [usr.name] ([usr.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")
				usr.attack_log += text("\[[time_stamp()]\] <font color='red'>Has thrown [M.name] ([M.ckey]) from [start_T_descriptor] with the target [end_T_descriptor]</font>")

	if(!item) return //Grab processing has a chance of returning null

	u_equip(item)
	if(src.client)
		src.client.screen -= item

	//actually throw it!
	if(item)
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


/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return


/mob/living/carbon/u_equip(obj/item/I)
	if(!I)	return 0

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand(0)
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand(0)
	if(I == back)
		back = null
		update_inv_back(0)
	else if(I == wear_mask)
		wear_mask = null
		update_inv_wear_mask(0)
	else if(I == handcuffed)
		handcuffed = null
		update_inv_handcuffed(0)
	else if(I == legcuffed)
		legcuffed = null
		update_inv_legcuffed(0)

	if(I)
		if(client)
			client.screen -= I
		I.loc = loc
		I.dropped(src)
		if(I)
			I.layer = initial(I.layer)


/mob/living/carbon/proc/get_temperature(var/datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc

		if(C.air_contents.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = C.air_contents.temperature

	else
		loc_temp = environment.temperature

	return loc_temp


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>		[wear_mask	? wear_mask	: "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[slot_l_hand]'>		[l_hand		? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[slot_r_hand]'>		[r_hand		? r_hand	: "Nothing"]</A>"}

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'> [back ? back : "Nothing"]</A>"

	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank))
		dat += "<BR><A href='?src=\ref[src];internal=1'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	if(handcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_handcuffed]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	user << browse(dat, "window=mob\ref[src];size=325x500")
	onclose(user, "mob\ref[src]")

/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))
		if(href_list["internal"])
			if(back && istype(back, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
				visible_message("<span class='danger'>[usr] tries to [internal ? "disable" : "set"] [src]'s internals.</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "disable" : "set"] [src]'s internals.</span>")
				if(do_mob(usr, src, STRIP_DELAY))
					if(internal)
						internal = null
						if(internals)
							internals.icon_state = "internal0"
					else if(back && istype(back, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
						internal = back
						if(internals)
							internals.icon_state = "internal1"

					visible_message("<span class='danger'>[usr] [internal ? "sets" : "disables"] [src]'s internals.</span>", \
									"<span class='userdanger'>[usr] [internal ? "sets" : "disables"] [src]'s internals.</span>")


/mob/living/carbon/attackby(obj/item/I, mob/user)
	if(lying || isslime(src))
		if(surgeries.len)
			if(user.a_intent == "help")
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(user, src))
						return 1

	..()


/mob/living/carbon/say(var/message)
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return

	..(message)

/mob/living/carbon/proc/is_mutantrace(var/mrace)
	if(mrace)
		if(src.dna && src.dna.mutantrace == mrace)
			return 1
	else
		return src.dna && src.dna.mutantrace ? 1 : 0
