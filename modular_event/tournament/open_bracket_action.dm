GLOBAL_VAR(bracket_url)

/datum/config_entry/string/bracket_url

/datum/config_entry/string/bracket_url/ValidateAndSet(str_val)
	. = ..()
	if (!.)
		return .

	GLOB.bracket_url = str_val

	for (var/mob/living/living_player in GLOB.player_list)
		living_player.setup_bracket_action()

/datum/action/open_bracket
	name = "Open Bracket"
	button_icon_state = "round_end"

/datum/action/open_bracket/Trigger()
	if (!GLOB.bracket_url)
		return

	if (tgui_alert(usr, "This will open up the bracket in your browser. Do you want to open it?",,list("Yes", "No")) != "Yes")
		return

	usr << link(GLOB.bracket_url)

/datum/action/open_bracket/IsAvailable()
	return TRUE

/mob
	var/datum/action/open_bracket/open_bracket_action

/mob/Destroy()
	if (!isnull(open_bracket_action))
		open_bracket_action.Remove(src)
		QDEL_NULL(open_bracket_action)

	return ..()

/mob/Login()
	. = ..()

	setup_bracket_action()

/mob/Logout()
	. = ..()

	if(!isnull(open_bracket_action))
		open_bracket_action.Remove(src)

/mob/proc/setup_bracket_action()
	if (!GLOB.bracket_url && !isnull(open_bracket_action))
		open_bracket_action.Remove(src)
		QDEL_NULL(open_bracket_action)
	else if (GLOB.bracket_url)
		if (isnull(open_bracket_action))
			open_bracket_action = new
		open_bracket_action.Grant(src)
