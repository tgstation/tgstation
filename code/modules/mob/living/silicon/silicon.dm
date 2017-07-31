/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
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

	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/last_lawchange_announce = 0
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/designation = ""
	var/radiomod = "" //Radio character used before state laws/arrivals announce to allow department transmissions, default, or none at all.
	var/obj/item/device/camera/siliconcam/aicamera = null //photography
	hud_possible = list(ANTAG_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_TRACK_HUD)

	var/obj/item/device/radio/borg/radio = null //AIs dont use this but this is at the silicon level to advoid copypasta in say()

	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

	var/lawcheck[1]
	var/ioncheck[1]
	var/devillawcheck[5]

	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC //There is only one kind of diag hud

	var/law_change_counter = 0
	var/obj/machinery/camera/builtInCamera = null
	var/updating = FALSE //portable camera camerachunk update

/mob/living/silicon/Initialize()
	..()
	GLOB.silicon_mobs += src
	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()

/mob/living/silicon/med_hud_set_health()
	return //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return //we use a different hud

/mob/living/silicon/Destroy()
	radio = null
	aicamera = null
	QDEL_NULL(builtInCamera)
	GLOB.silicon_mobs -= src
	return ..()

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

	if(!in_cooldown)
		spawn(3 * 10) // 3 seconds

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

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
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

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				to_chat(src, msg)


			alarms_to_show = list()
			alarms_to_clear = list()
			for(var/key in alarm_types_show)
				alarm_types_show[key] = 0
			for(var/key in alarm_types_clear)
				alarm_types_clear[key] = 0

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/can_inject(mob/user, error_msg)
	if(error_msg)
		to_chat(user, "<span class='alert'>Their outer shell is too tough.</span>")
	return 0

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0

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

	if (href_list["lawdevil"]) // Toggling whether or not a law gets stated by the State Laws verb --NeoFite
		var/L = text2num(href_list["lawdevil"])
		switch(devillawcheck[L])
			if ("Yes")
				devillawcheck[L] = "No"
			if ("No")
				devillawcheck[L] = "Yes"
		checklaws()


	if (href_list["laws"]) // With how my law selection code works, I changed statelaws from a verb to a proc, and call it through my law selection panel. --NeoFite
		statelaws()

	return


/mob/living/silicon/proc/statelaws(force = 0)

	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	src.say("[radiomod] Current Active Laws:")
	//src.laws_sanity_check()
	//src.laws.show_laws(world)
	var/number = 1
	sleep(10)

	if (src.laws.devillaws && src.laws.devillaws.len)
		for(var/index = 1, index <= src.laws.devillaws.len, index++)
			if (force || src.devillawcheck[index] == "Yes")
				src.say("[radiomod] 666. [src.laws.devillaws[index]]")
				sleep(10)


	if (src.laws.zeroth)
		if (force || src.lawcheck[1] == "Yes")
			src.say("[radiomod] 0. [src.laws.zeroth]")
			sleep(10)

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]
		var/num = ionnum()
		if (length(law) > 0)
			if (force || src.ioncheck[index] == "Yes")
				src.say("[radiomod] [num]. [law]")
				sleep(10)

	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			if (force || src.lawcheck[index+1] == "Yes")
				src.say("[radiomod] [number]. [law]")
				number++
				sleep(10)

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]

		if (length(law) > 0)
			if(src.lawcheck.len >= number+1)
				if (force || src.lawcheck[number+1] == "Yes")
					src.say("[radiomod] [number]. [law]")
					number++
					sleep(10)


/mob/living/silicon/proc/checklaws() //Gives you a link-driven interface for deciding what laws the statelaws() proc will share with the crew. --NeoFite

	var/list = "<b>Which laws do you want to include when stating them for the crew?</b><br><br>"

	if (src.laws.devillaws && src.laws.devillaws.len)
		for(var/index = 1, index <= src.laws.devillaws.len, index++)
			if (!src.devillawcheck[index])
				src.devillawcheck[index] = "No"
			list += {"<A href='byond://?src=\ref[src];lawdevil=[index]'>[src.devillawcheck[index]] 666:</A> [src.laws.devillaws[index]]<BR>"}

	if (src.laws.zeroth)
		if (!src.lawcheck[1])
			src.lawcheck[1] = "No" //Given Law 0's usual nature, it defaults to NOT getting reported. --NeoFite
		list += {"<A href='byond://?src=\ref[src];lawc=0'>[src.lawcheck[1]] 0:</A> [src.laws.zeroth]<BR>"}

	for (var/index = 1, index <= src.laws.ion.len, index++)
		var/law = src.laws.ion[index]

		if (length(law) > 0)
			if (!src.ioncheck[index])
				src.ioncheck[index] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawi=[index]'>[src.ioncheck[index]] [ionnum()]:</A> [law]<BR>"}
			src.ioncheck.len += 1

	var/number = 1
	for (var/index = 1, index <= src.laws.inherent.len, index++)
		var/law = src.laws.inherent[index]

		if (length(law) > 0)
			src.lawcheck.len += 1

			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++

	for (var/index = 1, index <= src.laws.supplied.len, index++)
		var/law = src.laws.supplied[index]
		if (length(law) > 0)
			src.lawcheck.len += 1
			if (!src.lawcheck[number+1])
				src.lawcheck[number+1] = "Yes"
			list += {"<A href='byond://?src=\ref[src];lawc=[number]'>[src.lawcheck[number+1]] [number]:</A> [law]<BR>"}
			number++
	list += {"<br><br><A href='byond://?src=\ref[src];laws=1'>State Laws</A>"}

	usr << browse(list, "window=laws")

/mob/living/silicon/proc/set_autosay() //For allowing the AI and borgs to set the radio behavior of auto announcements (state laws, arrivals).
	if(!radio)
		to_chat(src, "Radio not detected.")
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
				radiomod = key
				break

	to_chat(src, "<span class='notice'>Automatic announcements [Autochan == "None" ? "will not use the radio." : "set to [Autochan]."]</span>")

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return 0

// The src mob is trying to place an item on someone
// But the src mob is a silicon!!  Disable.
/mob/living/silicon/stripPanelEquip(obj/item/what, mob/who, slot)
	return 0


/mob/living/silicon/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/proc/remove_med_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)
	diagsensor.remove_hud_from(src)

/mob/living/silicon/proc/add_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	secsensor.add_hud_to(src)

/mob/living/silicon/proc/add_med_hud()
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	medsensor.add_hud_to(src)

/mob/living/silicon/proc/add_diag_hud()
	var/datum/atom_hud/diagsensor = GLOB.huds[d_hud]
	diagsensor.add_hud_to(src)

/mob/living/silicon/proc/sensor_mode()
	if(incapacitated())
		return
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Diagnostic","Disable")
	remove_med_sec_hud()
	switch(sensor_type)
		if ("Security")
			add_sec_hud()
			to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
		if ("Medical")
			add_med_hud()
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if ("Diagnostic")
			add_diag_hud()
			to_chat(src, "<span class='notice'>Robotics diagnostic overlay enabled.</span>")
		if ("Disable")
			to_chat(src, "Sensor augmentations disabled.")


/mob/living/silicon/proc/GetPhoto()
	if (aicamera)
		return aicamera.selectpicture(aicamera)

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
	return 1
