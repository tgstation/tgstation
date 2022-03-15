/datum/action/language_menu
	name = "Language Menu"
	desc = "Open the language menu to review your languages, their keys, and select your default language."
	button_icon_state = "language_menu"
	check_flags = NONE

/datum/action/language_menu/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(ismob(owner))
		var/mob/M = owner
		var/datum/language_holder/H = M.get_language_holder()
		H.open_language_menu(usr)
