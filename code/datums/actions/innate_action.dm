//Preset for general and toggled actions
/datum/action/innate
	check_flags = NONE
	/// Whether we're active or not, if we're a innate - toggle action.
	var/active = FALSE
	/// Whether we're a click action or not, if we're a innate - click action.
	var/click_action = FALSE
	/// If we're a click action, the mouse pointer we use
	var/ranged_mousepointer
	/// If we're a click action, the text shown on enable
	var/enable_text
	/// If we're a click action, the text shown on disable
	var/disable_text

/datum/action/innate/Trigger(trigger_flags)
	if(!..())
		return FALSE
	// We're a click action, trigger just sets it as active or not
	if(click_action)
		if(owner.click_intercept == src)
			unset_ranged_ability(owner, disable_text)
		else
			set_ranged_ability(owner, enable_text)
		return TRUE

	// We're not a click action (we're a toggle or otherwise)
	else
		if(active)
			Deactivate()
		else
			Activate()

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
/datum/action/innate/proc/set_ranged_ability(mob/living/on_who, text_to_show)
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = src

/// Removes this action as the active ability of the passed mob
/datum/action/innate/proc/unset_ranged_ability(mob/living/on_who, text_to_show)
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(owner.client?.mouse_pointer_icon)
		on_who.update_mouse_pointer()
	if(text_to_show)
		to_chat(on_who, text_to_show)
	on_who.click_intercept = null

/// Handles whenever a mob clicks on something
/datum/action/innate/proc/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	if(!IsAvailable())
		unset_ranged_ability(caller)
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
