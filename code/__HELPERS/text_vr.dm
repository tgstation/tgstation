//Readds quotes and apostrophes to HTML-encoded strings
/proc/readd_quotes(var/t)
	var/list/repl_chars = list("&#34;" = "\"","&#39;" = "'")
	for(var/char in repl_chars)
		var/index = findtext(t, char)
		while(index)
			t = copytext(t, 1, index) + repl_chars[char] + copytext(t, index+5)
			index = findtext(t, char)
	return t

proc/TextPreview(var/string,var/len=40)
	if(lentext(string) <= len)
		if(!lentext(string))
			return "\[...\]"
		else
			return string
	else
		return "[copytext(string, 1, 37)]..."

GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)

GLOBAL_LIST_EMPTY(whitelisted_species_list)

/proc/log_mentor(text)
	GLOB.mentorlog.Add(text)
	WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]MENTOR: [text]")

/proc/log_looc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_FILE(GLOB.world_game_log, "\[[time_stamp()]]LOOC: [text]")