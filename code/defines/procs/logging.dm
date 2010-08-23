/proc/log_admin(text)
	admin_log.Add(text)
	if (config.log_admin)
		diary << "ADMIN: [text]"

/proc/log_game(text)
	if (config.log_game)
		diary << "GAME: [text]"

/proc/log_vote(text)
	if (config.log_vote)
		diary << "VOTE: [text]"

/proc/log_access(text)
	if (config.log_access)
		diary << "ACCESS: [text]"

/proc/log_say(text)
	if (config.log_say)
		diary << "SAY: [text]"

/proc/log_ooc(text)
	if (config.log_ooc)
		diary << "OOC: [text]"

/proc/log_whisper(text)
	if (config.log_whisper)
		diary << "WHISPER: [text]"