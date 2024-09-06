/datum/keybinding/mob/pixel_shift
	hotkey_keys = list("B")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Shift your characters offset."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_MOB_PIXEL_SHIFT_DOWN

/datum/keybinding/mob/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	user.mob.add_pixel_shift_component()

/datum/keybinding/mob/pixel_shift/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, COMSIG_KB_MOB_PIXEL_SHIFT_UP)
