/proc/tts_speech_filter(text)
	// Only allow alphanumeric characters and whitespace
	var/static/regex/bad_chars_regex = regex("\[^a-zA-Z0-9 ,?.!'&-]", "g")
	return bad_chars_regex.Replace(text, " ")

/proc/tts_filter_encode(text, atom/movable/speaker, blips)
	text = replacetext(text, "%PITCH%", SStts.pitch_enabled ? speaker.pitch : 0)
	text = replacetext(text, "%FEMALE%", !!findtext(speaker.voice, "Woman"))
	text = replacetext(text, "%BLIPS%", blips)
	return url_encode(text)
