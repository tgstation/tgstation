//wrapper macros for easier grepping
#define DIRECT_OUTPUT(A, B) A << B
#define SEND_IMAGE(target, image) DIRECT_OUTPUT(target, image)
#define SEND_SOUND(target, sound) DIRECT_OUTPUT(target, sound)
#define SEND_TEXT(target, text) DIRECT_OUTPUT(target, text)
#define WRITE_FILE(file, text) DIRECT_OUTPUT(file, text)
#define WRITE_LOG(log, text) rustg_log_write(log, text)

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

#ifdef UNIT_TESTS
/proc/log_test(text)
	WRITE_LOG(GLOB.test_log, text)
	SEND_TEXT(world.log, text)
#endif


/* Items with ADMINPRIVATE prefixed are stripped from public logs. */
/proc/log_admin(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: [text]")

/proc/log_admin_private(text)
	GLOB.admin_log.Add(text)
	if (CONFIG_GET(flag/log_admin))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: [text]")

/proc/log_adminsay(text)
	if (CONFIG_GET(flag/log_adminchat))
		WRITE_LOG(GLOB.world_game_log, "ADMINPRIVATE: ASAY: [text]")

/proc/log_dsay(text)
	if (CONFIG_GET(flag/log_adminchat))
		WRITE_LOG(GLOB.world_game_log, "ADMIN: DSAY: [text]")


/* All other items are public. */
/proc/log_game(text)
	if (CONFIG_GET(flag/log_game))
		WRITE_LOG(GLOB.world_game_log, "GAME: [text]")

/proc/log_access(text)
	if (CONFIG_GET(flag/log_access))
		WRITE_LOG(GLOB.world_game_log, "ACCESS: [text]")

/proc/log_law(text)
	if (CONFIG_GET(flag/log_law))
		WRITE_LOG(GLOB.world_game_log, "LAW: [text]")

/proc/log_attack(text)
	if (CONFIG_GET(flag/log_attack))
		WRITE_LOG(GLOB.world_attack_log, "ATTACK: [text]")

/proc/log_manifest(ckey, datum/mind/mind,mob/body, latejoin = FALSE)
	if (CONFIG_GET(flag/log_manifest))
		WRITE_LOG(GLOB.world_manifest_log, "[ckey] \\ [body.real_name] \\ [mind.assigned_role] \\ [mind.special_role ? mind.special_role : "NONE"] \\ [latejoin ? "LATEJOIN":"ROUNDSTART"]")


/proc/log_say(text)
	if (CONFIG_GET(flag/log_say))
		WRITE_LOG(GLOB.world_game_log, "SAY: [text]")

/proc/log_ooc(text)
	if (CONFIG_GET(flag/log_ooc))
		WRITE_LOG(GLOB.world_game_log, "OOC: [text]")

/proc/log_whisper(text)
	if (CONFIG_GET(flag/log_whisper))
		WRITE_LOG(GLOB.world_game_log, "WHISPER: [text]")

/proc/log_emote(text)
	if (CONFIG_GET(flag/log_emote))
		WRITE_LOG(GLOB.world_game_log, "EMOTE: [text]")

/proc/log_prayer(text)
	if (CONFIG_GET(flag/log_prayer))
		WRITE_LOG(GLOB.world_game_log, "PRAY: [text]")

/proc/log_pda(text)
	if (CONFIG_GET(flag/log_pda))
		WRITE_LOG(GLOB.world_pda_log, "PDA: [text]")

/proc/log_comment(text)
	if (CONFIG_GET(flag/log_pda))
		//reusing the PDA option because I really don't think news comments are worth a config option
		WRITE_LOG(GLOB.world_pda_log, "COMMENT: [text]")

/proc/log_chat(text)
	if (CONFIG_GET(flag/log_pda))
		//same thing here
		WRITE_LOG(GLOB.world_pda_log, "CHAT: [text]")

/proc/log_vote(text)
	if (CONFIG_GET(flag/log_vote))
		WRITE_LOG(GLOB.world_game_log, "VOTE: [text]")


/proc/log_topic(text)
	WRITE_LOG(GLOB.world_game_log, "TOPIC: [text]")

/proc/log_href(text)
	WRITE_LOG(GLOB.world_href_log, "HREF: [text]")

/proc/log_sql(text)
	WRITE_LOG(GLOB.sql_error_log, "SQL: [text]")

/proc/log_qdel(text)
	WRITE_LOG(GLOB.world_qdel_log, "QDEL: [text]")

/proc/log_query_debug(text)
	WRITE_LOG(GLOB.query_debug_log, "SQL: [text]")

/proc/log_job_debug(text)
	if (CONFIG_GET(flag/log_job_debug))
		WRITE_LOG(GLOB.world_job_debug_log, "JOB: [text]")

/* Log to both DD and the logfile. */
/proc/log_world(text)
	WRITE_LOG(GLOB.world_runtime_log, text)
	SEND_TEXT(world.log, text)

/* Log to the logfile only. */
/proc/log_runtime(text)
	WRITE_LOG(GLOB.world_runtime_log, text)

/* Rarely gets called; just here in case the config breaks. */
/proc/log_config(text)
	WRITE_LOG(GLOB.config_error_log, text)
	SEND_TEXT(world.log, text)


/* For logging round startup. */
/proc/start_log(log)
	WRITE_LOG(log, "Starting up round ID [GLOB.round_id].\n-------------------------")

/* Close open log handles. This should be called as late as possible, and no logging should hapen after. */
/proc/shutdown_logging()
	rustg_log_close_all()


/* Helper procs for building detailed log lines */
/proc/datum_info_line(datum/D)
	if(!istype(D))
		return
	if(!ismob(D))
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
