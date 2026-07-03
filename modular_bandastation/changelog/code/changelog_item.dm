/datum/asset/changelog_item/New(date)
	item_filename = SANITIZE_FILENAME("[date].yml")
	SSassets.transport.register_asset(item_filename, file("html/changelogs/bandastation/archive/" + item_filename))
