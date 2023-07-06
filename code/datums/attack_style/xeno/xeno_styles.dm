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
	return ATTACK_SWING_HIT

/datum/attack_style/unarmed/help/larva

/datum/attack_style/unarmed/help/larva/finalize_attack(mob/living/carbon/alien/larva/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	smacked.visible_message(
		span_notice("[attacker] rubs its head against [smacked]."),
		span_notice("[attacker] rubs its head against you."),
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_notice("You rubs its head against [smacked]."))
	return ATTACK_SWING_HIT

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
		return ATTACK_SWING_SKIPPED
	return ..()

/datum/attack_style/unarmed/generic_damage/mob_attack/xeno/adult
	can_dismember_limbs = TRUE

/*
 * Xeno disarm
 */
/datum/attack_style/unarmed/disarm/xeno
	attack_effect = ATTACK_EFFECT_DISARM
	successful_hit_sound = null // Snowflaked

/datum/attack_style/unarmed/disarm/xeno/disarm_target(mob/living/attacker, mob/living/smacked, shove_verb)
	if(iscyborg(smacked))
		disarm_cyborg(attacker, smacked)
	else
		mega_shove_guy(attacker, smacked)
	return ATTACK_SWING_HIT

/datum/attack_style/unarmed/disarm/xeno/proc/disarm_cyborg(mob/living/attacker, mob/living/silicon/robot/smacked)
	var/mob/living/silicon/robot/robot_hit = smacked
	var/obj/item/borg_module = robot_hit.get_active_held_item()
	if(borg_module)
		smacked.uneq_active()
		smacked.visible_message(
			span_danger("[attacker] disarmed [smacked]!"),
			span_userdanger("[attacker] has disabled [smacked]'s active module!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You disable [smacked]'s active module!"))
		log_combat(attacker, smacked, "disarmed", addition = "[borg_module ? " removing [borg_module]" : ""]")
		playsound(smacked, 'sound/weapons/slash.ogg', 30, TRUE, -1)

	else
		smacked.Stun(4 SECONDS)
		step_away(smacked, attacker, 15)
		log_combat(attacker, smacked, "pushed")
		smacked.visible_message(
			span_danger("[attacker] forces back [smacked]!"),
			span_userdanger("[attacker] forces back [smacked]!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You force [smacked] back!"))
		playsound(smacked, 'sound/weapons/pierce.ogg', 30, TRUE, -1)

/datum/attack_style/unarmed/disarm/xeno/proc/mega_shove_guy(mob/living/attacker, mob/living/smacked)
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
		return

	if(HAS_TRAIT(smacked, TRAIT_INCAPACITATED))
		smacked.Paralyze(5 SECONDS)
		playsound(smacked, 'sound/weapons/punch3.ogg', 25, TRUE, -1)
		smacked.visible_message(
			span_danger("[attacker] slams [smacked] into the floor!"),
			span_userdanger("[attacker] slams you into the ground!"),
			span_hear("You hear something slam loudly onto the floor!"),
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You slam [src] into the floor beneath you!"))
		log_combat(attacker, smacked, "slammed into the ground")
		return

	playsound(smacked, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
	var/turf/shovetarget = get_edge_target_turf(attacker, get_dir(attacker, get_step_away(src, attacker)))
	smacked.apply_damage(35, STAMINA)
	smacked.throw_at(shovetarget, 4, 2, attacker, force = MOVE_FORCE_OVERPOWERING)
	smacked.visible_message(
		span_danger("[attacker] tackles [smacked] down!"),
		span_userdanger("[attacker] shoves you with great force!"),
		span_hear("You hear aggressive shuffling followed by a loud thud!"),
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_danger("You shove [smacked] with great force!"))
	log_combat(attacker, smacked, "shoved (xeno)")
