/**
 * Helper for logging chat messages that may or may not have a custom say verb,
 * or be a pure radio emote outright.
 *
 * This proc reads the `message_mods` to determine
 * in what ways the given message should be logged,
 * and forwards it to other logging procs as such.
 * Arguments:
 * * message - The message being logged
 * * message_mods - A list of message modifiers, i.e. whispering/singing.
 * * tag - tag that indicates the type of text(announcement, telepathy, etc)
 * * log_globally - boolean checking whether or not we write this log to the log file
 * * forced_by - source that forced the dialogue if any
 */
/atom/proc/log_sayverb_talk(message, list/message_mods = list(), tag = null, log_globally = TRUE, forced_by = null)
	// If it's just the custom say verb, log it to emotes.
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		log_talk(message_mods[MODE_CUSTOM_SAY_EMOTE], LOG_RADIO_EMOTE, tag, log_globally, forced_by)
		return

	if(message_mods[WHISPER_MODE])
		log_talk(message, LOG_WHISPER, tag, log_globally, forced_by, message_mods[MODE_CUSTOM_SAY_EMOTE])
	else
		log_talk(message, LOG_SAY, tag, log_globally, forced_by, message_mods[MODE_CUSTOM_SAY_EMOTE])

/**
 * Helper for logging chat messages or other logs with arbitrary inputs (e.g. announcements)
 *
 * This proc compiles a log string by prefixing the tag to the message
 * and suffixing what it was forced_by if anything
 * if the message lacks a tag and suffix then it is logged on its own
 * Arguments:
 * * message - The message being logged
 * * message_type - the type of log the message is(ATTACK, SAY, etc)
 * * tag - tag that indicates the type of text(announcement, telepathy, etc)
 * * log_globally - boolean checking whether or not we write this log to the log file
 * * forced_by - source that forced the dialogue if any
 */
/atom/proc/log_talk(message, message_type, tag = null, log_globally = TRUE, forced_by = null, custom_say_emote = null)
	var/prefix = tag ? "([tag]) " : ""
	var/suffix = forced_by ? " FORCED by [forced_by]" : ""
	log_message("[prefix][custom_say_emote ? "*[custom_say_emote]*, " : ""]\"[message]\"[suffix]", message_type, log_globally = log_globally)

/// Logging for generic spoken messages
/proc/log_say(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_SAY, text, data)

/// Logging for whispered messages
/proc/log_whisper(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_WHISPER, text, data)

/// Helper for logging of messages with only one sender and receiver (i.e. mind links)
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag = "[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, LOG_VICTIM, tag = "[tag] from [key_name(source)]", log_globally = FALSE)

/// Logging for speech taking place over comms, as well as tcomms equipment
/proc/log_telecomms(text, list/data)
	logger.Log(LOG_CATEGORY_TELECOMMS, text, data)

/// Logging for speech indicators.
/proc/log_speech_indicators(text, list/data)
	logger.Log(LOG_CATEGORY_SPEECH_INDICATOR, text, data)
