//
// Default Verbs have no permissions and are available to any and all admins
//
#define ADMIN_VERB_DEFAULT(module, _name, _desc, params...) ADMIN_VERB(module, _name, _desc, NONE, ##params)

// /*
// 	/client/proc/debugstatpanel,
// 	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
// 	/client/proc/hide_verbs, /*hides all our adminverbs*/
// 	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
// 	/client/proc/mark_datum_mapview,
// 	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
// */

ADMIN_VERB_DEFAULT(admin, deadmin, "Become a normal player")
	usr.client.holder.deactivate()

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

ADMIN_CONTEXT_ENTRY(contextcmd_tag_atom, "Tag Atom", NONE, datum/target in view(view))
	tag_datum(target)

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
