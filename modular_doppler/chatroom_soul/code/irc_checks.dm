/mob/living/proc/irc_checks(message)
	if(!length(message))
		return FALSE

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return FALSE

	//quickly calc our name stub again: duplicate this in say.dm override
	var/name_stub = " (<b>[usr]</b>)"
	if(length(message) > (MAX_MESSAGE_LEN - length(name_stub)))
		to_chat(usr, message)
		to_chat(usr, span_warning("^^^----- The preceding message has been DISCARDED for being over the maximum length of [MAX_MESSAGE_LEN]. It has NOT been sent! -----^^^"))
		return FALSE

	if(usr.stat != CONSCIOUS || usr.incapacitated)
		to_chat(usr, span_notice("You cannot use your PDA in your current condition."))
		return FALSE

	// check to make sure we've actually got a modular computer on us and that it is like, usable
	var/obj/item/modular_computer/our_computer
	var/obj/item/modular_computer/holding_computer = usr.is_holding_item_of_type(/obj/item/modular_computer)
	if (holding_computer)
		our_computer = holding_computer
	else
		if (ishuman(usr))
			var/mob/living/carbon/human/human_user = usr
			if (istype(human_user.belt, /obj/item/modular_computer))
				our_computer = human_user.belt
			else if (istype(human_user.wear_id, /obj/item/modular_computer))
				our_computer = human_user.wear_id
		else if (issilicon(usr))
			//really easy
			var/mob/living/silicon/robor_user = usr
			our_computer = robor_user.modularInterface

	if (!our_computer)
		to_chat(usr, span_notice("You need a PDA or another modular computer on you to use this!"))
		return FALSE

	if (!our_computer.enabled)
		to_chat(usr, span_notice("Your PDA needs to be on to use this!"))
		return FALSE

	// is our chat client open or in idle threads?
	var/capable = FALSE
	if (istype(our_computer.active_program, /datum/computer_file/program/chatclient))
		capable = TRUE

	if (locate(/datum/computer_file/program/chatclient) in our_computer.idle_threads)
		capable = TRUE

	if (!capable)
		to_chat(usr, span_notice("Your NTNRC app needs to be open or idling in the background to use this!"))
		return FALSE

	return our_computer
