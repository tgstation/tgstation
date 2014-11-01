//print an error message to world.log
/proc/error(msg)
	world.log << "## ERROR: [msg]"

/*
 * print a warning message to world.log
 */
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	world.log << "## WARNING: [msg]"

//print a testing-mode debug message to world.log
/proc/testing(msg)
	world.log << "## TESTING: [msg]"

/proc/log_admin(raw_text)
	var/text_to_log = "\[[time_stamp()]]ADMIN: [raw_text]"

	admin_log.Add(text_to_log)

	if(config.log_admin)
		diary << text_to_log

	if(config.log_admin_only)
		admin_diary << text_to_log

/proc/log_debug(text)
	if (config.log_debug)
		diary << "\[[time_stamp()]]DEBUG: [text]"

	for(var/client/C in admins)
		if(C.prefs.toggles & CHAT_DEBUGLOGS)
			C << "DEBUG: [text]"


/proc/log_game(text)
	if (config.log_game)
		diary << "\[[time_stamp()]]GAME: [text]"

/proc/log_vote(text)
	if (config.log_vote)
		diary << "\[[time_stamp()]]VOTE: [text]"

/proc/log_access(text)
	if (config.log_access)
		diary << "\[[time_stamp()]]ACCESS: [text]"

/proc/log_say(text)
	if (config.log_say)
		diary << "\[[time_stamp()]]SAY: [text]"

/proc/log_ooc(text)
	if (config.log_ooc)
		diary << "\[[time_stamp()]]OOC: [text]"

/proc/log_whisper(text)
	if (config.log_whisper)
		diary << "\[[time_stamp()]]WHISPER: [text]"

/proc/log_emote(text)
	if (config.log_emote)
		diary << "\[[time_stamp()]]EMOTE: [text]"

/proc/log_attack(text)
	if (config.log_attack)
		diaryofmeanpeople << "\[[time_stamp()]]ATTACK: [text]"

/proc/log_adminsay(text)
	if (config.log_adminchat)
		diary << "\[[time_stamp()]]ADMINSAY: [text]"

/proc/log_adminwarn(text)
	if (config.log_adminwarn)
		diary << "\[[time_stamp()]]ADMINWARN: [text]"

/proc/log_adminghost(text)
	if (config.log_adminghost)
		diary << "\[[time_stamp()]]ADMINGHOST: [text]"
		message_admins("\[ADMINGHOST\] [text]")

/proc/log_ghost(text)
	if (config.log_adminghost)
		diary << "\[[time_stamp()]]GHOST: [text]"
		message_admins("\[GHOST\] [text]")

/proc/log_pda(text)
	if (config.log_pda)
		diary << "\[[time_stamp()]]PDA: [text]"