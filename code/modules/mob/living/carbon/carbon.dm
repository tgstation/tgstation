/mob/living/carbon/New()
	create_reagents(1000)
	..()

/mob/living/carbon/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/carbon/proc/prepare_data_huds()
	..()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/carbon/updatehealth()
	..()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/carbon/Destroy()
	for(var/atom/movable/guts in internal_organs)
		qdel(guts)
	for(var/atom/movable/food in stomach_contents)
		qdel(food)
	remove_from_all_data_huds()
	if(dna)
		qdel(dna)
	return ..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == RUN)
				src.nutrition -= HUNGER_FACTOR/10
			else if(src.m_intent == SPRINT)
				src.nutrition -= 2*HUNGER_FACTOR/10
		if((src.disabilities & FAT) && src.bodytemperature <= 360)
			if(src.m_intent == RUN)
				src.bodytemperature += 2
			else if(src.m_intent == SPRINT)
				src.bodytemperature += 10

/mob/living/carbon/movement_delay()
	. = 0
	if(legcuffed)
		. += legcuffed.slowdown

/mob/living/carbon/relaymove(mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			if(prob(25))
				audible_message("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>", \
							 "<span class='warning'>You hear something rumbling.</span>", 4,\
							  "<span class='userdanger'>Something is rumbling inside your stomach!</span>")
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ("chest")
					if (istype(organ, /obj/item/organ/limb))
						var/obj/item/organ/limb/temp = organ
						if(temp.take_damage(d, 0))
							H.update_damage_overlays(0)
					H.updatehealth()
				else
					src.take_organ_damage(d)
				visible_message("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>", \
									"<span class='userdanger'>[user] attacks your stomach wall with the [I.name]!</span>")
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.loc = loc
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/gib(animation = 1)
	for(var/mob/M in src)
		if(M in stomach_contents)
			stomach_contents.Remove(M)
		M.loc = loc
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")
	. = ..()


/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, override = 0)
	shock_damage *= siemens_coeff
	if(shock_damage<1 && !override)
		return 0
	take_overall_damage(0,shock_damage)
	//src.burn_skin(shock_damage)
	//src.adjustFireLoss(shock_damage) //burn_skin will do this for us
	//src.updatehealth()
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>" \
	)
	jitteriness += 1000 //High numbers for violent convulsions
	do_jitter_animation(jitteriness)
	stuttering += 2
	Stun(2)
	spawn(20)
		jitteriness = max(jitteriness - 990, 10) //Still jittery, but vastly less
		Stun(3)
		Weaken(3)
	if(override)
		return override
	else
		return shock_damage


/mob/living/carbon/swap_hand()
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

/mob/living/carbon/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

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

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	var/damage = intensity - check_eye_prot()
	if(..()) // we've been flashed
		if(weakeyes)
			Stun(2)
		switch(damage)
			if(1)
				src << "<span class='warning'>Your eyes sting a little.</span>"
				if(prob(40))
					eye_stat += 1

			if(2)
				src << "<span class='warning'>Your eyes burn.</span>"
				eye_stat += rand(2, 4)

			else
				src << "<span class='warning'>Your eyes itch and burn severely!</span>"
				eye_stat += rand(12, 16)

		if(eye_stat > 10)
			eye_blind += damage
			eye_blurry += damage * rand(3, 6)

			if(eye_stat > 20)
				if (prob(eye_stat - 20))
					src << "<span class='warning'>Your eyes start to burn badly!</span>"
					disabilities |= NEARSIGHT
				else if(prob(eye_stat - 25))
					src << "<span class='warning'>You can't see anything!</span>"
					disabilities |= BLIND
			else
				src << "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>"
		return 1

	else if(damage == 0) // just enough protection
		if(prob(20))
			src << "<span class='notice'>Something bright flashes in the corner of your vision!</span>"

/mob/living/carbon/proc/tintcheck()
	return 0

//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
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
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen)) return

	var/atom/movable/item = src.get_active_hand()

	if(!item || (item.flags & NODROP)) return

	if(istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.get_mob_if_throwable() //throw the person instead of the grab
		qdel(G)			//We delete the grab, as it needs to stay around until it's returned.
		if(ismob(item))
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				var/mob/M = item
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				add_logs(src, M, "thrown", addition="from [start_T_descriptor] with the target [end_T_descriptor]")

	if(!item) return //Grab processing has a chance of returning null

	if(!ismob(item)) //Honk mobs don't have a dropped() proc honk
		unEquip(item)
	if(src.client)
		src.client.screen -= item

	//actually throw it!
	if(item)
		item.layer = initial(item.layer)
		src.visible_message("<span class='danger'>[src] has thrown [item].</span>")

		newtonian_move(get_dir(target, src))

		item.throw_at(target, item.throw_range, item.throw_speed, src)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/proc/canBeHandcuffed()
	return 0


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>				[(head && !(head.flags&ABSTRACT)) 			? head 		: "Nothing"]</A>
	<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>		[(wear_mask && !(wear_mask.flags&ABSTRACT))	? wear_mask	: "Nothing"]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[slot_l_hand]'>		[(l_hand && !(l_hand.flags&ABSTRACT))		? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[slot_r_hand]'>		[(r_hand && !(r_hand.flags&ABSTRACT))		? r_hand	: "Nothing"]</A>"}

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[back ? back : "Nothing"]</A>"

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
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["internal"])
			var/slot = text2num(href_list["internal"])
			var/obj/item/ITEM = get_item_by_slot(slot)
			if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
				visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>")
				if(do_mob(usr, src, POCKET_STRIP_DELAY))
					if(internal)
						internal = null
						if(internals)
							internals.icon_state = "internal0"
					else if(ITEM && istype(ITEM, /obj/item/weapon/tank) && wear_mask && (wear_mask.flags & MASKINTERNALS))
						internal = ITEM
						if(internals)
							internals.icon_state = "internal1"

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>")



/mob/living/carbon/getTrail()
	if(getBruteLoss() < 300)
		if(prob(50))
			return "ltrails_1"
		return "ltrails_2"
	else if(prob(50))
		return "trails_1"
	return "trails_2"

var/const/NO_SLIP_WHEN_WALKING = 1
var/const/SLIDE = 2
var/const/GALOSHES_DONT_HELP = 4
/mob/living/carbon/slip(s_amount, w_amount, obj/O, lube)
	return loc.handle_slip(src, s_amount, w_amount, O, lube)

/mob/living/carbon/fall(forced)
    loc.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/blob_act()
	if (stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>The blob attacks!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/proc/spin(spintime, speed)
	spawn()
		var/D = dir
		while(spintime >= speed)
			sleep(speed)
			switch(D)
				if(NORTH)
					D = EAST
				if(SOUTH)
					D = WEST
				if(EAST)
					D = SOUTH
				if(WEST)
					D = NORTH
			dir = D
			spintime -= speed
	return

/mob/living/carbon/resist_buckle()
	if(restrained())
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		visible_message("<span class='warning'>[src] attempts to unbuckle themself!</span>", \
					"<span class='notice'>You attempt to unbuckle yourself... (This will take around one minute and you need to stay still.)</span>")
		if(do_after(src, 600, needhand = 0, target = src))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src,src)
		else
			if(src && buckled)
				src << "<span class='warning'>You fail to unbuckle yourself!</span>"
	else
		buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	fire_stacks -= 5
	Weaken(3,1)
	spin(32,2)
	visible_message("<span class='danger'>[src] rolls on the floor, trying to put themselves out!</span>", \
		"<span class='notice'>You stop, drop, and roll!</span>")
	sleep(30)
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src] has successfully extinguished themselves!</span>", \
			"<span class='notice'>You extinguish yourself.</span>")
		ExtinguishMob()
	return

/mob/living/carbon/resist_restraints()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(I)


/mob/living/carbon/proc/cuff_resist(obj/item/I, breakouttime = 600, cuff_break = 0)
	if(istype(I, /obj/item/weapon/restraints))
		var/obj/item/weapon/restraints/R = I
		breakouttime = R.breakouttime
	var/displaytime = breakouttime / 600
	if(!cuff_break)
		visible_message("<span class='warning'>[src] attempts to remove [I]!</span>")
		src << "<span class='notice'>You attempt to remove [I]... (This will take around [displaytime] minutes and you need to stand still.)</span>"
		if(do_after(src, breakouttime, 10, 0, target = src))
			if(I.loc != src || buckled)
				return
			visible_message("<span class='danger'>[src] manages to remove [I]!</span>")
			src << "<span class='notice'>You successfully remove [I].</span>"

			if(handcuffed)
				handcuffed.loc = loc
				handcuffed.dropped(src)
				handcuffed = null
				if(buckled && buckled.buckle_requires_restraints)
					buckled.unbuckle_mob()
				update_inv_handcuffed()
				return
			if(legcuffed)
				legcuffed.loc = loc
				legcuffed.dropped()
				legcuffed = null
				update_inv_legcuffed()
		else
			src << "<span class='warning'>You fail to remove [I]!</span>"

	else
		breakouttime = 50
		visible_message("<span class='warning'>[src] is trying to break [I]!</span>")
		src << "<span class='notice'>You attempt to break [I]... (This will take around 5 seconds and you need to stand still.)</span>"
		if(do_after(src, breakouttime, needhand = 0, target = src))
			if(!I.loc || buckled)
				return
			visible_message("<span class='danger'>[src] manages to break [I]!</span>")
			src << "<span class='notice'>You successfully break [I].</span>"
			qdel(I)

			if(handcuffed)
				handcuffed = null
				update_inv_handcuffed()
				return
			else
				legcuffed = null
				update_inv_legcuffed()
		else
			src << "<span class='warning'>You fail to break [I]!</span>"

/mob/living/carbon/proc/uncuff()
	if (handcuffed)
		var/obj/item/weapon/W = handcuffed
		handcuffed = null
		if (buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob()
		update_inv_handcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
	if (legcuffed)
		var/obj/item/weapon/W = legcuffed
		legcuffed = null
		update_inv_legcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.loc = loc
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)

/mob/living/carbon/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	if( (!mask_only && head && (head.flags_cover & HEADCOVERSMOUTH)) || (!head_only && wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH)) )
		return 1

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	if(lying)
		return -6
	else
		return initial(pixel_y)

/mob/living/carbon/check_ear_prot()
	if(head && (head.flags & HEADBANGPROTECT))
		return 1

/mob/living/carbon/proc/accident(obj/item/I)
	if(!I || (I.flags & (NODROP|ABSTRACT)))
		return

	unEquip(I)

	var/modifier = 0
	if(disabilities & CLUMSY)
		modifier -= 40 //Clumsy people are more likely to hit themselves -Honk!

	switch(rand(1,100)+modifier) //91-100=Nothing special happens
		if(-INFINITY to 0) //attack yourself
			I.attack(src,src)
		if(1 to 30) //throw it at yourself
			I.throw_impact(src)
		if(31 to 60) //Throw object in facing direction
			var/turf/target = get_turf(loc)
			var/range = rand(2,I.throw_range)
			for(var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, dir)
				target = new_turf
				if(new_turf.density)
					break
			I.throw_at(target,I.throw_range,I.throw_speed,src)
		if(61 to 90) //throw it down to the floor
			var/turf/target = get_turf(loc)
			I.throw_at(target,I.throw_range,I.throw_speed,src)

/mob/living/carbon/emp_act(severity)
	for(var/obj/item/organ/internal/O in internal_organs)
		O.emp_act(severity)
	..()

/mob/living/carbon/check_eye_prot()
	var/number = ..()
	for(var/obj/item/organ/internal/cyberimp/eyes/EFP in internal_organs)
		number += EFP.flash_protect
	return number

/mob/living/carbon/proc/AddAbility(obj/effect/proc_holder/alien/A)
	abilities.Add(A)
	A.on_gain(src)
	if(A.has_action)
		if(!A.action)
			A.action = new/datum/action/spell_action/alien
			A.action.target = A
			A.action.name = A.name
			A.action.button_icon = A.action_icon
			A.action.button_icon_state = A.action_icon_state
			A.action.background_icon_state = A.action_background_icon_state
		A.action.Grant(src)
	sortInsert(abilities, /proc/cmp_abilities_cost, 0)

/mob/living/carbon/proc/RemoveAbility(obj/effect/proc_holder/alien/A)
	abilities.Remove(A)
	A.on_lose(src)
	if(A.action)
		A.action.Remove(src)

/mob/living/carbon/proc/add_abilities_to_panel()
	for(var/obj/effect/proc_holder/alien/A in abilities)
		statpanel("[A.panel]",A.plasma_cost > 0?"([A.plasma_cost])":"",A)

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/alien/plasmavessel/vessel = getorgan(/obj/item/organ/internal/alien/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.storedPlasma]/[vessel.max_plasma]")
		if(locate(/obj/item/device/assembly/health) in src)
			stat(null, "Health: [health]")

	add_abilities_to_panel()

/mob/living/carbon/proc/vomit(var/lost_nutrition = 10, var/blood)
	if(src.is_muzzled())
		src << "<span class='warning'>The muzzle prevents you from vomiting!</span>"
		return 0
	Stun(4)
	if(nutrition < 100 && !blood)
		visible_message("<span class='warning'>[src] dry heaves!</span>", \
						"<span class='userdanger'>You try to throw up, but there's nothing your stomach!</span>")
		Weaken(10)
	else
		visible_message("<span class='danger'>[src] throws up!</span>", \
						"<span class='userdanger'>You throw up!</span>")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		var/turf/T = get_turf(src)
		if(blood)
			if(T)
				T.add_blood_floor(src)
			adjustBruteLoss(3)
		else
			if(T)
				T.add_vomit_floor(src)
			nutrition -= lost_nutrition
			adjustToxLoss(-3)
	return 1
