/*
 * Xeno help
 */
/datum/attack_style/unarmed/help/xeno

/datum/attack_style/unarmed/help/xeno/finalize_attack(mob/living/carbon/alien/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	if(isalien(smacked))
		smacked.visible_message(
			span_notice("[attacker] nuzzles [smacked] trying to wake [smacked.p_them()] up!"),
			span_notice("[attacker] nuzzles you trying to wake you up!."),
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_notice("You nuzzle [smacked] trying to wake [smacked.p_them()] up!"))
		smacked.adjust_status_effects_on_shake_up()

	else
		smacked.visible_message(
			span_notice("[attacker] caresses [smacked] with its scythe-like arm."),
			span_notice("[attacker] caresses you with its scythe-like arm."),
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_notice("You caress [smacked] with your scythe-like arm."))
	return ATTACK_STYLE_HIT

/datum/attack_style/unarmed/help/larva

/datum/attack_style/unarmed/help/larva/finalize_attack(mob/living/carbon/alien/larva/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	smacked.visible_message(
		span_notice("[attacker] rubs its head against [smacked]."),
		span_notice("[attacker] rubs its head against you."),
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_notice("You rubs its head against [smacked]."))
	return ATTACK_STYLE_HIT

/*
 * Xeno harm
 */
/datum/attack_style/unarmed/generic_damage/mob_attack/xeno
	successful_hit_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	default_attack_verb = "slash"
	miss_chance_modifier = 10

/datum/attack_style/unarmed/generic_damage/mob_attack/xeno/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/bodypart/weapon, right_clicking)
	if(isalien(smacked))
		return ATTACK_STYLE_SKIPPED
	return ..()

/datum/attack_style/unarmed/generic_damage/mob_attack/xeno/adult
	can_dismember_limbs = TRUE

/*
 * Xeno disarm
 */
/datum/attack_style/unarmed/disarm/xeno
	attack_effect = ATTACK_EFFECT_DISARM
	successful_hit_sound = null

/datum/attack_style/unarmed/disarm/xeno/disarm_target(mob/living/attacker, mob/living/smacked, shove_verb)
	if(iscyborg(smacked))
		var/mob/living/silicon/robot/robot_hit = smacked
		var/obj/item/borg_module = robot_hit.get_active_held_item()
		if(borg_module)
			robot_hit.uneq_active()
			robot_hit.visible_message(
				span_danger("[attacker] disarmed [robot_hit]!"),
				span_userdanger("[attacker] has disabled [robot_hit]'s active module!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				ignored_mobs = attacker,
			)
			to_chat(attacker, span_danger("You disable [robot_hit]'s active module!"))
			log_combat(attacker, robot_hit, "disarmed", addition = "[borg_module ? " removing [borg_module]" : ""]")
			playsound(smacked, 'sound/weapons/slash.ogg', 30, TRUE, -1)
		else
			robot_hit.Stun(4 SECONDS)
			step_away(robot_hit, attacker, 15)
			log_combat(attacker, robot_hit, "pushed")
			robot_hit.visible_message(
				span_danger("[attacker] forces back [robot_hit]!"),
				span_userdanger("[attacker] forces back [robot_hit]!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				ignored_mobs = attacker,
			)
			to_chat(attacker, span_danger("You force [robot_hit] back!"))
			playsound(robot_hit, 'sound/weapons/pierce.ogg', 30, TRUE, -1)
		return ATTACK_STYLE_HIT

	var/obj/item/weapon = smacked.get_active_held_item()
	if(weapon && smacked.dropItemToGround(weapon))
		smacked.visible_message(
			span_danger("[attacker] disarms [smacked]!"),
			span_userdanger("[attacker] disarms you!"),
			span_hear("You hear aggressive shuffling!"),
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You disarm [smacked]!"))
		playsound(smacked, 'sound/weapons/slash.ogg', 30, TRUE, -1)
		log_combat(attacker, smacked, "disarmed", addition = " dropping [weapon]")

	else
		smacked.Paralyze(10 SECONDS)
		smacked.visible_message(
			span_danger("[attacker] tackles [smacked] down!"),
			span_userdanger("[attacker] tackles you down!"),
			span_hear("You hear aggressive shuffling followed by a loud thud!"),
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You tackle [smacked] down!"))
		playsound(smacked, 'sound/weapons/pierce.ogg', 30, TRUE, -1)
		log_combat(attacker, smacked, "tackled")
	return ATTACK_STYLE_HIT
