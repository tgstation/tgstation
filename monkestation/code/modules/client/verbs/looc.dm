// LOOC ported from Bee, which was in turn ported from Citadel

GLOBAL_VAR_INIT(looc_allowed, TRUE)

/client/verb/looc(msg as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(GLOB.say_disabled)    //This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	VALIDATE_CLIENT(src)

	if(is_banned_from(mob.ckey, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC and LOOC.</span>")
		return
	if(!CHECK_BITFIELD(prefs.chat_toggles, CHAT_OOC))
		to_chat(src, span_danger("You have OOC (and therefore LOOC) muted."))
		return

	msg = trim(sanitize(msg), MAX_MESSAGE_LEN)
	if(!length(msg))
		return

	var/raw_msg = msg

	var/list/filter_result = is_ooc_filtered(msg)
	if (!CAN_BYPASS_FILTER(usr) && filter_result)
		REPORT_CHAT_FILTER_TO_USER(usr, filter_result)
		log_filter("LOOC", msg, filter_result)
		return

	// Protect filter bypassers from themselves.
	// Demote hard filter results to soft filter results if necessary due to the danger of accidentally speaking in OOC.
	var/list/soft_filter_result = filter_result || is_soft_ooc_filtered(msg)

	if (soft_filter_result)
		if(tgui_alert(usr, "Your message contains \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\". \"[soft_filter_result[CHAT_FILTER_INDEX_REASON]]\", Are you sure you want to say it?", "Soft Blocked Word", list("Yes", "No")) != "Yes")
			return
		message_admins("[ADMIN_LOOKUPFLW(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")
		log_admin_private("[key_name(usr)] has passed the soft filter for \"[soft_filter_result[CHAT_FILTER_INDEX_WORD]]\" they may be using a disallowed term. Message: \"[msg]\"")

	// letting mentors use this as they might actually use this to help people. this cannot possibly go wrong! :clueless:
	if(!holder)
		if(!CONFIG_GET(flag/looc_enabled))
			to_chat(src, span_danger("LOOC is disabled."))
			return
		if(!GLOB.dooc_allowed && (mob.stat == DEAD) && SSticker.current_state < GAME_STATE_FINISHED && !mentor_datum)
			to_chat(usr, span_danger("LOOC for dead mobs has been turned off."))
			return
		if(CHECK_BITFIELD(prefs.muted, MUTE_OOC))
			to_chat(src, span_danger("You cannot use LOOC (muted)."))
			return
		if(handle_spam_prevention(msg, MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, span_danger("Advertising other servers is not allowed."))
			log_admin("[key_name(src)] has attempted to advertise in LOOC: [msg]")
			return
		if(mob.stat && SSticker.current_state < GAME_STATE_FINISHED && !mentor_datum)
			to_chat(src, span_danger("You cannot salt in LOOC while unconscious or dead."))
			return
		if(isdead(mob) && SSticker.current_state < GAME_STATE_FINISHED && !mentor_datum)
			to_chat(src, span_danger("You cannot use LOOC while ghosting."))
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_danger("You have been banned from OOC."))
		return
	if(QDELETED(src))
		return

	msg = emoji_parse(msg)
	mob.log_talk(raw_msg, LOG_OOC, tag = "LOOC")

	var/list/hearers = list()
	for(var/mob/hearer in get_hearers_in_view(9, mob))
		var/client/client = hearer.client
		if(QDELETED(client) || !CHECK_BITFIELD(client.prefs.chat_toggles, CHAT_OOC))
			continue
		hearers[client] = TRUE
		if((client in GLOB.admins) && is_admin_looc_omnipotent(client))
			continue
		to_chat(hearer, span_looc("[span_prefix("LOOC:")] <EM>[span_name("[mob.name]")]:</EM> <span class='message linkify'>[msg]</span>"), type = MESSAGE_TYPE_LOOC, avoid_highlighting = (hearer == mob))
		if(client.prefs.read_preference(/datum/preference/toggle/enable_runechat_looc))
			hearer.create_chat_message(mob, /datum/language/common, "\[LOOC: [raw_msg]\]", runechat_flags = LOOC_MESSAGE)

	for(var/client/client in GLOB.admins)
		if(!CHECK_BITFIELD(client.prefs.chat_toggles, CHAT_OOC) || !is_admin_looc_omnipotent(client))
			continue
		var/prefix = "[hearers[client] ? "" : "(R)"]LOOC"
		if(client.prefs.read_preference(/datum/preference/toggle/enable_runechat_looc))
			client.mob?.create_chat_message(mob, /datum/language/common, "\[LOOC: [raw_msg]\]", runechat_flags = LOOC_MESSAGE)
		to_chat(client, span_looc("[span_prefix("[prefix]:")] <EM>[ADMIN_LOOKUPFLW(mob)]:</EM> <span class='message linkify'>[msg]</span>"), type = MESSAGE_TYPE_LOOC, avoid_highlighting = (client == src))

/// Logging for messages sent in LOOC
/proc/log_looc(text, list/data)
	logger.Log(LOG_CATEGORY_GAME_LOOC, text, data)

//admin tool
/proc/toggle_looc(toggle = null)
	if(!isnull(toggle)) //if we're specifically en/disabling ooc
		GLOB.looc_allowed = toggle
	else //otherwise just toggle it
		GLOB.looc_allowed = !GLOB.looc_allowed
	to_chat(world, "<span class='oocplain bold'>LOOC channel has been globally [GLOB.looc_allowed ? "enabled" : "disabled"].</span>")

/datum/admins/proc/togglelooc()
	set category = "Server"
	set name = "Toggle LOOC"
	if(!check_rights(R_ADMIN))
		return
	toggle_looc()
	log_admin("[key_name(usr)] toggled LOOC.")
	message_admins("[key_name_admin(usr)] toggled LOOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle LOOC", "[GLOB.looc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/proc/is_admin_looc_omnipotent(client/admin)
	if(QDELETED(admin))
		return FALSE
	switch(admin.prefs.read_preference(/datum/preference/choiced/admin_hear_looc))
		if("Always")
			return TRUE
		if("When Observing")
			return isdead(admin.mob) || admin.mob.stat == DEAD
		else
			return FALSE
