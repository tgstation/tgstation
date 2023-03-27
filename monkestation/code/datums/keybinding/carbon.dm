/datum/keybinding/carbon/sprint
	hotkey_keys = list("Shift")
	name = "Sprint"
	full_name = "Sprint"
	description = "Move fast at the cost of stamina"
	keybind_signal = COMSIG_KB_CARBON_SPRINT_DOWN

/datum/keybinding/carbon/sprint/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/C = user.mob
	C.sprint_key_down = TRUE

/datum/keybinding/carbon/sprint/up(client/user)
	. = ..()
	if(.)
		return
	SEND_SIGNAL(user.mob, COMSIG_KB_CARBON_SPRINT_UP)
