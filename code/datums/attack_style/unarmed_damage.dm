/**
 * Unarmed attacks which generically apply damage to the mob it hits.
 */
/datum/attack_style/unarmed/generic_damage
	pacifism_completely_banned = TRUE // It's called generic damage for a reason

	/// Type damage this attack does.
	var/attack_type = BRUTE
	/// The verb used for an unarmed attack when using this limb, "punch".
	var/default_attack_verb = "bump"
	/// For deaf people, when this punch misses / gets blocked, this is the phrase used
	var/deaf_miss_phrase = "a swoosh"
	/// Flat added modifier to miss chance
	var/miss_chance_modifier = 0
	/// Wound bonus on attacks from this attack method
	var/wound_bonus = 0
	/// Armor penetration from this attack method
	var/attack_penetration = 0
	/// If TRUE, attacks on limbs which are at max damage will be dismembered
	var/can_dismember_limbs = FALSE

/datum/attack_style/unarmed/generic_damage/proc/select_damage(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with)
	return -1

/datum/attack_style/unarmed/generic_damage/proc/select_attack_verb(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with, damage)
	if(smacked.response_harm_simple)
		return smacked.response_harm_simple
	if(damage == 0 && attacker.friendly_verb_simple)
		return attacker.friendly_verb_simple
	if(attacker.attack_verb_simple)
		return attacker.attack_verb_simple

	return default_attack_verb

/datum/attack_style/unarmed/generic_damage/proc/calculate_miss_chance(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with, damage)
	if(smacked.body_position == LYING_DOWN || HAS_TRAIT(attacker, TRAIT_PERFECT_ATTACKER))
		return 0

	return miss_chance_modifier

/datum/attack_style/unarmed/generic_damage/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/bodypart/weapon, right_clicking)
	var/damage = max(0, select_damage(attacker, smacked, weapon))
	var/attack_verb = select_attack_verb(attacker, smacked, weapon, damage)

	if(smacked.check_block(attacker, damage, "[attacker]'s [default_attack_verb]", UNARMED_ATTACK, attack_penetration))
		smacked.visible_message(
			span_warning("[smacked] blocks [attacker]'s [attack_verb]!"),
			span_userdanger("You block [attacker]'s [attack_verb]!"),
			span_hear("You hear [deaf_miss_phrase]!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_warning("[smacked] blocks your [attack_verb]!"))
		return ATTACK_STYLE_BLOCKED

	// Todo : move this out and into its own style?
	if(!HAS_TRAIT(smacked, TRAIT_MARTIAL_ARTS_IMMUNE))
		var/datum/martial_art/art = attacker.mind?.martial_art
		switch(art?.harm_act(attacker, smacked))
			if(MARTIAL_ATTACK_SUCCESS)
				return ATTACK_STYLE_HIT
			if(MARTIAL_ATTACK_FAIL)
				return ATTACK_STYLE_MISSED

	var/obj/item/bodypart/affecting = smacked.get_bodypart(smacked.get_random_valid_zone(attacker.zone_selected))
	var/miss_chance = calculate_miss_chance(attacker, smacked, weapon, damage)

	if(damage <= 0 || (iscarbon(smacked) && !istype(affecting)) || prob(miss_chance))
		smacked.visible_message(
			span_danger("[attacker]'s [attack_verb] misses [smacked]!"),
			span_danger("You avoid [attacker]'s [attack_verb]!"),
			span_hear("You hear [deaf_miss_phrase]!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_warning("Your [attack_verb] misses [smacked]!"))
		log_combat(attacker, smacked, "missed unarmed attack ([attack_verb])")
		return ATTACK_STYLE_MISSED

	var/armor_block = min(ARMOR_MAX_BLOCK, smacked.run_armor_check(affecting, MELEE, armour_penetration = attack_penetration))

	// melbert todo : probably sounds silly
	smacked.visible_message(
		span_danger("[attacker] [attack_verb]ed [smacked]!"),
		span_userdanger("You're [attack_verb]ed by [attacker]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_danger("You [default_attack_verb] [smacked]!"))

	smacked.lastattacker = attacker.real_name
	smacked.lastattackerckey = attacker.ckey

	var/additional_logging = "([default_attack_verb])"
	var/logging_returned = actually_apply_damage(attacker, smacked, weapon, damage, affecting, armor_block, get_dir(attacker, smacked))
	if(logging_returned)
		additional_logging += logging_returned

	if(QDELETED(affecting) || affecting.owner != smacked)
		// Our attack ended up dismembering / removing the limb, so let's just null this out
		affecting = null

	smacked.was_attacked_effects(null, attacker, affecting, damage, armor_block)
	log_combat(attacker, smacked, "unarmed attack", addition = additional_logging)
	return ATTACK_STYLE_HIT

/**
 * Called when the damage actually is being applied to the smacked mob
 *
 * Arguments
 * * attacker - The mob that is attacking
 * * smacked - The mob that is being attacked
 * * hitting_with - The bodypart that is being used to attack. CAN BE NULL, if this unarmed attack is created without bodypart (such as simplemob attacks)
 * * damage - The amount of damage that is being applied
 * * affecting - The bodypart that is being hit by the attack. CAN BE NULL if the mob being hit is a simplemob or other mob that has no bodyparts.
 * * armor_block - The amount of armor that is blocking the attack (0 - 100, MELEE flag)
 * * direction - The dir of the attacker to the smacked mob
 *
 * Returns a string. This string will be added to the final combat log for this attack.
 */
/datum/attack_style/unarmed/generic_damage/proc/actually_apply_damage(
	mob/living/attacker,
	mob/living/smacked,
	obj/item/bodypart/hitting_with,
	damage,
	obj/item/bodypart/affecting,
	armor_block,
	direction,
)
	SHOULD_CALL_PARENT(TRUE)

	// Melbert todo : needs to pass in wound bonus so it gets wound bonus from simplemobs
	. = ""
	var/damage_type = istype(hitting_with) ? hitting_with.attack_type : attack_type
	smacked.apply_damage(damage, damage_type, affecting, armor_block, wound_bonus = wound_bonus, attack_direction = direction)

	if(can_dismember_limbs && istype(affecting) && (affecting.get_damage() >= affecting.max_damage))
		. += "(dismembering [affecting])"
		affecting.dismember(damage_type, silent = FALSE)

/*
 * Limb attack unarmed style
 *
 * This style deals damage / uses verbs and effects based on the limb being used to attack
 */
/datum/attack_style/unarmed/generic_damage/limb_based

/datum/attack_style/unarmed/generic_damage/limb_based/select_damage(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with)
	. = rand(hitting_with.unarmed_damage_low, hitting_with.unarmed_damage_high)
	if(attacker != hitting_with.owner)
		. *= 0.5 // Damage penalty for using a limb as a melee weapon

/datum/attack_style/unarmed/generic_damage/limb_based/calculate_miss_chance(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with, damage)
	if(..() == 0) // Guaranteed hit from parent
		return 0

	if(hitting_with.unarmed_damage_low <= 0)
		return 100

	return (hitting_with.unarmed_damage_high / hitting_with.unarmed_damage_low) \
		+ (attacker.getBruteLoss() * 0.5) \
		+ attacker.getStaminaLoss() \
		+ miss_chance_modifier

/datum/attack_style/unarmed/generic_damage/limb_based/actually_apply_damage(
	mob/living/attacker,
	mob/living/smacked,
	obj/item/bodypart/hitting_with,
	damage,
	obj/item/bodypart/affecting,
	armor_block,
	direction,
)
	. = ..()
	if(smacked.stat == DEAD)
		return
	if(hitting_with.unarmed_stun_threshold < 0)
		return

	if(damage >= hitting_with.unarmed_stun_threshold)
		smacked.visible_message(
			span_danger("[attacker] knocks [smacked] down!"),
			span_userdanger("You're knocked down by [attacker]!"),
			span_hear("You hear aggressive shuffling followed by a loud thud!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You knock [smacked] down!"))
		var/knockdown_duration = (4 SECONDS) + (smacked.getStaminaLoss() + (smacked.getBruteLoss() * 0.5)) * 0.8
		smacked.apply_effect(knockdown_duration, EFFECT_KNOCKDOWN, armor_block)
		. += "(stun attack)"

/*
 * Mob attack unarmed style
 *
 * This style deals damage / uses verbs based on the mob's vars,
 * generally for use in simple / basic mobs
 */
/datum/attack_style/unarmed/generic_damage/mob_attack

/datum/attack_style/unarmed/generic_damage/mob_attack/select_damage(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with)
	return rand(attacker.melee_damage_lower, attacker.melee_damage_upper)

/datum/attack_style/unarmed/generic_damage/mob_attack/select_attack_verb(mob/living/attacker, mob/living/smacked, obj/item/bodypart/hitting_with, damage)
	. = ..()
	if(. != default_attack_verb)
		return

	if(isanimal(attacker))
		var/mob/living/simple_animal/animal = attacker
		return animal.attack_verb_simple

	if(isbasicmob(attacker))
		var/mob/living/basic/animal = attacker
		return animal.attack_verb_simple

/datum/attack_style/unarmed/generic_damage/mob_attack/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(isanimal(attacker))
		var/mob/living/simple_animal/animal = attacker
		if(animal.attack_vis_effect)
			attacker.do_attack_animation(affecting[1], animal.attack_vis_effect)
		return

	if(isbasicmob(attacker))
		var/mob/living/basic/animal = attacker
		if(animal.attack_vis_effect)
			attacker.do_attack_animation(affecting[1], animal.attack_vis_effect)
		return
