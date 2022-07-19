/datum/action/language_menu
	name = "Language Menu"
	desc = "Open the language menu to review your languages, their keys, and select your default language."
	button_icon_state = "language_menu"
	check_flags = NONE

/datum/action/language_menu/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/datum/language_holder/owner_holder = owner.get_language_holder()
	owner_holder.open_language_menu(usr)
