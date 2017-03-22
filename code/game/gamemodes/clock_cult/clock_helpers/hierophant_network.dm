//Sends a string to all servants and optionally ghosts, who will get a follow link to whatever is provided as the target.
/proc/hierophant_message(message, servantsonly, atom/target)
	if(!message)
		return FALSE
	for(var/M in GLOB.mob_list)
		if(!servantsonly && isobserver(M))
			if(target)
				var/link = FOLLOW_LINK(M, target)
				to_chat(M, "[link] [message]")
			else
				to_chat(M, message)
		else if(is_servant_of_ratvar(M))
			to_chat(M, message)
	return TRUE

//Sends a titled message from a mob to all servants of ratvar and ghosts.
/proc/titled_hierophant_message(mob/user, message, name_span = "heavy_brass", message_span = "brass", user_title = "Servant")
	if(!user || !message)
		return FALSE
	var/parsed_message = "<span class='[name_span]'>[user_title ? "[user_title] ":""][findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]: \
	</span><span class='[message_span]'>\"[message]\"</span>"
	hierophant_message(parsed_message, FALSE, user)
	return TRUE

//Hierophant Network action, allows a servant with it to communicate to other servants.
/datum/action/innate/hierophant
	name = "Hierophant Network"
	desc = "Allows you to communicate with other Servants."
	button_icon_state = "hierophant"
	background_icon_state = "bg_clock"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUNNED|AB_CHECK_CONSCIOUS
	buttontooltipstyle = "clockcult"
	var/title = "Servant"
	var/span_for_name = "heavy_brass"
	var/span_for_message = "brass"

/datum/action/innate/hierophant/IsAvailable()
	if(!is_servant_of_ratvar(owner))
		return FALSE
	return ..()

/datum/action/innate/hierophant/Activate()
	var/input = stripped_input(usr, "Please enter a message to send to other servants.", "Hierophant Network", "")
	if(!input || !IsAvailable())
		return

	titled_hierophant_message(owner, input, span_for_name, span_for_message, title)
