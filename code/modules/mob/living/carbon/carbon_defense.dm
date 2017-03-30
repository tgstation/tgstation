
/mob/living/carbon/get_eye_protection()
	var/number = ..()

	var/obj/item/organ/eyes/E = getorganslot("eye_sight")
	if(!E)
		number = INFINITY //Can't get flashed without eyes
	else
		number += E.flash_protect
	return number

/mob/living/carbon/get_ear_protection()
	if(head && HAS_SECONDARY_FLAG(head, BANG_PROTECT))
		return 1

/mob/living/carbon/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	var/obj/item/bodypart/affecting = get_bodypart(def_zone)
	if(affecting && affecting.dismemberable && affecting.get_damage() >= (affecting.max_damage - P.dismemberment))
		affecting.dismember(P.damtype)

/mob/living/carbon/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked = 0)
	if(!skipcatch)	//ugly, but easy
		if(in_throw_mode && !get_active_held_item())	//empty active hand and we're in throw mode
			if(canmove && !restrained())
				if(istype(AM, /obj/item))
					var/obj/item/I = AM
					if(isturf(I.loc))
						put_in_active_hand(I)
						visible_message("<span class='warning'>[src] catches [I]!</span>")
						throw_mode_off()
						return 1
	..()


/mob/living/carbon/attacked_by(obj/item/I, mob/living/user)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
	if(!affecting) //missing limb? we select the first bodypart (you can never have zero, because of chest)
		affecting = bodyparts[1]
	send_item_attack_message(I, user, affecting.name)
	if(I.force)
		apply_damage(I.force, I.damtype, affecting)
		damage_clothes(I.force, I.damtype, "melee", affecting.body_zone)
		if(I.damtype == BRUTE && affecting.status == BODYPART_ORGANIC)
			if(prob(33))
				I.add_mob_blood(src)
				var/turf/location = get_turf(src)
				add_splatter_floor(location)
				if(get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)

				if(affecting.body_zone == "head")
					if(wear_mask)
						wear_mask.add_mob_blood(src)
						update_inv_wear_mask()
					if(wear_neck)
						wear_neck.add_mob_blood(src)
						update_inv_neck()
					if(head)
						head.add_mob_blood(src)
						update_inv_head()

		//dismemberment
		var/probability = I.get_dismemberment_chance(affecting)
		if(prob(probability))
			if(affecting.dismember(I.damtype))
				I.add_mob_blood(src)
				playsound(get_turf(src), I.get_dismember_sound(), 80, 1)
		return TRUE //successful attack

/mob/living/carbon/attack_drone(mob/living/simple_animal/drone/user)
	return //so we don't call the carbon's attack_hand().

/mob/living/carbon/attack_hand(mob/living/carbon/human/user)

	for(var/datum/disease/D in viruses)
		if(D.IsSpreadByTouch())
			user.ContractDisease(D)

	for(var/datum/disease/D in user.viruses)
		if(D.IsSpreadByTouch())
			ContractDisease(D)

	if(lying && surgeries.len)
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user))
					return 1
	return 0


/mob/living/carbon/attack_paw(mob/living/carbon/monkey/M)
	for(var/datum/disease/D in viruses)
		if(D.IsSpreadByTouch())
			M.ContractDisease(D)

	for(var/datum/disease/D in M.viruses)
		if(D.IsSpreadByTouch())
			ContractDisease(D)

	if(M.a_intent == INTENT_HELP)
		help_shake_act(M)
		return 0

	if(..()) //successful monkey bite.
		for(var/datum/disease/D in M.viruses)
			ForceContractDisease(D)
		return 1


/mob/living/carbon/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M.powerlevel > 0)
			var/stunprob = M.powerlevel * 7 + 10  // 17 at level 1, 80 at level 10
			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='danger'>The [M.name] has shocked [src]!</span>", \
				"<span class='userdanger'>The [M.name] has shocked [src]!</span>")

				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				var/power = M.powerlevel + rand(0,3)
				Weaken(power)
				if(stuttering < power)
					stuttering = power
				Stun(power)
				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))
					updatehealth()
		return 1

/mob/living/carbon/proc/dismembering_strike(mob/living/attacker, dam_zone)
	if(!attacker.limb_destroyer)
		return dam_zone
	var/obj/item/bodypart/affecting
	if(dam_zone && attacker.client)
		affecting = get_bodypart(ran_zone(dam_zone))
	else
		var/list/things_to_ruin = shuffle(bodyparts.Copy())
		for(var/B in things_to_ruin)
			var/obj/item/bodypart/bodypart = B
			if(bodypart.body_zone == "head" || bodypart.body_zone == "chest")
				continue
			if(!affecting || ((affecting.get_damage() / affecting.max_damage) < (bodypart.get_damage() / bodypart.max_damage)))
				affecting = bodypart
	if(affecting)
		dam_zone = affecting.body_zone
		if(affecting.get_damage() >= affecting.max_damage)
			affecting.dismember()
			return null
		return affecting.body_zone
	return dam_zone


/mob/living/carbon/blob_act(obj/structure/blob/B)
	if (stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>The blob attacks!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/emp_act(severity)
	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		O.emp_act(severity)
	..()

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, override = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	if(tesla_shock && tesla_ignore)
		return FALSE
	shock_damage *= siemens_coeff
	if(dna && dna.species)
		shock_damage *= dna.species.siemens_coeff
	if(shock_damage<1 && !override)
		return 0
	if(reagents.has_reagent("teslium"))
		shock_damage *= 1.5 //If the mob has teslium in their body, shocks are 50% more damaging!
	if(illusion)
		adjustStaminaLoss(shock_damage)
	else
		take_overall_damage(0,shock_damage)
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='italics'>You hear a heavy electrical crack.</span>" \
	)
	jitteriness += 1000 //High numbers for violent convulsions
	do_jitter_animation(jitteriness)
	stuttering += 2
	if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
		Stun(2)
	spawn(20)
		jitteriness = max(jitteriness - 990, 10) //Still jittery, but vastly less
		if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
			Stun(3)
			Weaken(3)
	if(override)
		return override
	else
		return shock_damage

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(on_fire)
		to_chat(M, "<span class='warning'>You can't put them out with just your bare hands!")
		return

	if(health >= 0 && !(status_flags & FAKEDEATH))

		if(lying)
			M.visible_message("<span class='notice'>[M] shakes [src] trying to get [p_them()] up!</span>", \
							"<span class='notice'>You shake [src] trying to get [p_them()] up!</span>")
		else if(check_zone(M.zone_selected) == "head")
			M.visible_message("<span class='notice'>[M] gives [src] a pat on the head to make [p_them()] feel better!</span>", \
						"<span class='notice'>You give [src] a pat on the head to make [p_them()] feel better!</span>")
		else
			M.visible_message("<span class='notice'>[M] hugs [src] to make [p_them()] feel better!</span>", \
						"<span class='notice'>You hug [src] to make [p_them()] feel better!</span>")
		AdjustSleeping(-5)
		AdjustParalysis(-3)
		AdjustStunned(-3)
		AdjustWeakened(-3)
		if(resting)
			resting = 0
			update_canmove()

		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)


/mob/living/carbon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	. = ..()

	var/damage = intensity - get_eye_protection()
	if(.) // we've been flashed
		if(visual)
			return

		if (damage == 1)
			to_chat(src, "<span class='warning'>Your eyes sting a little.</span>")
			if(prob(40))
				adjust_eye_damage(1)

		else if (damage == 2)
			to_chat(src, "<span class='warning'>Your eyes burn.</span>")
			adjust_eye_damage(rand(2, 4))

		else if( damage > 3)
			to_chat(src, "<span class='warning'>Your eyes itch and burn severely!</span>")
			adjust_eye_damage(rand(12, 16))

		if(eye_damage > 10)
			blind_eyes(damage)
			blur_eyes(damage * rand(3, 6))

			if(eye_damage > 20)
				if(prob(eye_damage - 20))
					if(become_nearsighted())
						to_chat(src, "<span class='warning'>Your eyes start to burn badly!</span>")
				else if(prob(eye_damage - 25))
					if(become_blind())
						to_chat(src, "<span class='warning'>You can't see anything!</span>")
			else
				to_chat(src, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
		if(has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
		return 1
	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")
		if(has_bane(BANE_LIGHT))
			mind.disrupt_spells(0)


/mob/living/carbon/soundbang_act(intensity = 1, stun_pwr = 1, damage_pwr = 5, deafen_pwr = 15)
	var/ear_safety = get_ear_protection()
	if(ear_safety < 2) //has ears
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			if(stun_pwr)
				Stun(stun_pwr*effect_amount)
				Weaken(stun_pwr*effect_amount)
			if(deafen_pwr || damage_pwr)
				setEarDamage(ear_damage + damage_pwr*effect_amount, max(ear_deaf, deafen_pwr*effect_amount))
				if (ear_damage >= 15)
					to_chat(src, "<span class='warning'>Your ears start to ring badly!</span>")
					if(prob(ear_damage - 5))
						to_chat(src, "<span class='warning'>You can't hear anything!</span>")
						disabilities |= DEAF
				else if(ear_damage >= 5)
					to_chat(src, "<span class='warning'>Your ears start to ring!</span>")
				src << sound('sound/weapons/flash_ring.ogg',0,1,0,250)
		return effect_amount //how soundbanged we are


/mob/living/carbon/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	if(!def_zone || def_zone == "head")
		var/obj/item/clothing/hit_clothes
		if(wear_mask)
			hit_clothes = wear_mask
		if(wear_neck)
			hit_clothes = wear_neck
		if(head)
			hit_clothes = head
		if(hit_clothes)
			hit_clothes.take_damage(damage_amount, damage_type, damage_flag, 0)
