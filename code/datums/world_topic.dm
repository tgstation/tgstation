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
	input -= "key"
	if(require_comms_key && !key_valid)
		. = "Bad Key"
		if (input["format"] == "json")
			. = list("error" = .)
	else
		. = Run(input)
	if (input["format"] == "json")
		. = json_encode(.)
	else if(islist(.))
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

/datum/world_topic/playing
	keyword = "playing"
	log = FALSE

/datum/world_topic/playing/Run(list/input)
	return GLOB.player_list.len

/datum/world_topic/pr_announce
	keyword = "announce"
	require_comms_key = TRUE
	var/static/list/PRcounts = list() //PR id -> number of times announced this round

/datum/world_topic/pr_announce/Run(list/input)
	var/list/payload = json_decode(input["payload"])
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > CONFIG_GET(number/pr_announcements_per_round))
			return

	var/final_composed = span_announce("PR: [input[keyword]]")
	for(var/client/C in GLOB.clients)
		C.AnnouncePR(final_composed)

/datum/world_topic/ahelp_relay
	keyword = "Ahelp"
	require_comms_key = TRUE

/datum/world_topic/ahelp_relay/Run(list/input)
	relay_msg_admins(span_adminnotice("<b><font color=red>HELP: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b>"))

/datum/world_topic/comms_console
	keyword = "Comms_Console"
	require_comms_key = TRUE

	var/list/timers

/datum/world_topic/comms_console/Run(list/input)
	// Reject comms messages from other servers that are not on our configured network,
	// if this has been configured. (See CROSS_COMMS_NETWORK in comms.txt)
	var/configured_network = CONFIG_GET(string/cross_comms_network)
	if (configured_network && configured_network != input["network"])
		return

	// We can't add the timer without the timer ID, but we can't get the timer ID without the timer!
	// To solve this, we just use a list that we mutate later.
	var/list/data = list("input" = input)
	var/timer_id = addtimer(CALLBACK(src, .proc/receive_cross_comms_message, data), CROSS_SECTOR_CANCEL_TIME, TIMER_STOPPABLE)
	data["timer_id"] = timer_id

	LAZYADD(timers, timer_id)

	to_chat(
		GLOB.admins,
		span_adminnotice( \
			"<b color='orange'>CROSS-SECTOR MESSAGE (INCOMING):</b> [input["sender_ckey"]] (from [input["source"]]) is about to send \
			the following message (will autoapprove in [DisplayTimeText(CROSS_SECTOR_CANCEL_TIME)]): \
			<b><a href='?src=[REF(src)];reject_cross_comms_message=[timer_id]'>REJECT</a></b><br> \
			[html_encode(input["message"])]" \
		)
	)

/datum/world_topic/comms_console/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["reject_cross_comms_message"])
		if (!usr.client?.holder)
			log_game("[key_name(usr)] tried to reject an incoming cross-comms message without being an admin.")
			message_admins("[key_name(usr)] tried to reject an incoming cross-comms message without being an admin.")
			return

		var/timer_id = href_list["reject_cross_comms_message"]
		if (!(timer_id in timers))
			to_chat(usr, span_warning("It's too late!"))
			return

		deltimer(timer_id)
		LAZYREMOVE(timers, timer_id)

		log_admin("[key_name(usr)] has cancelled the incoming cross-comms message.")
		message_admins("[key_name(usr)] has cancelled the incoming cross-comms message.")

		return TRUE

/datum/world_topic/comms_console/proc/receive_cross_comms_message(list/data)
	var/list/input = data["input"]
	var/timer_id = data["timer_id"]

	LAZYREMOVE(timers, timer_id)

	minor_announce(input["message"], "Incoming message from [input["message_sender"]]")
	message_admins("Receiving a message from [input["sender_ckey"]] at [input["source"]]")
	for(var/obj/machinery/computer/communications/communications_console in GLOB.machines)
		communications_console.override_cooldown()

/datum/world_topic/news_report
	keyword = "News_Report"
	require_comms_key = TRUE

/datum/world_topic/news_report/Run(list/input)
	minor_announce(input["message"], "Breaking Update From [input["message_sender"]]")

/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE

/datum/world_topic/adminmsg/Run(list/input)
	return TgsPm(input[keyword], input["msg"], input["sender"])

/datum/world_topic/namecheck
	keyword = "namecheck"
	require_comms_key = TRUE

/datum/world_topic/namecheck/Run(list/input)
	//Oh this is a hack, someone refactor the functionality out of the chat command PLS
	var/datum/tgs_chat_command/namecheck/NC = new
	var/datum/tgs_chat_user/user = new
	user.friendly_name = input["sender"]
	user.mention = user.friendly_name
	return NC.Run(user, input["namecheck"])

/datum/world_topic/adminwho
	keyword = "adminwho"
	require_comms_key = TRUE

/datum/world_topic/adminwho/Run(list/input)
	return tgsadminwho()

/datum/world_topic/status
	keyword = "status"

/datum/world_topic/status/Run(list/input)
	. = list()
	.["version"] = GLOB.game_version
	.["respawn"] = config ? !CONFIG_GET(flag/norespawn) : FALSE
	.["enter"] = !LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS)
	.["ai"] = CONFIG_GET(flag/allow_ai)
	.["host"] = world.host ? world.host : null
	.["round_id"] = GLOB.round_id
	.["players"] = GLOB.clients.len
	.["revision"] = GLOB.revdata.commit
	.["revision_date"] = GLOB.revdata.date
	.["hub"] = GLOB.hub_visibility


	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
	.["gamestate"] = SSticker.current_state

	.["map_name"] = SSmapping.config?.map_name || "Loading..."

	if(key_valid)
		.["active_players"] = get_active_player_count()

	.["security_level"] = SSsecurity_level.get_current_level_as_text()
	.["round_duration"] = SSticker ? round((world.time-SSticker.round_start_time)/10) : 0
	// Amount of world's ticks in seconds, useful for calculating round duration

	//Time dilation stats.
	.["time_dilation_current"] = SStime_track.time_dilation_current
	.["time_dilation_avg"] = SStime_track.time_dilation_avg
	.["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	.["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast

	//pop cap stats
	.["soft_popcap"] = CONFIG_GET(number/soft_popcap) || 0
	.["hard_popcap"] = CONFIG_GET(number/hard_popcap) || 0
	.["extreme_popcap"] = CONFIG_GET(number/extreme_popcap) || 0
	.["popcap"] = max(CONFIG_GET(number/soft_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/extreme_popcap)) //generalized field for this concept for use across ss13 codebases
	.["bunkered"] = CONFIG_GET(flag/panic_bunker) || FALSE
	.["interviews"] = CONFIG_GET(flag/panic_bunker_interview) || FALSE
	if(SSshuttle?.emergency)
		.["shuttle_mode"] = SSshuttle.emergency.mode
		// Shuttle status, see /__DEFINES/stat.dm
		.["shuttle_timer"] = SSshuttle.emergency.timeLeft()
		// Shuttle timer, in seconds

