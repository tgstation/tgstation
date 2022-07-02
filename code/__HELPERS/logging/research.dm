/// Puts the text into the research html file, not log. See [INVESTIGATE_RESEARCH] for [/atom/proc/investigate_log]
/proc/log_research(text)
	if(!text)
		return
	var/F = file("[GLOB.log_directory]/[INVESTIGATE_RESEARCH].html")
	WRITE_FILE(F, "[time_stamp()] [message]<br>")
