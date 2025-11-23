/datum/action/innate/change_name
	name = "Change Name"
	button_icon_state = "ghost"

/datum/action/innate/change_name/Activate()
	var/new_name = tgui_input_text(usr, "Enter a new name.", "Renaming", initial(owner.name))
	if(!new_name)
		return FALSE

	owner.fully_replace_character_name(owner.name, new_name)
	return TRUE
