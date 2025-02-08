GLOBAL_VAR_INIT(SOOC_COLOR, "#ff5454")
GLOBAL_VAR_INIT(sooc_allowed, TRUE)	// used with admin verbs to disable sooc - not a config option
GLOBAL_LIST_EMPTY(ckey_to_sooc_name)

#define SOOC_LISTEN_PLAYER 1
#define SOOC_LISTEN_ADMIN 2

/client/verb/sooc(msg as text)
	set name = "SOOC"
	set category = "OOC"

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Speech is currently admin-disabled."))
		return

	if(!mob)
		return

	var/static/list/job_lookup = list(JOB_CAPTAIN=TRUE, JOB_HEAD_OF_SECURITY=TRUE, JOB_WARDEN=TRUE, JOB_DETECTIVE=TRUE, JOB_SECURITY_OFFICER=TRUE, JOB_CORRECTIONS_OFFICER=TRUE)
	if(!holder)
		var/job = mob?.mind.assigned_role.title
		if(!job || !job_lookup[job])
			to_chat(src, span_danger("You're not a security role!"))
			return
		if(!GLOB.sooc_allowed)
			to_chat(src, span_danger("SOOC is globally muted."))
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, span_danger("You cannot use OOC (muted)."))
			return
	if(is_banned_from(ckey, "OOC"))
		to_chat(src, span_danger("You have been banned from OOC."))
		return
	if(QDELETED(src))
		return

	msg = copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN)
	var/raw_msg = msg

	if(!msg)
		return

	msg = emoji_parse(msg)

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, span_danger("You have OOC muted."))
		return

	mob.log_talk(raw_msg, LOG_OOC, tag="SOOC")

	var/keyname = key
	var/anon = FALSE

	//Anonimity for players and deadminned admins
	if(!holder || holder.deadmined)
		if(!GLOB.ckey_to_sooc_name[key])
			GLOB.ckey_to_sooc_name[key] = "Deputy [pick(GLOB.phonetic_alphabet)] [rand(1, 99)]"
		keyname = GLOB.ckey_to_sooc_name[key]
		anon = TRUE

	var/list/listeners = list()

	for(var/iterated_player as anything in GLOB.player_list)
		var/mob/iterated_mob = iterated_player
		//Admins with muted OOC do not get to listen to SOOC, but normal players do, as it could be admins talking important stuff to them
		if(iterated_mob.client?.holder && !iterated_mob.client?.holder?.deadmined && iterated_mob.client?.prefs?.chat_toggles & CHAT_OOC)
			listeners[iterated_mob.client] = SOOC_LISTEN_ADMIN
		else
			if(iterated_mob.mind)
				var/datum/mind/mob_mind = iterated_mob.mind
				if(job_lookup[mob_mind.assigned_role?.title])
					listeners[iterated_mob.client] = SOOC_LISTEN_PLAYER

	for(var/iterated_listener as anything in listeners)
		var/client/iterated_client = iterated_listener
		var/mode = listeners[iterated_listener]
		var/color = (!anon && CONFIG_GET(flag/allow_admin_ooccolor) && iterated_client?.prefs?.read_preference(/datum/preference/color/ooc_color)) ? iterated_client?.prefs?.read_preference(/datum/preference/color/ooc_color) : GLOB.SOOC_COLOR
		var/name = (mode == SOOC_LISTEN_ADMIN && anon) ? "([key])[keyname]" : keyname
		to_chat(iterated_client, span_oocplain("<font color='[color]'><b><span class='prefix'>SOOC:</span> <EM>[name]:</EM> <span class='message linkify'>[msg]</span></b></font>"))

#undef SOOC_LISTEN_PLAYER
#undef SOOC_LISTEN_ADMIN

/proc/toggle_sooc(toggle = null)
	if(toggle != null) //if we're specifically en/disabling sooc
		if(toggle != GLOB.sooc_allowed)
			GLOB.sooc_allowed = toggle
		else
			return
	else //otherwise just toggle it
		GLOB.sooc_allowed = !GLOB.sooc_allowed
	var/list/listeners = list()
	var/static/list/job_lookup = list(JOB_SECURITY_OFFICER = TRUE, JOB_WARDEN = TRUE, JOB_DETECTIVE = TRUE, JOB_HEAD_OF_SECURITY = TRUE, JOB_CAPTAIN = TRUE, JOB_BLUESHIELD = TRUE)
	for(var/iterated_player as anything in GLOB.player_list)
		var/mob/iterated_mob = iterated_player
		if(!iterated_mob.client?.holder?.deadmined)
			listeners[iterated_mob.client] = TRUE
		else
			if(iterated_mob.mind)
				var/datum/mind/mob_mind = iterated_mob.mind
				if(job_lookup[mob_mind.assigned_role])
					listeners[iterated_mob.client] = TRUE
	for(var/iterated_listener as anything in listeners)
		var/client/iterated_client = iterated_listener
		to_chat(iterated_client, span_oocplain("<b>The SOOC channel has been globally [GLOB.sooc_allowed ? "enabled" : "disabled"].</b>"))

ADMIN_VERB(togglesooc, R_ADMIN, "Toggle Security OOC", "Toggles Security OOC.", ADMIN_CATEGORY_SERVER)
	toggle_sooc()
	log_admin("[key_name(usr)] toggled Security OOC.")
	message_admins("[key_name_admin(usr)] toggled Security OOC.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Antag OOC", "[GLOB.sooc_allowed ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
