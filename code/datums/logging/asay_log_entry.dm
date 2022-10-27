/datum/log_entry/asay
	category = "ASAY"
	private = TRUE

/datum/log_entry/asay/New(client/author, message)
	..(message)
	with_source(author)
	with_location(author)
