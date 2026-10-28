
/mob/living/silicon/grippedby(mob/living/carbon/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection(ignore_deafness = FALSE)
	return ..() + EAR_PROTECTION_HEAVY //no ears

/mob/living/silicon/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.) //if harm or disarm intent
		return
	var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
	if (prob(90))
		playsound(loc, 'sound/items/weapons/slash.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user] slashes at [src]!"), \
						span_userdanger("[user] slashes at you!"), null, null, user)
		to_chat(user, span_danger("You slash at [src]!"))
		if(prob(8))
			flash_act(affect_silicon = 1)
		adjust_brute_loss(damage)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/items/weapons/slashmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user]'s swipe misses [src]!"),
						span_danger("You avoid [user]'s swipe!"), null, null, user)
		to_chat(user, span_warning("Your swipe misses [src]!"))
		log_combat(user, src, "attacked and missed")

/mob/living/silicon/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	var/damage_received = .
	if(prob(damage_received))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.Paralyze(2 SECONDS)
			unbuckle_mob(buckled)
			buckled.visible_message(
				span_danger("[buckled] is knocked off of [src] by [user]!"),
				span_userdanger("You're knocked off of [src] by [user]!"),
				ignored_mobs = user,
			)
			to_chat(user, span_danger("You knock [buckled] off of [src]!"))

/mob/living/silicon/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(!L.combat_mode)
		visible_message(span_notice("[L.name] rubs its head against [src]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjust_brute_loss(rand(10, 15))
	playsound(loc, /datum/sound_effect/punch, 25, TRUE, -1)
	visible_message(span_danger("[user] punches [src]!"), \
					span_userdanger("[user] punches you!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You punch [src]!"))

/mob/living/silicon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.disarm(src)
		return TRUE

	if(has_buckled_mobs() && !user.combat_mode)
		user_unbuckle_mob(buckled_mobs[1], user)
		return TRUE
	if(user.combat_mode)
		// we're ostensibly just implementing the part that matters for borgs from _species/proc/harm(); getting sometimes punched, kicked or bitten by people.
		var/obj/item/organ/brain/brain = user.get_organ_slot(ORGAN_SLOT_BRAIN)
		var/datum/martial_art/attacker_style

		if(user.mind)
			attacker_style = GET_ACTIVE_MARTIAL_ART(user)

		var/obj/item/bodypart/attacking_bodypart = attacker_style?.get_attacking_limb(user, src) || brain?.get_attacking_limb(src) || user.get_active_hand()

		var/atk_verb_index = rand(1, length(attacking_bodypart.unarmed_attack_verbs))
		var/atk_verb = attacking_bodypart.unarmed_attack_verbs[atk_verb_index]
		var/atk_verb_continuous = "[atk_verb]s"
		if (length(attacking_bodypart.unarmed_attack_verbs_continuous) >= atk_verb_index) // Just in case
			atk_verb_continuous = attacking_bodypart.unarmed_attack_verbs_continuous[atk_verb_index]

		var/atk_effect = attacking_bodypart.unarmed_attack_effect

		if(atk_effect == ATTACK_EFFECT_BITE)
			if(user.is_mouth_covered(ITEM_SLOT_MASK))
				if((user.get_active_hand())) //In the event we can't bite, emergency swap to see if we can attack with a hand.
					attacking_bodypart = user.get_active_hand()
					atk_verb_index = rand(1, length(attacking_bodypart.unarmed_attack_verbs))
					atk_verb = attacking_bodypart.unarmed_attack_verbs[atk_verb_index]
					atk_verb_continuous = "[atk_verb]s"
					if (length(attacking_bodypart.unarmed_attack_verbs_continuous) >= atk_verb_index) // Just in case
						atk_verb_continuous = attacking_bodypart.unarmed_attack_verbs_continuous[atk_verb_index]
					atk_effect = attacking_bodypart.unarmed_attack_effect
				else  //Nothing? Okay. Fail.
					user.balloon_alert(user, "can't attack!")
					return FALSE

		// We do our basic damage calculations, taking into account the presence of strength and athletics skill
		var/upper_unarmed_damage = attacking_bodypart.unarmed_damage_high + (HAS_TRAIT(user, TRAIT_STRENGTH) ? 2 : 0)
		var/lower_unarmed_damage = min(attacking_bodypart.unarmed_damage_low + (user.mind?.get_skill_level(/datum/skill/athletics) || 0), upper_unarmed_damage)
		var/damage = rand(lower_unarmed_damage, upper_unarmed_damage)

		var/user_drunkenness = user.get_drunk_amount()
		if(user_drunkenness && HAS_TRAIT(user, TRAIT_DRUNKEN_BRAWLER)) // If we're drunk at all, and we're a drunken brawler, we can beat up borgs all the better!
			//Drunken brawlers gain additional damage based on how low their health is.
			var/brawler_brute_and_burn = (user.get_fire_loss() + user.get_brute_loss())

			damage += damage * clamp(brawler_brute_and_burn / 100, 0.3, 2)

			var/drunken_martial_descriptor = pick("Drunken", "Intoxicated", "Tipsy", "Inebriated", "Delirious", "Day-Drinker's", "Firegut", "Blackout")
			atk_verb = "[drunken_martial_descriptor] [capitalize(atk_verb)]"
			atk_verb_continuous = "[drunken_martial_descriptor] [capitalize(atk_verb_continuous)]"

		if(check_block(user, damage, "[user]'s [atk_verb]", UNARMED_ATTACK, 0, BRUTE))
			user.do_attack_animation(src, atk_effect)
			playsound(loc, 'sound/effects/bang.ogg', 10, TRUE)
			return

		user.do_attack_animation(src, atk_effect)
		visible_message(span_danger("[user] [atk_verb_continuous] [src]!"), \
					span_userdanger("[user] [atk_verb_continuous] you!"), span_hear("You hear something impacting metal!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You [atk_verb] [src]!"))
		playsound(loc, 'sound/effects/bang.ogg', 10, TRUE)
		apply_damage(damage, attacking_bodypart.attack_type)
		log_combat(user, src, "punched")
		updatehealth()
	else
		visible_message(span_notice("[user] pets [src]."), span_notice("[user] pets you."), null, null, user)
		to_chat(user, span_notice("You pet [src]."))
		SEND_SIGNAL(user, COMSIG_MOB_PAT_BORG)
		return TRUE

/mob/living/silicon/attack_drone(mob/living/basic/drone/user)
	if(user.combat_mode)
		return
	return ..()

/mob/living/silicon/attack_drone_secondary(mob/living/basic/drone/user)
	if(user.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Warning: Electromagnetic pulse detected."))
	if(. & EMP_PROTECT_SELF || QDELETED(src))
		return
	switch(severity)
		if(1)
			src.take_bodypart_damage(burn = 20)
		if(2)
			src.take_bodypart_damage(burn = 10)
	to_chat(src, span_userdanger("*BZZZT*"))
	for(var/mob/living/M in buckled_mobs)
		if(prob(severity*50))
			unbuckle_mob(M)
			M.Paralyze(40)
			M.visible_message(span_boldwarning("[M] is thrown off of [src]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(hitting_projectile.damage_type == BURN)
		hitting_projectile.damage_type = BRUTE //Burn is for wire damage. Brute is the outer chassis.
	. = ..()
	if(. != BULLET_ACT_HIT)
		return .

	var/prob_of_knocking_dudes_off = 0
	if(hitting_projectile.damage_type == BRUTE)
		prob_of_knocking_dudes_off = hitting_projectile.damage * 1.5
	if(hitting_projectile.stun || hitting_projectile.knockdown || hitting_projectile.paralyze)
		prob_of_knocking_dudes_off = 100

	if(prob(prob_of_knocking_dudes_off))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.visible_message(span_boldwarning("[buckled] is knocked off of [src] by [hitting_projectile]!"))
			unbuckle_mob(buckled)
			buckled.Paralyze(4 SECONDS)

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static, length = 25)
	if(affect_silicon)
		return ..()

/// If an item does this or more throwing damage it will slow a borg down on hit
#define CYBORG_SLOWDOWN_THRESHOLD 10

/mob/living/silicon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || AM.throwforce < CYBORG_SLOWDOWN_THRESHOLD) // can cyborgs even catch things?
		return
	apply_status_effect(/datum/status_effect/borg_slow, AM.throwforce / 20)

/mob/living/silicon/attack_effects(damage_done, hit_zone, armor_block, obj/item/attacking_item, mob/living/attacker)
	. = ..()
	if(damage_done < CYBORG_SLOWDOWN_THRESHOLD)
		return
	apply_status_effect(/datum/status_effect/borg_slow, damage_done / 60)

#undef CYBORG_SLOWDOWN_THRESHOLD

/mob/living/silicon/hypnosis_vulnerable()
	return FALSE //It obeys its laws
