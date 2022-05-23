//Preset for general and toggled actions
/datum/action/innate
	check_flags = NONE
	var/active = 0

/datum/action/innate/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return

/**
 * This is gross, but a somewhat-required bit of copy+paste until action code becomes slightly more sane.
 * Anything that uses these functions should eventually be moved to use cooldown actions.
 * (Either that, or the click ability of cooldown actions should be moved down a type.)
 *
 * If you're adding something that uses these, rethink your choice in subtypes.
 */

/// Sets this action as the active ability for the passed mob
/datum/action/innate/proc/set_ranged_abiliity(mob/living/on_who, text_to_show)
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = src
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer

/// Removes this action as the active ability of the passed mob
/datum/action/innate/proc/unset_ranged_ability(mob/living/on_who, text_to_show)
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(owner.client?.mouse_pointer_icon)

/// Handles whenever a mob clicks on something
/datum/action/innate/proc/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	if(!IsAvailable())
		return FALSE
	if(!clicked_on)
		return FALSE

	return do_ability(caller, clicked_on)

/// Actually goes through and does the click ability
/datum/action/innate/proc/do_ability(mob/living/caller, params, atom/clicked_on)
	return FALSE

/datum/action/innate/Remove(mob/removed_from)
	if(removed_from.click_intercept == src)
		unset_ranged_ability(removed_from)
	return ..()
