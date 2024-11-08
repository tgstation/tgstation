/// Ensures sentences end in appropriate punctuation (a period if none exist) and that all whitespace-bounded 'i' characters are capitalized.
/// If the sentence ends in chat-flavored markdown for bolds, italics or underscores and does not have a preceding period, exclamation mark or other flavored sentence terminator, add a period.
/// (e.g: 'Borgs are rogue' becomes 'Borgs are rogue.', '+BORGS ARE ROGUE+ becomes '+BORGS ARE ROGUE+.', '+Borgs are rogue~+' is untouched.)
/proc/autopunct_bare(input_text)
	if (findtext(input_text, GLOB.needs_eol_autopunctuation))
		input_text += "."

	input_text = replacetext(input_text, GLOB.noncapital_i, "I")
	return input_text
