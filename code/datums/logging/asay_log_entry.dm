/datum/log_entry/asay
	version = "1.0.0"
	category = "ASAY"
	private = TRUE

/datum/log_entry/asay/New(client/author, message)
	..(message)
	with_source(author)
	with_location(author)
	finalize()

/datum/log_entry/asay/to_text()
	return "\[[source_ckey]\]: [message]"
