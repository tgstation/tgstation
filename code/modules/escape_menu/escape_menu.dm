GLOBAL_VAR(escape_menu_suicide_icon_base64)

/proc/generate_escape_menu_suicide_icon()
	set waitfor = FALSE
	if(!isnull(GLOB.escape_menu_suicide_icon_base64))
		return
	GLOB.escape_menu_suicide_icon_base64 = ""
	UNTIL(MC_RUNNING(SSatoms.init_stage))
	var/mob/living/carbon/human/consistent/clown = new
	clown.equipOutfit(/datum/outfit/job/clown)
	var/icon/clown_icon = getFlatIcon(clown)
	clown_icon.Turn(90)
	qdel(clown)
	GLOB.escape_menu_suicide_icon_base64 = icon2base64(clown_icon)
	for(var/datum/escape_menu/menu as anything in GLOB.escape_menus)
		menu.send_update(list("suicideIcon" = GLOB.escape_menu_suicide_icon_base64))

GLOBAL_LIST_EMPTY(escape_menus)

/client/var/datum/escape_menu/escape_menu

/client/proc/initialize_escape_menu()
	set waitfor = FALSE
	sleep(3 SECONDS)
	generate_escape_menu_suicide_icon()
	escape_menu = new(src)

GAME_VERB_HIDDEN(/client, reset_held_keys_verb, "Reset Held Keys")
	reset_held_keys()

/datum/escape_menu
	var/client/client
	var/datum/tgui_window/window

	/// If we've already notified the user that their BYOND version is not cool with transparent browsers
	var/version_warned

/datum/escape_menu/New(client/client)
	src.client = client
	window = new(client, "escape_menu")
	window.is_browser = TRUE
	window.initialize(
		strict_mode = TRUE,
		inline_css = file("tgui/public/tgui-escape-menu.bundle.css"),
		inline_js = file("tgui/public/tgui-escape-menu.bundle.js"),
	)
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/escape_menu_font))
	window.send_asset(get_asset_datum(/datum/asset/simple/namespaced/escape_menu_sounds))
	window.send_asset(get_asset_datum(/datum/asset/spritesheet/escape_menu_icons))
	window.subscribe(src, PROC_REF(on_message))

	RegisterSignal(client, COMSIG_QDELETING, PROC_REF(on_client_qdel))
	RegisterSignal(client, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(on_client_mob_login))
	RegisterSignals(client, list(COMSIG_CLIENT_VERB_ADDED, COMSIG_CLIENT_VERB_REMOVED), PROC_REF(on_verb_change))
	RegisterSignal(SSdcs, COMSIG_GLOB_STATION_NAME_CHANGED, PROC_REF(on_station_name_changed))
	RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(on_round_start))

	GLOB.escape_menus += src
	send_init()

/datum/escape_menu/Destroy(force)
	GLOB.escape_menus -= src
	STOP_PROCESSING(SSescape_menu, src)
	window?.unsubscribe(src)
	window = null
	client = null
	return ..()

// BANDASTATION EDIT START: Manual send update
/datum/escape_menu/process(seconds_per_tick)
	var/list/data = list(
		"serverTime" = current_server_time(),
		"shiftTime" = (SSticker.round_start_time == 0) ? "Pre-Game" : round_timestamp(),
		"timeDilation" = "[round(SStime_track.time_dilation_current, 1)]",
		"admins" = build_admin_list(),
		"players" = build_player_list(),
		"ignoredOffline" = build_ignored_offline(),
	)
	data += build_ticket_state()
	send_update(data)
// BANDASTATION EDIT END: Manual send update

/datum/escape_menu/proc/on_client_qdel()
	SIGNAL_HANDLER
	qdel(src)

/datum/escape_menu/proc/on_client_mob_login()
	SIGNAL_HANDLER
	send_update(list(
		"canLeaveBody" = isliving(client?.mob),
	))

/datum/escape_menu/proc/on_verb_change(client/source, list/verbs_changed)
	SIGNAL_HANDLER
	if(/client/verb/adminhelp in verbs_changed)
		send_update(build_ticket_state()) // BANDASTATION EDIT: Manual send update

/datum/escape_menu/proc/on_station_name_changed()
	SIGNAL_HANDLER
	send_update(list(
		"stationName" = station_name(),
	))

/datum/escape_menu/proc/on_round_start()
	SIGNAL_HANDLER
	send_update(list(
		"shiftTime" = round_timestamp(),
		"timeDilation" = "[round(SStime_track.time_dilation_current, 1)]",
	))

// BANDASTATION EDIT START: Escape menu

/datum/escape_menu/proc/current_server_time()
	return server_timestamp(format = "hh:mm:ss", ic_time = TRUE, twelve_hour_clock = client?.prefs?.read_preference(/datum/preference/toggle/twelve_hour)) // BANDASTATION EDIT - preserve old ESC menu time display

/datum/escape_menu/proc/get_current_help_ticket()
	return client?.persistent_client?.current_help_ticket // Ticket manager replaces client.current_ticket

/datum/escape_menu/proc/can_open_admin_ticket()
	return (/client/verb/adminhelp in client?.verbs) || !isnull(get_current_help_ticket()) // Ticket manager opens existing tickets through adminhelp()

/datum/escape_menu/proc/build_ticket_state()
	var/datum/help_ticket/current_help_ticket = get_current_help_ticket()
	return list(
		"canAdminHelp" = can_open_admin_ticket(),
		"hasTicketNotification" = !isnull(current_help_ticket) && current_help_ticket.admin_replied,
	)

/datum/escape_menu/proc/open_admin_ticket()
	if(!can_open_admin_ticket())
		return
	client?.adminhelp()

// BANDASTATION EDIT END: Escape menu

/datum/escape_menu/proc/send_init()
	var/list/resources = list()

	var/githuburl = CONFIG_GET(string/githuburl)
	if(githuburl)
		resources += list(list("id" = "bug", "label" = "Report Bug", "tooltip" = "Report a bug/issue"))
		resources += list(list("id" = "github", "label" = "Github", "tooltip" = "Open the repository for the game"))

	var/forumurl = CONFIG_GET(string/forumurl)
	if(forumurl)
		resources += list(list("id" = "forums", "label" = "Forums", "tooltip" = "Visit the server's forums"))

	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		resources += list(list("id" = "rules", "label" = "Rules", "tooltip" = "View the server rules"))

	var/wikiurl = CONFIG_GET(string/wikiurl)
	if(wikiurl)
		resources += list(list("id" = "wiki", "label" = "Wiki", "tooltip" = "See the wiki for the game"))

	var/configurl = CONFIG_GET(string/configurl)
	if(configurl)
		resources += list(list("id" = "config", "label" = "Config", "tooltip" = "View the server configuration files"))

	resources += list(list("id" = "changelog", "label" = "Change Log", "tooltip" = "See all changes to the server"))

	var/list/data = list( // BANDASTATION EDIT: Escape menu
		"stationName" = station_name(),
		"roundId" = GLOB.round_id || "Unset",
		"serverTime" = current_server_time(), // BANDASTATION EDIT: Escape menu
		"shiftTime" = (SSticker.round_start_time == 0) ? "Pre-Game" : round_timestamp(),
		"timeDilation" = "[round(SStime_track.time_dilation_current, 1)]",
		"mapName" = SSmapping.current_map?.map_name || "Loading...",
		"mapFeedbackLink" = SSmapping.current_map?.feedback_link,
		"mapWebmap" = SSmapping.current_map?.mapping_url,
		"canLeaveBody" = isliving(client?.mob),
		"canSeeNotes" = CONFIG_GET(flag/see_own_notes),
		"admins" = build_admin_list(),
		"players" = build_player_list(),
		"ignoredOffline" = build_ignored_offline(),
		"resources" = resources,
		"suicideIcon" = GLOB.escape_menu_suicide_icon_base64,
	)
	// BANDASTATION EDIT START: Escape menu
	data += build_ticket_state()
	window.send_message("init", data)
	// BANDASTATION EDIT END: Escape menu

/datum/escape_menu/proc/build_admin_list()
	var/list/result = list()
	for(var/client/admin as anything in GLOB.admins)
		result += list(list(
			"ckey" = admin.ckey,
			"displayName" = admin.holder?.fakekey || admin.ckey,
			"rank" = admin.holder?.rank_names(),
			"feedbackLink" = admin.holder?.feedback_link(),
			"ping" = round(admin.avgping, 1),
			"ignored" = (admin.ckey in client?.prefs?.ignoring),
			"isSelf" = (admin.ckey == client?.ckey),
		))
	return result

/datum/escape_menu/proc/build_player_list()
	var/list/result = list()
	for(var/client/player as anything in GLOB.clients - GLOB.admins)
		result += list(list(
			"ckey" = player.ckey,
			"displayName" = player.ckey,
			"ping" = round(player.avgping, 1),
			"ignored" = (player.ckey in client?.prefs?.ignoring),
			"isSelf" = (player.ckey == client?.ckey),
		))
	return result

/datum/escape_menu/proc/build_ignored_offline()
	var/list/result = list()
	if(client?.prefs?.ignoring)
		for(var/ignored_key in client.prefs.ignoring)
			if(!(ignored_key in GLOB.directory))
				result += ignored_key
	return result

/datum/escape_menu/proc/send_update(list/data)
	window.send_message("state", data)

/datum/escape_menu/proc/on_message(type, payload, href_list)
	if(type == "ready")
		send_init()
		return TRUE

	if(type != "action")
		return FALSE

	var/action = payload["action"]
	switch(action)
		if("opened")
			if(!version_warned && client.byond_build < 1680)
				to_chat(client, span_warning("Your BYOND version is not up-to-date enough to render the escape menu, please update to 516.1680 or higher."))
				version_warned = TRUE

			send_update(build_ticket_state()) // BANDASTATION EDIT: Escape menu
			START_PROCESSING(SSescape_menu, src)
		if("closed")
			STOP_PROCESSING(SSescape_menu, src)
		if("character")
			client?.prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
			client?.prefs.update_static_data(client?.mob)
			client?.prefs.ui_interact(client?.mob)
		if("settings")
			client?.prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
			client?.prefs.update_static_data(client?.mob)
			client?.prefs.ui_interact(client?.mob)
		if("create_ticket")
			open_admin_ticket() // BANDASTATION EDIT: Escape menu
		if("view_ticket")
			open_admin_ticket() // BANDASTATION EDIT: Escape menu
		if("pray")
			var/datum/keybinding/client/communication/pray/pray_verb = GLOB.keybindings_by_name[/datum/keybinding/client/communication/pray::name]
			pray_verb.down(client)
		if("see_notes")
			if(!CONFIG_GET(flag/see_own_notes))
				to_chat(client.mob, span_notice("Seeing notes has been disabled on this server."))
				return TRUE
			browse_messages(null, client.ckey, null, TRUE)
		if("ghost")
			var/mob/living/living_user = client?.mob
			living_user?.ghost()
		if("suicide")
			var/mob/living/carbon/human/human_user = client?.mob
			human_user?.suicide()
		if("quit")
			winset(usr, null, list("command"=".quit"))
		if("resource_bug")
			client?.reportissue()
		if("resource_github")
			client?.github()
		if("resource_forums")
			client?.forum()
		if("resource_rules")
			client?.rules()
		if("resource_wiki")
			client?.wiki()
		if("resource_config")
			client?.config()
		if("resource_changelog")
			client?.changelog()
		if("admin_notice")
			client?.admin_notice()
		if("toggle_ignore")
			var/ckey = payload["ckey"]
			if(!ckey || ckey == client?.ckey)
				return TRUE
			if(ckey in client?.prefs?.ignoring)
				client.prefs.ignoring -= ckey
			else
				LAZYADD(client.prefs.ignoring, ckey)
			client.prefs.save_preferences()
			to_chat(client, span_notice("[ckey] has been [(ckey in client.prefs.ignoring) ? "" : "un"]ignored in OOC."))

	return TRUE
