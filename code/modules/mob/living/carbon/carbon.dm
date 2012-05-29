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
			var/obj/item/I = user.equipped()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
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
			playsound(src.loc, 'thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"\blue [M] shakes [src] trying to wake [t_him] up!", \
				"\blue You shake [src] trying to wake [t_him] up!", \
				)

/mob/living/carbon/proc/eyecheck()
	return 0

