/datum/martial_art/psychotic_brawling
	name = "Psychotic Brawling"
	id = MARTIALART_PSYCHOBRAWL
	pacifist_style = TRUE

/datum/martial_art/psychotic_brawling/disarm_act(mob/living/attacker, mob/living/defender)
	return psycho_attack(attacker, defender)

/datum/martial_art/psychotic_brawling/grab_act(mob/living/attacker, mob/living/defender)
	return psycho_attack(attacker, defender, TRUE)

/datum/martial_art/psychotic_brawling/harm_act(mob/living/attacker, mob/living/defender)
	return psycho_attack(attacker, defender)

/datum/martial_art/psychotic_brawling/proc/psycho_attack(mob/living/attacker, mob/living/defender, grab_attack)
	var/atk_verb
	switch(rand(1,8))
		if(1)
			if(iscarbon(defender) && iscarbon(attacker))
				var/mob/living/carbon/carbon_defender = defender
				carbon_defender.help_shake_act(attacker)
			atk_verb = "helped"

		if(2)
			attacker.emote("cry")
			attacker.Stun(2 SECONDS)
			atk_verb = "cried looking at"

		if(3)
			if(defender.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
				return MARTIAL_ATTACK_FAIL
			if(attacker.body_position == LYING_DOWN)
				return MARTIAL_ATTACK_INVALID

			if(attacker.grab_state >= GRAB_AGGRESSIVE)
				defender.grabbedby(attacker, 1)
			else
				attacker.start_pulling(defender, supress_message = TRUE)
				if(attacker.pulling)
					defender.drop_all_held_items()
					defender.stop_pulling()
					if(grab_attack)
						log_combat(attacker, defender, "grabbed", addition="aggressively")
						combat_message(
							attacker = attacker,
							defender = defender,
							to_attacker = "You violently grab [defender]!",
							to_defender = "[attacker] violently grabs you!",
							to_blind_attacker = "You violently grab someone!",
							to_blind_defender = "Something violently grabs you!",
							to_viewers = "[attacker] violently grabs [defender]!",
							to_blind_viewers = "You hear sounds of aggressive fondling!",
							dangerous = TRUE,
						)
						attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab
					else
						log_combat(attacker, defender, "grabbed", addition="passively")
						attacker.setGrabState(GRAB_PASSIVE)

		if(4)
			var/defender_damage = rand(5, 10)
			if(defender.check_block(attacker, defender_damage, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
				return MARTIAL_ATTACK_FAIL

			atk_verb = "headbutt"
			attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
			attacker.emote("flip")
			combat_message(
				attacker = attacker,
				defender = defender,
				to_attacker = "You [atk_verb] [defender]!",
				to_defender = "[attacker] [PRESENT_TENSE(atk_verb)] you!",
				to_blind_attacker = "You [atk_verb] someone!",
				to_blind_defender = "Something [PRESENT_TENSE(atk_verb)] you!",
				to_viewers = "[attacker] [PRESENT_TENSE(atk_verb)] [defender]!",
				to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
				dangerous = TRUE,
			)
			playsound(defender, 'sound/items/weapons/punch1.ogg', 40, TRUE, -1)
			defender.apply_damage(defender_damage, attacker.get_attack_type(), BODY_ZONE_HEAD)
			attacker.apply_damage(rand(5, 10), attacker.get_attack_type(), BODY_ZONE_HEAD)
			if(iscarbon(defender))
				var/mob/living/carbon/carbon_defender = defender
				if(!istype(carbon_defender.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/helmet) && !istype(carbon_defender.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/utility/hardhat))
					carbon_defender.adjust_organ_loss(ORGAN_SLOT_BRAIN, 5)
			attacker.Stun(rand(1 SECONDS, 4.5 SECONDS))
			defender.Stun(rand(0.5 SECONDS, 3 SECONDS))
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)

		if(5, 6)
			if(defender.check_block(attacker, 0, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
				return MARTIAL_ATTACK_FAIL

			atk_verb = pick("kick", "hit", "slam")
			attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
			combat_message(
				attacker = attacker,
				defender = defender,
				to_attacker = "You [atk_verb] [defender] with such inhuman strength that it sends [defender.p_them()] flying backwards!",
				to_defender = "[attacker] [atk_verb]s you with such inhuman strength that it sends you flying backwards!",
				to_blind_attacker = "You [atk_verb] someone with such inhuman strength that it sends them flying backwards!",
				to_blind_defender = "Something [atk_verb]s you with such inhuman strength that it sends you flying backwards!",
				to_viewers = "[attacker] [atk_verb]s [defender] with such inhuman strength that it sends [defender.p_them()] flying backwards!",
				to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
				dangerous = TRUE,
			)
			defender.apply_damage(rand(15, 30), attacker.get_attack_type())
			playsound(defender, 'sound/effects/meteorimpact.ogg', 25, TRUE, -1)
			var/throwtarget = get_edge_target_turf(attacker, get_dir(attacker, get_step_away(defender, attacker)))
			defender.throw_at(throwtarget, 4, 2, attacker)//So stuff gets tossed around at the same time.
			defender.Paralyze(6 SECONDS)
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)

		if(7, 8)
			return MARTIAL_ATTACK_INVALID //Resume default behaviour

	if(atk_verb)
		log_combat(attacker, defender, "[atk_verb] (Psychotic Brawling)")
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_FAIL
