/*!
 * Contains the "Void Chill" status effect. Harmful debuff which freezes and slows down non-heretics
 */
/datum/status_effect/void_chill
	id = "void_chill"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/void_chill
	status_type = STATUS_EFFECT_REFRESH //Custom code
	on_remove_on_mob_delete = TRUE
	remove_on_fullheal = TRUE
	///Current amount of stacks we have
	var/stacks
	///Maximum of stacks that we could possibly get
	var/stack_limit = MAX_FREEZE_STACKS
	///icon for the overlay
	var/image/stacks_overlay

/datum/status_effect/void_chill/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	set_stacks(new_stacks)
	owner.update_icon(UPDATE_OVERLAYS)

/datum/status_effect/void_chill/on_apply()
	owner.add_atom_colour(COLOR_BLUE_LIGHT, TEMPORARY_COLOUR_PRIORITY)
	return TRUE

/datum/status_effect/void_chill/Destroy()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	return ..()

/datum/status_effect/void_chill/on_remove()
	owner.update_icon(UPDATE_OVERLAYS)
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BLUE_LIGHT)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/void_chill)
	owner.remove_alt_appearance("heretic_status")

/datum/status_effect/void_chill/tick(seconds_between_ticks)
	owner.adjust_bodytemperature(-12 * stacks)

/datum/status_effect/void_chill/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)
	owner.update_icon(UPDATE_OVERLAYS)

///Updates the overlay that gets applied on our victim
/datum/status_effect/void_chill/proc/update_stacks_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(stacks >= 5)
		linked_alert.icon_state = "void_chill_major"
		linked_alert.update_appearance(UPDATE_ICON_STATE)

	owner.remove_alt_appearance("heretic_status")
	stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_partial")
	if(stacks >= 5)
		stacks_overlay = image('icons/effects/effects.dmi', owner, "void_chill_oh_fuck")
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/heretic, "heretic_status", stacks_overlay, NONE)

/**
 * Setter and adjuster procs for stacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/status_effect/void_chill/proc/set_stacks(new_stacks)
	stacks = max(0, min(stack_limit, new_stacks))
	update_movespeed(stacks)

/datum/status_effect/void_chill/proc/adjust_stacks(new_stacks)
	stacks = max(0, min(stack_limit, stacks + new_stacks))
	update_movespeed(stacks)

///Updates the movespeed of owner based on the amount of stacks of the debuff
/datum/status_effect/void_chill/proc/update_movespeed(stacks)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE)
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/void_chill, update = TRUE, multiplicative_slowdown = (0.5 * stacks))
	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:center'>[stacks]</span>")

/datum/status_effect/void_chill/lasting
	id = "lasting_void_chill"
	duration = -1

/datum/movespeed_modifier/void_chill
	variable = TRUE
	multiplicative_slowdown = 0.1

//---- Screen alert
/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "There's something freezing you from within and without. You've never felt cold this oppressive before..."
	icon_state = "void_chill_minor"
