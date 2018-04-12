// SETUP

/proc/TopicHandlers()
	. = list()
	var/list/all_handlers = subtypesof(/datum/world_topic)
	for(var/I in all_handlers)
		var/datum/world_topic/WT = I
		var/keyword = initial(WT.keyword)
		if(!keyword)
			warning("[WT] has no keyword! Ignoring...")
			continue
		var/existing_path = .[keyword]
		if(existing_path)
			warning("[existing_path] and [WT] have the same keyword! Ignoring [WT]...")
		else if(keyword == "key")
			warning("[WT] has keyword 'key'! Ignoring...")
		else
			.[keyword] = WT

// DATUM

/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE

/datum/world_topic/proc/TryRun(list/input)
	key_valid = config && (CONFIG_GET(string/comms_key) == input["key"])
	if(require_comms_key && !key_valid)
		return "Bad Key"
	input -= "key"
	. = Run(input)
	if(islist(.))
		. = list2params(.)

/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")

// TOPICS

/datum/world_topic/ping
	keyword = "ping"
	log = FALSE

/datum/world_topic/ping/Run(list/input)
	. = 0
	for (var/client/C in GLOB.clients)
		++.

/datum/world_topic/players
	keyword = "players"
	log = FALSE

/datum/world_topic/players/Run(list/input)
	return GLOB.player_list.len

/datum/world_topic/adminwho
	keyword = "adminwho"
	log = FALSE

/datum/world_topic/adminwho/Run(list/input)
	var/msg = "Current Admins:\n"
	for(var/adm in GLOB.admins)
		var/client/C = adm
		if(!C.holder.fakekey)
			msg += "\t[C] is a [C.holder.rank]"
			msg += "\n"
	return msg

/datum/world_topic/who
	keyword = "who"
	log = FALSE

/datum/world_topic/who/Run(list/input)
	var/msg = "Current Players:\n"
	var/n = 0
	for(var/client/C in GLOB.clients)
		n++
		if(C.holder && C.holder.fakekey)
			msg += "\t[C.holder.fakekey]\n"
		else
			msg += "\t[C.key]\n"
	msg += "Total Players: [n]"
	return msg

/datum/world_topic/asay
	keyword = "asay"
	require_comms_key = TRUE

/datum/world_topic/asay/Run(list/input)
	msg = "<span class='adminobserver'><span class='prefix'>DISCORD ADMIN:</span> <EM>[input["admin"]]</EM>: <span class='message'>[input["asay"]]</span></span>"
	to_chat(GLOB.admins, msg)

/datum/world_topic/ooc
	keyword = "ooc"

/datum/world_topic/ooc/Run(list/input)
	if(!GLOB.ooc_allowed&&!input["isadmin"])
		return "globally muted"

	for(var/client/C in GLOB.clients)
		if(C.prefs.chat_toggles & CHAT_OOC) // ooc ignore
			if(!(C.prefs.chat_toggles & CHAT_MUTED_DISCORD_OOC)||input["isadmin"]) // discord ooc ignore, bypassed by admins
				if(!(input["ckey"] in C.prefs.ignoring)) //ckey ignore
					to_chat(C, "<font color='[GLOB.normal_ooc_colour]'><span class='ooc'><span class='prefix'>DISCORD OOC:</span> <EM>[input["ckey"]]:</EM> <span class='message'>[input["ooc"]]</span></span></font>")

/datum/world_topic/ahelp
	keyword = "ahelp"
	require_comms_key = TRUE

/datum/world_topic/ahelp/Run(list/input)
	var/r_ckey = ckey(input["ckey"])
	var/s_admin = input["admin"]
	var/msg = sanitize_russian(input["response"])
	var/keywordparsedmsg = keywords_lookup(msg)
	var/client/recipient = GLOB.directory[r_ckey]
	if(!recipient)
		return "FAIL"
	if(!recipient.current_ticket)
		new /datum/admin_help(msg, recipient, TRUE)
	to_chat(recipient, "<font color='red' size='4'><b>-- Discord administrator private message --</b></font>")
	to_chat(recipient, "<font color='red'>Admin PM from-<b>[s_admin]</b>: [msg]</font>")
	to_chat(recipient, "<font color='red'><i>Write to ahelp to reply.</i></font>")
	to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, 1, 1)]</b>: [msg]</font>")

	admin_ticket_log(recipient, "<font color='blue'>PM From [s_admin]: [keywordparsedmsg]</font>")
	//BWOINK
	SEND_SOUND(recipient, sound('sound/effects/adminhelp.ogg'))
	log_admin_private("PM: IRC -> [r_ckey]: [sanitize(msg)]")
	for(var/client/X in GLOB.admins)
		to_chat(X, "<font color='blue'><B>PM: DISCORD([s_admin]) -&gt; [key_name(recipient, X, 0)]</B> [keywordparsedmsg]</font>")


/datum/world_topic/status
	keyword = "status"

/datum/world_topic/status/Run(list/input)
	. = list()
	.["version"] = GLOB.game_version
	.["mode"] = GLOB.master_mode
	.["respawn"] = config ? !CONFIG_GET(flag/norespawn) : FALSE
	.["enter"] = GLOB.enter_allowed
	.["vote"] = CONFIG_GET(flag/allow_vote_mode)
	.["ai"] = CONFIG_GET(flag/allow_ai)
	.["host"] = world.host ? world.host : null
	.["round_id"] = GLOB.round_id
	.["players"] = GLOB.clients.len
	.["revision"] = GLOB.revdata.commit
	.["revision_date"] = GLOB.revdata.date

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
	.["gamestate"] = SSticker.current_state

	.["map_name"] = SSmapping.config.map_name

	if(key_valid)
		.["active_players"] = get_active_player_count()
		if(SSticker.HasRoundStarted())
			.["real_mode"] = SSticker.mode.name
			// Key-authed callers may know the truth behind the "secret"

	.["security_level"] = get_security_level()
	.["round_duration"] = SSticker ? round((world.time-SSticker.round_start_time)/10) : 0
	// Amount of world's ticks in seconds, useful for calculating round duration

	if(SSshuttle && SSshuttle.emergency)
		.["shuttle_mode"] = SSshuttle.emergency.mode
		// Shuttle status, see /__DEFINES/stat.dm
		.["shuttle_timer"] = SSshuttle.emergency.timeLeft()
		// Shuttle timer, in seconds
