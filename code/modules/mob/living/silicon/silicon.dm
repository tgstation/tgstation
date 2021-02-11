/mob/living/silicon
	gender = NEUTER
	has_unlimited_silicon_privilege = 1
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"
	initial_language_holder = /datum/language_holder/synthetic
	see_in_dark = 8
	bubble_icon = "machine"
	weather_immunities = list("ash")
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	mob_biotypes = MOB_ROBOTIC
	deathsound = 'sound/voice/borg_deathsound.ogg'
	speech_span = SPAN_ROBOT
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1 | HEAR_1 | RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	examine_cursor_icon = null
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/last_lawchange_announce = 0
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/radiomod = "" //Radio character used before state laws/arrivals announce to allow department transmissions, default, or none at all.
	var/obj/item/camera/siliconcam/aicamera = null //photography
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)

	var/obj/item/radio/borg/radio = null  ///If this is a path, this gets created as an object in Initialize.

	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

	var/lawcheck[1]
	var/ioncheck[1]
	var/hackedcheck[1]

	///Are our siliconHUDs on? TRUE for yes, FALSE for no.
	var/sensors_on = TRUE
	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_BASIC //Determines the diag hud to use

	var/law_change_counter = 0
	var/obj/machinery/camera/builtInCamera = null
	var/updating = FALSE //portable camera camerachunk update

	var/hack_software = FALSE //Will be able to use hacking actions
	var/interaction_range = 7			//wireless control range
	var/obj/item/pda/ai/aiPDA

/mob/living/silicon/Initialize()
	. = ..()
	GLOB.silicon_mobs += src
	faction += "silicon"
	if(ispath(radio))
		radio = new radio(src)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()
	add_sensors()
	ADD_TRAIT(src, TRAIT_ADVANCEDTOOLUSER, ROUNDSTART_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, ROUNDSTART_TRAIT)

/mob/living/silicon/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(aicamera)
	QDEL_NULL(builtInCamera)
	QDEL_NULL(aiPDA)
	QDEL_NULL(laws)
	GLOB.silicon_mobs -= src
	return ..()

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/contents_explosion(severity, target)
	return

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(in_cooldown)
		return

	addtimer(CALLBACK(src, .proc/show_alarms), 3 SECONDS)

/mob/living/silicon/proc/show_alarms()
	if(alarms_to_show.len < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(alarms_to_show.len)

		var/msg = "--- "

		if(alarm_types_show["Burglar"])
			msg += "BURGLAR: [alarm_types_show["Burglar"]] alarms detected. - "

		if(alarm_types_show["Motion"])
			msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

		if(alarm_types_show["Fire"])
			msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

		if(alarm_types_show["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

		if(alarm_types_show["Power"])
			msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

		if(alarm_types_show["Camera"])
			msg += "CAMERA: [alarm_types_show["Camera"]] alarms detected. - "

		msg += "<A href=?src=[REF(src)];showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, msg)

	if(alarms_to_clear.len < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(alarms_to_clear.len)
		var/msg = "--- "

		if(alarm_types_clear["Motion"])
			msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

		if(alarm_types_clear["Fire"])
			msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

		if(alarm_types_clear["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

		if(alarm_types_clear["Power"])
			msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

		if(alarm_types_show["Camera"])
			msg += "CAMERA: [alarm_types_clear["Camera"]] alarms cleared. - "

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
		to_chat(user, "<span class='alert'>[p_their(TRUE)] outer shell is too tough.</span>")

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return FALSE
	if(bot.connected_ai == ai)
		return TRUE
	return FALSE

/mob/living/silicon/Topic(href, href_list)
	if (href_list["lawc"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawc"])
		switch(lawcheck[L+1])
			if ("Yes")
				lawcheck[L+1] = "No"
			if ("No")
				lawcheck[L+1] = "Yes"
		checklaws()

	if (href_list["lawi"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawi"])
		switch(ioncheck[L])
			if ("Yes")
				ioncheck[L] = "No"
			if ("No")
				ioncheck[L] = "Yes"
		checklaws()

	if (href_list["lawh"])
		var/L = text2num(href_list["lawh"])
		switch(hackedcheck[L])
			if ("Yes")
				hackedcheck[L] = "No"
			if ("No")
				hackedcheck[L] = "Yes"
		checklaws()


	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	if (href_list["printlawtext"]) // this is kinda backwards
		if (href_list["dead"] && (!isdead(usr) && !usr.client.holder)) // do not print deadchat law notice if the user is now alive
			to_chat(usr, "<span class='warning'>You cannot view law changes that were made while you were dead.</span>")
			return
		to_chat(usr, href_list["printlawtext"])

	return

/mob/living/silicon/proc/statelaws(force = 0)
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

	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	say("[radiomod] Current Active Laws:")
	//laws_sanity_check()
	//laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (lawcache_zeroth)
		if (force || lawcache_lawcheck[1] == "Yes")
			say("[radiomod] 0. [lawcache_zeroth]")
			sleep(10)

	for (var/index in 1 to length(lawcache_hacked))
		var/law = lawcache_hacked[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (force || lawcache_hackedcheck[index] == "Yes")
				say("[radiomod] [num]. [law]")
				sleep(10)

	for (var/index in 1 to length(lawcache_ion))
		var/law = lawcache_ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (force || lawcache_ioncheck[index] == "Yes")
				say("[radiomod] [num]. [law]")
				sleep(10)

	for (var/index in 1 to length(lawcache_inherent))
		var/law = lawcache_inherent[index]

		if (length(law) > 0)
			if (force || lawcache_lawcheck[index+1] == "Yes")
				say("[radiomod] [number]. [law]")
				number++
				sleep(10)

	for (var/index in 1 to length(lawcache_supplied))
		var/law = lawcache_supplied[index]

		if (length(law) > 0)
			if(lawcache_lawcheck.len >= number+1)
				if (force || lawcache_lawcheck[number+1] == "Yes")
					say("[radiomod] [number]. [law]")
					number++
					sleep(10)


/mob/living/silicon/proc/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (laws.zeroth)
		if (!lawcheck[1])
			lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=[REF(src)];lawc=0'>[lawcheck[1]] 0:</A> <font color='#ff0000'><b>[laws.zeroth]</b></font><BR>"}

	for (var/index = 1, index <= laws.hacked.len, index++)
		var/law = laws.hacked[index]
		if (length(law) > 0)
			if (!hackedcheck[index])
				hackedcheck[index] = "No"
			list += {"<A href='byond://?src=[REF(src)];lawh=[index]'>[hackedcheck[index]] [ionnum()]:</A> <font color='#660000'>[law]</font><BR>"}
			hackedcheck.len += 1

	for (var/index = 1, index <= laws.ion.len, index++)
		var/law = laws.ion[index]

		if (length(law) > 0)
			if (!ioncheck[index])
				ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawi=[index]'>[ioncheck[index]] [ionnum()]:</A> <font color='#547DFE'>[law]</font><BR>"}
			ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= laws.inherent.len, index++)
		var/law = laws.inherent[index]

		if (length(law) > 0)
			lawcheck.len += 1

			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawc=[number]'>[lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= laws.supplied.len, index++)
		var/law = laws.supplied[index]
		if (length(law) > 0)
			lawcheck.len += 1
			if (!lawcheck[number+1])
				lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=[REF(src)];lawc=[number]'>[lawcheck[number+1]] [number]:</A> <font color='#990099'>[law]</font><BR>"}
			number++
	list += {"<br><br><A href='byond://?src=[REF(src)];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")

/mob/living/silicon/proc/ai_roster()
	if(!client)
		return
	if(world.time < client.crew_manifest_delay)
		return
	client.crew_manifest_delay = world.time + (1 SECONDS)

	var/datum/browser/popup = new(src, "airoster", "Crew Manifest", 387, 420)
	popup.set_content(GLOB.data_core.get_manifest_html())
	popup.open()

/mob/living/silicon/proc/set_autosay() //For allowing the AI and borgs to set the radio behavior of auto announcements (state laws, arrivals).
	if(!radio)
		to_chat(src, "<span class='alert'>Radio not detected.</span>")
		return

	//Ask the user to pick a channel from what it has available.
	var/Autochan = input("Select a channel:") as null|anything in list("Default","None") + radio.channels

	if(!Autochan)
		return
	if(Autochan == "Default") //Autospeak on whatever frequency to which the radio is set, usually Common.
		radiomod = ";"
		Autochan += " ([radio.frequency])"
	else if(Autochan == "None") //Prevents use of the radio for automatic annoucements.
		radiomod = ""
	else	//For department channels, if any, given by the internal radio.
		for(var/key in GLOB.department_radio_keys)
			if(GLOB.department_radio_keys[key] == Autochan)
				radiomod = ":" + key
				break

	to_chat(src, "<span class='notice'>Automatic announcements [Autochan == "None" ? "will not use the radio." : "set to [Autochan]."]</span>")

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return FALSE

// The src mob is trying to place an item on someone
// But the src mob is a silicon!!  Disable.
/mob/living/silicon/stripPanelEquip(obj/item/what, mob/who, slot)
	return FALSE


/mob/living/silicon/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/proc/remove_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)
	diagsensor.remove_hud_from(src)

/mob/living/silicon/proc/add_sensors()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.add_hud_to(src)
	medsensor.add_hud_to(src)
	diagsensor.add_hud_to(src)

/mob/living/silicon/proc/toggle_sensors()
	if(incapacitated())
		return
	sensors_on = !sensors_on
	if (!sensors_on)
		to_chat(src, "<span class='notice'>Sensor overlay deactivated.</span>")
		remove_sensors()
		return
	add_sensors()
	to_chat(src, "<span class='notice'>Sensor overlay activated.</span>")

/mob/living/silicon/proc/GetPhoto(mob/user)
	if (aicamera)
		return aicamera.selectpicture(user)

/mob/living/silicon/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2,easing = EASE_IN|EASE_OUT)
	return ..()

/mob/living/silicon/is_literate()
	return TRUE

/mob/living/silicon/get_inactive_held_item()
	return FALSE

/mob/living/silicon/handle_high_gravity(gravity)
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
