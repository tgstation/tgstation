#define MIN_DISARM_CHANCE 25
#define MAX_DISARM_CHANCE 75
#define PICKUP_RESTRICTION_TIME 3 SECONDS // so other players can pickup the ball after someone scores

/// You hit exhaustion when you use 100 stamina
#define STAMINA_COST_SHOOTING 10 // shooting with RMB drains stamina (but LMB does not)
#define STAMINA_COST_DUNKING 20 // dunking is more strenous than shooting
#define STAMINA_COST_DUNKING_MOB 30 // dunking another person is harder
#define STAMINA_COST_SPINNING 15 // spin emote uses stamina while holding ball
#define STAMINA_COST_DISARMING 10 // getting shoved or disarmed while holding ball drains stamina

/obj/item/toy/basketball
	name = "basketball"
	icon = 'icons/obj/toys/balls.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets
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

// what about wielder.combat_mode  ???

/obj/item/toy/basketball/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

	// test this and remove if it doesn't work
	RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(after_throw_reset))
	RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(after_throw_reset))

// basketball/qdel don't forget to remove these signals
//	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/toy/basketball/proc/reset_pickup_restriction()
	pickup_restriction_ckeys = list()
	COOLDOWN_RESET(src, pickup_cooldown)

/obj/item/toy/basketball/proc/on_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER

	/*
	if(!(source.slot_flags & slot))
		return
	*/
	wielder = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(movement_effect))
	//RegisterSignal(user, COMSIG_MOB_EMOTE, PROC_REF(on_spin))
	RegisterSignal(user, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin))
	RegisterSignal(user, COMSIG_HUMAN_DISARM_HIT, PROC_REF(on_equipped_mob_disarm))
	RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_equipped_mob_knockdown))
	RegisterSignal(user, COMSIG_MOB_THROW, PROC_REF(on_throw))

	// use this to check shoving?
	//RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, PROC_REF(check_shove))

/obj/item/toy/basketball/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielder = null
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EMOTED("spin"), COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOB_THROW))

/obj/item/toy/basketball/proc/on_throw(mob/living/carbon/thrower)
	SIGNAL_HANDLER

	wielder = null
	UnregisterSignal(thrower, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EMOTED("spin"), COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_MOB_THROW))


/**
 * After a ball is thrown we need to reset the pass_flags since shooting lets you shoot through mobs
 * * source: Datum src from original signal call
**/
/obj/item/toy/basketball/proc/after_throw_reset(datum/source) // other args are redundant
	SIGNAL_HANDLER

	pass_flags = initial(pass_flags)

/**
 * Proc that triggers when the thrown boomerang hits an object.
 * * source: Datum src from original signal call.
 * * hit_atom: The atom that has been hit by the boomerang component.
 * * init_throwing_datum: The thrownthing datum that originally impacted the object, that we use to build the new throwing datum for the rebound.
/datum/component/boomerang/proc/return_hit_throw(datum/source, atom/hit_atom, datum/thrownthing/init_throwing_datum)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/obj/item/true_parent = parent
	aerodynamic_swing(init_throwing_datum, true_parent)

 * Proc that triggers when the thrown boomerang does not hit a target.
 * * source: Datum src from original signal call.
 * * throwing_datum: The thrownthing datum that originally impacted the object, that we use to build the new throwing datum for the rebound.

/datum/component/boomerang/proc/return_missed_throw(datum/source, datum/thrownthing/throwing_datum)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, last_boomerang_throw))
		return
	var/obj/item/true_parent = parent
	aerodynamic_swing(throwing_datum, true_parent)
 */

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
		//wielder.adjustStaminaLoss(1) // balling drains your stamina as you move
	else
		steps++

/obj/item/toy/basketball/proc/on_spin(mob/living/user)
	SIGNAL_HANDLER

	for(var/i in 1 to 6)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), src, 'sound/items/basketball_bounce.ogg', 75, FALSE), 0.25 SECONDS * i)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon/, adjustStaminaLoss), STAMINA_COST_SPINNING), 1.5 SECONDS)

/// Used to calculate our disarm chance based on stamina, direction, and spinning
/// Note - monkeys use attack_paw() and never trigger this signal (so they always have 100% disarm)
/obj/item/toy/basketball/proc/on_equipped_mob_disarm(mob/living/baller, mob/living/stealer, zone)
	SIGNAL_HANDLER

	if(!istype(baller))
		return

	// spinning gives you a lower disarm chance but it drains stamina
	var/disarm_chance = baller.flags_1 & IS_SPINNING_1 ? 35 : 50
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
			INVOKE_ASYNC(stealer, TYPE_PROC_REF(/mob, put_in_hands), src) // put_in_hands uses sleep() so need to use ASYNCH
			//stealer.put_in_hands(src)
		if(FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR)
			if(prob(50))
				if(!baller.dropItemToGround(src))
					return
				stealer.balloon_alert_to_viewers("bats the ball")
			else
				stealer.balloon_alert_to_viewers("steals the ball")
				INVOKE_ASYNC(stealer, TYPE_PROC_REF(/mob, put_in_hands), src) // put_in_hands uses sleep() so need to use ASYNCH
				//stealer.put_in_hands(src)
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

	//user.balloon_alert_to_viewers("passes the ball")
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
	target.put_in_hands(src)

/obj/item/toy/basketball/attack_self(mob/living/user)
	if(!user.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return

	// no spamming
	if(last_use + use_delay > world.time)
		return

	// need a free hand and can't be spinning
	if(!user.put_in_inactive_hand(src) && user.flags_1 & IS_SPINNING_1)
		return

	last_use = world.time
	user.swap_hand(user.get_held_index_of_item(src))
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)

/**
	M.update_held_items()
	for(var/hand_index in user.get_empty_held_indexes())
		if(target.can_put_in_hand(held_item, hand_index))
			has_valid_hand = TRUE
			break
*/

/obj/item/toy/basketball/afterattack(atom/target, mob/user)
	. = ..()
	user.throw_item(target)


//	pass_flags = initial(pass_flags)

/obj/item/toy/basketball/afterattack_secondary(atom/aim_target, mob/living/baller, params)
	//attack_hand(user, modifiers, flip_card = TRUE)

	// dunking negates shooting
	if(istype(aim_target, /obj/structure/hoop) && baller.Adjacent(aim_target))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	//baller.balloon_alert_to_viewers("shooting...")
	baller.adjustStaminaLoss(STAMINA_COST_SHOOTING)

	var/dunk_dir = get_dir(baller, aim_target)
	var/dunk_pixel_y = dunk_dir & SOUTH ? -16 : 16
	var/dunk_pixel_x = dunk_dir & EAST && 16 || dunk_dir & WEST && -16 || 0

	animate(baller, pixel_x = dunk_pixel_x, pixel_y = dunk_pixel_y, time = 5, easing = BOUNCE_EASING|EASE_IN|EASE_OUT)
	if(do_after(baller, 0.5 SECONDS))
		pass_flags |= PASSMOB
		baller.throw_item(aim_target)
//		pass_flags = initial(pass_flags)
		//sleep(0.5 SECONDS)
		animate(baller, pixel_x = 0, pixel_y = 0, time = 3) // easing = BOUNCE_EASING)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	animate(baller, pixel_x = 0, pixel_y = 0, time = 3) // easing = BOUNCE_EASING)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/**
	if(!isliving(victim) || !IN_GIVEN_RANGE(user, victim, GUNPOINT_SHOOTER_STRAY_RANGE))
		return ..() //if they're out of range, just shootem.
	if(!can_hold_up)
		return ..()
	var/datum/component/gunpoint/gunpoint_component = user.GetComponent(/datum/component/gunpoint)
	if (gunpoint_component)
		if(gunpoint_component.target == victim)
			return ..() //we're already holding them up, shoot that mans instead of complaining
		balloon_alert(user, "already holding someone up!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if (user == victim)
		balloon_alert(user, "can't hold yourself up!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	user.AddComponent(/datum/component/gunpoint, victim, src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
*/

//afterattack_secondary
// if(HAS_TRAIT(src, TRAIT_WIELDED))dg
// M.apply_damage(10, STAMINA)

//obj/item/toy/basketball/pre_attack_secondary(mob/living/user, list/modifiers)

/obj/item/toy/basketball/throw_impact(mob/living/carbon/target, datum/thrownthing/throwingdatum)
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)

	if(!istype(target))
		return ..()

	var/atom/movable/actual_target = throwingdatum.initial_target?.resolve()
	if(target == actual_target || prob(50)) // 50% chance to catch the ball if you don't directly aim on target
		target.put_in_hands(src)

	// . = ..()

/**
/obj/item/toy/basketball/attack_secondary(mob/living/victim, mob/living/user, params)
	var/signal_result = SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SECONDARY, victim, user, params)

	if(signal_result & COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(signal_result & COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	return SECONDARY_ATTACK_CALL_NORMAL
*/

/datum/crafting_recipe/basketball_hoop
	name = "Basketball Hoop"
	result = /obj/structure/hoop
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/iron = 1, // the backboard
				/obj/item/stack/rods = 5)
	time = 10 SECONDS
	category = CAT_STRUCTURE

/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/toys/basketball_hoop.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	/// Keeps track of the total points scored
	var/total_score = 0
	/// The chance to score a ball into the hoop based on distance
	/// ex. a distance of two tiles away, throw_range_success[2], results in 80% chance to score
	/// if someone shoots 3 tiles away (65% chance) or more, it scores 3 points
	var/static/list/throw_range_success = list(95, 80, 65, 50, 35, 20)

/obj/structure/hoop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED, AfterRotation = CALLBACK(src, PROC_REF(reset_appearance)))
	update_appearance()

/obj/structure/hoop/proc/reset_appearance()
	update_appearance()

/obj/structure/hoop/proc/score(obj/item/toy/basketball/ball, mob/living/baller, points)
	// we still play buzzer sound regardless of the object
	playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)

	if(!istype(ball))
		return

	total_score += points
	update_appearance()
	// whoever scored doesn't get to pickup the ball instantly
	COOLDOWN_START(ball, pickup_cooldown, PICKUP_RESTRICTION_TIME)

	ball.pickup_restriction_ckeys |= baller.ckey
	return TRUE

/obj/structure/hoop/update_overlays()
	. = ..()

	if(dir & NORTH)
		SET_PLANE_IMPLICIT(src, GAME_PLANE_UPPER)

	cut_overlays()

	var/dir_offset_x = 0
	var/dir_offset_y = 0

	switch(dir)
		if(NORTH)
			dir_offset_y = -32
		if(SOUTH)
			dir_offset_y = 32
		if(EAST)
			dir_offset_x = -32
		if(WEST)
			dir_offset_x = 32

	var/mutable_appearance/scoreboard = mutable_appearance('icons/obj/signs.dmi', "basketball_scorecard")
	scoreboard.pixel_x = dir_offset_x
	scoreboard.pixel_y = dir_offset_y
	SET_PLANE_EXPLICIT(scoreboard, GAME_PLANE, src)
	. += scoreboard
	//add_overlay(scoreboard)

	var/ones = total_score % 10
	var/mutable_appearance/ones_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[ones]", layer + 0.01)
	ones_overlay.pixel_x = 4
	var/mutable_appearance/emissive_ones_overlay  = emissive_appearance('icons/obj/signs.dmi', "days_[ones]", src, alpha = src.alpha)
	emissive_ones_overlay.pixel_x = 4
	scoreboard.add_overlay(ones_overlay)
	scoreboard.add_overlay(emissive_ones_overlay)

	var/tens = (total_score / 10) % 10
	var/mutable_appearance/tens_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[tens]", layer + 0.01)
	tens_overlay.pixel_x = -5

	var/mutable_appearance/emissive_tens_overlay  = emissive_appearance('icons/obj/signs.dmi', "days_[tens]", src, alpha = src.alpha)
	emissive_tens_overlay.pixel_x = -5
	scoreboard.add_overlay(tens_overlay)
	scoreboard.add_overlay(emissive_tens_overlay)

/obj/structure/hoop/attackby(obj/item/ball, mob/living/baller, params)
	if(get_dist(src, baller) < 2) // TK users aren't allowed to dunk (not sure if this code even works tbh)
		if(baller.transferItemToLoc(ball, drop_location()))
			var/dunk_dir = get_dir(baller, src)

			var/dunk_pixel_y = dunk_dir & SOUTH ? -16 : 16
			var/dunk_pixel_x = dunk_dir & EAST && 16 || dunk_dir & WEST && -16 || 0

			animate(baller, pixel_x = dunk_pixel_x, pixel_y = dunk_pixel_y, time = 5, easing = BOUNCE_EASING|EASE_IN|EASE_OUT)
			sleep(0.5 SECONDS)
			animate(baller, pixel_x = 0, pixel_y = 0, time = 3) // easing = BOUNCE_EASING)

			visible_message(span_warning("[baller] dunks [ball] into \the [src]!"))
			score(ball, baller, 2)

			if(istype(ball, /obj/item/toy/basketball))
				baller.adjustStaminaLoss(STAMINA_COST_DUNKING)

/obj/structure/hoop/attack_hand(mob/living/baller, list/modifiers)
	. = ..()
	if(.)
		return
	if(baller.pulling && isliving(baller.pulling))
		var/mob/living/loser = baller.pulling
		if(baller.grab_state < GRAB_AGGRESSIVE)
			to_chat(baller, span_warning("You need a better grip to do that!"))
			return
		loser.forceMove(loc)
		loser.Paralyze(100)
		visible_message(span_danger("[baller] dunks [loser] into \the [src]!"))
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
		baller.adjustStaminaLoss(STAMINA_COST_DUNKING_MOB)
		baller.stop_pulling()
	else
		..()

/obj/structure/hoop/CtrlClick(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH|NEED_HANDS))
		return

	user.balloon_alert_to_viewers("resetting score...")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(do_after(user, 5 SECONDS, target = src))
		total_score = 0
		update_appearance()
	return ..()

/*
/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle = FALSE, quickstart = TRUE)
	if(!..())
		return
	playsound(src.loc,'sound/weapons/bolathrow.ogg', 75, TRUE)
*/

/obj/structure/hoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && !istype(AM, /obj/projectile))
		var/distance = clamp(throwingdatum.dist_travelled + 1, 1, throw_range_success.len)
		var/score_chance = throw_range_success[distance]
		var/obj/structure/hoop/backboard = throwingdatum.initial_target?.resolve()
		var/click_on_hoop = TRUE
		var/mob/living/thrower = throwingdatum.thrower

		// aim penalty for not clicking directly on the hoop when shooting
		if(!istype(backboard) || backboard != src)
			click_on_hoop = FALSE
			score_chance *= 0.5

		// aim penalty for spinning while shooting
		if(istype(thrower) && thrower.flags_1 & IS_SPINNING_1)
			score_chance *= 0.5

		if(prob(score_chance))
			AM.forceMove(get_turf(src))
			// is it a 3 pointer shot
			var/points = (distance > 2) ? 3 : 2
			score(AM, thrower, points)
			visible_message(span_warning("[click_on_hoop ? "Swish!" : ""] [AM] lands in [src]."))
		else
			visible_message(span_danger("[AM] bounces off of [src]'s [click_on_hoop ? "rim" : "backboard"]!"))

	return ..()

// Special hoops for the minigame
/obj/structure/hoop/minigame
	/// This is a list of ckeys for the minigame to prevent scoring on their own hoops
	var/list/team_ckeys = list()

/obj/structure/hoop/minigame/score(obj/item/toy/basketball/ball, mob/living/baller, points)
	var/is_team_hoop = (baller.ckey in team_ckeys)
	if(is_team_hoop)
		baller.balloon_alert_to_viewers("cant score own hoop!")
		return

	if(..())
		ball.pickup_restriction_ckeys |= team_ckeys

	// RegisterSignal(ball, COMSIG_ITEM_PICKUP, TYPE_PROC_REF(/obj/item/toy/basketball, pickup_restriction), team)
	// addtimer(CALLBACK(ball, TYPE_PROC_REF(/obj/item/toy/basketball, reset_pickup_restriction)), PICKUP_RESTRICTION_TIME)

// No resetting the score for minigame hoops
/obj/structure/hoop/minigame/CtrlClick(mob/living/user)
	return

/obj/item/clothing/mask/whistle/minigame
	name = "referee whistle"
	desc = "A referee whistle used to call fouls against players."
	actions_types = list(/datum/action/innate/timeout)

// should be /datum/action/item_action but it doesn't support InterceptClickOn()
/datum/action/innate/timeout
	name = "Call foul"
	desc = "Puts a person in a timeout for a few seconds."
	button_icon = 'icons/obj/clothing/masks.dmi'
	button_icon_state = "whistle"
	click_action = TRUE
	enable_text = span_cult("You prepare to call a foul on someone...")
	disable_text = span_cult("You decide it was a bad call...")
	COOLDOWN_DECLARE(whistle_cooldown_minigame)

/datum/action/innate/timeout/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	var/turf/caller_turf = get_turf(caller)
	if(!isturf(caller_turf))
		return FALSE

	if(!ishuman(clicked_on) || get_dist(caller, clicked_on) > 7)
		return FALSE

	if(clicked_on == caller) // can't call a foul on yourself
		return FALSE

	if(!COOLDOWN_FINISHED(src, whistle_cooldown_minigame))
		caller.balloon_alert(caller, "cant cast for [COOLDOWN_TIMELEFT(src, whistle_cooldown_minigame) *0.1] seconds!")
		unset_ranged_ability(caller)
		return FALSE

	return ..()

/datum/action/innate/timeout/do_ability(mob/living/caller, mob/living/carbon/human/target)
	caller.say("FOUL BY [target]!", forced = "whistle")
	playsound(caller, 'sound/misc/whistle.ogg', 75, FALSE, 4)

	new /obj/effect/timestop(get_turf(target), 0, 5 SECONDS, list(caller), TRUE, TRUE)

	COOLDOWN_START(src, whistle_cooldown_minigame, 1 MINUTES)
	unset_ranged_ability(caller)

	to_chat(target, span_bold("[caller] has given you a timeout for a foul!"))
	to_chat(caller, span_bold("You put [target] in a timeout!"))
	// build_all_button_icons()
	return TRUE

#undef PICKUP_RESTRICTION_TIME

#undef STAMINA_COST_SHOOTING
#undef STAMINA_COST_DUNKING
#undef STAMINA_COST_DUNKING_MOB
#undef STAMINA_COST_SPINNING
#undef STAMINA_COST_DISARMING
