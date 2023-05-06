/*
*	Whirring Convergence
*   Communicate a message to all other clock cultists
*/
/datum/action/innate/clockcult/comm
	name = "Whirring Convergence"
	desc = "Whispered words that link to the internal cogs of us all.<br><b>Warning:</b> Nearby non-servants can still hear you."
	button_icon_state = "linked_minds"

/datum/action/innate/clockcult/comm/Activate()
	var/input = tgui_input_text(usr, "Message to tell to the other followers.", "Voice of Cogs")
	if(!input || !IsAvailable())
		return

	var/list/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
	if(filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		return

	var/list/soft_filter_result = CAN_BYPASS_FILTER(usr) ? null : is_soft_ic_filtered(input)
	if(soft_filter_result)

		if(tgui_alert(usr,"Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[html_encode(input)]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[input]\"")

	cultist_commune(usr, input)

/// A user can input a message to send to other clock cultists over the clock cult communication channel
/datum/action/innate/clockcult/comm/proc/cultist_commune(mob/living/user, message)
	if(!message)
		return

	user.whisper("Engine, V vaibxr gb-gur`r gb-pbzzhar gb-nyy.", language = /datum/language/common) //Ratvar, I invoke to-the`e to-commune to-all.
	user.whisper(html_decode(message), filterproof = TRUE)
	send_clock_message(user, message)

/// Send `sent_message` to all other clock cultists and ghosts from the user
/proc/send_clock_message(mob/living/user, sent_message, span = "<span class='brass'>", msg_ghosts = TRUE)
	var/final_message = ""
	if(user)
		final_message = span + "<i><b>Clock[user.gender == FEMALE ? "sister" : "brother"] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]</b> transmits, \"" + sent_message + "\"</i></span>"
	else
		final_message = span + sent_message + "</span>"

	for(var/mob/player_mob as anything in GLOB.player_list)

		if(IS_CLOCK(player_mob))
			to_chat(player_mob, final_message)

		else if(player_mob in GLOB.dead_mob_list)
			if(!msg_ghosts)
				continue
			if(user)
				to_chat(player_mob, "[FOLLOW_LINK(player_mob, user)] [final_message]")
			else
				to_chat(player_mob, final_message)
