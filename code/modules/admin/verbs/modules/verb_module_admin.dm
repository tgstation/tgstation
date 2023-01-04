ADMIN_VERB(admin, admin_say, "Speak to your fellow jannies", NONE, message as text)
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

ADMIN_VERB(admin, admin_pm, "Send a message directly to a client", NONE)
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

ADMIN_VERB(null, admin_pm_context, "", NONE, mob/target in GLOB.player_list)
	var/message = usr.client.request_adminpm_message(target.client, null)
	if(!usr.client.sends_adminpm_message(target.client, message))
		return
	usr.client.notify_adminpm_message(target.client, message)
