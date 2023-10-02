/// Armsy starts to look a bit funky if he's shorter than this
#define MINIMUM_ARMSY_LENGTH 3

// What if we took a linked list... But made it a mob?
/// The "Terror of the Night" / Armsy, a large worm made of multiple bodyparts that occupies multiple tiles
/mob/living/basic/heretic_summon/armsy
	name = "Lord of the Night"
	real_name = "Master of Decay"
	desc = "An abomination made from dozens and dozens of severed and malformed limbs piled onto each other."
	icon_state = "armsy_start"
	icon_living = "armsy_start"
	base_icon_state = "armsy"
	maxHealth = 400
	health = 400
	melee_damage_lower = 30
	melee_damage_upper = 50
	obj_damage = 200
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	sentience_type = SENTIENCE_BOSS
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	///Previous segment in the chain
	var/mob/living/basic/heretic_summon/armsy/back
	///Next segment in the chain
	var/mob/living/basic/heretic_summon/armsy/front
	///Your old location
	var/atom/old_loc
	///How many arms do we have to eat to expand?
	var/stacks_to_grow = 5
	///Currently eaten arms
	var/current_stacks = 0

/*
 * Arguments
 * * spawn_bodyparts - whether we spawn additional armsy bodies until we reach length.
 * * worm_length - the length of the worm we're creating. Below 3 doesn't work very well.
 */
/mob/living/basic/heretic_summon/armsy/Initialize(mapload, spawn_bodyparts = TRUE, worm_length = 6)
	. = ..()
	AddElement(/datum/element/wall_smasher, ENVIRONMENT_SMASH_RWALLS)
	AddComponent(\
		/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood/tracks, \
		target_dir_change = TRUE,\
	)

	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(update_chain_links))

	old_loc = loc
	if(worm_length < MINIMUM_ARMSY_LENGTH)
		stack_trace("[type] created with invalid len ([worm_length]). Reverting to 3.")
		worm_length = MINIMUM_ARMSY_LENGTH
	if(spawn_bodyparts)
		build_tail(worm_length)

	var/datum/action/cooldown/mob_cooldown/worm_contract/shrink = new (src)
	shrink.Grant(src)

/mob/living/basic/heretic_summon/armsy/proc/build_tail(worm_length)
	// Sets the hp of the head to be exactly the (length * hp), so the head is de facto the hardest to destroy.
	maxHealth = worm_length * maxHealth
	health = maxHealth

	var/mob/living/basic/heretic_summon/armsy/prev = src
	var/mob/living/basic/heretic_summon/armsy/current

	for(var/i in 1 to worm_length)
		current = new type(drop_location(), FALSE)
		ADD_TRAIT(current, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
		current.front = prev
		current.update_appearance(UPDATE_ICON_STATE)
		prev.back = current
		prev = current

	prev.icon_state = "armsy_end"
	prev.icon_living = "armsy_end"
	prev.update_appearance(UPDATE_ICON_STATE)
	update_appearance(UPDATE_ICON_STATE)

/mob/living/basic/heretic_summon/armsy/update_icon_state()
	. = ..()
	if(isnull(front))
		icon_living = "[base_icon_state]_start"
	else if(isnull(back))
		icon_living = "[base_icon_state]_end"
	else
		icon_living = "[base_icon_state]_mid"
	icon_state = icon_living

/mob/living/basic/heretic_summon/armsy/adjustBruteLoss(amount, updating_health, forced, required_bodytype)
	if(isnull(back))
		return ..()
	return back.adjustBruteLoss()

/mob/living/basic/heretic_summon/armsy/adjustFireLoss(amount, updating_health, forced, required_bodytype)

	if(isnull(back))
		return ..()
	return back.adjustFireLoss()

// We are literally a vessel of otherworldly destruction, we bring our own gravity unto this plane
/mob/living/basic/heretic_summon/armsy/has_gravity(turf/gravity_turf)
	return TRUE

/mob/living/basic/heretic_summon/armsy/can_be_pulled()
	return FALSE

/// Updates every body in the chain to force move onto a single tile.
/mob/living/basic/heretic_summon/armsy/proc/contract_next_chain_into_single_tile()
	if(isnull(back))
		return
	back.forceMove(loc)
	back.contract_next_chain_into_single_tile()

/*
 * Recursively get the length of our chain.
 */
/mob/living/basic/heretic_summon/armsy/proc/get_length()
	. = 1
	if(isnull(back))
		return
	. += back.get_length()

/// Updates the next mob in the chain to move to our last location. Fixes the chain if somehow broken.
/mob/living/basic/heretic_summon/armsy/proc/update_chain_links()
	SIGNAL_HANDLER
	if(!isnull(back) && back.loc != old_loc)
		back.Move(old_loc)
	// self fixing properties if somehow broken
	if(!isnull(front) && loc != front.old_loc)
		forceMove(front.old_loc)
	old_loc = loc

/mob/living/basic/heretic_summon/armsy/Destroy()
	if(!isnull(front))
		front.update_appearance(UPDATE_ICON_STATE)
		front.back = null
		front = null
	QDEL_NULL(back)
	return ..()

/mob/living/basic/heretic_summon/armsy/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	if(istype(target, /obj/item/bodypart/arm))
		playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
		qdel(target)
		on_arm_eaten()
		return
	if(target == back || target == front)
		return
	back?.melee_attack(target, modifiers, ignore_cooldown)
	if(!Adjacent(target))
		return

	. = ..()

	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	if(HAS_TRAIT(carbon_target, TRAIT_NODISMEMBER))
		return

	var/list/parts_to_remove = list()
	for(var/obj/item/bodypart/bodypart in carbon_target.bodyparts)
		if(bodypart.body_part == HEAD || bodypart.body_part == CHEST || bodypart.body_part == LEG_LEFT || bodypart.body_part == LEG_RIGHT)
			continue
		if(bodypart.bodypart_flags & BODYPART_UNREMOVABLE)
			continue
		parts_to_remove += bodypart

	if(!length(parts_to_remove) || prob(90))
		return
	if(parts_to_remove.len && prob(10))
		var/obj/item/bodypart/lost_arm = pick(parts_to_remove)
		lost_arm.dismember()


/*
 * Handle healing our chain.
 *
 * Eating arms off the ground heals us,
 * and if we eat enough arms while above
 * a certain health threshold,  we even gain back parts!
 */
/mob/living/basic/heretic_summon/armsy/proc/on_arm_eaten()
	if(!isnull(back))
		back.on_arm_eaten()
		return

	adjustBruteLoss(-maxHealth * 0.5, FALSE)
	adjustFireLoss(-maxHealth * 0.5, FALSE)

	if(health < maxHealth * 0.8)
		return

	current_stacks++
	if(current_stacks < stacks_to_grow)
		return

	current_stacks = 0
	var/mob/living/basic/heretic_summon/armsy/prev = new type(drop_location(), FALSE)
	back = prev
	update_appearance(UPDATE_ICON_STATE)
	prev.front = src
	prev.update_appearance(UPDATE_ICON_STATE)


/**
 * Shrink the worm into one tile.
 * I don't particularly love an action which calls a proc on a specific mob typepath, but what can you do?
 */
/datum/action/cooldown/mob_cooldown/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "worm_contract"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/mob_cooldown/worm_contract/IsAvailable(feedback)
	return ..() && istype(owner, /mob/living/basic/heretic_summon/armsy)

/datum/action/cooldown/mob_cooldown/worm_contract/Activate(atom/target)
	var/mob/living/basic/heretic_summon/armsy/worm_guy = owner
	worm_guy.contract_next_chain_into_single_tile()

#undef MINIMUM_ARMSY_LENGTH
