/// No deviation at all. Flashed from the front or front-left/front-right. Alternatively, flashed in direct view.
#define FACE_TO_BACK 0
/// Partial deviation. Flashed from the side. Alternatively, flashed out the corner of your eyes.
#define FACE_TO_SIDE 1
/// Full deviation. Flashed from directly behind or behind-left/behind-rack. Not flashed at all.
#define FACE_TO_FACE 2

#define MIN_DISARM_CHANCE 25
#define MAX_DISARM_CHANCE 75

/obj/item/toy/basketball
	name = "basketball"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets
	/// The person dribbling the basketball
	var/mob/living/wielder

	// So the basketball doesn't make sound every step
	var/steps = 0
	var/step_delay = 2

	// So they can't spam dribbling (at least not too much)
	var/last_use = 0
	var/use_delay = 0.2 SECONDS

// what about wielder.combat_mode  ???

/obj/item/toy/basketball/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

// basketball/qdel don't forget to remove these signals
//	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/toy/basketball/proc/on_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER

	/*
	if(!(source.slot_flags & slot))
		return
	*/
	wielder = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(movement_effect))
	RegisterSignal(user, COMSIG_MOB_EMOTE, PROC_REF(emote_stamina_drain))
	RegisterSignal(user, COMSIG_HUMAN_DISARM_HIT, PROC_REF(on_equipped_mob_disarm))
	RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_equipped_mob_knockdown))

	// use this to check shoving?
	//RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, PROC_REF(check_shove))

/obj/item/toy/basketball/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielder = null
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EMOTE, COMSIG_HUMAN_DISARM_HIT, COMSIG_LIVING_STATUS_KNOCKDOWN))

/obj/item/toy/basketball/proc/movement_effect(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(steps > step_delay)
		playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
		steps = 0
		wielder.adjustStaminaLoss(1) // balling drains your stamina as you move
	else
		steps++

/obj/item/toy/basketball/proc/emote_stamina_drain(mob/living/user, datum/emote/emote)
	SIGNAL_HANDLER

	if(!istype(emote, /datum/emote/spin))
		return

	for(var/i in 1 to 6)
		playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
		sleep(0.25 SECONDS)
		user.adjustStaminaLoss(2)

/**
 * Handles the directionality of the attack
 *
 * Returns the amount of 'deviation', 0 being facing eachother, 1 being sideways, 2 being facing away from eachother.
 * Arguments:
 * * victim - Victim
 * * attacker - Attacker
 */
/obj/item/toy/basketball/proc/calculate_deviation(mob/victim, atom/attacker)
	// Are they on the same tile? We'll return partial deviation. This may be someone flashing while lying down
	// or flashing someone they're stood on the same turf as, or a borg flashing someone buckled to them.
	if(victim.loc == attacker.loc)
		return FACE_TO_SIDE

	// If the victim was looking at the attacker, this is the direction they'd have to be facing.
	var/victim_to_attacker = get_dir(victim, attacker)
	// The victim's dir is necessarily a cardinal value.
	var/victim_dir = victim.dir

	// - - -
	// - V - Victim facing south
	// # # #
	// Attacker within 45 degrees of where the victim is facing.
	if(victim_dir & victim_to_attacker)
		return FACE_TO_FACE

	// # # #
	// - V - Victim facing south
	// - - -
	// Attacker at 135 or more degrees of where the victim is facing.
	if(victim_dir & REVERSE_DIR(victim_to_attacker))
		return FACE_TO_BACK

	// - - -
	// # V # Victim facing south
	// - - -
	// Attacker lateral to the victim.
	return FACE_TO_SIDE

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
	baller.adjustStaminaLoss(10)

	if(!prob(disarm_chance))
		return // the disarm failed

	var/blocking_dir_bonus = calculate_deviation(baller, stealer)

	switch(blocking_dir_bonus)
		if(FACE_TO_FACE)
			stealer.balloon_alert_to_viewers("steals the ball")
			stealer.put_in_hands(src)
		if(FACE_TO_SIDE)
			if(prob(50))
				if(!baller.dropItemToGround(src))
					return
				stealer.balloon_alert_to_viewers("bats the ball")
			else
				stealer.balloon_alert_to_viewers("steals the ball")
				stealer.put_in_hands(src)
		if(FACE_TO_BACK)
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
	if(!iscarbon(target))
		return ..()

	user.balloon_alert_to_viewers("passes the ball")
	playsound(src, 'sound/items/basketball_bounce.ogg', 75, FALSE)
	target.put_in_hands(src)

/obj/item/toy/basketball/attack_self(mob/living/user)
	// no spamming
	if(last_use + use_delay > world.time)
		return

	// need a free hand and can't be spinning
	if(!user.put_in_inactive_hand(src) && user.flags_1 & IS_SPINNING_1)
		return

	last_use = world.time
	user.swap_hand(user.get_held_index_of_item(src))
	user.balloon_alert_to_viewers("dribbles the ball")
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
	pass_flags = initial(pass_flags)

/obj/item/toy/basketball/afterattack_secondary(atom/aim_target, mob/living/baller, params)
	//attack_hand(user, modifiers, flip_card = TRUE)
	//if(user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE, need_hands = !iscyborg(user)))
	baller.balloon_alert_to_viewers("shooting...")
	baller.adjustStaminaLoss(10)

	var/dunk_dir = get_dir(baller, aim_target)
	var/dunk_pixel_y = dunk_dir & SOUTH ? -16 : 16
	var/dunk_pixel_x = dunk_dir & EAST && 16 || dunk_dir & WEST && -16 || 0

	animate(baller, pixel_x = dunk_pixel_x, pixel_y = dunk_pixel_y, time = 5, easing = BOUNCE_EASING|EASE_IN|EASE_OUT)
	if(do_after(baller, 0.5 SECONDS))
		pass_flags |= PASSMOB
		baller.throw_item(aim_target)
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


/obj/item/toy/basketball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!isliving(hit_atom)) // only reset our pass flags
		pass_flags = initial(pass_flags)

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
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	/// Keeps track of the total points scored
	var/total_score = 0
	/// The chance to score a ball into the hoop based on distance
	/// ex. a distance of two tiles away, throw_range_success[2], results in 50% chance to score
	/// if someone shoots 3 tiles away or more, it scores 3 points
	var/static/list/throw_range_success = list(65, 50, 35, 20, 15, 10)

/obj/structure/hoop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED, AfterRotation = CALLBACK(src, PROC_REF(reset_appearance)))
	update_appearance()

/obj/structure/hoop/proc/reset_appearance()
	update_appearance()

/obj/structure/hoop/proc/score(points)
	playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
	total_score += points
	update_appearance()

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

			if(istype(ball, /obj/item/toy/basketball))
				score(2)
				baller.adjustStaminaLoss(10) // dunking is more strenous than shooting

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
		baller.adjustStaminaLoss(30)
		baller.stop_pulling()
	else
		..()

/obj/structure/hoop/CtrlClick(mob/living/user)
	if(user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE, need_hands = !iscyborg(user)))
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

			if(distance > 2) // 3 pointer shot
				score(3)
			else
				score(2)

			if(click_on_hoop)
				visible_message(span_warning("Swish! [AM] lands in [src]."))
			else
				visible_message(span_warning("[AM] bounces off the backboard and lands in [src]."))
			return
		else
			if(click_on_hoop)
				visible_message(span_danger("[AM] bounces off of [src]'s rim!"))
			else
				visible_message(span_danger("[AM] bounces off of [src]'s backboard!"))
			return ..()
	else
		return ..()

#undef FACE_TO_BACK
#undef FACE_TO_SIDE
#undef FACE_TO_FACE
