/**
 * Vibebot's vibe ability
 *
 * Given to vibebots so sentient ones can change/reset thier colors at will.
 */
/datum/action/innate/vibe
	name = "Vibe"
	desc = "LMB: Change vibe color. RMB: Reset vibe color."
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "funk"

/datum/action/innate/vibe/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_BOT_TURNED_ON, PROC_REF(activate_lights))
	RegisterSignal(grant_to, COMSIG_CHANGE_VIBEBOT_COLOR, PROC_REF(vibe))
	RegisterSignal(grant_to, COMSIG_BOT_TURNED_OFF, PROC_REF(turn_off_lights))

/datum/action/innate/vibe/Remove(mob/removed_from)
	UnregisterSignal(removed_from, list(COMSIG_BOT_TURNED_ON, COMSIG_BOT_TURNED_OFF))
	return ..()

/datum/action/innate/vibe/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(isbasicbot(owner))
		var/mob/living/basic/bot/bot_mob = owner
		if(!(bot_mob.bot_mode_flags & BOT_MODE_ON))
			return FALSE
	return TRUE

/datum/action/innate/vibe/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		remove_colors()
	else
		vibe()

///Gives a random color. Can feed in an optional color to use instead.
/datum/action/innate/vibe/proc/vibe(light_color = null)
	if(isnull(light_color))
		light_color = random_color()

	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.add_atom_colour("#[light_color]", TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(owner.color)

///Removes all colors
/datum/action/innate/vibe/proc/remove_colors()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	owner.set_light_color(null)

/datum/action/innate/vibe/proc/activate_lights()
	SIGNAL_HANDLER
	vibe(light_color = COLOR_WHITE) // nicety so they don't immediately spawn in with something garish

/datum/action/innate/vibe/proc/turn_off_lights()
	SIGNAL_HANDLER
	remove_colors()
