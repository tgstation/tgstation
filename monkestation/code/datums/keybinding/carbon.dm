/datum/keybinding/living/sprint
	hotkey_keys = list("Shift")
	name = "Sprint"
	full_name = "Sprint"
	description = "Move fast at the cost of stamina"
	keybind_signal = COMSIG_KB_CARBON_SPRINT_DOWN

/datum/keybinding/living/sprint/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/C = user.mob
	C.sprint_key_down = TRUE

/datum/keybinding/living/sprint/up(client/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(user.mob, COMSIG_KB_CARBON_SPRINT_UP)
