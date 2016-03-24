//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	world.log << "## WARNING: [msg]"

//not an error or a warning, but worth to mention on the world log, just in case.
#define NOTICE(MSG) notice(MSG)
/proc/notice(msg)
	world.log << "## NOTICE: [msg]"

//print a testing-mode debug message to world.log
/proc/testing(msg)
#ifdef TESTING
	world.log << "## TESTING: [msg]"
#endif

/proc/log_admin(text)
	admin_log.Add(russian_text2html(sanitize_russian(text,1)))
	if (config.log_admin)
		diary << "\[[time_stamp()]]ADMIN: [text]"

/proc/log_adminsay(text)
	if (config.log_adminchat)
		log_admin("ASAY: [sanitize_russian(russian_html2text(text))]")

/proc/log_dsay(text)
	if (config.log_adminchat)
		log_admin("DSAY: [sanitize_russian(russian_html2text(text))]")

/proc/log_game(text)
	if (config.log_game)
		diary << "\[[time_stamp()]]GAME: [text]"

/proc/log_vote(text)
	if (config.log_vote)
		diary << "\[[time_stamp()]]VOTE: [sanitize_russian(russian_html2text(text))]"

/proc/log_access(text)
	if (config.log_access)
		diary << "\[[time_stamp()]]ACCESS: [text]"

/proc/log_say(text)
	if (config.log_say)
		diary << "\[[time_stamp()]]SAY: [sanitize_russian(russian_html2text(text))]"

/proc/log_prayer(text)
	if (config.log_prayer)
		diary << "\[[time_stamp()]]PRAY: [sanitize_russian(russian_html2text(text))]"

/proc/log_law(text)
	if (config.log_law)
		diary << "\[[time_stamp()]]LAW: [sanitize_russian(russian_html2text(text))]"

/proc/log_ooc(text)
	if (config.log_ooc)
		diary << "\[[time_stamp()]]OOC: [sanitize_russian(russian_html2text(text))]"

/proc/log_whisper(text)
	if (config.log_whisper)
		diary << "\[[time_stamp()]]WHISPER: [sanitize_russian(russian_html2text(text))]"

/proc/log_emote(text)
	if (config.log_emote)
		diary << "\[[time_stamp()]]EMOTE: [sanitize_russian(russian_html2text(text))]"

/proc/log_attack(text)
	if (config.log_attack)
		diary << "\[[time_stamp()]]ATTACK: [text]"

/proc/log_pda(text)
	if (config.log_pda)
		diary << "\[[time_stamp()]]PDA: [sanitize_russian(russian_html2text(text))]"

/proc/log_comment(text)
	if (config.log_pda)
		//reusing the PDA option because I really don't think news comments are worth a config option
		diary << "\[[time_stamp()]]COMMENT: [sanitize_russian(russian_html2text(text))]"

