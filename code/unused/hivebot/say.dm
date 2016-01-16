
/mob/living/silicon/hivebot/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))]\"";

	return "states, \"[text]\"";
