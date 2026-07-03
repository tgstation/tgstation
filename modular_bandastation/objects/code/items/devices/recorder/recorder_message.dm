/datum/tape_message
	/// Timestamp of this message as text
	var/timestamp = null
	/// Name of the speaker of this message
	var/speaker_name = null
	/// Text of this message
	var/text = null
	/// TTS seed of the speaker
	var/tts_seed = null

/datum/tape_message/New(timestamp, speaker_name, text, tts_seed)
	src.timestamp = timestamp
	src.speaker_name = speaker_name
	src.text = text
	src.tts_seed = tts_seed

/datum/tape_message/proc/get_composed_message()
	var/list/message_parts = list()
	if(timestamp)
		message_parts += "\[[timestamp]\]"
	if(speaker_name)
		message_parts += "[speaker_name]:"
	if(text)
		message_parts += text

	return message_parts.Join(" ")
