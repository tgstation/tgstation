/datum/autowiki/emoji
	page = "Template:Autowiki/Content/Emojis"

/datum/autowiki/emoji/generate()
	var/output = ""
	var/list/icon_states = icon_states(EMOJI_SET)

	for(var/icon_state in icon_states)
		var/filename = SANITIZE_FILENAME(escape_value("[icon_state]_wiki_emoji"))

		output += include_template("Autowiki/Emoji", list(
			"name" = ":[escape_value(icon_state)]:",
			"icon" = filename,
		))

		// It would be cool to make this support gifs someday, but not now
		upload_icon(icon(EMOJI_SET, icon_state, frame = 1), filename)

	return include_template("Autowiki/EmojiTable", list("content" = output))
