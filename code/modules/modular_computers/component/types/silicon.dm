/datum/modular_computer_host/silicon
	hardware_flag = PROGRAM_SILICON

//Integrated (Silicon) tablets don't drain power, because the tablet is required to state laws, so it being disabled WILL cause problems.
/datum/modular_computer_host/silicon/check_power_override()
	return TRUE

// our silicon friends get their message privately TODO: message clutter, return instead?
/datum/modular_computer_host/silicon/say(message)
	var/mob/silicon = physical
	to_chat(silicon, span_notice(message))

/datum/modular_computer_host/silicon/visible_message(message, range)
	to_chat(physical)

/datum/modular_computer_host/silicon/cyborg
	valid_on = /mob/living/silicon/robot

/datum/modular_computer_host/silicon/ai
	valid_on = /mob/living/silicon/ai
