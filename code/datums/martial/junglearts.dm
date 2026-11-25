/datum/martial_art/jungle_arts
	name = "Jungle Arts"
	id = MARTIALART_JUNGLEARTS
	pacifist_style = TRUE

/datum/martial_art/jungle_arts/disarm_act(mob/living/attacker, mob/living/defender)
	return jungle_attack(attacker, defender)

/datum/martial_art/jungle_arts/grab_act(mob/living/attacker, mob/living/defender)
	return jungle_attack(attacker, defender, TRUE)

/datum/martial_art/jungle_arts/harm_act(mob/living/attacker, mob/living/defender)
	return jungle_attack(attacker, defender)

/datum/martial_art/jungle_arts/proc/jungle_attack(mob/living/attacker, mob/living/defender, grab_attack)
	switch(rand(1, 6))
		if(1)
			var/obj/item/organ/tail/tail = attacker.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			if(isnull(tail) && IS_UNCONSCIOUS_OR_CRIT(defender) || defender.IsParalyzed())
				return MARTIAL_ATTACK_INVALID

			log_combat(attacker, defender, "tail grab (Jungle Arts)")
			attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
			attacker.emote("spin")
			combat_message(
				attacker = attacker,
				defender = defender,
				to_attacker = "You twist your tail around [defender], dragging [defender.p_them()] to the ground!",
				to_defender = "[attacker] twists [attacker.p_their()] tail around you, dragging you to the ground!",
				to_blind_attacker = "You twist your tail around someone, dragging them to the ground!",
				to_blind_defender = "Something twists its tail around you, dragging you to the ground!",
				to_viewers = "[attacker] twists [attacker.p_their()] tail around [defender], dragging [defender.p_them()] to the ground!",
				to_blind_viewers = "You hear a snap, followed by a thud!",
			)
			defender.apply_damage(rand(5, 10), attacker.get_attack_type())
			playsound(attacker, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
			defender.Knockdown(2 SECONDS)
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)
			return MARTIAL_ATTACK_SUCCESS

		if(2)
			var/obj/item/organ/tail/tail = attacker.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			if(isnull(tail))
				return MARTIAL_ATTACK_INVALID

			var/atk_verb = pick("whip", "flog", "lash")
			log_combat(attacker, defender, "tail whip (Jungle Arts)")
			attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
			combat_message(
				attacker = attacker,
				defender = defender,
				to_attacker = "In one swift motion, you [atk_verb] [defender] with your tail!",
				to_defender = "[attacker] [PRESENT_TENSE(atk_verb)] you with [attacker.p_their()] tail!",
				to_blind_attacker = "In one swift motion, you [atk_verb] someone with your tail!",
				to_blind_defender = "Something [PRESENT_TENSE(atk_verb)] you with its tail!",
				to_viewers = "[attacker] [PRESENT_TENSE(atk_verb)] [defender] with [attacker.p_their()] tail!",
				to_blind_viewers = "You hear a sharp whipping noise!",
			)
			defender.apply_damage(rand(10, 15), attacker.get_attack_type())
			playsound(attacker, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
			defender.drop_all_held_items()
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)
			return MARTIAL_ATTACK_SUCCESS

	var/atk_verb = pick("chomp", "gnaw", "chew")
	if(defender.check_block(attacker, 0, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
		return MARTIAL_ATTACK_FAIL

	log_combat(attacker, defender, "strong bite (Jungle Arts)")
	attacker.do_attack_animation(defender, ATTACK_EFFECT_BITE)
	combat_message(
		attacker = attacker,
		defender = defender,
		to_attacker = "You [atk_verb] [defender] with vicious force!",
		to_defender = "[attacker] [PRESENT_TENSE(atk_verb)] you with vicious force!",
		to_blind_attacker = "You [atk_verb] someone with vicious force!",
		to_blind_defender = "Something [PRESENT_TENSE(atk_verb)] you with vicious force!",
		to_viewers = "[attacker] [PRESENT_TENSE(atk_verb)] [defender] with vicious force!",
		to_blind_viewers = "You hear a violent gnawing sound!",
	)
	defender.apply_damage(rand(10, 20), damagetype = BRUTE, sharpness = SHARP_POINTY, wound_bonus = 50)
	playsound(attacker, 'sound/items/weapons/bite.ogg', 50, TRUE, -1)
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
		attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)
	return MARTIAL_ATTACK_SUCCESS
