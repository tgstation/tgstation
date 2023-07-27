GLOBAL_VAR_INIT(looc_allowed, TRUE)

/datum/keybinding/client/communication/looc
	hotkey_keys = list("L")
	name = LOOC_CHANNEL
	full_name = "Local OOC (LOOC)"
	keybind_signal = COMSIG_KB_CLIENT_LOOC_DOWN

/datum/keybinding/client/communication/looc/down(client/user)
	. = ..()
	if(.)
		return
	winset(user, null, "command=[user.tgui_say_create_open_command(LOOC_CHANNEL)]")
	return TRUE

/datum/tgui_say/alter_entry(payload)
	/// No OOC leaks
	if(payload["channel"] == LOOC_CHANNEL)
		return pick(hurt_phrases)
	. = ..()

/datum/tgui_say/delegate_speech(entry, channel)
	switch(channel)
		if(LOOC_CHANNEL)
			client.looc(entry)
			return TRUE
	. = ..()

#define LOOC_RANGE 7

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	looc_message(msg)

/client/verb/looc_wallpierce(msg as text)
	set name = "LOOC (Wallpierce)"
	set desc = "Local OOC, seen by anyone within 7 tiles of you."
	set category = "OOC"

	looc_message(msg, TRUE)

/client/proc/looc_message(msg, wall_pierce)
	if(GLOB.say_disabled)
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	if(!holder)
		if(!GLOB.looc_allowed)
			to_chat(src, span_danger("LOOC is globally muted."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_boldannounce("<B>Advertising other servers is not allowed.</B>"))
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(prefs.muted & MUTE_LOOC)
			to_chat(src, span_danger("You cannot use LOOC (muted)."))
			return
		if(is_banned_from(ckey, BAN_LOOC))
			to_chat(src, span_warning("You are LOOC banned!"))
			return

	msg = emoji_parse(msg)

	mob.log_talk(msg,LOG_OOC, tag="LOOC")
	var/list/heard
	if(wall_pierce)
		heard = get_hearers_in_range(LOOC_RANGE, mob.get_top_level_mob())
	else
		heard = get_hearers_in_view(LOOC_RANGE, mob.get_top_level_mob())

	//so the ai can post looc text
	if(istype(mob, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = mob
		if(wall_pierce)
			heard = get_hearers_in_range(LOOC_RANGE, ai.eyeobj)
		else
			heard = get_hearers_in_view(LOOC_RANGE, ai.eyeobj)
	//so the ai can see looc text
	for(var/mob/living/silicon/ai/ai as anything in GLOB.ai_list)
		if(ai.client && !(ai in heard) && (ai.eyeobj in heard))
			heard += ai

	var/list/admin_seen = list()
	for(var/mob/hearing in heard)
		if(!hearing.client)
			continue
		var/client/hearing_client = hearing.client
		if (hearing_client.holder)
			admin_seen[hearing_client] = TRUE
			continue //they are handled after that

		if (isobserver(hearing))
			continue //Also handled later.

		to_chat(hearing_client, span_looc(span_prefix("LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM>[src.mob.name]:</EM> <span class='message'>[msg]")))

	for(var/cli in GLOB.admins)
		var/client/cli_client = cli
		if (admin_seen[cli_client])
			to_chat(cli_client, span_looc("[ADMIN_FLW(usr)] <span class='prefix'>LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span>"))
		else if (cli_client.prefs.read_preference(/datum/preference/toggle/see_looc))
			to_chat(cli_client, span_looc("[ADMIN_FLW(usr)] <span class='prefix'>(R)LOOC[wall_pierce ? " (WALL PIERCE)" : ""]:</span> <EM>[src.key]/[src.mob.name]:</EM> <span class='message'>[msg]</span>"))

#undef LOOC_RANGE

/mob/proc/get_top_level_mob()
	if(ismob(loc) && (loc != src))
		var/mob/M = loc
		return M.get_top_level_mob()
	return src

/datum/preference/toggle/see_looc
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "looc_admin_pref"
	savefile_identifier = PREFERENCE_PLAYER
