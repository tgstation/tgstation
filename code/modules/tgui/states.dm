/*!
 * Base state and helpers for states. Just does some sanity checks,
 * implement a proper state for in-depth checks.
 *
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * public
 *
 * Checks the UI state for a mob.
 *
 * required user mob The mob who opened/is using the UI.
 * required state datum/ui_state The state to check.
 *
 * return UI_state The state of the UI.
 */
/datum/proc/ui_status(mob/user, datum/ui_state/state)
	var/src_object = ui_host(user)
	. = UI_CLOSE
	if(!state)
		return

	if(isobserver(user))
		// If they turn on ghost AI control, admins can always interact.
		if(isAdminGhostAI(user))
			. = max(., UI_INTERACTIVE)

		// Regular ghosts can always at least view if in range.
		if(user.client)
			var/clientviewlist = getviewsize(user.client.view)
			if(get_dist(src_object, user) < max(clientviewlist[1], clientviewlist[2]))
				. = max(., UI_UPDATE)

	// Check if the state allows interaction
	var/result = state.can_use_topic(src_object, user)
	. = max(., result)

/**
 * private
 *
 * Checks if a user can use src_object's UI, and returns the state.
 * Can call a mob proc, which allows overrides for each mob.
 *
 * required src_object datum The object/datum which owns the UI.
 * required user mob The mob who opened/is using the UI.
 *
 * return UI_state The state of the UI.
 */
/datum/ui_state/proc/can_use_topic(src_object, mob/user)
	// Don't allow interaction by default.
	return UI_CLOSE

/**
 * public
 *
 * Standard interaction/sanity checks. Different mob types may have overrides.
 *
 * return UI_state The state of the UI.
 */
/mob/proc/shared_ui_interaction(src_object)
	// Close UIs if mindless.
	if(!client && !HAS_TRAIT(src, TRAIT_PRESERVE_UI_WITHOUT_CLIENT))
		return UI_CLOSE
	// Disable UIs if unconscious.
	else if(IS_UNCONSCIOUS_OR_CRIT(src))
		return UI_DISABLED
	// Update UIs if incapicitated but conscious.
	else if(incapacitated)
		return UI_UPDATE
	return UI_INTERACTIVE

/mob/living/shared_ui_interaction(atom/src_object)
	. = ..()
	if(!(mobility_flags & MOBILITY_UI) && !(src_object.interaction_flags_atom & INTERACT_ATOM_IGNORE_MOBILITY) && . == UI_INTERACTIVE)
		return UI_UPDATE

/mob/living/silicon/ai/shared_ui_interaction(src_object)
	// Disable UIs if the AI is unpowered.
	if(apc_override == src_object) //allows AI to (eventually) use the interface for their own APC even when out of power
		return UI_INTERACTIVE
	if(lacks_power())
		return UI_DISABLED
	return ..()

/mob/living/silicon/robot/shared_ui_interaction(src_object)
	// Disable UIs if the object isn't installed in the borg AND the borg is either locked, has a dead cell, or no cell.
	var/atom/device = src_object
	if((istype(device) && device.loc != src) && (!cell || cell.charge <= 0 || lockcharge))
		return UI_DISABLED
	return ..()


/// quick viewcheck for UI interactions
/mob/living/proc/view_can_ui_interact(atom/target, range = 5)
	return target in view(range, src)

/// Whether we can see the target the way the client's screen draws it.
/mob/living/proc/sight_can_ui_interact(atom/target)
	var/see_flag = NONE // this proc is only meant to work on two actual physical objects in the game world but I'm having this in as a failover in case funky stuff happens that sight isn't accounting for.

	if(isobj(target))
		see_flag = SEE_OBJS
	else if(ismob(target))
		see_flag = SEE_MOBS
	else if(isturf(target))
		see_flag = SEE_TURFS

	if(sight & see_flag)
		return TRUE
	if(sight & BLIND)
		return FALSE

	return is_in_sight(src, target)

/**
 * public
 *
 * Distance versus interaction check.
 *
 * required src_object atom/movable The object which owns the UI.
 *
 * return UI_state The state of the UI.
 */
/mob/living/proc/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE, allow_tk = TRUE)
	var/obj/item/item_in_hand = get_active_held_item()
	if(istype(item_in_hand, /obj/item/machine_remote)) //snowflake, this lets you interact with all.
		var/obj/item/machine_remote/remote = item_in_hand
		if(remote.controlling_machine_or_bot == src_object)
			return UI_INTERACTIVE

	var/dist = get_dist(src_object, src)
	// If the object is obscured or too far away, close it.
	if (dist > 5 || (viewcheck && !view_can_ui_interact(src_object)))
		return UI_CLOSE
	// Disable if further than 2 tiles
	if (dist > 2)
		return UI_DISABLED
	// Update but block interactions if further than a tile away
	if (dist > 1)
		return UI_UPDATE
	// Open and interact if 1-0 tiles away.
	return UI_INTERACTIVE

/mob/living/carbon/human/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE, allow_tk = TRUE)
	if(allow_tk && dna.check_mutation(/datum/mutation/telekinesis) && tkMaxRangeCheck(src, src_object))
		if(viewcheck && sight_can_ui_interact(src_object))
			return UI_INTERACTIVE

	return ..()
