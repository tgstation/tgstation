/mob/verb/pray(message as text)
	set name = VERB_PRAY

	if(GLOB.say_disabled) //This is here to try to identify lag problems
		to_chat(src, span_danger("Speech is currently admin-disabled."), confidential = TRUE)
		return

	message = copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN)
	if(!message)
		return
	log_prayer("[src.key]/([src.name]): [message]")
	if(src.client)
		if(src.client.prefs.muted & MUTE_PRAY)
			to_chat(src, span_danger("You cannot pray (muted)."), confidential = TRUE)
			return
		if(src.client.handle_spam_prevention(message, MUTE_PRAY))
			return


	var/prayer_type = DEFAULT_PRAYER
	var/list/deities = list()
	if(src.job == JOB_CHAPLAIN)
		prayer_type = CHAPLAIN_PRAYER
		if(GLOB.deity)
			deities += GLOB.deity
	else if(IS_CULTIST(src))
		prayer_type = CULT_PRAYER
		deities += "Nar'Sie"
	else if(IS_HERETIC_OR_MONSTER(src))
		prayer_type = HERETIC_PRAYER
		deities += "the Mansus"
	else if(HAS_TRAIT(src, TRAIT_SPIRITUAL))
		prayer_type = SPIRITUAL_PRAYER
	else if(HAS_TRAIT(src, TRAIT_EVIL))
		prayer_type = EVIL_PRAYER

	var/mutable_appearance/cross = mutable_appearance('icons/obj/storage/book.dmi', GLOB.prayer_type_to_icon_state[prayer_type])

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_SEND_PRAYER, src, message, prayer_type, cross, deities)


	var/msg_tmp = message
	GLOB.requests.pray(src.client, message, src.job == JOB_CHAPLAIN)
	message = span_adminnotice("[icon2html(cross, GLOB.admins)]<b><font color=[GLOB.prayer_type_to_font_color[prayer_type]]>[prayer_type][length(deities) ? " (to [english_list(deities)])" : ""]: </font>[ADMIN_FULLMONTY(src)] [ADMIN_SC(src)]:</b> [span_linkify(message)]")
	message = custom_boxed_message(GLOB.prayer_type_to_message_box[prayer_type], message)
	for(var/client/C in GLOB.admins)
		if(get_chat_toggles(C) & CHAT_PRAYER)
			to_chat(C, message, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	to_chat(src, span_info("You pray to the gods: \"[msg_tmp]\""), confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Prayer")


/// Used by communications consoles to message CentCom
/proc/message_centcom(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	GLOB.requests.message_centcom(sender.client, msg)
	msg = span_adminnotice("<b><font color=orange>CENTCOM:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_CENTCOM_REPLY(sender)]:</b> [msg]")
	for(var/client/staff as anything in GLOB.admins)
		if(staff?.prefs.read_preference(/datum/preference/toggle/comms_notification))
			SEND_SOUND(staff, sound('sound/misc/server-ready.ogg'))
	to_chat(GLOB.admins, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.shuttle_caller_list)
		console.override_cooldown()

/// Used by communications consoles to message the Syndicate
/proc/message_syndicate(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	GLOB.requests.message_syndicate(sender.client, msg)
	msg = span_adminnotice("<b><font color=crimson>SYNDICATE:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_SYNDICATE_REPLY(sender)]:</b> [msg]")
	for(var/client/staff as anything in GLOB.admins)
		if(staff?.prefs.read_preference(/datum/preference/toggle/comms_notification))
			SEND_SOUND(staff, sound('sound/misc/server-ready.ogg'))
	to_chat(GLOB.admins, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.shuttle_caller_list)
		console.override_cooldown()

/// Used by communications consoles to request the nuclear launch codes
/proc/nuke_request(text, mob/sender)
	var/msg = copytext_char(sanitize(text), 1, MAX_MESSAGE_LEN)
	GLOB.requests.nuke_request(sender.client, msg)
	msg = span_adminnotice("<b><font color=orange>NUKE CODE REQUEST:</font>[ADMIN_FULLMONTY(sender)] [ADMIN_CENTCOM_REPLY(sender)] [ADMIN_SET_SD_CODE]:</b> [msg]")
	for(var/client/staff as anything in GLOB.admins)
		SEND_SOUND(staff, sound('sound/misc/server-ready.ogg'))
	to_chat(GLOB.admins, msg, type = MESSAGE_TYPE_PRAYER, confidential = TRUE)
	for(var/obj/machinery/computer/communications/console in GLOB.shuttle_caller_list)
		console.override_cooldown()
