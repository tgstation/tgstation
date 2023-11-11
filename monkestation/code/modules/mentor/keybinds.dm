/datum/keybinding/mentor
	category = CATEGORY_ADMIN
	weight = WEIGHT_ADMIN

/datum/keybinding/mentor/can_use(client/user)
	return user.mentor_datum ? TRUE : FALSE

/datum/keybinding/mentor/mentor_say
	hotkey_keys = list("F4")
	name = MENTOR_CHANNEL
	full_name = "Mentor say"
	description = "Talk with fellow mentors and admins."
	keybind_signal = COMSIG_KB_ADMIN_MSAY_DOWN
