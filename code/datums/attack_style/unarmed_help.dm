/datum/attack_style/unarmed/help
	attack_effect = null
	successful_hit_sound = 'sound/weapons/thudswoosh.ogg'
	miss_sound = null
	slowdown = 0
	cd = 0 SECONDS // snowflaked, only set when we actually collide with a guy
	can_hit_self = TRUE // help yourself

/datum/attack_style/unarmed/help/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	attacker.changeNext_move(CLICK_CD_MELEE)

	if(attacker != smacked)
		if(smacked.check_block(attacker, 0, "[attacker]'s touch", attack_type = UNARMED_ATTACK))
			return ATTACK_SWING_BLOCKED

		// Todo : move this out and into its own style?
		if(!HAS_TRAIT(smacked, TRAIT_MARTIAL_ARTS_IMMUNE) && martial_arts_compatible)
			var/datum/martial_art/art = attacker.mind?.martial_art
			switch(art?.help_act(attacker, smacked))
				if(MARTIAL_ATTACK_SUCCESS)
					return ATTACK_SWING_HIT
				if(MARTIAL_ATTACK_FAIL)
					return ATTACK_SWING_MISSED

	var/list/new_modifiers = list(LEFT_CLICK = !right_clicking, RIGHT_CLICK = right_clicking)
	smacked.attack_hand(attacker, new_modifiers)
	return ATTACK_SWING_HIT
