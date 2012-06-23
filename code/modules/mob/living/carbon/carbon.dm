/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(src.nutrition && src.stat != 2)
			src.nutrition -= HUNGER_FACTOR/10
			if(src.m_intent == "run")
				src.nutrition -= HUNGER_FACTOR/10
/*		if((FAT in src.mutations) && src.m_intent == "run" && src.bodytemperature <= 360)
			src.bodytemperature += 2
*/
/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("\red You hear something rumbling inside [src]'s stomach..."), 2)
			var/obj/item/I = user.equipped()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ("chest")
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						temp.take_damage(d, 0)
					H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("\red <B>[user] attacks [src]'s stomach wall with the [I.name]!"), 2)
				playsound(user.loc, 'attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
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
	if (M.hand)
		if(ishuman(M) || ismonkey(M))
			var/datum/organ/external/temp = M:organs["l_hand"]
			if(temp.status & DESTROYED)
				M << "\red Yo- wait a minute."
				return
	else
		if(ishuman(M) || ismonkey(M))
			var/datum/organ/external/temp = M:organs["r_hand"]
			if(temp.status & DESTROYED)
				M << "\red Yo- wait a minute."
				return

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
	if (M.hand)
		if(ishuman(M) || ismonkey(M))
			var/datum/organ/external/temp = M:organs["l_hand"]
			if(temp.status & DESTROYED)
				M << "\red Yo- wait a minute."
				return
	else
		if(ishuman(M) || ismonkey(M))
			var/datum/organ/external/temp = M:organs["r_hand"]
			if(temp.status & DESTROYED)
				M << "\red Yo- wait a minute."
				return


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
	src.take_overall_damage(0,shock_damage,"Electrocution")
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
			var/mob/living/carbon/human/H = M
			var/list/damaged = H.get_damaged_organs(1,1)
			visible_message("\blue [src] examines [get_gender_form("itself")].", \
				"\blue You check yourself for injuries.", \
				"You hear a rustle, as someone checks about their person.")

			for(var/datum/organ/external/org in damaged)
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
					status = "blugeoned"
				if(brutedamage > 40)
					status = "mangled"
				if(org.status & BLEEDING && brutedamage)
					status += ",[burndamage ? "" : " and"] bleeding[burndamage ? "," : ""]"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"
				if(org.status & DESTROYED)
					status = "MISSING!"

				if(status == "")
					status = "OK"
				src.show_message(text("\t []My [] is [].",status=="OK"?"\blue ":"\red ",org.getDisplayName(),status),1)
			src.show_message(text("\blue You finish checking yourself."),1)
		else
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			if(!src.sleeping_willingly)
				src.sleeping = max(0,src.sleeping-5)
			if(src.sleeping == 0)
				src.resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"\blue \The [M] shakes \the [src] trying to wake them up!", \
				"\blue You shake \the [src] trying to wake them up!", \
				"You hear someone get shaken.") //Using it or its here have he or his, which made no sense, so sticking with gender neutral for now

/mob/living/carbon/proc/eyecheck()
	return 0

// in a coma from logitis!
/mob/living/carbon/Logout()
	..()

	if(!src.sleeping && !src.admin_observing) // would be exploited by stoxin'd people otherwise ;)
					   // (also make admins set-observing not sleep)
		src.sleeping = 1
		src.sleeping_willingly = 1

/mob/living/carbon/Login()
	..()

	src.admin_observing = 0
	if(src.sleeping_willingly)
		src.sleeping = 0
		src.sleeping_willingly = 0
/*	// Update the hands-indicator on re-join.
	if (!( src.hand ))
		src.hands.dir = NORTH
	else
		src.hands.dir = SOUTH
*/

/mob/living/carbon/human/proc/GetOrgans()
	var/list/L = list(  )
	for(var/t in organs)
		if (istype(organs[text("[]", t)], /datum/organ/external))
			L += organs[text("[]", t)]
	return L

/mob/living/carbon/proc/UpdateDamage()

	if (!(istype(src, /mob/living/carbon/human)))	//Added by Strumpetplaya - Invincible Monkey Fix
		return										//Possibly helps with other invincible mobs like Aliens?
	var/list/L = list(  )
	for(var/t in organs)
		if (istype(organs[text("[]", t)], /datum/organ/external))
			L += organs[text("[]", t)]
	bruteloss = 0
	fireloss = 0
	for(var/datum/organ/external/O in L)
		bruteloss += O.get_damage_brute()
		fireloss += O.get_damage_fire()
	return

/mob/living/carbon/proc/check_dna()
	dna.check_integrity(src)
	return

/mob/living/carbon/proc/get_organ(var/zone)
	if(!zone)	zone = "chest"
	for(var/name in organs)
		var/datum/organ/external/O = organs[name]
		if(O.name == zone)
			return O
	return null

/mob/living/carbon/proc/drip()

/mob/living/carbon/proc/vomit()
	// only humanoids and monkeys can vomit
	if(!istype(src,/mob/living/carbon/human) && !istype(src,/mob/living/carbon/monkey))
		return

	// Make the human vomit on the floor
	for(var/mob/O in viewers(world.view, src))
		O.show_message(text("<b>\red [] throws up!</b>", src), 1)
	playsound(src.loc, 'splat.ogg', 50, 1)

	var/turf/location = loc
	if (istype(location, /turf/simulated))
		location.add_vomit_floor(src, 1)

	nutrition -= 20
	adjustToxLoss(-3)

