GLOBAL_DATUM_INIT(debug_state, /datum/ui_state/debug_state, new)

/datum/ui_state/debug_state/can_use_topic(src_object, mob/user)
	if(check_rights_for(user.client, R_DEBUG))
		return UI_INTERACTIVE
	return UI_CLOSE
