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
	var/atk_verb
	switch(rand(1,6))
		if(1)
			atk_verb = "dragged"
			var/obj/item/organ/tail/tail = attacker.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			if(isnull(tail) && defender.stat != CONSCIOUS || defender.IsParalyzed())
				return MARTIAL_ATTACK_INVALID

			attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
			attacker.emote("spin")
			defender.visible_message(
				span_danger("[attacker]'s tail [atk_verb] [defender] down to the ground!"),
				span_userdanger("Your body twists as you're [atk_verb] to the ground by [attacker]'s tail!"),
				span_hear("You hear a snap, followed by a thud!"),
				null,
				attacker,
			)
			to_chat(attacker, span_danger("You latch your tail to [defender], [atk_verb] them to the ground!"))
			defender.apply_damage(rand(5, 10), attacker.get_attack_type())
			playsound(attacker, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
			defender.Knockdown(2 SECONDS)
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)

		if(6)
			var/obj/item/organ/tail/tail = attacker.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
			if(isnull(tail))
				return MARTIAL_ATTACK_INVALID

			atk_verb = pick("whipped", "flogged", "lashed")
			attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
			defender.visible_message(
				span_danger("[attacker]'s tail [atk_verb] [defender] in one quick motion!"),
				span_userdanger("You feel a sharp sting as you're [atk_verb] by [attacker]!"),
				span_hear("You hear a sharp whipping noise!"),
				null,
				attacker,
			)
			to_chat(attacker, span_danger("In one motion, you [atk_verb] [defender] quickly!"))
			defender.apply_damage(rand(10, 15), attacker.get_attack_type())
			playsound(attacker, 'sound/items/weapons/whip.ogg', 50, TRUE, -1)
			defender.drop_all_held_items()
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)

		else
			atk_verb = pick("chomp", "gnaw", "chew")
			if(defender.check_block(attacker, 0, "[attacker]'s [atk_verb]", UNARMED_ATTACK))
				return MARTIAL_ATTACK_FAIL

			attacker.do_attack_animation(defender, ATTACK_EFFECT_BITE)
			defender.visible_message(
				span_danger("[attacker] [atk_verb]s [defender] violently!"),
				span_userdanger("You're viciously [atk_verb]ed by [attacker]!"),
				span_hear("You hear a violent gnawing sound!"),
				null,
				attacker,
			)
			to_chat(attacker, span_danger("You [atk_verb] [defender] with vicious force!"))
			defender.apply_damage(rand(10, 20), damagetype = BRUTE, sharpness = SHARP_POINTY, wound_bonus = 50)
			playsound(attacker, 'sound/items/weapons/bite.ogg', 50, TRUE, -1)
			if(HAS_TRAIT(attacker, TRAIT_PACIFISM))
				attacker.add_mood_event("bypassed_pacifism", /datum/mood_event/pacifism_bypassed)

	if(atk_verb)
		log_combat(attacker, defender, "[atk_verb] (Jungle Arts)")
		return MARTIAL_ATTACK_SUCCESS

	return MARTIAL_ATTACK_FAIL
