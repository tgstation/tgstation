
/datum/attack_style/unarmed/disarm
	attack_effect = ATTACK_EFFECT_DISARM
	successful_hit_sound = 'sound/weapons/thudswoosh.ogg'

/datum/attack_style/unarmed/disarm/execute_attack(mob/living/attacker, obj/item/bodypart/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	if(attacker.body_position != STANDING_UP)
		return ATTACK_STYLE_CANCEL
	if(attacker.loc in affecting)
		return ATTACK_STYLE_CANCEL

	return ..()

/datum/attack_style/unarmed/disarm/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	if(attacker == smacked || attacker.loc == smacked.loc)
		return ATTACK_STYLE_CANCEL

	var/shove_verb = smacked.response_disarm_simple || "shove"

	if(smacked.check_block(attacker, 0, "[attacker]'s [shove_verb]", MELEE_ATTACK))
		smacked.visible_message(
			span_warning("[smacked] blocks [attacker]'s [shove_verb]!"),
			span_userdanger("You block [attacker]'s [shove_verb]!"),
			span_hear("You hear a swoosh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_warning("[smacked] blocks your [shove_verb]!"))
		return ATTACK_STYLE_BLOCKED

	if(attacker.move_force < smacked.move_resist)
		smacked.visible_message(
			span_warning("[smacked] resists [attacker]'s [shove_verb]!"),
			span_userdanger("You resist [attacker]'s [shove_verb]!"),
			span_hear("You hear a swoosh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_warning("[smacked] resists your [shove_verb]!"))
		return ATTACK_STYLE_BLOCKED

	if (ishuman(smacked))
		var/mob/living/carbon/human/human_smacked = smacked
		human_smacked.w_uniform?.add_fingerprint(attacker)

	// Todo : move this out and into its own style?
	if(!HAS_TRAIT(smacked, TRAIT_MARTIAL_ARTS_IMMUNE))
		var/datum/martial_art/art = attacker.mind?.martial_art
		switch(art?.disarm_act(attacker, smacked))
			if(MARTIAL_ATTACK_SUCCESS)
				return ATTACK_STYLE_HIT
			if(MARTIAL_ATTACK_FAIL)
				return ATTACK_STYLE_MISSED

	return disarm_target(attacker, smacked, shove_verb)

/datum/attack_style/unarmed/disarm/proc/disarm_target(mob/living/attacker, mob/living/smacked, shove_verb)
	var/shove_dir = get_dir(attacker, smacked)
	var/turf/target_shove_turf = get_step(smacked, shove_dir)
	var/turf/target_old_turf = smacked.loc

	//Are we hitting anything? or
	var/pre_sig_return = SEND_SIGNAL(target_shove_turf, COMSIG_LIVING_DISARM_PRESHOVE)
	if(pre_sig_return & DISARM_STOP)
		return ATTACK_STYLE_MISSED

	// At this point a shove is going to happen
	SEND_SIGNAL(smacked, COMSIG_LIVING_DISARM_HIT, attacker, attacker.zone_selected)

	var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied
	if(pre_sig_return & DISARM_ACT_AS_SOLID)
		shove_blocked = TRUE
	else
		smacked.Move(target_shove_turf, shove_dir)
		if(get_turf(smacked) == target_old_turf)
			shove_blocked = TRUE

	if(!shove_blocked)
		smacked.setGrabState(GRAB_PASSIVE)

	. = NONE
	if(smacked.IsKnockdown() && !smacked.IsParalyzed()) //KICK HIM IN THE NUTS
		smacked.Paralyze(SHOVE_CHAIN_PARALYZE)
		smacked.visible_message(
			span_danger("[attacker] kicks [smacked] onto [smacked.p_their()] side!"),
			span_userdanger("You're kicked onto your side by [attacker]!"),
			span_hear("You hear aggressive shuffling followed by a loud thud!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_danger("You kick [smacked] onto [smacked.p_their()] side!"))
		addtimer(CALLBACK(smacked, TYPE_PROC_REF(/mob/living, SetKnockdown), 0 SECONDS), SHOVE_CHAIN_PARALYZE)
		log_combat(attacker, smacked, "kicks", "onto their side (paralyzing)")
		. |= ATTACK_STYLE_HIT

	var/directional_blocked = FALSE
	var/can_hit_something = (!smacked.is_shove_knockdown_blocked() && !smacked.buckled)

	//Directional checks to make sure that we're not shoving through a windoor or something like that
	if(shove_blocked && can_hit_something && (shove_dir in GLOB.cardinals))
		var/turf/target_current_turf = get_turf(smacked)
		for(var/obj/obj_content in target_current_turf)
			if((obj_content.flags_1 & ON_BORDER_1) && obj_content.dir == shove_dir && obj_content.density)
				directional_blocked = TRUE
				break

		if(target_current_turf != target_shove_turf && !directional_blocked) //Make sure that we don't run the exact same check twice on the same tile
			for(var/obj/obj_content in target_shove_turf)
				if((obj_content.flags_1 & ON_BORDER_1) && obj_content.dir == turn(shove_dir, 180) && obj_content.density)
					directional_blocked = TRUE
					break

	if(can_hit_something)
		//Don't hit people through windows, ok?
		if(!directional_blocked && (SEND_SIGNAL(target_shove_turf, COMSIG_LIVING_DISARM_COLLIDE, attacker, smacked, shove_blocked) & DISARM_SHOVE_HANDLED))
			return . | ATTACK_STYLE_HIT

		if(directional_blocked || shove_blocked)
			smacked.Knockdown(SHOVE_KNOCKDOWN_SOLID)
			smacked.visible_message(
				span_danger("[attacker] [shove_verb]s [smacked], knocking [smacked.p_them()] down!"),
				span_userdanger("You're knocked down from a [shove_verb] by [attacker]!"),
				span_hear("You hear aggressive shuffling followed by a loud thud!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
				ignored_mobs = attacker,
			)
			to_chat(attacker, span_danger("You [shove_verb] [smacked], knocking [smacked.p_them()] down!"))
			log_combat(attacker, smacked, "shoved", "knocking them down")
			return . | ATTACK_STYLE_HIT

	smacked.visible_message(
		span_danger("[attacker] [shove_verb]s [smacked]!"),
		span_userdanger("You're [shove_verb]d by [attacker]!"),
		span_hear("You hear aggressive shuffling!"),
		vision_distance = COMBAT_MESSAGE_RANGE,
		ignored_mobs = attacker,
	)
	to_chat(attacker, span_danger("You [shove_verb] [smacked]!"))

	//Take their lunch money
	var/obj/item/target_held_item = smacked.get_active_held_item()
	var/append_message = ""
	if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types)) //It's too expensive we'll get caught
		target_held_item = null

	if(!smacked.has_movespeed_modifier(/datum/movespeed_modifier/shove))
		smacked.add_movespeed_modifier(/datum/movespeed_modifier/shove)
		if(target_held_item)
			append_message = "loosening [smacked.p_their()] grip on [target_held_item]"
			smacked.visible_message(
				span_danger("[smacked]'s grip on \the [target_held_item] loosens!"), //He's already out what are you doing
				span_warning("Your grip on \the [target_held_item] loosens!"),
				vision_distance = COMBAT_MESSAGE_RANGE,
			)
		addtimer(CALLBACK(smacked, TYPE_PROC_REF(/mob/living, clear_shove_slowdown), target_held_item), SHOVE_SLOWDOWN_LENGTH)

	else if(target_held_item)
		smacked.dropItemToGround(target_held_item)
		append_message = "causing [smacked.p_them()] to drop [target_held_item]"
		smacked.visible_message(
			span_danger("[smacked] drops \the [target_held_item]!"),
			span_warning("You drop \the [target_held_item]!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
		)

	log_combat(attacker, smacked, "shoved", append_message)
	return . | ATTACK_STYLE_HIT

/datum/attack_style/unarmed/grab
	attack_effect = null
	successful_hit_sound = null
	miss_sound = null

/datum/attack_style/unarmed/grab/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	if(smacked.check_block(attacker, 0, "[attacker]'s grab", UNARMED_ATTACK))
		smacked.visible_message(
			span_warning("[smacked] blocks [attacker]'s grab!"),
			span_userdanger("You block [attacker]'s grab!"),
			span_hear("You hear a swoosh!"),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = attacker,
		)
		to_chat(attacker, span_warning("[smacked] blocks your grab!"))
		return ATTACK_STYLE_BLOCKED

	// Todo : move this out and into its own style?
	if(!HAS_TRAIT(smacked, TRAIT_MARTIAL_ARTS_IMMUNE))
		var/datum/martial_art/art = attacker.mind?.martial_art
		switch(art?.grab_act(attacker, smacked))
			if(MARTIAL_ATTACK_SUCCESS)
				return ATTACK_STYLE_HIT
			if(MARTIAL_ATTACK_FAIL)
				return ATTACK_STYLE_MISSED

	smacked.grabbedby(attacker)
	return ATTACK_STYLE_HIT
