/datum/action/bb/comms
	name = "Blood Bond"
	desc = "Communicate privately with your fellow blood brother(s)."
	button_icon_state = "comms"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/bb/comms/IsAvailable(feedback)
	. = ..()
	if(!.)
		return
	if(length(team.members) < 2)
		if(feedback)
			owner.balloon_alert(owner, "no blood brothers to communicate with!")
		return FALSE

/datum/action/bb/comms/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/message = tgui_input_text(owner, "What do you wish to communicate with your fellow blood brother[length(team.members) > 2 ? "s" : ""]?", "Blood Bond", timeout = 90 SECONDS)
	if(!message || !IsAvailable(feedback = TRUE))
		return FALSE
	bond.communicate(message)
