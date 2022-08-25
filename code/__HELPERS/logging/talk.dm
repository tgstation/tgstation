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
/proc/log_say(text)
	if (CONFIG_GET(flag/log_say))
		WRITE_LOG(GLOB.world_game_log, "SAY: [text]")

/// Logging for whispered messages
/proc/log_whisper(text)
	if (CONFIG_GET(flag/log_whisper))
		WRITE_LOG(GLOB.world_game_log, "WHISPER: [text]")

/// Helper for logging of messages with only one sender and receiver (i.e. mind links)
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag = "[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, LOG_VICTIM, tag = "[tag] from [key_name(source)]", log_globally = FALSE)

/// Logging for speech taking place over comms, as well as tcomms equipment
/proc/log_telecomms(text)
	if (CONFIG_GET(flag/log_telecomms))
		WRITE_LOG(GLOB.world_telecomms_log, "TCOMMS: [text]")

/// Logging for speech indicators.
/proc/log_speech_indicators(text)
	if (CONFIG_GET(flag/log_speech_indicators))
		WRITE_LOG(GLOB.world_speech_indicators_log, "SPEECH INDICATOR: [text]")
