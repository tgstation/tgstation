/**
 * tgui state: view
 *
 * Checks if the object is in view or the mob is holding it, otherwise close the UI
 */

GLOBAL_DATUM_INIT(hold_or_view_state, /datum/ui_state/hold_or_view_state, new)

/datum/ui_state/hold_or_view_state/can_use_topic(src_object, mob/user)
	if((user in viewers(user.client?.view, src_object)) || user.is_holding(src_object))
		return UI_INTERACTIVE
	return UI_CLOSE
