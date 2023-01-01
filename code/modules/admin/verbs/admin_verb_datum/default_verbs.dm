/*
	/client/proc/cmd_admin_pm_context, /*right-click adminPM interface*/
	/client/proc/cmd_admin_pm_panel, /*admin-pm list*/
	/client/proc/debugstatpanel,
	/client/proc/debug_variables, /*allows us to -see- the variables of any instance in the game. +VAREDIT needed to modify*/
	/client/proc/dsay, /*talk in deadchat using our ckey/fakekey*/
	/client/proc/fix_air, /*resets air in designated radius to its default atmos composition*/
	/client/proc/hide_verbs, /*hides all our adminverbs*/
	/client/proc/investigate_show, /*various admintools for investigation. Such as a singulo grief-log*/
	/client/proc/mark_datum_mapview,
	/client/proc/reestablish_db_connection, /*reattempt a connection to the database*/
	/client/proc/reload_admins,
	/client/proc/requests,
	/client/proc/secrets,
	/client/proc/stop_sounds,
	/client/proc/tag_datum_mapview,
*/

/datum/admin_verb_datum/admin_pm
	verb_name = "Admin PM"
	verb_desc = "Set a message directly to a client"

/datum/admin_verb_datum/admin_pm/get_arguments(client/target)
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

	var/target = input(src,"To whom shall we send a message?", "Admin PM", null) as null|anything in sort_list(targets)
	if(!target)
		return list()
	return list(ADMINVERB_ARGUMENT_TARGET = target)

/datum/admin_verb_datum/admin_pm/invoke(client/target, list/arguments)
	var/whom = arguments[ADMINVERB_ARGUMENT_TARGET]
	if(!whom)
		return

	var/message = target.request_adminpm_message(disambiguate_client(whom), arguments[ADMINVERB_ARGUMENT_MESSAGE])

	if(!target.sends_adminpm_message(disambiguate_client(whom), message))
		return

	target.notify_adminpm_message(disambiguate_client(whom), message)

/datum/admin_verb_datum/deadmin
	verb_name = "DeAdmin"
	verb_desc = "Become a normal player"

/datum/admin_verb_datum/deadmin/invoke()
	usr.client.holder.deactivate()

/datum/admin_verb_datum/admin_say
	verb_name = "ASay"
	verb_desc = "Talk to your fellow jannies"

/datum/admin_verb_datum/admin_say/get_arguments(client/target)
	var/msg = input(target, null, "asay message") as text|null
	return list(ADMINVERB_ARGUMENT_MESSAGE = msg)

/datum/admin_verb_datum/admin_say/invoke(client/target, list/arguments)
	var/msg = arguments[ADMINVERB_ARGUMENT_MESSAGE]

	msg = emoji_parse(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	if(findtext(msg, "@") || findtext(msg, "#"))
		var/list/link_results = check_asay_links(msg)
		if(length(link_results))
			msg = link_results[ASAY_LINK_NEW_MESSAGE_INDEX]
			link_results[ASAY_LINK_NEW_MESSAGE_INDEX] = null
			var/list/pinged_admin_clients = link_results[ASAY_LINK_PINGED_ADMINS_INDEX]
			for(var/iter_ckey in pinged_admin_clients)
				var/client/iter_admin_client = pinged_admin_clients[iter_ckey]
				if(!iter_admin_client?.holder)
					continue
				window_flash(iter_admin_client)
				SEND_SOUND(iter_admin_client.mob, sound('sound/misc/asay_ping.ogg'))

	usr.log_talk(msg, LOG_ASAY)
	msg = keywords_lookup(msg)
	var/asay_color = target.prefs.read_preference(/datum/preference/color/asay_color)
	var/custom_asay_color = (CONFIG_GET(flag/allow_admin_asaycolor) && asay_color) ? "<font color=[asay_color]>" : "<font color='[DEFAULT_ASAY_COLOR]'>"
	msg = "[span_adminsay("[span_prefix("ADMIN:")] <EM>[key_name(usr, 1)]</EM> [ADMIN_FLW(usr)]: [custom_asay_color]<span class='message linkify'>[msg]")]</span>[custom_asay_color ? "</font>":null]"
	to_chat(GLOB.admins,
		type = MESSAGE_TYPE_ADMINCHAT,
		html = msg,
		confidential = TRUE)
