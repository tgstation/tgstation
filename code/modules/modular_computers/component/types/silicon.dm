/datum/modular_computer_host/silicon
	hardware_flag = PROGRAM_SILICON

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
