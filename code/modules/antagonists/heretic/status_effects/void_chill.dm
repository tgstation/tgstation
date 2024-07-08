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
	/// Current amount of stacks we have
	var/stacks
	/// Maximum of stacks that we could possibly get
	var/stack_limit = MAX_FREEZE_STACKS

/datum/status_effect/void_chill/on_creation(mob/living/new_owner, new_stacks, ...)
	. = ..()
	set_stacks(new_stacks)

/datum/status_effect/void_chill/on_apply()
	owner.add_atom_colour(COLOR_BLUE_LIGHT, TEMPORARY_COLOUR_PRIORITY)
	return TRUE

/datum/status_effect/void_chill/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BLUE_LIGHT)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/void_chill)

/datum/status_effect/void_chill/tick(seconds_between_ticks)
	owner.adjust_bodytemperature(-12 * stacks)

/datum/status_effect/void_chill/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)

/**
 * Setter and adjuster procs for firestacks
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

//	owner.fire_stacks = 0
//	var/was_on_fire = owner.on_fire
//	owner.on_fire = FALSE
//	for(var/datum/status_effect/void_chill/possible_fire in owner.status_effects)
//		owner.fire_stacks += possible_fire.stacks * possible_fire.stack_modifier
//
//		if(!istype(possible_fire, /datum/status_effect/void_chill/fire_stacks))
//			continue
//
//		var/datum/status_effect/void_chill/fire_stacks/our_fire = possible_fire
//		if(our_fire.on_fire)
//			owner.on_fire = TRUE
//
//	if(was_on_fire && !owner.on_fire)
//		owner.clear_alert(ALERT_FIRE)
//	else if(!was_on_fire && owner.on_fire)
//		owner.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire)
//	owner.update_appearance(UPDATE_OVERLAYS)
//	update_particles()

/datum/status_effect/void_chill/lasting
	id = "lasting_void_chill"
	duration = -1

/datum/movespeed_modifier/void_chill
	variable = TRUE
	multiplicative_slowdown = 0.1

/atom/movable/screen/alert/status_effect/void_chill
	name = "Void Chill"
	desc = "There's something freezing you from within and without. You've never felt cold this oppressive before..."
	icon_state = "void_chill"

