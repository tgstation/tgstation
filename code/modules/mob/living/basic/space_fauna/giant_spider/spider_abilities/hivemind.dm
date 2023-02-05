/**
 * Sets a directive to be given to all future spiders created by the user.
 * This will be overwritten if used again.
 */
/datum/action/set_spider_directive
	name = "Set Directive"
	desc = "Set a directive for your future children to follow."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "directive"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS
	/// Current directive to apply
	var/current_directive = ""

/datum/action/set_spider_directive/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return
	var/new_directive = tgui_input_text(owner, "Enter the new directive", "Create directive", "[current_directive]")
	if(isnull(new_directive) || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return FALSE

	current_directive = new_directive
	message_admins("[ADMIN_LOOKUPFLW(owner)] set its directive to: '[current_directive]'.")
	owner.log_message("set its directive to: '[current_directive]'.", LOG_GAME)
	return TRUE

/**
 * Sends a message to all currently living spiders.
 */
/datum/action/command_spiders
	name = "Command"
	desc = "Send a command to all living spiders."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "command"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/command_spiders/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

	var/input = tgui_input_text(owner, "Input a command for your legions to follow.", "Command")
	if(!input || QDELETED(src) || QDELETED(owner) || !IsAvailable(feedback = TRUE))
		return FALSE

	spider_command(owner, input)
	return TRUE

/**
 * Sends a message to all spiders from the target.
 *
 * Allows the user to send a message to all spiders that exist.  Ghosts will also see the message.
 * Arguments:
 * * user - The spider sending the message
 * * message - The message to be sent
 */
/datum/action/command_spiders/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message = span_spider("<b>Command from [user]:</b> [message]")
	for(var/mob/living/simple_animal/hostile/giant_spider/spider as anything in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag = "spider command")
