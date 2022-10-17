/**
 * Logs a mesage to the mob_tags log, including the mobs tag
 * Arguments:
 * * text - text to log.
 */
/mob/proc/log_mob_tag(text)
	WRITE_LOG(GLOB.world_mob_tag_log, "TAG: \[[tag]\] [text]")

/proc/log_silicon(text)
	if (CONFIG_GET(flag/log_silicon))
		WRITE_LOG(GLOB.world_silicon_log, "SILICON: [text]")


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
