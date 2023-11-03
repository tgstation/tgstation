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
	else if(stat)
		return UI_DISABLED
	// Update UIs if incapicitated but concious.
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
	// If the object is obscured, close it.
	if(viewcheck && !(src_object in view(src)))
		return UI_CLOSE
	var/dist = get_dist(src_object, src)
	// Open and interact if 1-0 tiles away.
	if(dist <= 1)
		return UI_INTERACTIVE
	// View only if 2-3 tiles away.
	else if(dist <= 2)
		return UI_UPDATE
	// Disable if 5 tiles away.
	else if(dist <= 5)
		return UI_DISABLED
	// Otherwise, we got nothing.
	return UI_CLOSE

/mob/living/carbon/human/shared_living_ui_distance(atom/movable/src_object, viewcheck = TRUE, allow_tk = TRUE)
	if(allow_tk && dna.check_mutation(/datum/mutation/human/telekinesis) && tkMaxRangeCheck(src, src_object))
		return UI_INTERACTIVE
	return ..()
