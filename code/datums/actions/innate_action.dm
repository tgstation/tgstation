//Preset for general and toggled actions
/datum/action/innate
	check_flags = NONE
	var/active = 0

/datum/action/innate/Trigger(trigger_flags)
	if(!..())
		return FALSE
	if(!active)
		Activate()
	else
		Deactivate()
	return TRUE

/datum/action/innate/proc/Activate()
	return

/datum/action/innate/proc/Deactivate()
	return
