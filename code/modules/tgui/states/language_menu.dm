 /**
  * tgui state: language_menu_state
  */

/var/global/datum/ui_state/language_menu/language_menu_state = new()

/datum/ui_state/language_menu/can_use_topic(src_object, mob/user)
	. = UI_CLOSE
	if(check_rights_for(user.client, R_ADMIN))
		. = UI_INTERACTIVE
	else if(istype(src_object, /datum/language_menu))
		var/datum/language_menu/LM = src_object
		if(LM.owner == user)
			. = UI_INTERACTIVE
