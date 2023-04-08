/datum/keybinding/admin/mentor_say
	hotkey_keys = list("F4")
	name = MENTOR_CHANNEL
	full_name = "Mentor say"
	description = "Speak with other mentors."
	keybind_signal = COMSIG_KB_ADMIN_MSAY_DOWN

//Snowflakey fix for mentors not being able to use the hotkey, without moving the hotkey to a new category
/datum/keybinding/admin/mentor_say/can_use(client/user)
	return user.is_mentor() ? TRUE : FALSE
