//print a warning message to world.log
#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
/proc/warning(msg)
	msg = "## WARNING: [msg]"
	log_world(msg)

//not an error or a warning, but worth to mention on the world log, just in case.
#define NOTICE(MSG) notice(MSG)
/proc/notice(msg)
	msg = "## NOTICE: [msg]"
	log_world(msg)

//print a testing-mode debug message to world.log and world
#ifdef TESTING
#define testing(msg) log_world("## TESTING: [msg]"); to_chat(world, "## TESTING: [msg]")
#else
#define testing(msg)
#endif

/proc/log_admin(text)
	admin_log.Add(text)
	if (config.log_admin)
		diary << "\[[time_stamp()]]ADMIN: [text]"

//Items using this proc are stripped from public logs - use with caution
/proc/log_admin_private(text)
	admin_log.Add(text)
	if (config.log_admin)
		diary << "\[[time_stamp()]]ADMINPRIVATE: [text]"

/proc/log_adminsay(text)
	if (config.log_adminchat)
		log_admin_private("ASAY: [text]")

/proc/log_dsay(text)
	if (config.log_adminchat)
		log_admin("DSAY: [text]")

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

/proc/log_prayer(text)
	if (config.log_prayer)
		diary << "\[[time_stamp()]]PRAY: [text]"

/proc/log_law(text)
	if (config.log_law)
		diary << "\[[time_stamp()]]LAW: [text]"

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

/proc/log_pda(text)
	if (config.log_pda)
		diary << "\[[time_stamp()]]PDA: [text]"

/proc/log_comment(text)
	if (config.log_pda)
		//reusing the PDA option because I really don't think news comments are worth a config option
		diary << "\[[time_stamp()]]COMMENT: [text]"

/proc/log_chat(text)
	if (config.log_pda)
		diary << "\[[time_stamp()]]CHAT: [text]"

/proc/log_sql(text)
	if(config.sql_enabled)
		diary << "\[[time_stamp()]]SQL: [text]"

//This replaces world.log so it displays both in DD and the file
/proc/log_world(text)
	if(config && config.log_runtimes)
		world.log = runtime_diary
		world.log << text
	world.log = null
	world.log << text

// Helper procs for building detailed log lines

/proc/datum_info_line(datum/D)
	if(!istype(D))
		return
	if(!istype(D, /mob))
		return "[D] ([D.type])"
	var/mob/M = D
	return "[M] ([M.ckey]) ([M.type])"

/proc/atom_loc_line(atom/A)
	if(!istype(A))
		return
	var/turf/T = get_turf(A)
	if(istype(T))
		return "[A.loc] [COORD(T)] ([A.loc.type])"
	else if(A.loc)
		return "[A.loc] (0, 0, 0) ([A.loc.type])"
