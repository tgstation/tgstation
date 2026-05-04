
#define VISION_ACTION_LIGHT_OFF 0
#define VISION_ACTION_LIGHT_LOW 1
#define VISION_ACTION_LIGHT_MID 2
#define VISION_ACTION_LIGHT_HIG 3

/datum/action/adjust_vision
	name = "Adjust Vision"
	desc = "See better in the dark. Or don't. Your advanced vision allows either."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "adjust_vision"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_default_border"


	// These lists are used as the color cutoff for the action
	// They need to be filled out for subtypes
	var/list/low_light_cutoff
	var/list/medium_light_cutoff
	var/list/high_light_cutoff
	var/light_level = VISION_ACTION_LIGHT_OFF

/datum/action/adjust_vision/Grant(mob/living/grant_to)
	. = ..()
	set_light_level(VISION_ACTION_LIGHT_LOW)
	RegisterSignal(grant_to, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(on_update_sight))

/datum/action/adjust_vision/Remove(mob/living/remove_from)
	set_light_level(VISION_ACTION_LIGHT_OFF)
	UnregisterSignal(remove_from, COMSIG_MOB_UPDATE_SIGHT)
	. = ..()

/datum/action/adjust_vision/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	switch(light_level)
		if (VISION_ACTION_LIGHT_OFF)
			set_light_level(VISION_ACTION_LIGHT_LOW)
		if (VISION_ACTION_LIGHT_LOW)
			set_light_level(VISION_ACTION_LIGHT_MID)
		if (VISION_ACTION_LIGHT_MID)
			set_light_level(VISION_ACTION_LIGHT_HIG)
		else
			set_light_level(VISION_ACTION_LIGHT_OFF)

/datum/action/adjust_vision/proc/set_light_level(new_level)
	light_level = new_level
	owner.update_sight()

/datum/action/adjust_vision/proc/on_update_sight(datum/source)
	SIGNAL_HANDLER
	var/list/color_from
	switch(light_level)
		if (VISION_ACTION_LIGHT_LOW)
			color_from = low_light_cutoff
		if (VISION_ACTION_LIGHT_MID)
			color_from = medium_light_cutoff
		if (VISION_ACTION_LIGHT_HIG)
			color_from = high_light_cutoff
		else // just in case
			color_from = list(0, 0, 0)
	owner.lighting_color_cutoffs = blend_cutoff_colors(owner.lighting_color_cutoffs, color_from.Copy())

/datum/action/adjust_vision/bileworm
	low_light_cutoff = list(18, 12, 0)
	medium_light_cutoff = list(30, 20, 5)
	high_light_cutoff = list(45, 30, 10)

#undef VISION_ACTION_LIGHT_OFF
#undef VISION_ACTION_LIGHT_LOW
#undef VISION_ACTION_LIGHT_MID
#undef VISION_ACTION_LIGHT_HIG
