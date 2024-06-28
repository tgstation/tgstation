#define MIN_DISARM_CHANCE 25
#define MAX_DISARM_CHANCE 75

/obj/item/toy/basketball
	name = "basketball"
	icon = 'icons/obj/toys/balls.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets
	item_flags = XENOMORPH_HOLDABLE // playing ball against a xeno is rigged since they cannot be disarmed
	/// The person dribbling the basketball
	var/mob/living/wielder
	/// So the basketball doesn't make sound every step
	var/steps = 0
	var/step_delay = 2
	/// So they can't spam dribbling (at least not too much)
	var/last_use = 0
	var/use_delay = 0.2 SECONDS
	/// List of player ckeys who aren't allowed to pickup the ball (after scoring)
	/// This resets after someone else picks up the ball or a certain amount of time has passed
	var/pickup_restriction_ckeys = list()
	/// Pickup restriction cooldown
	COOLDOWN_DECLARE(pickup_cooldown)

/obj/item/toy/basketball/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(remove_ball_effects))
	RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(after_throw_reset))
	RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(after_throw_reset))

/obj/item/toy/basketball/proc/reset_pickup_restriction()
	pickup_restriction_ckeys = list()
	COOLDOWN_RESET(src, pickup_cooldown)

/obj/item/toy/basketball/proc/on_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER

	wielder = user

	// the equip signal is sent AFTER the object is put in hands
	// so we need to manually check if the held object is different
	for(var/obj/item/toy/basketball/ball in user.held_items)
		if(ball != src)
			return // multiple balls in different hands so no need to setup signals again

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(movement_effect))
	RegisterSignal(user, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin))
	RegisterSignal(user, COMSIG_LIVING_DISARM_HIT, PROC_REF(on_equipped_mob_disarm))
	RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_equipped_mob_knockdown))

/obj/item/toy/basketball/proc/remove_ball_effects()
	SIGNAL_HANDLER

	// unlike on_equip, this signal is triggered after the ball is removed from hands
	// so we can just use is_holding_item_of_type() proc to check for multiple balls
	if(!wielder.is_holding_item_of_type(/obj/item/toy/basketball))
		UnregisterSignal(wielder, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EMOTED("spin"), COMSIG_LIVING_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOB_THROW))

	wielder = null

/**
 * After a ball is thrown we need to reset the pass_flags since shooting lets you shoot through mobs
 * * source: Datum src from original signal call
**/
/obj/item/toy/basketball/proc/after_throw_reset() // don't need the args for the signal
	SIGNAL_HANDLER

	pass_flags = initial(pass_flags)

/obj/item/toy/basketball/attack_hand(mob/living/user, list/modifiers)
	if(!user.can_perform_action(src, NEED_HANDS))
		return

	if((user.ckey in pickup_restriction_ckeys) && !COOLDOWN_FINISHED(src, pickup_cooldown))
		user.balloon_alert(user, "cant pickup for [COOLDOWN_TIMELEFT(src, pickup_cooldown) *0.1] seconds!")
		return

	reset_pickup_restriction()
	return ..()

/obj/item/toy/basketball/proc/movement_effect(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(steps > step_delay)
		playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
		steps = 0
	else
		steps++

/obj/item/toy/basketball/proc/on_spin(mob/living/user)
	SIGNAL_HANDLER

	for(var/i in 1 to 6)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/basketball_bounce.ogg', 75, FALSE), 0.25 SECONDS * i)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon/, adjustStaminaLoss), STAMINA_COST_SPINNING), 1.5 SECONDS)

/// Used to calculate our disarm chance based on stamina, direction, and spinning
/// Note - monkeys use attack_paw() and never trigger this signal (so they always have 100% disarm)
/obj/item/toy/basketball/proc/on_equipped_mob_disarm(mob/living/baller, mob/living/stealer, zone, obj/item/weapon)
	SIGNAL_HANDLER

	// spinning gives you a lower disarm chance but it drains stamina
	var/disarm_chance = HAS_TRAIT(baller, TRAIT_SPINNING) ? 35 : 50
	// ballers stamina results in lower disarm, stealer stamina results in higher disarm
	disarm_chance += (baller.getStaminaLoss() - stealer.getStaminaLoss()) / 2
	// the lowest chance for disarm is 25% and the highest is 75%
	disarm_chance = clamp(disarm_chance, MIN_DISARM_CHANCE, MAX_DISARM_CHANCE)

	// getting disarmed or shoved while holding the ball drains stamina
	baller.adjustStaminaLoss(STAMINA_COST_DISARMING)

	if(!prob(disarm_chance))
		return // the disarm failed

	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
	var/blocking_dir_bonus = check_target_facings(stealer, baller)

	switch(blocking_dir_bonus)
		if(FACING_EACHOTHER)
			stealer.balloon_alert_to_viewers("steals the ball")
			INVOKE_ASYNC(stealer, TYPE_PROC_REF(/mob, put_in_hands), src)
		if(FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR)
			if(prob(50))
				if(!baller.dropItemToGround(src))
					return
				stealer.balloon_alert_to_viewers("bats the ball")
			else
				stealer.balloon_alert_to_viewers("steals the ball")
				INVOKE_ASYNC(stealer, TYPE_PROC_REF(/mob, put_in_hands), src)
		if(FACING_SAME_DIR)
			if(!baller.dropItemToGround(src))
				return
			stealer.balloon_alert_to_viewers("bats the ball")

/obj/item/toy/basketball/proc/on_equipped_mob_knockdown(mob/living/user, amount)
	SIGNAL_HANDLER

	if(!istype(user))
		return

	// Healing knockdown or setting knockdown to zero or something? No fumble
	if(amount <= 0)
		return

	if(!user.dropItemToGround(src))
		return

	user.balloon_alert_to_viewers("fumbles the ball")

/obj/item/toy/basketball/attack(mob/living/carbon/target, mob/living/user, params)
	if(!iscarbon(target) || user.combat_mode)
		return ..()

	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
	target.put_in_hands(src)

/obj/item/toy/basketball/attack_self(mob/living/user)
	if(!user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return

	// no spamming
	if(last_use + use_delay > world.time)
		return

	// need a free hand and can't be spinning
	if(!user.put_in_inactive_hand(src) || HAS_TRAIT(user, TRAIT_SPINNING))
		return

	last_use = world.time
	user.swap_hand(user.get_held_index_of_item(src))
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)

/obj/item/toy/basketball/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom(interacting_with, user, modifiers)

/obj/item/toy/basketball/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.combat_mode)
		user.throw_item(interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/toy/basketball/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/obj/item/toy/basketball/interact_with_atom_secondary(atom/interacting_with, mob/living/baller, list/modifiers)
	if(istype(interacting_with, /obj/structure/hoop) && baller.Adjacent(interacting_with))
		return NONE // Do hoop stuff

	baller.adjustStaminaLoss(STAMINA_COST_SHOOTING)

	var/dunk_dir = get_dir(baller, interacting_with)
	var/dunk_pixel_y = dunk_dir & SOUTH ? -16 : 16
	var/dunk_pixel_x = dunk_dir & EAST && 16 || dunk_dir & WEST && -16 || 0

	animate(baller, pixel_x = dunk_pixel_x, pixel_y = dunk_pixel_y, time = 5, easing = BOUNCE_EASING|EASE_IN|EASE_OUT)
	if(do_after(baller, 0.5 SECONDS))
		pass_flags |= PASSMOB
		baller.throw_item(interacting_with)
		animate(baller, pixel_x = 0, pixel_y = 0, time = 3)
		return ITEM_INTERACT_SUCCESS

	animate(baller, pixel_x = 0, pixel_y = 0, time = 3)
	return ITEM_INTERACT_BLOCKING

/obj/item/toy/basketball/throw_impact(mob/living/carbon/target, datum/thrownthing/throwingdatum)
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)

	if(!istype(target))
		return ..()

	target.put_in_hands(src)

#undef MAX_DISARM_CHANCE
#undef MIN_DISARM_CHANCE
