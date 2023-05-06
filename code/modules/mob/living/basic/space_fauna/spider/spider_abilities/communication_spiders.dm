/**
 * Sends a message to all currently living spiders.
 */
/datum/action/communication_spiders
	name = "Communication"
	desc = "Send a command to all living spiders."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "communication"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/communication_spiders/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/input = tgui_input_text(owner, "Input a message to inform your nest.", "Communication")
	if(!input || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return FALSE

	spider_communication(owner, input)
	return TRUE

/**
 * Sends a message to all spiders from the target.
 *
 * Allows the user to send a message to all spiders that exist.  Ghosts will also see the message.
 * Arguments:
 * * user - The spider sending the message
 * * message - The message to be sent
 */
/datum/action/communication_spiders/proc/spider_communication(mob/living/user, message)
	if(!message)
		return
	var/my_message = span_spider("<>Command from [user]:</> [message]")
	for(var/mob/living/basic/spider as anything in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag = "spider commmunication")
