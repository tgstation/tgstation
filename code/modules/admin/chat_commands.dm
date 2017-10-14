#define IRC_STATUS_THROTTLE 5

/datum/server_tools_command/ircstatus
	name = "status"
	help_text = "Gets the admincount, playercount, gamemode, and true game mode of the server"
	admin_only = TRUE
	var/static/last_irc_status = 0

/datum/server_tools_command/ircstatus/Run(sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_status < IRC_STATUS_THROTTLE)
		return
	last_irc_status = rtod
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["total"]
	var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
	status += "Players: [GLOB.clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [SSticker.mode ? SSticker.mode.name : "Not started"]."
	return status

/datum/server_tools_command/irccheck
	name = "check"
	help_text = "Gets the playercount, gamemode, and address of the server"
	var/static/last_irc_check = 0

/datum/server_tools_command/irccheck/Run(sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_irc_check < IRC_STATUS_THROTTLE)
		return
	last_irc_check = rtod
	var/server = CONFIG_GET(string/server)
	return "[GLOB.round_id ? "Round #[GLOB.round_id]: " : ""][GLOB.clients.len] players on [SSmapping.config.map_name], Mode: [GLOB.master_mode]; Round [SSticker.HasRoundStarted() ? (SSticker.IsRoundInProgress() ? "Active" : "Finishing") : "Starting"] -- [server ? server : "[world.internet_address]:[world.port]"]" 

/datum/server_tools_command/ahelp
	name = "ahelp"
	help_text = "<ckey> <message|ticket <close|resolve|icissue|reject|reopen <ticket #>|list>>"
	required_parameters = 2
	admin_only = TRUE

/datum/server_tools_command/ahelp/Run(sender, params)
	var/list/all_params = splittext(params, " ")
	var/target = all_params[1]
	all_params.Cut(1, 2)
	return IrcPm(target, all_params.Join(" "), sender)

/datum/server_tools_command/namecheck
	name = "namecheck"
	help_text = "Returns info on the specified target"
	required_parameters = 1
	admin_only = TRUE

/datum/server_tools_command/namecheck/Run(sender, params)
	log_admin("Chat Name Check: [sender] on [params]")
	message_admins("Name checking [params] from [sender]")
	return keywords_lookup(params, 1)

/datum/server_tools_command/adminwho
	name = "adminwho"
	help_text = "Lists administrators currently on the server"
	admin_only = TRUE

/datum/server_tools_command/adminwho/Run(sender, params)
	return ircadminwho()

GLOBAL_LIST(round_end_notifiees)

/datum/server_tools_command/notify
	name = "notify"
	help_text = "Pings the invoker when the round ends"
	admin_only = TRUE

/datum/server_tools_command/notify/Run(sender, params)
	if(!SSticker.IsRoundInProgress() && SSticker.HasRoundStarted())
		return "[sender], the round has already ended!"
	LAZYINITLIST(GLOB.round_end_notifiees)
	GLOB.round_end_notifiees[sender] = TRUE
	return "I will notify [sender] when the round ends."