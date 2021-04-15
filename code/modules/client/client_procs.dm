	////////////
	//SECURITY//
	////////////
#define UPLOAD_LIMIT 524288 //Restricts client uploads to the server to 0.5MB
#define UPLOAD_LIMIT_ADMIN 2621440 //Restricts admin client uploads to the server to 2.5MB

GLOBAL_LIST_INIT(blacklisted_builds, list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",

	))

#define LIMITER_SIZE 5
#define CURRENT_SECOND 1
#define SECOND_COUNT 2
#define CURRENT_MINUTE 3
#define MINUTE_COUNT 4
#define ADMINSWARNED_AT 5
	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/

/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob) //stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	// asset_cache
	var/asset_cache_job
	if(href_list["asset_cache_confirm_arrival"])
		asset_cache_job = asset_cache_confirm_arrival(href_list["asset_cache_confirm_arrival"])
		if (!asset_cache_job)
			return

	// Rate limiting
	var/mtl = CONFIG_GET(number/minute_topic_limit)
	if (!holder && mtl)
		var/minute = round(world.time, 600)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (minute != topiclimiter[CURRENT_MINUTE])
			topiclimiter[CURRENT_MINUTE] = minute
			topiclimiter[MINUTE_COUNT] = 0
		topiclimiter[MINUTE_COUNT] += 1
		if (topiclimiter[MINUTE_COUNT] > mtl)
			var/msg = "Your previous action was ignored because you've done too many in a minute."
			if (minute != topiclimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				topiclimiter[ADMINSWARNED_AT] = minute
				msg += " Administrators have been informed."
				log_game("[key_name(src)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] Has hit the per-minute topic limit of [mtl] topic calls in a given game minute")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	var/stl = CONFIG_GET(number/second_topic_limit)
	if (!holder && stl)
		var/second = round(world.time, 10)
		if (!topiclimiter)
			topiclimiter = new(LIMITER_SIZE)
		if (second != topiclimiter[CURRENT_SECOND])
			topiclimiter[CURRENT_SECOND] = second
			topiclimiter[SECOND_COUNT] = 0
		topiclimiter[SECOND_COUNT] += 1
		if (topiclimiter[SECOND_COUNT] > stl)
			to_chat(src, "<span class='danger'>Your previous action was ignored because you've done too many in a second</span>")
			return

	// Tgui Topic middleware
	if(tgui_Topic(href_list))
		return
	if(href_list["reload_tguipanel"])
		nuke_chat()
	if(href_list["reload_statbrowser"])
		src << browse(file('html/statbrowser.html'), "window=statbrowser")
	// Log all hrefs
	log_href("[src] (usr:[usr]\[[COORD(usr)]\]) : [hsrc ? "[hsrc] " : ""][href]")

	//byond bug ID:2256651
	if (asset_cache_job && (asset_cache_job in completed_asset_jobs))
		to_chat(src, "<span class='danger'>An error has been detected in how your client is receiving resources. Attempting to correct.... (If you keep seeing these messages you might want to close byond and reconnect)</span>")
		src << browse("...", "window=asset_cache_browser")
		return
	if (href_list["asset_cache_preload_data"])
		asset_cache_preload_data(href_list["asset_cache_preload_data"])
		return

	// Admin PM
	if(href_list["priv_msg"])
		cmd_admin_pm(href_list["priv_msg"],null)
		return

	switch(href_list["_src_"])
		if("holder")
			hsrc = holder
		if("usr")
			hsrc = mob
		if("prefs")
			if (inprefs)
				return
			inprefs = TRUE
			. = prefs.process_link(usr,href_list)
			inprefs = FALSE
			return
		if("vars")
			return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if("openLink")
			src << link(href_list["link"])
	if (hsrc)
		var/datum/real_src = hsrc
		if(QDELETED(real_src))
			return

	..() //redirect to hsrc.Topic()

/client/proc/is_content_unlocked()
	if(!prefs.unlock_content)
		to_chat(src, "Become a BYOND member to access member-perks and features, as well as support the engine that makes this game possible. Only 10 bucks for 3 months! <a href=\"https://secure.byond.com/membership\">Click Here to find out more</a>.")
		return FALSE
	return TRUE
/*
 * Call back proc that should be checked in all paths where a client can send messages
 *
 * Handles checking for duplicate messages and people sending messages too fast
 *
 * The first checks are if you're sending too fast, this is defined as sending
 * SPAM_TRIGGER_AUTOMUTE messages in
 * 5 seconds, this will start supressing your messages,
 * if you send 2* that limit, you also get muted
 *
 * The second checks for the same duplicate message too many times and mutes
 * you for it
 */
/client/proc/handle_spam_prevention(message, mute_type)

	//Increment message count
	total_message_count += 1

	//store the total to act on even after a reset
	var/cache = total_message_count

	if(total_count_reset <= world.time)
		total_message_count = 0
		total_count_reset = world.time + (5 SECONDS)

	//If they're really going crazy, mute them
	if(cache >= SPAM_TRIGGER_AUTOMUTE * 2)
		total_message_count = 0
		total_count_reset = 0
		cmd_admin_mute(src, mute_type, 1)
		return TRUE

	//Otherwise just supress the message
	else if(cache >= SPAM_TRIGGER_AUTOMUTE)
		return TRUE


	if(CONFIG_GET(flag/automute_on) && !holder && last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "<span class='danger'>You have exceeded the spam filter limit for identical messages. An auto-mute was applied.</span>")
			cmd_admin_mute(src, mute_type, 1)
			return TRUE
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "<span class='danger'>You are nearing the spam filter limit for identical messages.</span>")
			return FALSE
	else
		last_message = message
		src.last_message_count = 0
		return FALSE

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if (holder)
		if(filelength > UPLOAD_LIMIT_ADMIN)
			to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT_ADMIN/1024]KiB.</font>")
			return FALSE
	else if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return FALSE
	return TRUE


	///////////
	//CONNECT//
	///////////

/client/New(TopicData)
	var/tdata = TopicData //save this for later use
	TopicData = null //Prevent calls to client.Topic from connect

	if(connection != "seeker" && connection != "web")//Invalid connection type.
		return null

	GLOB.clients += src
	GLOB.directory[ckey] = src

	// Instantiate tgui panel
	tgui_panel = new(src)

	set_right_click_menu_mode(TRUE)

	GLOB.ahelp_tickets.ClientLogin(src)
	GLOB.interviews.client_login(src)
	var/connecting_admin = FALSE //because de-admined admins connecting should be treated like admins.
	//Admin Authorisation
	holder = GLOB.admin_datums[ckey]
	if(holder)
		GLOB.admins |= src
		holder.owner = src
		connecting_admin = TRUE
	else if(GLOB.deadmins[ckey])
		add_verb(src, /client/proc/readmin)
		connecting_admin = TRUE
	if(CONFIG_GET(flag/autoadmin))
		if(!GLOB.admin_datums[ckey])
			var/datum/admin_rank/autorank
			for(var/datum/admin_rank/R in GLOB.admin_ranks)
				if(R.name == CONFIG_GET(string/autoadmin_rank))
					autorank = R
					break
			if(!autorank)
				to_chat(world, "Autoadmin rank not found")
			else
				new /datum/admins(autorank, ckey)
	if(CONFIG_GET(flag/enable_localhost_rank) && !connecting_admin)
		var/localhost_addresses = list("127.0.0.1", "::1")
		if(isnull(address) || (address in localhost_addresses))
			var/datum/admin_rank/localhost_rank = new("!localhost!", R_EVERYTHING, R_DBRANKS, R_EVERYTHING) //+EVERYTHING -DBRANKS *EVERYTHING
			new /datum/admins(localhost_rank, ckey, 1, 1)
	//preferences datum - also holds some persistent data for the client (because we may as well keep these datums to a minimum)
	prefs = GLOB.preferences_datums[ckey]
	if(prefs)
		prefs.parent = src
	else
		prefs = new /datum/preferences(src)
		GLOB.preferences_datums[ckey] = prefs
	prefs.last_ip = address //these are gonna be used for banning
	prefs.last_id = computer_id //these are gonna be used for banning
	fps = (prefs.clientfps < 0) ? RECOMMENDED_FPS : prefs.clientfps

	if(fexists(roundend_report_file()))
		add_verb(src, /client/proc/show_previous_roundend_report)

	if(fexists("data/server_last_roundend_report.html"))
		add_verb(src, /client/proc/show_servers_last_roundend_report)

	var/full_version = "[byond_version].[byond_build ? byond_build : "xxx"]"
	log_access("Login: [key_name(src)] from [address ? address : "localhost"]-[computer_id] || BYOND v[full_version]")

	var/alert_mob_dupe_login = FALSE
	if(CONFIG_GET(flag/log_access))
		for(var/I in GLOB.clients)
			if(!I || I == src)
				continue
			var/client/C = I
			if(C.key && (C.key != key) )
				var/matches
				if( (C.address == address) )
					matches += "IP ([address])"
				if( (C.computer_id == computer_id) )
					if(matches)
						matches += " and "
					matches += "ID ([computer_id])"
					alert_mob_dupe_login = TRUE
				if(matches)
					if(C)
						message_admins("<span class='danger'><B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)].</span>")
						log_admin_private("Notice: [key_name(src)] has the same [matches] as [key_name(C)].")
					else
						message_admins("<span class='danger'><B>Notice: </B></span><span class='notice'>[key_name_admin(src)] has the same [matches] as [key_name_admin(C)] (no longer logged in). </span>")
						log_admin_private("Notice: [key_name(src)] has the same [matches] as [key_name(C)] (no longer logged in).")
	var/reconnecting = FALSE
	if(GLOB.player_details[ckey])
		reconnecting = TRUE
		player_details = GLOB.player_details[ckey]
		player_details.byond_version = full_version
	else
		player_details = new(ckey)
		player_details.byond_version = full_version
		GLOB.player_details[ckey] = player_details


	. = ..() //calls mob.Login()
	if (length(GLOB.stickybanadminexemptions))
		GLOB.stickybanadminexemptions -= ckey
		if (!length(GLOB.stickybanadminexemptions))
			restore_stickybans()

	if (byond_version >= 512)
		if (!byond_build || byond_build < 1386)
			message_admins("<span class='adminnotice'>[key_name(src)] has been detected as spoofing their byond version. Connection rejected.</span>")
			add_system_note("Spoofed-Byond-Version", "Detected as using a spoofed byond version.")
			log_access("Failed Login: [key] - Spoofed byond version")
			qdel(src)

		if (num2text(byond_build) in GLOB.blacklisted_builds)
			log_access("Failed login: [key] - blacklisted byond version")
			to_chat(src, "<span class='userdanger'>Your version of byond is blacklisted.</span>")
			to_chat(src, "<span class='danger'>Byond build [byond_build] ([byond_version].[byond_build]) has been blacklisted for the following reason: [GLOB.blacklisted_builds[num2text(byond_build)]].</span>")
			to_chat(src, "<span class='danger'>Please download a new version of byond. If [byond_build] is the latest, you can go to <a href=\"https://secure.byond.com/download/build\">BYOND's website</a> to download other versions.</span>")
			if(connecting_admin)
				to_chat(src, "As an admin, you are being allowed to continue using this version, but please consider changing byond versions")
			else
				qdel(src)
				return

	if(SSinput.initialized)
		set_macros()

	// Initialize tgui panel
	src << browse(file('html/statbrowser.html'), "window=statbrowser")
	addtimer(CALLBACK(src, .proc/check_panel_loaded), 30 SECONDS)
	tgui_panel.initialize()

	if(alert_mob_dupe_login)
		spawn()
			tgui_alert(mob, "You have logged in already with another key this round, please log out of this one NOW or risk being banned!")

	connection_time = world.time
	connection_realtime = world.realtime
	connection_timeofday = world.timeofday
	winset(src, null, "command=\".configure graphics-hwmode on\"")
	var/cev = CONFIG_GET(number/client_error_version)
	var/ceb = CONFIG_GET(number/client_error_build)
	var/cwv = CONFIG_GET(number/client_warn_version)
	if (byond_version < cev || (byond_version == cev && byond_build < ceb)) //Out of date client.
		to_chat(src, "<span class='danger'><b>Your version of BYOND is too old:</b></span>")
		to_chat(src, CONFIG_GET(string/client_error_message))
		to_chat(src, "Your version: [byond_version].[byond_build]")
		to_chat(src, "Required version: [cev].[ceb] or later")
		to_chat(src, "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.")
		if (connecting_admin)
			to_chat(src, "Because you are an admin, you are being allowed to walk past this limitation, But it is still STRONGLY suggested you upgrade")
		else
			qdel(src)
			return
	else if (byond_version < cwv) //We have words for this client.
		if(CONFIG_GET(flag/client_warn_popup))
			var/msg = "<b>Your version of byond may be getting out of date:</b><br>"
			msg += CONFIG_GET(string/client_warn_message) + "<br><br>"
			msg += "Your version: [byond_version]<br>"
			msg += "Required version to remove this message: [cwv] or later<br>"
			msg += "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.<br>"
			src << browse(msg, "window=warning_popup")
		else
			to_chat(src, "<span class='danger'><b>Your version of byond may be getting out of date:</b></span>")
			to_chat(src, CONFIG_GET(string/client_warn_message))
			to_chat(src, "Your version: [byond_version]")
			to_chat(src, "Required version to remove this message: [cwv] or later")
			to_chat(src, "Visit <a href=\"https://secure.byond.com/download\">BYOND's website</a> to get the latest version of BYOND.")

	if (connection == "web" && !connecting_admin)
		if (!CONFIG_GET(flag/allow_webclient))
			to_chat(src, "Web client is disabled")
			qdel(src)
			return
		if (CONFIG_GET(flag/webclient_only_byond_members) && !IsByondMember())
			to_chat(src, "Sorry, but the web client is restricted to byond members only.")
			qdel(src)
			return

	if( (world.address == address || !address) && !GLOB.host )
		GLOB.host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		to_chat(src, get_message_output("memo"))
		adminGreet()
	if (mob && reconnecting)
		var/stealth_admin = mob.client?.holder?.fakekey
		var/announce_leave = mob.client?.prefs?.broadcast_login_logout
		if (!stealth_admin)
			deadchat_broadcast(" has reconnected.", "<b>[mob][mob.get_realname_string()]</b>", follow_target = mob, turf_target = get_turf(mob), message_type = DEADCHAT_LOGIN_LOGOUT, admin_only=!announce_leave)
	add_verbs_from_config()
	var/cached_player_age = set_client_age_from_db(tdata) //we have to cache this because other shit may change it and we need it's current value now down below.
	if (isnum(cached_player_age) && cached_player_age == -1) //first connection
		player_age = 0
	var/nnpa = CONFIG_GET(number/notify_new_player_age)
	if (isnum(cached_player_age) && cached_player_age == -1) //first connection
		if (nnpa >= 0)
			message_admins("New user: [key_name_admin(src)] is connecting here for the first time.")
			if (CONFIG_GET(flag/irc_first_connection_alert))
				send2tgs_adminless_only("New-user", "[key_name(src)] is connecting for the first time!")
	else if (isnum(cached_player_age) && cached_player_age < nnpa)
		message_admins("New user: [key_name_admin(src)] just connected with an age of [cached_player_age] day[(player_age==1?"":"s")]")
	if(CONFIG_GET(flag/use_account_age_for_jobs) && account_age >= 0)
		player_age = account_age
	if(account_age >= 0 && account_age < nnpa)
		message_admins("[key_name_admin(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
		if (CONFIG_GET(flag/irc_first_connection_alert))
			send2tgs_adminless_only("new_byond_user", "[key_name(src)] (IP: [address], ID: [computer_id]) is a new BYOND account [account_age] day[(account_age==1?"":"s")] old, created on [account_join_date].")
	get_message_output("watchlist entry", ckey)
	check_ip_intel()
	validate_key_in_db()

	send_resources()

	generate_clickcatcher()
	apply_clickcatcher()

	if(prefs.lastchangelog != GLOB.changelog_hash) //bolds the changelog button on the interface so we know there are updates.
		to_chat(src, "<span class='info'>You have unread updates in the changelog.</span>")
		if(CONFIG_GET(flag/aggressive_changelog))
			changelog()
		else
			winset(src, "infowindow.changelog", "font-style=bold")

	if(ckey in GLOB.clientmessages)
		for(var/message in GLOB.clientmessages[ckey])
			to_chat(src, message)
		GLOB.clientmessages.Remove(ckey)

	if(CONFIG_GET(flag/autoconvert_notes))
		convert_notes_sql(ckey)
	to_chat(src, get_message_output("message", ckey))
	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")

	update_ambience_pref()

	//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	if (!interviewee)
		initialize_menus()

	view_size = new(src, getScreenSize(prefs.widescreenpref))
	view_size.resetFormat()
	view_size.setZoomMode()
	fit_viewport()
	Master.UpdateTickRate()

//////////////
//DISCONNECT//
//////////////

/client/Del()
	if(!gc_destroyed)
		Destroy() //Clean up signals and timers.
	return ..()

/client/Destroy()
	if(mob)
		var/stealth_admin = mob.client?.holder?.fakekey
		var/announce_join = mob.client?.prefs?.broadcast_login_logout
		if (!stealth_admin)
			deadchat_broadcast(" has disconnected.", "<b>[mob][mob.get_realname_string()]</b>", follow_target = mob, turf_target = get_turf(mob), message_type = DEADCHAT_LOGIN_LOGOUT, admin_only=!announce_join)

	GLOB.clients -= src
	GLOB.directory -= ckey
	log_access("Logout: [key_name(src)]")
	GLOB.ahelp_tickets.ClientLogout(src)
	GLOB.interviews.client_logout(src)
	SSserver_maint.UpdateHubStatus()
	if(credits)
		QDEL_LIST(credits)
	if(holder)
		adminGreet(1)
		holder.owner = null
		GLOB.admins -= src
		if (!GLOB.admins.len && SSticker.IsRoundInProgress()) //Only report this stuff if we are currently playing.
			var/cheesy_message = pick(
				"I have no admins online!",\
				"I'm all alone :(",\
				"I'm feeling lonely :(",\
				"I'm so lonely :(",\
				"Why does nobody love me? :(",\
				"I want a man :(",\
				"Where has everyone gone?",\
				"I need a hug :(",\
				"Someone come hold me :(",\
				"I need someone on me :(",\
				"What happened? Where has everyone gone?",\
				"Forever alone :("\
			)

			send2adminchat("Server", "[cheesy_message] (No admins online)")
	QDEL_LIST_ASSOC_VAL(char_render_holders)
	if(movingmob != null)
		movingmob.client_mobs_in_contents -= mob
		UNSETEMPTY(movingmob.client_mobs_in_contents)
		movingmob = null
	active_mousedown_item = null
	SSambience.ambience_listening_clients -= src
	QDEL_NULL(view_size)
	QDEL_NULL(void)
	QDEL_NULL(tooltips)
	seen_messages = null
	Master.UpdateTickRate()
	..() //Even though we're going to be hard deleted there are still some things that want to know the destroy is happening
	return QDEL_HINT_HARDDEL_NOW

/client/proc/set_client_age_from_db(connectiontopic)
	if (IsGuestKey(src.key))
		return
	if(!SSdbcore.Connect())
		return
	var/datum/db_query/query_get_related_ip = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE ip = INET_ATON(:address) AND ckey != :ckey",
		list("address" = address, "ckey" = ckey)
	)
	if(!query_get_related_ip.Execute())
		qdel(query_get_related_ip)
		return
	related_accounts_ip = ""
	while(query_get_related_ip.NextRow())
		related_accounts_ip += "[query_get_related_ip.item[1]], "
	qdel(query_get_related_ip)
	var/datum/db_query/query_get_related_cid = SSdbcore.NewQuery(
		"SELECT ckey FROM [format_table_name("player")] WHERE computerid = :computerid AND ckey != :ckey",
		list("computerid" = computer_id, "ckey" = ckey)
	)
	if(!query_get_related_cid.Execute())
		qdel(query_get_related_cid)
		return
	related_accounts_cid = ""
	while (query_get_related_cid.NextRow())
		related_accounts_cid += "[query_get_related_cid.item[1]], "
	qdel(query_get_related_cid)
	var/admin_rank = "Player"
	if (src.holder && src.holder.rank)
		admin_rank = src.holder.rank.name
	else
		if (!GLOB.deadmins[ckey] && check_randomizer(connectiontopic))
			return
	var/new_player
	var/datum/db_query/query_client_in_db = SSdbcore.NewQuery(
		"SELECT 1 FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_client_in_db.Execute())
		qdel(query_client_in_db)
		return

	//If we aren't an admin, and the flag is set
	if(CONFIG_GET(flag/panic_bunker) && !holder && !GLOB.deadmins[ckey])
		var/living_recs = CONFIG_GET(number/panic_bunker_living)
		//Relies on pref existing, but this proc is only called after that occurs, so we're fine.
		var/minutes = get_exp_living(pure_numeric = TRUE)
		if(minutes <= living_recs && !CONFIG_GET(flag/panic_bunker_interview))
			var/reject_message = "Failed Login: [key] - Account attempting to connect during panic bunker, but they do not have the required living time [minutes]/[living_recs]"
			log_access(reject_message)
			message_admins("<span class='adminnotice'>[reject_message]</span>")
			var/message = CONFIG_GET(string/panic_bunker_message)
			message = replacetext(message, "%minutes%", living_recs)
			to_chat(src, message)
			var/list/connectiontopic_a = params2list(connectiontopic)
			var/list/panic_addr = CONFIG_GET(string/panic_server_address)
			if(panic_addr && !connectiontopic_a["redirect"])
				var/panic_name = CONFIG_GET(string/panic_server_name)
				to_chat(src, "<span class='notice'>Sending you to [panic_name ? panic_name : panic_addr].</span>")
				winset(src, null, "command=.options")
				src << link("[panic_addr]?redirect=1")
			qdel(query_client_in_db)
			qdel(src)
			return

	if(!query_client_in_db.NextRow())
		new_player = 1
		account_join_date = findJoinDate()
		var/datum/db_query/query_add_player = SSdbcore.NewQuery({"
			INSERT INTO [format_table_name("player")] (`ckey`, `byond_key`, `firstseen`, `firstseen_round_id`, `lastseen`, `lastseen_round_id`, `ip`, `computerid`, `lastadminrank`, `accountjoindate`)
			VALUES (:ckey, :key, Now(), :round_id, Now(), :round_id, INET_ATON(:ip), :computerid, :adminrank, :account_join_date)
		"}, list("ckey" = ckey, "key" = key, "round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "adminrank" = admin_rank, "account_join_date" = account_join_date || null))
		if(!query_add_player.Execute())
			qdel(query_client_in_db)
			qdel(query_add_player)
			return
		qdel(query_add_player)
		if(!account_join_date)
			account_join_date = "Error"
			account_age = -1
	qdel(query_client_in_db)
	var/datum/db_query/query_get_client_age = SSdbcore.NewQuery(
		"SELECT firstseen, DATEDIFF(Now(),firstseen), accountjoindate, DATEDIFF(Now(),accountjoindate) FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_get_client_age.Execute())
		qdel(query_get_client_age)
		return
	if(query_get_client_age.NextRow())
		player_join_date = query_get_client_age.item[1]
		player_age = text2num(query_get_client_age.item[2])
		if(!account_join_date)
			account_join_date = query_get_client_age.item[3]
			account_age = text2num(query_get_client_age.item[4])
			if(!account_age)
				account_join_date = findJoinDate()
				if(!account_join_date)
					account_age = -1
				else
					var/datum/db_query/query_datediff = SSdbcore.NewQuery(
						"SELECT DATEDIFF(Now(), :account_join_date)",
						list("account_join_date" = account_join_date)
					)
					if(!query_datediff.Execute())
						qdel(query_datediff)
						qdel(query_get_client_age)
						return
					if(query_datediff.NextRow())
						account_age = text2num(query_datediff.item[1])
					qdel(query_datediff)
	qdel(query_get_client_age)
	if(!new_player)
		var/datum/db_query/query_log_player = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET lastseen = Now(), lastseen_round_id = :round_id, ip = INET_ATON(:ip), computerid = :computerid, lastadminrank = :admin_rank, accountjoindate = :account_join_date WHERE ckey = :ckey",
			list("round_id" = GLOB.round_id, "ip" = address, "computerid" = computer_id, "admin_rank" = admin_rank, "account_join_date" = account_join_date || null, "ckey" = ckey)
		)
		if(!query_log_player.Execute())
			qdel(query_log_player)
			return
		qdel(query_log_player)
	if(!account_join_date)
		account_join_date = "Error"
	var/datum/db_query/query_log_connection = SSdbcore.NewQuery({"
		INSERT INTO `[format_table_name("connection_log")]` (`id`,`datetime`,`server_ip`,`server_port`,`round_id`,`ckey`,`ip`,`computerid`)
		VALUES(null,Now(),INET_ATON(:internet_address),:port,:round_id,:ckey,INET_ATON(:ip),:computerid)
	"}, list("internet_address" = world.internet_address || "0", "port" = world.port, "round_id" = GLOB.round_id, "ckey" = ckey, "ip" = address, "computerid" = computer_id))
	query_log_connection.Execute()
	qdel(query_log_connection)

	SSserver_maint.UpdateHubStatus()

	if(new_player)
		player_age = -1
	. = player_age

/client/proc/findJoinDate()
	var/list/http = world.Export("http://byond.com/members/[ckey]?format=text")
	if(!http)
		log_world("Failed to connect to byond member page to age check [ckey]")
		return
	var/F = file2text(http["CONTENT"])
	if(F)
		var/regex/R = regex("joined = \"(\\d{4}-\\d{2}-\\d{2})\"")
		if(R.Find(F))
			. = R.group[1]
		else
			CRASH("Age check regex failed for [src.ckey]")

/client/proc/validate_key_in_db()
	var/sql_key
	var/datum/db_query/query_check_byond_key = SSdbcore.NewQuery(
		"SELECT byond_key FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	if(!query_check_byond_key.Execute())
		qdel(query_check_byond_key)
		return
	if(query_check_byond_key.NextRow())
		sql_key = query_check_byond_key.item[1]
	qdel(query_check_byond_key)
	if(key != sql_key)
		var/list/http = world.Export("http://byond.com/members/[ckey]?format=text")
		if(!http)
			log_world("Failed to connect to byond member page to get changed key for [ckey]")
			return
		var/F = file2text(http["CONTENT"])
		if(F)
			var/regex/R = regex("\\tkey = \"(.+)\"")
			if(R.Find(F))
				var/web_key = R.group[1]
				var/datum/db_query/query_update_byond_key = SSdbcore.NewQuery(
					"UPDATE [format_table_name("player")] SET byond_key = :byond_key WHERE ckey = :ckey",
					list("byond_key" = web_key, "ckey" = ckey)
				)
				query_update_byond_key.Execute()
				qdel(query_update_byond_key)
			else
				CRASH("Key check regex failed for [ckey]")

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	if (!CONFIG_GET(flag/check_randomizer))
		return
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()
	var/datum/db_query/query_cidcheck = SSdbcore.NewQuery(
		"SELECT computerid FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	query_cidcheck.Execute()

	var/lastcid
	if (query_cidcheck.NextRow())
		lastcid = query_cidcheck.item[1]
	qdel(query_cidcheck)
	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] appears to have attempted to spoof a cid randomizer check.</span>")
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(15 SECONDS) //Longer sleep here since this would trigger if a client tries to reconnect manually because the inital reconnect failed

			//we sleep after telling the client to reconnect, so if we still exist something is up
			log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

			qdel(src)
			return TRUE

		if (oldcid != computer_id && computer_id != lastcid) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat(src, "<span class='userdanger'>Connection Error:</span>")
			to_chat(src, "<span class='danger'>Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again.</span>")

			if (!cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a cid randomizer. Connection rejected.</span>")
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been detected as using a cid randomizer. Connection rejected.")
				cidcheck_failedckeys[ckey] = TRUE
				note_randomizer_user()

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			qdel(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer</span>")
				send2tgs_adminless_only("CidRandomizer", "[key_name(src)] has been allowed to connect after showing they removed their cid randomizer.")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time</span>")
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else if (computer_id != lastcid)
		cidcheck[ckey] = computer_id
		tokens[ckey] = cid_check_reconnect()

		sleep(5 SECONDS) //browse is queued, we don't want them to disconnect before getting the browse() command.

		//we sleep after telling the client to reconnect, so if we still exist something is up
		log_access("Forced disconnect: [key] [computer_id] [address] - CID randomizer check")

		qdel(src)
		return TRUE

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse({"<a id='link' href="byond://[url]?token=[token]">byond://[url]?token=[token]</a><script type="text/javascript">document.getElementById("link").click();window.location="byond://winset?command=.quit"</script>"}, "border=0;titlebar=0;size=1x1;window=redirect")
	to_chat(src, {"<a href="byond://[url]?token=[token]">You will be automatically taken to the game, if not, click here to be taken manually</a>"})

/client/proc/note_randomizer_user()
	add_system_note("CID-Error", "Detected as using a cid randomizer.")

/client/proc/add_system_note(system_ckey, message)
	//check to see if we noted them in the last day.
	var/datum/db_query/query_get_notes = SSdbcore.NewQuery(
		"SELECT id FROM [format_table_name("messages")] WHERE type = 'note' AND targetckey = :targetckey AND adminckey = :adminckey AND timestamp + INTERVAL 1 DAY < NOW() AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL)",
		list("targetckey" = ckey, "adminckey" = system_ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		qdel(query_get_notes)
		return
	qdel(query_get_notes)
	//regardless of above, make sure their last note is not from us, as no point in repeating the same note over and over.
	query_get_notes = SSdbcore.NewQuery(
		"SELECT adminckey FROM [format_table_name("messages")] WHERE targetckey = :targetckey AND deleted = 0 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) ORDER BY timestamp DESC LIMIT 1",
		list("targetckey" = ckey)
	)
	if(!query_get_notes.Execute())
		qdel(query_get_notes)
		return
	if(query_get_notes.NextRow())
		if (query_get_notes.item[1] == system_ckey)
			qdel(query_get_notes)
			return
	qdel(query_get_notes)
	create_message("note", key, system_ckey, message, null, null, 0, 0, null, 0, 0)


/client/proc/check_ip_intel()
	set waitfor = 0 //we sleep when getting the intel, no need to hold up the client connection while we sleep
	if (CONFIG_GET(string/ipintel_email))
		var/datum/ipintel/res = get_ip_intel(address)
		if (res.intel >= CONFIG_GET(number/ipintel_rating_bad))
			message_admins("<span class='adminnotice'>Proxy Detection: [key_name_admin(src)] IP intel rated [res.intel*100]% likely to be a Proxy/VPN.</span>")
		ip_intel = res.intel

/client/Click(atom/object, atom/location, control, params)
	if(click_intercept_time)
		if(click_intercept_time >= world.time)
			click_intercept_time = 0 //Reset and return. Next click should work, but not this one.
			return
		click_intercept_time = 0 //Just reset. Let's not keep re-checking forever.
	var/ab = FALSE
	var/list/modifiers = params2list(params)

	var/dragged = LAZYACCESS(modifiers, DRAG)
	if(dragged && !LAZYACCESS(modifiers, dragged)) //I don't know what's going on here, but I don't trust it
		return

	if (object && object == middragatom && LAZYACCESS(modifiers, LEFT_CLICK))
		ab = max(0, 5 SECONDS-(world.time-middragtime)*0.1)

	var/mcl = CONFIG_GET(number/minute_click_limit)
	if (!holder && mcl)
		var/minute = round(world.time, 600)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (minute != clicklimiter[CURRENT_MINUTE])
			clicklimiter[CURRENT_MINUTE] = minute
			clicklimiter[MINUTE_COUNT] = 0
		clicklimiter[MINUTE_COUNT] += 1+(ab)
		if (clicklimiter[MINUTE_COUNT] > mcl)
			var/msg = "Your previous click was ignored because you've done too many in a minute."
			if (minute != clicklimiter[ADMINSWARNED_AT]) //only one admin message per-minute. (if they spam the admins can just boot/ban them)
				clicklimiter[ADMINSWARNED_AT] = minute

				msg += " Administrators have been informed."
				if (ab)
					log_game("[key_name(src)] is using the middle click aimbot exploit")
					message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] is using the middle click aimbot exploit</span>")
					add_system_note("aimbot", "Is using the middle click aimbot exploit")
				log_game("[key_name(src)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
				message_admins("[ADMIN_LOOKUPFLW(usr)] [ADMIN_KICK(usr)] Has hit the per-minute click limit of [mcl] clicks in a given game minute")
			to_chat(src, "<span class='danger'>[msg]</span>")
			return

	var/scl = CONFIG_GET(number/second_click_limit)
	if (!holder && scl)
		var/second = round(world.time, 10)
		if (!clicklimiter)
			clicklimiter = new(LIMITER_SIZE)
		if (second != clicklimiter[CURRENT_SECOND])
			clicklimiter[CURRENT_SECOND] = second
			clicklimiter[SECOND_COUNT] = 0
		clicklimiter[SECOND_COUNT] += 1+(!!ab)
		if (clicklimiter[SECOND_COUNT] > scl)
			to_chat(src, "<span class='danger'>Your previous click was ignored because you've done too many in a second</span>")
			return

	if (prefs.hotkeys)
		// If hotkey mode is enabled, then clicking the map will automatically
		// unfocus the text bar. This removes the red color from the text bar
		// so that the visual focus indicator matches reality.
		winset(src, null, "input.background-color=[COLOR_INPUT_DISABLED]")

	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")

	..()

/client/proc/add_verbs_from_config()
	if (interviewee)
		return
	if(CONFIG_GET(flag/see_own_notes))
		add_verb(src, /client/proc/self_notes)
	if(CONFIG_GET(flag/use_exp_tracking))
		add_verb(src, /client/proc/self_playtime)


#undef UPLOAD_LIMIT

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = CONFIG_GET(number/inactivity_period))
	if(inactivity > duration)
		return inactivity
	return FALSE

/// Send resources to the client.
/// Sends both game resources and browser assets.
/client/proc/send_resources()
#if (PRELOAD_RSC == 0)
	var/static/next_external_rsc = 0
	var/list/external_rsc_urls = CONFIG_GET(keyed_list/external_rsc_urls)
	if(length(external_rsc_urls))
		next_external_rsc = WRAP(next_external_rsc+1, 1, external_rsc_urls.len+1)
		preload_rsc = external_rsc_urls[next_external_rsc]
#endif

	spawn (10) //removing this spawn causes all clients to not get verbs.

		//load info on what assets the client has
		src << browse('code/modules/asset_cache/validate_assets.html', "window=asset_cache_browser")

		//Precache the client with all other assets slowly, so as to not block other browse() calls
		if (CONFIG_GET(flag/asset_simple_preload))
			addtimer(CALLBACK(SSassets.transport, /datum/asset_transport.proc/send_assets_slow, src, SSassets.transport.preload), 5 SECONDS)

		#if (PRELOAD_RSC == 0)
		for (var/name in GLOB.vox_sounds)
			var/file = GLOB.vox_sounds[name]
			Export("##action=load_rsc", file)
			stoplag()
		#endif


//Hook, override it to run code when dir changes
//Like for /atoms, but clients are their own snowflake FUCK
/client/proc/setDir(newdir)
	dir = newdir

/client/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, holder))
			return FALSE
		if (NAMEOF(src, ckey))
			return FALSE
		if (NAMEOF(src, key))
			return FALSE
		if(NAMEOF(src, view))
			view_size.setDefault(var_value)
			return TRUE
	. = ..()

/client/proc/rescale_view(change, min, max)
	view_size.setTo(clamp(change, min, max), clamp(change, min, max))

/**
 * Updates the keybinds for special keys
 *
 * Handles adding macros for the keys that need it
 * And adding movement keys to the clients movement_keys list
 * At the time of writing this, communication(OOC, Say, IC) require macros
 * Arguments:
 * * direct_prefs - the preference we're going to get keybinds from
 */
/client/proc/update_special_keybinds(datum/preferences/direct_prefs)
	var/datum/preferences/D = prefs || direct_prefs
	if(!D?.key_bindings)
		return
	movement_keys = list()
	for(var/key in D.key_bindings)
		for(var/kb_name in D.key_bindings[key])
			switch(kb_name)
				if("North")
					movement_keys[key] = NORTH
				if("East")
					movement_keys[key] = EAST
				if("West")
					movement_keys[key] = WEST
				if("South")
					movement_keys[key] = SOUTH
				if("Say")
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=say")
				if("OOC")
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=ooc")
				if("Me")
					winset(src, "default-[REF(key)]", "parent=default;name=[key];command=me")

/client/proc/change_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	mob.hud_used.screentip_text.update_view()
	apply_clickcatcher()
	mob.reload_fullscreen()
	if (isliving(mob))
		var/mob/living/M = mob
		M.update_damage_hud()
	if (prefs.auto_fit_viewport)
		addtimer(CALLBACK(src,.verb/fit_viewport,10)) //Delayed to avoid wingets from Login calls.

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

/client/proc/apply_clickcatcher()
	generate_clickcatcher()
	var/list/actualview = getviewsize(view)
	void.UpdateGreed(actualview[1],actualview[2])

/client/proc/AnnouncePR(announcement)
	if(prefs && prefs.chat_toggles & CHAT_PULLR)
		to_chat(src, announcement)

/client/proc/show_character_previews(mutable_appearance/MA)
	var/pos = 0
	for(var/D in GLOB.cardinals)
		pos++
		var/atom/movable/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.dir = D
		O.screen_loc = "character_preview_map:0,[pos]"

/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/atom/movable/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null

///Redirect proc that makes it easier to call the unlock achievement proc. Achievement type is the typepath to the award, user is the mob getting the award, and value is an optional variable used for leaderboard value increments
/client/proc/give_award(achievement_type, mob/user, value = 1)
	return player_details.achievements.unlock(achievement_type, user, value)

///Redirect proc that makes it easier to get the status of an achievement. Achievement type is the typepath to the award.
/client/proc/get_award_status(achievement_type, mob/user, value = 1)
	return player_details.achievements.get_achievement_status(achievement_type)

///Gives someone hearted status for OOC, from behavior commendations
/client/proc/adjust_heart(duration = 24 HOURS)
	var/new_duration = world.realtime + duration
	if(prefs.hearted_until > new_duration)
		return
	to_chat(src, "<span class='nicegreen'>Someone awarded you a heart!</span>")
	prefs.hearted_until = new_duration
	prefs.hearted = TRUE
	prefs.save_preferences()

/// compiles a full list of verbs and sends it to the browser
/client/proc/init_verbs()
	if(IsAdminAdvancedProcCall())
		return
	var/list/verblist = list()
	var/list/verbstoprocess = verbs.Copy()
	if(mob)
		verbstoprocess += mob.verbs
		for(var/AM in mob.contents)
			var/atom/movable/thing = AM
			verbstoprocess += thing.verbs
	panel_tabs.Cut() // panel_tabs get reset in init_verbs on JS side anyway
	for(var/thing in verbstoprocess)
		var/procpath/verb_to_init = thing
		if(!verb_to_init)
			continue
		if(verb_to_init.hidden)
			continue
		if(!istext(verb_to_init.category))
			continue
		panel_tabs |= verb_to_init.category
		verblist[++verblist.len] = list(verb_to_init.category, verb_to_init.name)
	src << output("[url_encode(json_encode(panel_tabs))];[url_encode(json_encode(verblist))]", "statbrowser:init_verbs")

/client/proc/check_panel_loaded()
	if(statbrowser_ready)
		return
	to_chat(src, "<span class='userdanger'>Statpanel failed to load, click <a href='?src=[REF(src)];reload_statbrowser=1'>here</a> to reload the panel </span>")

/**
 * Initializes dropdown menus on client
 */
/client/proc/initialize_menus()
	var/list/topmenus = GLOB.menulist[/datum/verbs/menu]
	for (var/thing in topmenus)
		var/datum/verbs/menu/topmenu = thing
		var/topmenuname = "[topmenu]"
		if (topmenuname == "[topmenu.type]")
			var/list/tree = splittext(topmenuname, "/")
			topmenuname = tree[tree.len]
		winset(src, "[topmenu.type]", "parent=menu;name=[url_encode(topmenuname)]")
		var/list/entries = topmenu.Generate_list(src)
		for (var/child in entries)
			winset(src, "[child]", "[entries[child]]")
			if (!ispath(child, /datum/verbs/menu))
				var/procpath/verbpath = child
				if (verbpath.name[1] != "@")
					new child(src)

	for (var/thing in prefs.menuoptions)
		var/datum/verbs/menu/menuitem = GLOB.menulist[thing]
		if (menuitem)
			menuitem.Load_checked(src)

/client/proc/open_filter_editor(atom/in_atom)
	if(holder)
		holder.filteriffic = new /datum/filter_editor(in_atom)
		holder.filteriffic.ui_interact(mob)


/client/proc/set_right_click_menu_mode(shift_only)
	if(shift_only)
		winset(src, "mapwindow.map", "right-click=true")
		winset(src, "ShiftUp", "is-disabled=false")
		winset(src, "Shift", "is-disabled=false")
	else
		winset(src, "mapwindow.map", "right-click=false")
		winset(src, "default.Shift", "is-disabled=true")
		winset(src, "default.ShiftUp", "is-disabled=true")

/client/proc/update_ambience_pref()
	if(prefs.toggles & SOUND_AMBIENCE)
		if(SSambience.ambience_listening_clients[src] > world.time)
			return // If already properly set we don't want to reset the timer.
		SSambience.ambience_listening_clients[src] = world.time + 10 SECONDS //Just wait 10 seconds before the next one aight mate? cheers.
	else
		SSambience.ambience_listening_clients -= src

/// Checks if this client has met the days requirement passed in, or if
/// they are exempt from it.
/// Returns the number of days left, or 0.
/client/proc/get_remaining_days(days_needed)
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return 0

	if(!isnum(player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced

	if(!isnum(days_needed))
		return 0

	return max(0, days_needed - player_age)
