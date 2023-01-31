//
// Default Verbs have no permissions and are available to any and all admins
//
#define ADMIN_VERB_DEFAULT(module, _name, _desc, params...) ADMIN_VERB(module, _name, _desc, NONE, ##params)

ADMIN_VERB_DEFAULT(server, reestablish_db_connection, "Attempts to establish a connection to the DB")
	if(!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, span_adminnotice("The Database is not enabled!"))
		return

	if(SSdbcore.IsConnected())
		if(!check_rights(R_DEBUG,0))
			tgui_alert(usr, "The database is already connected! (Only those with +debug can force a reconnection)", "The database is already connected!")
			return

		var/reconnect = tgui_alert(usr, "The database is already connected! If you *KNOW* that this is incorrect, you can force a reconnection", "The database is already connected!", list("Force Reconnect", "Cancel"))
		if(reconnect != "Force Reconnect")
			return

		SSdbcore.Disconnect()
		log_admin("[key_name(usr)] has forced the database to disconnect")
		message_admins("[key_name_admin(usr)] has <b>forced</b> the database to disconnect!")

	log_admin("[key_name(usr)] is attempting to re-establish the DB Connection")
	message_admins("[key_name_admin(usr)] is attempting to re-establish the DB Connection")

	SSdbcore.failed_connections = 0
	if(!SSdbcore.Connect())
		message_admins("Database connection failed: " + SSdbcore.ErrorMsg())
	else
		message_admins("Database connection re-established")

ADMIN_VERB_DEFAULT(debug, debug_stat_panel, "Enable advanced stat panel debugging")
	usr.client.stat_panel.send_message("create_debug")

ADMIN_VERB_DEFAULT(game, dead_say, "Speak a message to observers", message as text)
	if(usr.client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, span_danger("You cannot send DSAY messages (muted)."))
		return

	if(!message)
		message = tgui_input_text(usr, "Message", "Dead Say")
		if(!message)
			return

	if(usr.client.handle_spam_prevention(message, MUTE_DEADCHAT))
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(!message)
		return
	usr.log_talk(message, LOG_DSAY)

	var/rank_name = usr.client.holder.rank_names()
	var/admin_name = usr.ckey
	if(usr.client.holder.fakekey)
		rank_name = pick(strings("admin_nicknames.json", "ranks", "config"))
		admin_name = pick(strings("admin_nicknames.json", "names", "config"))
	var/name_and_rank = "[span_tooltip(rank_name, "STAFF")] ([admin_name])"
	deadchat_broadcast("[span_prefix("DEAD:")] [name_and_rank] says, <span class='message'>\"[emoji_parse(message)]\"</span>")

ADMIN_VERB_DEFAULT(admin, deadmin, "Become a normal player")
	usr.client.holder.deactivate()
	log_admin("[key_name(usr)] deadmined")

ADMIN_VERB_DEFAULT(debug, reload_admins, "Reloads all admins from the data store")
	var/confirm = tgui_alert(usr, "Are you sure you want to reload all admins?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	message_admins("[key_name_admin(usr)] manually reloaded admins.")
	load_admins()

ADMIN_VERB_DEFAULT(debug, stop_all_sounds, "Stop all sounds on all connected clients")
	log_admin("[key_name(usr)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(usr)] stopped all currently playing sounds.")
	for(var/mob/player as anything in GLOB.player_list)
		SEND_SOUND(player, sound(null))
		// player list is only supposed to contain mobs with an attached client,
		// but clients can just poof in and out of existence
		player.client?.tgui_panel.stop_music()

ADMIN_VERB_DEFAULT(game, secrets_panel, "Abuse harder than you ever knew was possible")
	usr.client?.secrets()

ADMIN_VERB_DEFAULT(game, requests_manager, "Open the request manager panel to view all requests during this round")
	GLOB.requests.ui_interact(usr)

ADMIN_VERB_DEFAULT(admin, admin_say, "Speak to your fellow jannies", message as text)
	message ||= tgui_input_text(usr, "Message", "Admin Say")
	message = emoji_parse(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return

	if(findtext(message, "@") || findtext(message, "#"))
		var/list/link_results = check_asay_links(message)
		if(length(link_results))
			message = link_results[ASAY_LINK_NEW_MESSAGE_INDEX]
			link_results[ASAY_LINK_NEW_MESSAGE_INDEX] = null
			var/list/pinged_admin_clients = link_results[ASAY_LINK_PINGED_ADMINS_INDEX]
			for(var/iter_ckey in pinged_admin_clients)
				var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
				if(!iter_admin_client?.holder)
					continue
				window_flash(iter_admin_client)
				SEND_SOUND(iter_admin_client.mob, sound('sound/misc/asay_ping.ogg'))
	usr.log_talk(message, LOG_ASAY)
	message = keywords_lookup(message)
	var/asay_color = usr.client?.prefs.read_preference(/datum/preference/color/asay_color)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && asay_color) ? "<font color=[asay_color]>" : "<font color='[DEFAULT_ASAY_COLOR]'>"
	message = "[span_adminsay("[span_prefix("ADMIN:")] <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(usr)]: [custom_asay_color]<span class='message linkify'>[message]")]</span>[custom_asay_color ? "</font>":null]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = message,
		confidential = TRUE)

ADMIN_VERB_DEFAULT(admin, admin_pm, "Send a message directly to a client")
	var/list/targets = list()
	for(var/client/client in GLOB.clients)
		var/nametag = ""
		var/mob/lad = client.mob
		var/mob_name = lad?.name
		var/real_mob_name = lad?.real_name
		if(!lad)
			nametag = "(No Mob)"
		else if(isnewplayer(lad))
			nametag = "(New Player)"
		else if(isobserver(lad))
			nametag = "[mob_name](Ghost)"
		else
			nametag = "[real_mob_name](as [mob_name])"
		targets["[nametag] - [client]"] = client

	var/whom = input(usr, "To whom shall we send a message?", "Admin PM", null) as null|anything in sort_list(targets)
	if(!whom)
		return
	whom = disambiguate_client(targets[whom])

	var/message = usr.client.request_adminpm_message(whom, null)
	if(!usr.client.sends_adminpm_message(whom, message))
		return
	usr.client.notify_adminpm_message(whom, message)

ADMIN_CONTEXT_ENTRY(contextcmd_tag_atom, "Tag Atom", NONE, atom/target in view(view))
	tag_datum(target)

ADMIN_VERB(debug, tag_datum, "Tag an atom in view", NONE, atom/target)
	usr.client.tag_datum(target)

/client/proc/tag_datum(datum/target_datum)
	if(!holder || QDELETED(target_datum))
		return
	holder.add_tagged_datum(target_datum)

/client/proc/toggle_tag_datum(datum/target_datum)
	if(!holder || !target_datum)
		return

	if(LAZYFIND(holder.tagged_datums, target_datum))
		holder.remove_tagged_datum(target_datum)
	else
		holder.add_tagged_datum(target_datum)

ADMIN_CONTEXT_ENTRY(contextcmd_mark_atom, "Mark Atom", NONE, atom/target in view(view))
	mark_datum(target)

ADMIN_VERB(debug, mark_object, "Mark an atom in view", NONE, atom/target)
	usr.client.mark_datum(target)

/client/proc/mark_datum(datum/D)
	if(!holder)
		return
	if(holder.marked_datum)
		holder.UnregisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING)
		vv_update_display(holder.marked_datum, "marked", "")
	holder.marked_datum = D
	holder.RegisterSignal(holder.marked_datum, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/admins, handle_marked_del))
	vv_update_display(D, "marked", VV_MSG_MARKED)

/datum/admins/proc/handle_marked_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(marked_datum, COMSIG_PARENT_QDELETING)
	marked_datum = null

/atom/proc/investigate_log(message, subject)
	if(!message || !subject)
		return
	var/F = file("[GLOB.log_directory]/[subject].html")
	var/source = "[src]"

	if(isliving(src))
		var/mob/living/source_mob = src
		source += " ([source_mob.ckey ? source_mob.ckey : "*no key*"])"

	WRITE_FILE(F, "[time_stamp(format = "YYYY-MM-DD hh:mm:ss")] [REF(src)] ([x],[y],[z]) || [source] [message]<br>")

ADMIN_VERB(game, investigate, "Look at various detailed investigate sources", NONE)
	var/list/investigates = list(
		INVESTIGATE_ACCESSCHANGES,
		INVESTIGATE_ATMOS,
		INVESTIGATE_BOTANY,
		INVESTIGATE_CARGO,
		INVESTIGATE_CRAFTING,
		INVESTIGATE_DEATHS,
		INVESTIGATE_ENGINE,
		INVESTIGATE_EXPERIMENTOR,
		INVESTIGATE_GRAVITY,
		INVESTIGATE_HALLUCINATIONS,
		INVESTIGATE_HYPERTORUS,
		INVESTIGATE_PORTAL,
		INVESTIGATE_PRESENTS,
		INVESTIGATE_RADIATION,
		INVESTIGATE_RECORDS,
		INVESTIGATE_RESEARCH,
		INVESTIGATE_WIRES,
	)

	var/list/logs_present = list("notes, memos, watchlist")
	var/list/logs_missing = list("---")

	for(var/subject in investigates)
		var/temp_file = file("[GLOB.log_directory]/[subject].html")
		if(fexists(temp_file))
			logs_present += subject
		else
			logs_missing += "[subject] (empty)"

	var/list/combined = sort_list(logs_present) + sort_list(logs_missing)

	var/selected = tgui_input_list(usr, "Investigate what?", "Investigation", combined)
	if(isnull(selected))
		return
	if(!(selected in combined) || selected == "---")
		return

	selected = replacetext(selected, " (empty)", "")

	if(selected == "notes, memos, watchlist" && check_rights(R_ADMIN))
		browse_messages()
		return

	var/F = file("[GLOB.log_directory]/[selected].html")
	if(!fexists(F))
		to_chat(usr, span_danger("No [selected] logfile was found."), confidential = TRUE)
		return
	usr << browse(F,"window=investigate[selected];size=800x300")
