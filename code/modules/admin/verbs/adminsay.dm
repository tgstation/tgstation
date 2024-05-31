ADMIN_VERB(cmd_admin_say, R_NONE, "ASay", "Send a message to other admins", ADMIN_CATEGORY_MAIN, message as text)
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

	user.mob.log_talk(message, LOG_ASAY)
	message = keywords_lookup(message)
	var/asay_color = user.prefs.read_preference(/datum/preference/color/asay_color)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && asay_color) ? "<font color=[asay_color]>" : "<font color='[DEFAULT_ASAY_COLOR]'>"
	message = "[span_adminsay("[span_prefix("ADMIN:")] <EM>[key_name_admin(user)]</EM> [ADMIN_FLW(user.mob)]: [custom_asay_color]<span class='message linkify'>[message]")]</span>[custom_asay_color ? "</font>":null]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = message,
		confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Asay")

/client/proc/get_admin_say()
	var/msg = input(src, null, "asay \"text\"") as text|null
	SSadmin_verbs.dynamic_invoke_verb(src, /datum/admin_verb/cmd_admin_say, msg)
