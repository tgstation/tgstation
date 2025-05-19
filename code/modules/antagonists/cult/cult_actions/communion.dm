/datum/action/innate/cult/comm
	name = "Communion"
	desc = "Whispered words that all cultists can hear.<br><b>Warning:</b>Nearby non-cultists can still hear you."
	button_icon_state = "cult_comms"
	// Unholy words dont require hands or mobility
	check_flags = AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS

/datum/action/innate/cult/comm/IsAvailable(feedback = FALSE)
	if(isshade(owner) && IS_CULTIST(owner))
		return TRUE
	return ..()

/datum/action/innate/cult/comm/Activate()
	var/input = tgui_input_text(usr, "Message to tell to the other acolytes", "Voice of Blood", max_length = MAX_MESSAGE_LEN)
	if(!input || !IsAvailable(feedback = TRUE))
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

/datum/action/innate/cult/comm/proc/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message || !user.mind)
		return
	user.whisper("O bidai nabora se[pick("'","`")]sma!", language = /datum/language/common, forced = "cult invocation")
	user.whisper(html_decode(message), filterproof = TRUE)
	var/title = "Acolyte"
	var/span = "cult italic"
	var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
	if(cult_datum.is_cult_leader())
		span = "cult_large"
		title = "Master"
	else if(!ishuman(user))
		title = "Construct"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/mob/listener as anything in GLOB.player_list)
		if(IS_CULTIST(listener))
			to_chat(listener, my_message, type = MESSAGE_TYPE_RADIO, avoid_highlighting = listener == user)
		else if(listener in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(listener, user)
			to_chat(listener, "[link] [my_message]", type = MESSAGE_TYPE_RADIO)

	user.log_talk(message, LOG_SAY, tag="cult")

/datum/action/innate/cult/comm/spirit
	name = "Spiritual Communion"
	desc = "Conveys a message from the spirit realm that all cultists can hear."

/datum/action/innate/cult/comm/spirit/IsAvailable(feedback = FALSE)
	if(IS_CULTIST(owner.mind.current))
		return TRUE
	return ..()

/datum/action/innate/cult/comm/spirit/cultist_commune(mob/living/user, message)
	var/my_message
	if(!message)
		return
	my_message = span_cult_bold_italic("\The [user]: [message]")
	for(var/mob/player_list as anything in GLOB.player_list)
		if(IS_CULTIST(player_list))
			to_chat(player_list, my_message)
		else if(player_list in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(player_list, user)
			to_chat(player_list, "[link] [my_message]")
