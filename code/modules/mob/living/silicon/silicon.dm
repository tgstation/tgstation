/mob/living/silicon
	gender = NEUTER
	has_unlimited_silicon_privilege = TRUE
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	mob_biotypes = MOB_ROBOTIC
	death_sound = 'sound/voice/borg_deathsound.ogg'
	speech_span = SPAN_ROBOT
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	examine_cursor_icon = null
	fire_stack_decay_rate = -0.55
	tts_silicon_voice_effect = TRUE
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/last_lawchange_announce = 0
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/radiomod = "" //Radio character used before state laws/arrivals announce to allow department transmissions, default, or none at all.
	var/obj/item/camera/siliconcam/aicamera = null //photography
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)

	var/obj/item/radio/borg/radio = null  ///If this is a path, this gets created as an object in Initialize.

	var/list/alarm_types_show = list(ALARM_ATMOS = 0, ALARM_POWER = 0, ALARM_CAMERA = 0, ALARM_MOTION = 0)
	var/list/alarm_types_clear = list(ALARM_ATMOS = 0, ALARM_POWER = 0, ALARM_CAMERA = 0, ALARM_MOTION = 0)

	//These lists will contain each law that should be announced / set to yes in the state laws menu.
	///List keeping track of which laws to announce
	var/list/lawcheck = list()
	///List keeping track of hacked laws to announce
	var/list/hackedcheck = list()
	///List keeping track of ion laws to announce
	var/list/ioncheck = list()

	///Are our siliconHUDs on? TRUE for yes, FALSE for no.
	var/sensors_on = TRUE
	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_BASIC //Determines the diag hud to use

	var/law_change_counter = 0
	var/obj/machinery/camera/builtInCamera = null
	var/updating = FALSE //portable camera camerachunk update
	///Whether we have been emagged
	var/emagged = FALSE
	var/hack_software = FALSE //Will be able to use hacking actions
	interaction_range = 7 //wireless control range
	var/control_disabled = FALSE // Set to 1 to stop AI from interacting via Click()

	var/obj/item/modular_computer/pda/silicon/modularInterface


/mob/living/silicon/Initialize(mapload)
	. = ..()
	if(SStts.tts_enabled)
		voice = pick(SStts.available_speakers)
	GLOB.silicon_mobs += src
	faction += FACTION_SILICON
	if(ispath(radio))
		radio = new radio(src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_atom_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	add_sensors()

	var/static/list/traits_to_apply = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_ASHSTORM_IMMUNE,
		TRAIT_LITERATE,
		TRAIT_MADNESS_IMMUNE,
		TRAIT_MARTIAL_ARTS_IMMUNE,
		TRAIT_NOFIRE_SPREAD,
		TRAIT_BRAWLING_KNOCKDOWN_BLOCKED,
	)

	add_traits(traits_to_apply, ROUNDSTART_TRAIT)
	RegisterSignal(src, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_silicon_shocked))

/mob/living/silicon/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(aicamera)
	QDEL_NULL(builtInCamera)
	laws?.owner = null //Laws will refuse to die otherwise.
	QDEL_NULL(laws)
	QDEL_NULL(modularInterface)
	GLOB.silicon_mobs -= src
	return ..()

/mob/living/silicon/proc/on_silicon_shocked(datum/source, shock_damage, shock_source, siemens_coeff, flags)
	SIGNAL_HANDLER
	for(var/mob/living/living_mob in buckled_mobs)
		unbuckle_mob(living_mob)
		living_mob.electrocute_act(shock_damage/100, shock_source, siemens_coeff, flags) //Hard metal shell conducts!

	return COMPONENT_LIVING_BLOCK_SHOCK //So borgs don't die trying to fix wiring

/mob/living/silicon/proc/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/pda/silicon(src)
	var/job_name = ""
	if(isAI(src))
		job_name = "AI"
	if(ispAI(src))
		job_name = "pAI Messenger"

	modularInterface.layer = ABOVE_HUD_PLANE
	SET_PLANE_EXPLICIT(modularInterface, ABOVE_HUD_PLANE, src)
	modularInterface.imprint_id(real_name || name, job_name)

/mob/living/silicon/robot/create_modularInterface()
	if(!modularInterface)
		modularInterface = new /obj/item/modular_computer/pda/silicon/cyborg(src)
		modularInterface.imprint_id(job_name = "Cyborg")
	return ..()

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/contents_explosion(severity, target)
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = FALSE)
	var/in_cooldown = (length(alarms_to_show) || length(alarms_to_clear))
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(in_cooldown)
		return

	addtimer(CALLBACK(src, PROC_REF(show_alarms)), 3 SECONDS)

/mob/living/silicon/proc/show_alarms()
	if(length(alarms_to_show) < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(length(alarms_to_show))

		var/msg = "--- "
		for(var/alarm_type in alarm_types_show)
			msg += "[uppertext(alarm_type)]: [alarm_types_show[alarm_type]] alarms detected. - "

		msg += "<A href=?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	if(length(alarms_to_clear) < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(length(alarms_to_clear))
		var/msg = "--- "

		for(var/alarm_type in alarm_types_clear)
			msg += "[uppertext(alarm_type)]: [alarm_types_clear[alarm_type]] alarms cleared. - "

		msg += "<A href=?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)


	alarms_to_show.Cut()
	alarms_to_clear.Cut()
	for(var/key in alarm_types_show)
		alarm_types_show[key] = 0
	for(var/key in alarm_types_clear)
		alarm_types_clear[key] = 0

/mob/living/silicon/can_inject(mob/user, target_zone, injection_flags)
	return FALSE

/mob/living/silicon/try_inject(mob/user, target_zone, injection_flags)
	. = ..()
	if(!. && (injection_flags & INJECT_TRY_SHOW_ERROR_MESSAGE))
		to_chat(user, span_alert("[p_Their()] outer shell is too tough."))

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return FALSE
	if(bot.connected_ai == ai)
		return TRUE
	return FALSE

/**
 * Assembles all the zeroth, inherent and supplied laws into a single list.
 */
/mob/living/silicon/proc/assemble_laws()
	var/list/laws_to_return = list()
	laws_to_return += laws.zeroth
	for (var/law in laws.inherent)
		laws_to_return += law
	for (var/law in laws.supplied)
		if (law != "") // supplied laws start off with 15 blank strings, so don't add any of those
			laws_to_return += law
	return laws_to_return

/mob/living/silicon/Topic(href, href_list)
	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb
		var/law_index = text2num(href_list["lawc"])
		var/law = assemble_laws()[law_index + 1]
		if (law in lawcheck)
			lawcheck -= law
		else
			lawcheck += law
		checklaws()

	if (href_list["lawi"])
		var/law_index = text2num(href_list["lawi"])
		var/law = laws.ion[law_index]
		if (law in ioncheck)
			ioncheck -= law
		else
			ioncheck += law
		checklaws()

	if (href_list["lawh"])
		var/law_index = text2num(href_list["lawh"])
		var/law = laws.hacked[law_index]
		if (law in hackedcheck)
			hackedcheck -= law
		else
			hackedcheck += law
		checklaws()

	if (href_list["laws"])
		statelaws()

	if (href_list["printlawtext"]) // this is kinda backwards
		if (href_list["dead"] && (!isdead(usr) && !usr.client.holder)) // do not print deadchat law notice if the user is now alive
			to_chat(usr, span_warning("You cannot view law changes that were made while you were dead."))
			return
		to_chat(usr, href_list["printlawtext"])

	return

/mob/living/silicon/proc/statelaws(force = 0)
	laws_sanity_check()
	// Create a cache of our laws and lawcheck flags before we do anything else.
	// These are used to prevent weirdness when laws are changed when the AI is mid-stating.
	var/lawcache_zeroth = laws.zeroth
	var/list/lawcache_hacked = laws.hacked.Copy()
	var/list/lawcache_ion = laws.ion.Copy()
	var/list/lawcache_inherent = laws.inherent.Copy()
	var/list/lawcache_supplied = laws.supplied.Copy()

	var/list/lawcache_lawcheck = lawcheck.Copy()
	var/list/lawcache_ioncheck = ioncheck.Copy()
	var/list/lawcache_hackedcheck = hackedcheck.Copy()
	var/forced_log_message = "stating laws[force ? ", forced" : ""]"
	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	say("[radiomod] Current Active Laws:", forced = forced_log_message)
	sleep(1 SECONDS)

	if (lawcache_zeroth)
		if (force || (lawcache_zeroth in lawcache_lawcheck))
			say("[radiomod] 0. [lawcache_zeroth]", forced = forced_log_message)
			sleep(1 SECONDS)

	for (var/index in 1 to length(lawcache_hacked))
		var/law = lawcache_hacked[index]
		var/num = ion_num()
		if (length(law) <= 0)
			continue
		if (force || (law in lawcache_hackedcheck))
			say("[radiomod] [num]. [law]", forced = forced_log_message)
			sleep(1 SECONDS)

	for (var/index in 1 to length(lawcache_ion))
		var/law = lawcache_ion[index]
		var/num = ion_num()
		if (length(law) <= 0)
			return
		if (force || (law in lawcache_ioncheck))
			say("[radiomod] [num]. [law]", forced = forced_log_message)
			sleep(1 SECONDS)

	var/number = 1
	for (var/index in 1 to length(lawcache_inherent))
		var/law = lawcache_inherent[index]
		if (length(law) <= 0)
			continue
		if (force || (law in lawcache_lawcheck))
			say("[radiomod] [number]. [law]", forced = forced_log_message)
			number++
			sleep(1 SECONDS)

	for (var/index in 1 to length(lawcache_supplied))
		var/law = lawcache_supplied[index]

		if (length(law) <= 0)
			continue
		if (force || (law in lawcache_lawcheck))
			say("[radiomod] [number]. [law]", forced = forced_log_message)
			number++
			sleep(1 SECONDS)

///Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew.
/mob/living/silicon/proc/checklaws()
	laws_sanity_check()
	var/list = "<meta charset='UTF-8'><b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	var/law_display = "Yes"
	if (laws.zeroth)
		if (!(laws.zeroth in lawcheck))
			law_display = "No"
		list += {"<A href='byond://?src=[REF(src)];lawc=0'>[law_display] 0:</A> <font color='#ff0000'><b>[laws.zeroth]</b></font><BR>"}

	for (var/index in 1 to length(laws.hacked))
		law_display = "Yes"
		var/law = laws.hacked[index]
		if (length(law) > 0)
			if (!(law in hackedcheck))
				law_display = "No"
			list += {"<A href='byond://?src=[REF(src)];lawh=[index]'>[law_display] [ion_num()]:</A> <font color='#660000'>[law]</font><BR>"}

	for (var/index in 1 to length(laws.ion))
		law_display = "Yes"
		var/law = laws.ion[index]
		if (length(law) > 0)
			if(!(law in ioncheck))
				law_display = "No"
			list += {"<A href='byond://?src=[REF(src)];lawi=[index]'>[law_display] [ion_num()]:</A> <font color='#547DFE'>[law]</font><BR>"}

	var/number = 1
	for (var/index in 1 to length(laws.inherent))
		law_display = "Yes"
		var/law = laws.inherent[index]
		if (length(law) > 0)
			if (!(law in lawcheck))
				law_display = "No"
			list += {"<A href='byond://?src=[REF(src)];lawc=[index]'>[law_display] [number]:</A> [law]<BR>"}
			number++

	for (var/index in 1 to length(laws.supplied))
		law_display = "Yes"
		var/law = laws.supplied[index]
		if (length(law) > 0)
			if (!(law in lawcheck))
				law_display = "No"
			list += {"<A href='byond://?src=[REF(src)];lawc=[number]'>[law_display] [number]:</A> <font color='#990099'>[law]</font><BR>"}
			number++
	list += {"<br><br><A href='byond://?src=[REF(src)];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")

/mob/living/silicon/proc/ai_roster()
	if(!client)
		return
	if(world.time < client.crew_manifest_delay)
		return
	client.crew_manifest_delay = world.time + (1 SECONDS)

	GLOB.manifest.ui_interact(src)

/mob/living/silicon/proc/set_autosay() //For allowing the AI and borgs to set the radio behavior of auto announcements (state laws, arrivals).
	if(!radio)
		to_chat(src, span_alert("Radio not detected."))
		return

	//Ask the user to pick a channel from what it has available.
	var/chosen_channel = tgui_input_list(usr, "Select a channel", "Channel Selection", list("Default","None") + radio.channels)
	if(isnull(chosen_channel))
		return
	if(chosen_channel == "Default") //Autospeak on whatever frequency to which the radio is set, usually Common.
		radiomod = ";"
		chosen_channel += " ([radio.get_frequency()])"
	if(chosen_channel == "None") //Prevents use of the radio for automatic annoucements.
		radiomod = ""
	else //For department channels, if any, given by the internal radio.
		for(var/key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[key] == chosen_channel)
				radiomod = ":" + key
				break

	to_chat(src, span_notice("Automatic announcements [chosen_channel == "None" ? "will not use the radio." : "set to [chosen_channel]."]"))

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return FALSE

/mob/living/silicon/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/proc/remove_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.hide_from(src)
	medsensor.hide_from(src)
	diagsensor.hide_from(src)

/mob/living/silicon/proc/add_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.show_to(src)
	medsensor.show_to(src)
	diagsensor.show_to(src)

/mob/living/silicon/proc/toggle_sensors()
	if(incapacitated())
		return
	sensors_on = !sensors_on
	if (!sensors_on)
		to_chat(src, span_notice("Sensor overlay deactivated."))
		remove_sensors()
		return
	add_sensors()
	to_chat(src, span_notice("Sensor overlay activated."))

/mob/living/silicon/proc/GetPhoto(mob/user)
	if (aicamera)
		return aicamera.selectpicture(user)

/mob/living/silicon/get_inactive_held_item()
	return FALSE

/mob/living/silicon/handle_high_gravity(gravity, seconds_per_tick, times_fired)
	return

/mob/living/silicon/rust_heretic_act()
	adjustBruteLoss(500)

/mob/living/silicon/on_floored_start()
	return // Silicons are always standing by default.

/mob/living/silicon/on_floored_end()
	return // Silicons are always standing by default.

/mob/living/silicon/on_lying_down()
	return // Silicons are always standing by default.

/mob/living/silicon/on_standing_up()
	return // Silicons are always standing by default.

/mob/living/silicon/get_butt_sprite()
	return BUTT_SPRITE_QR_CODE

/**
 * Records an IC event log entry in the cyborg's internal tablet.
 *
 * Creates an entry in the borglog list of the cyborg's internal tablet (if it's a borg), listing the current
 * in-game time followed by the message given. These logs can be seen by the cyborg in their
 * BorgUI tablet app. By design, logging fails if the cyborg is dead.
 *
 * (This used to be in robot.dm. It's in here now.)
 *
 * Arguments:
 * arg1: a string containing the message to log.
 */
/mob/living/silicon/proc/logevent(string = "")
	if(!string)
		return
	if(stat == DEAD) //Dead silicons log no longer
		return
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	var/mob/living/silicon/robot/robo = modularInterface.silicon_owner
	if(istype(robo))
		modularInterface.borglog += "[station_time_timestamp()] - [string]"
	var/datum/computer_file/program/robotact/program = modularInterface.get_robotact()
	if(program)
		var/datum/tgui/active_ui = SStgui.get_open_ui(src, program.computer)
		if(active_ui)
			active_ui.send_full_update()

/// Same as the normal character name replacement, but updates the contents of the modular interface.
/mob/living/silicon/fully_replace_character_name(oldname, newname)
	. = ..()
	if(!modularInterface)
		stack_trace("Silicon [src] ( [type] ) was somehow missing their integrated tablet. Please make a bug report.")
		create_modularInterface()
	modularInterface.imprint_id(name = newname)

/mob/living/silicon/can_track(mob/living/user)
	//if their camera is online, it's safe to assume they are in cameranets
	//since it takes a while for camera vis to update, this lets us bypass that so AIs can always see their borgs,
	//without making cameras constantly update every time a borg moves.
	if(builtInCamera && builtInCamera.can_use())
		return TRUE
	return ..()
