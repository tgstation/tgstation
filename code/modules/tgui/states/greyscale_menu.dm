/**
 * tgui state: greyscale menu
 *
 * Checks that the target var of the greyscale menu meets the default can_use_topic criteria
 */

GLOBAL_DATUM_INIT(greyscale_menu_state, /datum/ui_state/greyscale_menu_state, new)

/datum/ui_state/greyscale_menu_state/can_use_topic(src_object, mob/user)
	var/datum/greyscale_modify_menu/menu = src_object
	if(!isatom(menu.target))
		return TRUE

	return GLOB.default_state.can_use_topic(menu.target, user)
