/// Allows people to force other people to touch it to cause burns
/// Or maybe in the future clumsy people can touch it to burn themselves, who knows
/datum/component/touch_the_stove
	/// Determines whether we can actually burn people
	VAR_PRIVATE/datum/callback/is_active
	/// Temperature that which we burn
	VAR_PRIVATE/temperature = 1000
	/// Damage dealt when touching the stove
	VAR_PRIVATE/damage = 20

/datum/component/touch_the_stove/Initialize(datum/callback/is_active, damage = 20, temperature = 1000)
	src.is_active = is_active
	src.temperature = temperature
	src.damage = damage
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

/datum/component/touch_the_stove/Destroy()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	return ..()

/datum/component/touch_the_stove/proc/on_attack_hand(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER

	if(astype(user.pulling, /mob/living)?.num_hands <= 0)
		return NONE
	if(user.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You need a better grip to do that!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	user.changeNext_move(CLICK_CD_SLOW)
	var/mob/living/hand_target = user.pulling
	if(is_active && !is_active.Invoke())
		user.visible_message(
			span_danger("[user] places [hand_target]'s hand on [source] - but as it's not on, only succeeds in looking like a fool."),
			span_danger("You place [hand_target]'s hand on [source] - but as it's not on, you only succeed in looking like a fool."),
		)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	log_combat(user, hand_target, "forcibly burned hand on hot surface", source)

	user.visible_message(
		span_danger("[user] places [hand_target]'s hand on [source]!"),
		span_danger("You place [hand_target]'s hand on [source]!"),
		ignored_mobs = hand_target,
	)
	var/hand_target_zone = IS_RIGHT_INDEX(user.active_hand_index) ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM
	var/hand_target_real = hand_target.get_bodypart(hand_target) || hand_target.get_bodypart(BODY_ZONE_R_ARM) || hand_target.get_bodypart(BODY_ZONE_L_ARM)
	var/armor_power = hand_target.getarmor(hand_target_zone, FIRE)
	for(var/obj/item/thing as anything in astype(hand_target, /mob/living/carbon/human)?.get_clothing_on_part(hand_target_real))
		thing.fire_act(temperature)

	if(!hand_target.apply_damage(damage, BURN, hand_target_zone, armor_power))
		to_chat(hand_target, span_danger("[user] places your hand on [source], but you can barely feel the griddle."))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	hand_target.dropItemToGround(hand_target.get_active_held_item())
	switch(armor_power)
		if(90 to INFINITY)
			to_chat(hand_target, span_danger("[user] places your hand on [source], but you can barely feel any heat."))
		if(50 to 90)
			to_chat(hand_target, span_danger("[user] places your hand on [source]! You feel the heat building!"))
		else
			to_chat(hand_target, span_danger("[user] places your hand on [source]! It burns like hell!"))
			hand_target.painful_scream()

	playsound(hand_target, /datum/sound_effect/sizzle, vol = 50, vary = TRUE)
	return COMPONENT_CANCEL_ATTACK_CHAIN
