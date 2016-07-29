<<<<<<< HEAD
/mob/living/carbon
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/New()
	create_reagents(1000)
	..()

/mob/living/carbon/Destroy()
	for(var/atom/movable/guts in internal_organs)
		qdel(guts)
	for(var/atom/movable/food in stomach_contents)
		qdel(food)
	for(var/BP in bodyparts)
		qdel(BP)
	bodyparts = list()
	remove_from_all_data_huds()
	if(dna)
		qdel(dna)
	return ..()

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
					var/organ = H.get_bodypart("chest")
					if (istype(organ, /obj/item/bodypart))
						var/obj/item/bodypart/temp = organ
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


/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, override = 0, tesla_shock = 0)
	shock_damage *= siemens_coeff
	if(dna && dna.species)
		shock_damage *= dna.species.siemens_coeff
	if(shock_damage<1 && !override)
		return 0
	if(reagents.has_reagent("teslium"))
		shock_damage *= 1.5 //If the mob has teslium in their body, shocks are 50% more damaging!
	take_overall_damage(0,shock_damage)
	//src.adjustFireLoss(shock_damage)
	//src.updatehealth()
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>" \
	)
	jitteriness += 1000 //High numbers for violent convulsions
	do_jitter_animation(jitteriness)
	stuttering += 2
	if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
		Stun(2)
	spawn(20)
		jitteriness = max(jitteriness - 990, 10) //Still jittery, but vastly less
		if(!tesla_shock || (tesla_shock && siemens_coeff > 0.5))
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
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()
	/*if (!( src.hand ))
		src.hands.setDir(NORTH)
	else
		src.hands.setDir(SOUTH)*/
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
	if(on_fire)
		M << "<span class='warning'>You can't put them out with just your bare hands!"
		return

	if(health >= 0 && !(status_flags & FAKEDEATH))

		if(lying)
			M.visible_message("<span class='notice'>[M] shakes [src] trying to get them up!</span>", \
							"<span class='notice'>You shake [src] trying to get them up!</span>")
		else
			M.visible_message("<span class='notice'>[M] hugs [src] to make them feel better!</span>", \
						"<span class='notice'>You hug [src] to make them feel better!</span>")
		AdjustSleeping(-5)
		AdjustParalysis(-3)
		AdjustStunned(-3)
		AdjustWeakened(-3)
		if(resting)
			resting = 0
			update_canmove()

		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	. = ..()

	var/damage = intensity - check_eye_prot()
	if(.) // we've been flashed
		if(visual)
			return
		if(weakeyes)
			Stun(2)

		if (damage == 1)
			src << "<span class='warning'>Your eyes sting a little.</span>"
			if(prob(40))
				adjust_eye_damage(1)

		else if (damage == 2)
			src << "<span class='warning'>Your eyes burn.</span>"
			adjust_eye_damage(rand(2, 4))

		else if( damage > 3)
			src << "<span class='warning'>Your eyes itch and burn severely!</span>"
			adjust_eye_damage(rand(12, 16))

		if(eye_damage > 10)
			blind_eyes(damage)
			blur_eyes(damage * rand(3, 6))

			if(eye_damage > 20)
				if(prob(eye_damage - 20))
					if(become_nearsighted())
						src << "<span class='warning'>Your eyes start to burn badly!</span>"
				else if(prob(eye_damage - 25))
					if(become_blind())
						src << "<span class='warning'>You can't see anything!</span>"
			else
				src << "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>"
		if(has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
		return 1
	else if(damage == 0) // just enough protection
		if(prob(20))
			src << "<span class='notice'>Something bright flashes in the corner of your vision!</span>"
		if(has_bane(BANE_LIGHT))
			mind.disrupt_spells(0)


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
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_off"


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = 1
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen))
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = src.get_active_hand()

	if(!I)
		if(pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			var/mob/living/throwable_mob = pulling
			if(!throwable_mob.buckled)
				thrown_thing = throwable_mob
				stop_pulling()
				var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
				var/turf/end_T = get_turf(target)
				if(start_T && end_T)
					var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
					var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"
					add_logs(src, throwable_mob, "thrown", addition="from [start_T_descriptor] with the target [end_T_descriptor]")

	else if(!(I.flags & (NODROP|ABSTRACT)))
		thrown_thing = I
		unEquip(I)

	if(thrown_thing)
		visible_message("<span class='danger'>[src] has thrown [thrown_thing].</span>")
		newtonian_move(get_dir(target, src))
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src)

/mob/living/carbon/restrained(ignore_grab)
	. = (handcuffed || (!ignore_grab && pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE))

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
						update_internals_hud_icon(0)
					else if(ITEM && istype(ITEM, /obj/item/weapon/tank))
						if((wear_mask && (wear_mask.flags & MASKINTERNALS)) || getorganslot("breathing_tube"))
							internal = ITEM
							update_internals_hud_icon(1)

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>")


/mob/living/carbon/fall(forced)
    loc.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/blob_act(obj/effect/blob/B)
	if (stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>The blob attacks!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/proc/spin(spintime, speed)
	set waitfor = 0
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
		setDir(D)
		spintime -= speed

/mob/living/carbon/resist_buckle()
	if(restrained())
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		visible_message("<span class='warning'>[src] attempts to unbuckle themself!</span>", \
					"<span class='notice'>You attempt to unbuckle yourself... (This will take around one minute and you need to stay still.)</span>")
		if(do_after(src, 600, 0, target = src))
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
	breakouttime = I.breakouttime
	var/displaytime = breakouttime / 600
	if(!cuff_break)
		visible_message("<span class='warning'>[src] attempts to remove [I]!</span>")
		src << "<span class='notice'>You attempt to remove [I]... (This will take around [displaytime] minutes and you need to stand still.)</span>"
		if(do_after(src, breakouttime, 0, target = src))
			clear_cuffs(I, cuff_break)
		else
			src << "<span class='warning'>You fail to remove [I]!</span>"

	else if(cuff_break == FAST_CUFFBREAK)
		breakouttime = 50
		visible_message("<span class='warning'>[src] is trying to break [I]!</span>")
		src << "<span class='notice'>You attempt to break [I]... (This will take around 5 seconds and you need to stand still.)</span>"
		if(do_after(src, breakouttime, 0, target = src))
			clear_cuffs(I, cuff_break)
		else
			src << "<span class='warning'>You fail to break [I]!</span>"

	else if(cuff_break == INSTANT_CUFFBREAK)
		clear_cuffs(I, cuff_break)

/mob/living/carbon/proc/uncuff()
	if (handcuffed)
		var/obj/item/weapon/W = handcuffed
		handcuffed = null
		if (buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
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

/mob/living/carbon/proc/clear_cuffs(obj/item/I, cuff_break)
	if(!I.loc || buckled)
		return
	visible_message("<span class='danger'>[src] manages to [cuff_break ? "break" : "remove"] [I]!</span>")
	src << "<span class='notice'>You successfully [cuff_break ? "break" : "remove"] [I].</span>"

	if(cuff_break)
		qdel(I)
		if(I == handcuffed)
			handcuffed = null
			update_handcuffed()
			return
		else if(I == legcuffed)
			legcuffed = null
			update_inv_legcuffed()
			return
		return TRUE

	else
		if(I == handcuffed)
			handcuffed.loc = loc
			handcuffed.dropped(src)
			handcuffed = null
			if(buckled && buckled.buckle_requires_restraints)
				buckled.unbuckle_mob(src)
			update_handcuffed()
			return
		if(I == legcuffed)
			legcuffed.loc = loc
			legcuffed.dropped()
			legcuffed = null
			update_inv_legcuffed()
			return
		return TRUE

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
	for(var/obj/item/organ/O in internal_organs)
		O.emp_act(severity)
	..()

/mob/living/carbon/check_eye_prot()
	var/number = ..()
	for(var/obj/item/organ/cyberimp/eyes/EFP in internal_organs)
		number += EFP.flash_protect
	return number

/mob/living/carbon/proc/AddAbility(obj/effect/proc_holder/alien/A)
	abilities.Add(A)
	A.on_gain(src)
	if(A.has_action)
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
		var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.storedPlasma]/[vessel.max_plasma]")
		if(locate(/obj/item/device/assembly/health) in src)
			stat(null, "Health: [health]")

	add_abilities_to_panel()

/mob/living/carbon/proc/vomit(var/lost_nutrition = 10, var/blood = 0, var/stun = 1, var/distance = 0, var/message = 1, var/toxic = 0)
	if(nutrition < 100 && !blood)
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing your stomach!</span>")
		if(stun)
			Weaken(10)
		return 1

	if(is_mouth_covered()) //make this add a blood/vomit overlay later it'll be hilarious
		if(message)
			visible_message("<span class='danger'>[src] throws up all over themself!</span>", \
							"<span class='userdanger'>You throw up all over yourself!</span>")
		distance = 0
	else
		if(message)
			visible_message("<span class='danger'>[src] throws up!</span>", "<span class='userdanger'>You throw up!</span>")

	if(stun)
		Stun(4)

	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
	var/turf/T = get_turf(src)
	for(var/i=0 to distance)
		if(blood)
			if(T)
				add_splatter_floor(T)
			if(stun)
				adjustBruteLoss(3)
		else
			if(T)
				T.add_vomit_floor(src, 0)//toxic barf looks different
			nutrition -= lost_nutrition
			adjustToxLoss(-3)
		T = get_step(T, dir)
		if (is_blocked_turf(T))
			break
	return 1



/mob/living/carbon/fully_replace_character_name(oldname,newname)
	..()
	if(dna)
		dna.real_name = real_name

/mob/living/carbon/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	for(var/obj/item/organ/cyberimp/eyes/E in internal_organs)
		sight |= E.sight_flags
		if(E.dark_view)
			see_in_dark = max(see_in_dark,E.dark_view)
		if(E.see_invisible)
			see_invisible = min(see_invisible, E.see_invisible)

	if(see_override)
		see_invisible = see_override


//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!tinted_weldhelh)
		return
	tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		overlay_fullscreen("tint", /obj/screen/fullscreen/blind)
	else if(tinttotal >= TINT_DARKENED)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
	else
		clear_fullscreen("tint", 0)

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = head
		. += HT.tint
	if(wear_mask)
		. += wear_mask.tint

//this handles hud updates
/mob/living/carbon/update_damage_hud()

	if(!client)
		return

	if(stat == UNCONSCIOUS && health <= config.health_threshold_crit)
		var/severity = 0
		switch(health)
			if(-20 to -10) severity = 1
			if(-30 to -20) severity = 2
			if(-40 to -30) severity = 3
			if(-50 to -40) severity = 4
			if(-60 to -50) severity = 5
			if(-70 to -60) severity = 6
			if(-80 to -70) severity = 7
			if(-90 to -80) severity = 8
			if(-95 to -90) severity = 9
			if(-INFINITY to -95) severity = 10
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		if(oxyloss)
			var/severity = 0
			switch(oxyloss)
				if(10 to 20) severity = 1
				if(20 to 25) severity = 2
				if(25 to 30) severity = 3
				if(30 to 35) severity = 4
				if(35 to 40) severity = 5
				if(40 to 45) severity = 6
				if(45 to INFINITY) severity = 7
			overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15) severity = 1
				if(15 to 30) severity = 2
				if(30 to 45) severity = 3
				if(45 to 70) severity = 4
				if(70 to 85) severity = 5
				if(85 to INFINITY) severity = 6
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = 1
			if(!shown_health_amount)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth*0.8)
				hud_used.healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth*0.4)
				hud_used.healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/carbon/proc/update_internals_hud_icon(internal_state = 0)
	if(hud_used && hud_used.internals)
		hud_used.internals.icon_state = "internal[internal_state]"

/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health<= config.health_threshold_dead || !getorgan(/obj/item/organ/brain))
			death()
			return
		if(paralysis || sleeping || getOxyLoss() > 50 || (status_flags & FAKEDEATH) || health <= config.health_threshold_crit)
			if(stat == CONSCIOUS)
				stat = UNCONSCIOUS
				blind_eyes(1)
				update_canmove()
		else
			if(stat == UNCONSCIOUS)
				stat = CONSCIOUS
				resting = 0
				adjust_blindness(-1)
				update_canmove()
	update_damage_hud()
	update_health_hud()
	med_hud_set_status()

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
	else
		clear_alert("handcuffed")
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()
	update_hud_handcuffed()

/mob/living/carbon/fully_heal(admin_revive = 0)
	if(reagents)
		reagents.clear_reagents()
	var/obj/item/organ/brain/B = getorgan(/obj/item/organ/brain)
	if(B)
		B.damaged_brain = 0
	for(var/datum/disease/D in viruses)
		D.cure(0)
	if(admin_revive)
		handcuffed = initial(handcuffed)
		for(var/obj/item/weapon/restraints/R in contents) //actually remove cuffs from inventory
			qdel(R)
		update_handcuffed()
		if(reagents)
			reagents.addiction_list = list()
	..()

/mob/living/carbon/can_be_revived()
	. = ..()
	if(!getorgan(/obj/item/organ/brain))
		return 0

/mob/living/carbon/harvest(mob/living/user)
	if(qdeleted(src))
		return
	var/organs_amt = 0
	for(var/obj/item/organ/O in internal_organs)
		if(prob(50))
			organs_amt++
			O.Remove(src)
			O.loc = get_turf(src)
	if(organs_amt)
		user << "<span class='notice'>You retrieve some of [src]\'s internal organs!</span>"

	..()

/mob/living/carbon/adjustToxLoss(amount, updating_health=1)
	if(has_dna() && TOXINLOVER in dna.species.specflags) //damage becomes healing and healing becomes damage
		amount = -amount
		if(amount > 0)
			blood_volume -= 5*amount
		else
			blood_volume -= amount
	return ..()

/mob/living/carbon/fakefire(var/fire_icon = "Generic_mob_burning")
	overlays_standing[FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"= fire_icon, "layer"=-FIRE_LAYER)
	apply_overlay(FIRE_LAYER)

/mob/living/carbon/fakefireextinguish()
	remove_overlay(FIRE_LAYER)

=======
/mob/living/carbon/Login()
	..()
	update_hud()
	return

/mob/living/carbon/Bump(var/atom/movable/AM)
	if(now_pushing)
		return
	..()
	if(istype(AM, /mob/living/carbon) && prob(10))
		src.spread_disease_to(AM, "Contact")


/mob/living/carbon/Move(NewLoc,Dir=0,step_x=0,step_y=0)
	. = ..()

	if(.)
		if(nutrition && stat != DEAD)
			burn_calories(HUNGER_FACTOR / 20)

			if(m_intent == "run")
				burn_calories(HUNGER_FACTOR / 20)
		update_minimap()

/mob/living/carbon/attack_animal(mob/living/simple_animal/M as mob)//humans and slimes have their own
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='warning'><B>[M]</B> [M.attacktext] \the [src] !</span>")
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG)
		if(M.zone_sel && M.zone_sel.selecting)
			dam_zone = M.zone_sel.selecting
		var/datum/organ/external/affecting = ran_zone(dam_zone)
		apply_damage(damage,M.melee_damage_type, affecting)
		updatehealth()


/mob/living/carbon/proc/update_minimap()
	var/obj/item/device/pda/pda_device = machine
	if(machine && istype(pda_device))
		var/turf/user_loc = get_turf(src)
		var/turf/pda_loc = get_turf(pda_device)
		if(get_dist(user_loc,pda_loc) <= 1)
			if(pda_device.mode == PDA_APP_STATIONMAP)
				pda_device.attack_self(src)
		else
			unset_machine()
			src << browse(null, "window=pda")

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ(LIMB_CHEST)
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						if(temp.take_damage(d, 0))
							H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)
				src.delayNextMove(10) //no just holding the key for an instant gib

/mob/living/carbon/gib()
	dropBorers(1)
	drop_stomach_contents()
	src.visible_message("<span class='warning'>Something bursts from \the [src]'s stomach!</span>")
	. = ..()

/mob/living/carbon/proc/share_contact_diseases(var/mob/M)
	for(var/datum/disease/D in viruses)
		if(D.spread_by_touch())
			M.contract_disease(D, 0, 1, CONTACT_HANDS)
	for(var/datum/disease/D in M.viruses)
		if(D.spread_by_touch())
			contract_disease(D, 0, 1, CONTACT_HANDS)

/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	if (hasorgans(M))
		var/datum/organ/external/temp = find_organ_by_grasp_index(active_hand)

		if(temp && !temp.is_usable())
			to_chat(M, "<span class='warning'>You can't use your [temp.display_name]</span>")
			return
	share_contact_diseases(M)
	return


/mob/living/carbon/attack_paw(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	share_contact_diseases(M)
	return

/mob/living/carbon/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		damage = 0

	if(dna.mutantrace == "slime")
		heal_overall_damage(damage/2, damage/2)
		Jitter(10)
		Stun(5)
		Weaken(5)
		//It would be cool if someone added an animation of some electrical shit going through the body
	else
		if(take_overall_damage(0, damage, used_weapon = "[source]") == 0) // godmode
			return 0
		Jitter(20)
		Stun(10)
		Weaken(10)

	visible_message( \
		"<span class='warning'>[src] was shocked by the [source]!</span>", \
		"<span class='danger'>You feel a powerful shock course through your body!</span>", \
		"<span class='warning'>You hear a heavy electrical crack.</span>", \
		"<span class='notice'>[src] starts raving!</span>", \
		"<span class='notice'>You feel butterflies in your stomach!</span>", \
		"<span class='warning'>You hear a policeman whistling!</span>"
	)

	//if(src.stunned < shock_damage)	src.stunned = shock_damage
	//if(src.weakened < 20*siemens_coeff)	src.weakened = 20*siemens_coeff

	var/datum/effect/effect/system/spark_spread/SparkSpread = new
	SparkSpread.set_up(5, 1, loc)
	SparkSpread.start()

	return damage

/mob/living/carbon/swap_hand()
	if(++active_hand > held_items.len)
		active_hand = 1

	for(var/obj/screen/inventory/hand_hud_object in hud_used.hand_hud_objects)
		if(active_hand == hand_hud_object.hand_index)
			hand_hud_object.icon_state = "hand_active"
		else
			hand_hud_object.icon_state = "hand_inactive"

	return

/mob/living/carbon/activate_hand(var/selhand)
	active_hand = selhand

	for(var/obj/screen/inventory/hand_hud_object in hud_used.hand_hud_objects)
		if(active_hand == hand_hud_object.hand_index)
			hand_hud_object.icon_state = "hand_active"
		else
			hand_hud_object.icon_state = "hand_inactive"

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
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
					status = "<span class='warning'>bleeding</span>"
				if(brutedamage > 40)
					status = "<span class='danger'>mangled</span>"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "<span class='orangeb'>peeling away</span>"

				else if(burndamage > 10)
					status += "<span class='orangei'>blistered</span>"
				else if(burndamage > 0)
					status += "numb"
				if(org.status & ORGAN_DESTROYED)
					status = "MISSING!"
				if(org.status & ORGAN_MUTATED)
					status = "weirdly shapen."
				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"<span class='notice'></span>":"<span class='danger'></span>",org.display_name,status),1)
			if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else if(lying) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
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
			playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
				"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>", \
				drugged_message = "<span class='notice'>[M] starts massaging [src]'s back.</span>", \
				self_drugged_message = "<span class='notice'>You start massaging [src]'s back.</span>"
				)
		// BEGIN HUGCODE - N3X
		else
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] gives [src] a [pick("hug","warm embrace")].</span>", \
				"<span class='notice'>You hug [src].</span>", \
				)
			reagents.add_reagent(PARACETAMOL, 1)

			share_contact_diseases(M)

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
			H.gloves.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves(0)
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob


//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = 0
	if(throw_icon)
		throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	if(gcDestroyed) return
	in_throw_mode = 1
	if(throw_icon)
		throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(var/atom/target,var/atom/movable/what=null)
	return

/mob/living/carbon/throw_item(var/atom/target,var/atom/movable/what=null)
	src.throw_mode_off()
	if(usr.stat || !target)
		return

	if(!istype(loc,/turf))
		to_chat(src, "<span class='warning'>You can't do that now!</span>")
		return

	if(target.type == /obj/screen) return

	var/atom/movable/item = src.get_active_hand()
	if(what)
		item=what

	if(!item) return

	if (istype(item, /obj/item/offhand))
		var/obj/item/offhand/offhand = item
		if(offhand.wielding)
			src.throw_item(target, offhand.wielding)
			return

	else if (istype(item, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = item
		item = G.toss() //throw the person instead of the grab
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
				if(!iscarbon(usr))
					M.LAssailant = null
				else
					M.LAssailant = usr
				returnToPool(G)
	if(!item) return //Grab processing has a chance of returning null

	var/obj/item/I = item
	if(istype(I) && I.cant_drop > 0)
		to_chat(usr, "<span class='warning'>It's stuck to your hand!</span>")
		return

	remove_from_mob(item)

	//actually throw it!
	if (item)
		item.forceMove(get_turf(src))
		src.visible_message("<span class='warning'>[src] has thrown [item].</span>", \
			drugged_message = "<span class='warning'>[item] escapes from [src]'s grasp and flies away!</span>")

		if((istype(src.loc, /turf/space)) || (src.areaMaster && (src.areaMaster.has_gravity == 0)))
			var/mob/space_obj=src
			// If we're being held, make the guy holding us move.
			if(istype(loc,/obj/item/weapon/holder))
				var/obj/item/weapon/holder/Ho=loc
				// Who holds the holder?
				if(ismob(Ho.loc))
					space_obj=Ho.loc
			space_obj.inertia_dir = get_dir(target, src)
			step(space_obj, inertia_dir)


/*
		if(istype(src.loc, /turf/space) || (src.flags & NOGRAV)) //they're in space, move em one space in the opposite direction
			src.inertia_dir = get_dir(target, src)
			step(src, inertia_dir)
*/


		var/throw_mult=1
		if(istype(src,/mob/living/carbon/human))
			var/mob/living/carbon/human/H=src
			throw_mult = H.species.throw_mult
			if(M_HULK in H.mutations || M_STRONG in H.mutations)
				throw_mult+=0.5
		item.throw_at(target, item.throw_range*throw_mult, item.throw_speed*throw_mult)

/*mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)*/

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(locked_to && ! istype(locked_to, /obj/structure/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if(timestopped) return 1 //under effects of time magick
	if (handcuffed)
		return 1
	return

/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)
	var/dat = ""

	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=handcuff'>Remove</A>"
	else
		for(var/i = 1 to held_items.len) //Hands
			var/obj/item/I = held_items[i]
			dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"

	dat += "<BR>"

	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if(href_list["hands"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_hand(usr, text2num(href_list["hands"])) //href_list "hands" is the hand index, not the item itself. example, GRASP_LEFT_HAND

	else if(href_list["item"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_slot(usr, text2num(href_list["item"])) //href_list "item" would actually be the item slot, not the item itself. example: slot_head

	else if(href_list["internals"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		set_internals(usr)

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_2SLOW)
			temp = rand(20, 40)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		to_chat(usr, "<span class='warning'>You are already sleeping.</span>")
		return
	if(alert(src,"Are you sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 150 //Long nap of 5 minutes. Those are MC TICKS. Don't get fooled

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()
	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	do_release_control(0)

/mob/living/carbon/proc/do_release_control(var/rptext=1)
	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		if(rptext)
			to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")
			to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	verbs -= /mob/living/carbon/proc/release_control
	verbs -= /mob/living/carbon/proc/punish_host

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

//Check for brain worms in given limb.
/mob/proc/has_brain_worms(var/host_region = LIMB_HEAD)
	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			var/mob/living/simple_animal/borer/B = I
			if(B.hostlimb == host_region)
				return B

	return 0

/mob/proc/get_brain_worms()
	var/list/borers_in_mob = list()
	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			var/mob/living/simple_animal/borer/B = I
			borers_in_mob.Add(B)
	if(borers_in_mob.len)
		return borers_in_mob
	else
		return 0

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))


/mob/living/carbon/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return (health < config.health_threshold_crit) && (stat != DEAD)

/mob/living/carbon/get_default_language()
	if(default_language)
		return default_language

	return null

/mob/living/carbon/html_mob_check(var/typepath)
	for(var/atom/movable/AM in html_machines)
		if(typepath == AM.type)
			if(Adjacent(AM))
				return 1
	return 0

/mob/living/carbon/CheckSlip()
	return !locked_to && !lying && !unslippable

/mob/living/carbon/proc/Slip(stun_amount, weaken_amount, slip_on_walking = 0)
	if(!slip_on_walking && m_intent == "walk")
		return 0

	if (CheckSlip() < 1 || !on_foot())
		return 0

	stop_pulling()
	Stun(stun_amount)
	Weaken(weaken_amount)

	playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)

	return 1

/mob/living/carbon/proc/transferImplantsTo(mob/living/carbon/newmob)
	for(var/obj/item/weapon/implant/I in src)
		I.loc = newmob
		I.implanted = 1
		I.imp_in = newmob
		if(istype(newmob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = newmob
			if(!I.part) //implanted as a nonhuman, won't have one.
				I.part = /datum/organ/external/chest
			for (var/datum/organ/external/affected in H.organs)
				if(!istype(affected, I.part)) continue
				affected.implants += I

/mob/living/carbon/proc/dropBorers(var/gibbed = null)
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		B.detach()
		if(gibbed)
			to_chat(B, "<span class='danger'>As your host is violently destroyed, so are you!</span>")
			B.ghostize(0)
			qdel(B)
		else
			to_chat(B, "<span class='notice'>You're forcefully popped out of your host!</span>")

/mob/living/carbon/proc/transferBorers(mob/living/target)
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		B.detach()
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			B.perform_infestation(C)
		else
			to_chat(B, "<span class='notice'>You're forcefully popped out of your host!</span>")

/mob/living/carbon/proc/drop_stomach_contents(var/target)
	if(!target)
		target = get_turf(src)

	var/mob/living/simple_animal/borer/B = src.has_brain_worms()
	for(var/mob/M in src)//mobs, all of them
		if(M == B)
			continue
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.forceMove(target)

	for(var/obj/O in src)//objects, only the ones in the stomach
		if(O in src.stomach_contents)
			src.stomach_contents.Remove(O)
			O.forceMove(target)

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	if(eyecheck() < intensity)
		..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
