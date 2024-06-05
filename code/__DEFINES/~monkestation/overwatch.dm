
/proc/new_sql_sanitize_text(text)
	text = replacetext(text, "'", "")
	text = replacetext(text, ";", "")
	text = replacetext(text, "&", "")
	text = replacetext(text, "`", "")
	return text

/proc/remove_all_spaces(text)
	text = replacetext(text, " ", "")
	return text

/proc/sql_sanitize_text(text)
	text = replacetext(text, "'", "''")
	text = replacetext(text, ";", "")
	text = replacetext(text, "&", "")
	return text
