/datum/log_entry/ooc
	category = "OOC"

/datum/log_entry/ooc/New(client/author, message)
	..(message)
	with_source(author)
	with_location(author)

/datum/log_entry/ooc/to_text()
	return "(OOC) [key_name(source_ckey)] [extended_data["client_is_observer"] ? "(observer)" : ""]: [message]"
