/// Stores information about a chat payload
/datum/chat_payload
	/// Number of times we tried to send this payload
	var/send_tries = 0
	/// world.time we sent last
	var/last_send = 0
	/// Sequence number of this payload
	var/sequence_number = 0
	/// Message we are sending
	var/list/content

/// Converts the chat payload into a JSON string
/datum/chat_payload/proc/into_message()
	return "{\"sequence\":[sequence_number],\"content\":[json_encode(content)]}"
