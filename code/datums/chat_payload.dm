/// Stores information about a chat payload
/datum/chat_payload
	/// Sequence number of this payload
	var/sequence = 0
	/// Message we are sending
	var/list/content
	/// Resend count
	var/resends = 0

/// Converts the chat payload into a JSON string
/datum/chat_payload/proc/into_message()
	return "{\"sequence\":[sequence],\"content\":[json_encode(content)]}"
