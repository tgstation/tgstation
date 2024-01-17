/**
 * Logs a mesage to the mob_tags log, including the mobs tag
 * Arguments:
 * * text - text to log.
 */
/mob/proc/log_mob_tag(text, list/data)
	logger.Log(LOG_CATEGORY_DEBUG_MOBTAG, text, data)

/proc/log_silicon(text, list/data)
	logger.Log(LOG_CATEGORY_SILICON, text, data)


/// Logs a message in a mob's individual log, and in the global logs as well if log_globally is true
/mob/log_message(message, message_type, color = null, log_globally = TRUE)
	if(!LAZYLEN(message))
		stack_trace("Empty message")
		return

	// Cannot use the list as a map if the key is a number, so we stringify it (thank you BYOND)
	var/smessage_type = num2text(message_type, MAX_BITFLAG_DIGITS)

	if(client)
		if(!islist(client.player_details.logging[smessage_type]))
			client.player_details.logging[smessage_type] = list()

	if(!islist(logging[smessage_type]))
		logging[smessage_type] = list()

	var/colored_message = message
	if(color)
		if(color[1] == "#")
			colored_message = "<font color=[color]>[message]</font>"
		else
			colored_message = "<font color='[color]'>[message]</font>"

	//This makes readability a bit better for admins.
	switch(message_type)
		if(LOG_WHISPER)
			colored_message = "(WHISPER) [colored_message]"
		if(LOG_OOC)
			colored_message = "(OOC) [colored_message]"
		if(LOG_ASAY)
			colored_message = "(ASAY) [colored_message]"
		if(LOG_EMOTE)
			colored_message = "(EMOTE) [colored_message]"
		if(LOG_RADIO_EMOTE)
			colored_message = "(RADIOEMOTE) [colored_message]"

	var/list/timestamped_message = list("\[[time_stamp(format = "YYYY-MM-DD hh:mm:ss")]\] [key_name(src)] [loc_name(src)] (Event #[LAZYLEN(logging[smessage_type])])" = colored_message)

	logging[smessage_type] += timestamped_message

	if(client)
		client.player_details.logging[smessage_type] += timestamped_message

	..()

/**
 * Returns an associative list of the logs of a certain amount of lines spoken recently by this mob
 * copy_amount - number of lines to return
 * line_chance - chance to return a line, if you don't want just the most recent x lines
 */
/mob/proc/copy_recent_speech(copy_amount = LING_ABSORB_RECENT_SPEECH, line_chance = 100)
	var/list/recent_speech = list()
	var/list/say_log = list()
	var/log_source = logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				say_log = reverse_range(reversed.Copy())
				break

	for(var/spoken_memory in say_log)
		if(recent_speech.len >= copy_amount)
			break
		if(!prob(line_chance))
			continue
		recent_speech[spoken_memory] = splittext(say_log[spoken_memory], "\"", 1, 0, TRUE)[3]

	var/list/raw_lines = list()
	for (var/key as anything in recent_speech)
		raw_lines += recent_speech[key]

	return raw_lines

/// Takes in an associated list (key `/datum/action` typepaths, value is the AI blackboard key) and handles granting the action and adding it to the mob's AI controller blackboard.
/// This is only useful in instances where you don't want to store the reference to the action on a variable on the mob.
/// You can set the value to null if you don't want to add it to the blackboard (like in player controlled instances). Is also safe with null AI controllers.
/// Assumes that the action will be initialized and held in the mob itself, which is typically standard.
/mob/proc/grant_actions_by_list(list/input)
	if(length(input) <= 0)
		return

	for(var/action in input)
		var/datum/action/ability = new action(src)
		ability.Grant(src)

		var/blackboard_key = input[action]
		if(isnull(blackboard_key))
			continue

		ai_controller?.set_blackboard_key(blackboard_key, ability)
